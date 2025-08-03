using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;

namespace Talma.CorporateServices.Configuration;

/// <summary>
/// Extension methods for configuring Talma Corporate Services Configuration
/// </summary>
public static class ServiceCollectionExtensions
{
    /// <summary>
    /// Adds Talma configuration services to the DI container
    /// </summary>
    /// <param name="services">Service collection</param>
    /// <param name="configuration">Application configuration</param>
    /// <returns>Service collection for chaining</returns>
    public static IServiceCollection AddTalmaConfiguration(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        return services.AddTalmaConfiguration(configuration, _ => { });
    }

    /// <summary>
    /// Adds Talma configuration services to the DI container with options
    /// </summary>
    /// <param name="services">Service collection</param>
    /// <param name="configuration">Application configuration</param>
    /// <param name="configureOptions">Options configuration action</param>
    /// <returns>Service collection for chaining</returns>
    public static IServiceCollection AddTalmaConfiguration(
        this IServiceCollection services,
        IConfiguration configuration,
        Action<TalmaConfigurationOptions> configureOptions)
    {
        // Configure options
        var options = new TalmaConfigurationOptions();
        configureOptions(options);
        services.AddSingleton(options);

        // Register core services
        services.AddMemoryCache();
        services.AddHttpClient();

        // Register configuration provider factory
        services.AddSingleton<IConfigurationProviderFactory, ConfigurationProviderFactory>();

        // Register main configuration provider
        services.AddSingleton<IConfigurationProvider>(serviceProvider =>
        {
            var factory = serviceProvider.GetRequiredService<IConfigurationProviderFactory>();
            var logger = serviceProvider.GetRequiredService<ILogger<IConfigurationProvider>>();
            var cache = serviceProvider.GetRequiredService<IMemoryCache>();

            var providerType = configuration["TalmaConfiguration:Provider"] ?? "database";
            var baseProvider = factory.Create(providerType, configuration, logger);

            // Wrap with cache
            var cachedProvider = new CachedConfigurationProvider(baseProvider, cache, logger);

            // Wrap with instrumentation
            var instrumentedProvider = new InstrumentedConfigurationProvider(cachedProvider, logger);

            // Configure fallback if specified
            var fallbackType = configuration["TalmaConfiguration:FallbackProvider"];
            if (!string.IsNullOrEmpty(fallbackType))
            {
                var fallbackProvider = factory.Create(fallbackType, configuration, logger);
                return new FallbackConfigurationProvider(instrumentedProvider, fallbackProvider, logger);
            }

            return instrumentedProvider;
        });

        // Register health checks
        services.AddHealthChecks()
            .AddCheck<ConfigurationProviderHealthCheck>("talma-configuration");

        // Register audit service
        services.AddScoped<IConfigurationAuditService, ConfigurationAuditService>();

        return services;
    }

    /// <summary>
    /// Adds country-specific configuration providers
    /// </summary>
    /// <param name="services">Service collection</param>
    /// <param name="configuration">Application configuration</param>
    /// <param name="countryConfiguration">Country configuration action</param>
    /// <returns>Service collection for chaining</returns>
    public static IServiceCollection AddTalmaConfigurationWithCountries(
        this IServiceCollection services,
        IConfiguration configuration,
        Action<CountryConfigurationBuilder> countryConfiguration)
    {
        var builder = new CountryConfigurationBuilder();
        countryConfiguration(builder);

        services.AddSingleton<ICountryConfigurationProvider>(serviceProvider =>
        {
            var factory = serviceProvider.GetRequiredService<IConfigurationProviderFactory>();
            var logger = serviceProvider.GetRequiredService<ILogger<ICountryConfigurationProvider>>();

            return new CountryConfigurationProvider(builder.Build(), factory, configuration, logger);
        });

        // Replace main provider with country-aware provider
        services.AddSingleton<IConfigurationProvider>(serviceProvider =>
        {
            return serviceProvider.GetRequiredService<ICountryConfigurationProvider>();
        });

        return services.AddTalmaConfiguration(configuration);
    }
}

/// <summary>
/// Configuration options for Talma configuration services
/// </summary>
public class TalmaConfigurationOptions
{
    /// <summary>
    /// Default cache TTL for configuration values
    /// </summary>
    public TimeSpan DefaultCacheTtl { get; set; } = TimeSpan.FromMinutes(30);

    /// <summary>
    /// Cache TTL for secrets (shorter for security)
    /// </summary>
    public TimeSpan SecretsCacheTtl { get; set; } = TimeSpan.FromMinutes(5);

    /// <summary>
    /// Cache TTL for feature flags
    /// </summary>
    public TimeSpan FeatureFlagsCacheTtl { get; set; } = TimeSpan.FromMinutes(10);

    /// <summary>
    /// Enable audit logging for configuration access
    /// </summary>
    public bool EnableAuditLogging { get; set; } = true;

    /// <summary>
    /// Enable distributed tracing
    /// </summary>
    public bool EnableTracing { get; set; } = true;

    /// <summary>
    /// Maximum retry attempts for failed provider calls
    /// </summary>
    public int MaxRetryAttempts { get; set; } = 3;

    /// <summary>
    /// Circuit breaker failure threshold
    /// </summary>
    public int CircuitBreakerThreshold { get; set; } = 5;
}

/// <summary>
/// Builder for country-specific configuration
/// </summary>
public class CountryConfigurationBuilder
{
    private readonly Dictionary<string, string> _countryProviders = new();

    /// <summary>
    /// Configure provider for specific country
    /// </summary>
    /// <param name="countryCode">Country code (PE, CO, MX, EC)</param>
    /// <returns>Country configuration fluent interface</returns>
    public CountryProviderBuilder ForCountry(string countryCode)
    {
        return new CountryProviderBuilder(countryCode, this);
    }

    internal void AddCountryProvider(string countryCode, string provider)
    {
        _countryProviders[countryCode] = provider;
    }

    internal Dictionary<string, string> Build() => _countryProviders;
}

/// <summary>
/// Fluent builder for country provider configuration
/// </summary>
public class CountryProviderBuilder
{
    private readonly string _countryCode;
    private readonly CountryConfigurationBuilder _parent;

    internal CountryProviderBuilder(string countryCode, CountryConfigurationBuilder parent)
    {
        _countryCode = countryCode;
        _parent = parent;
    }

    /// <summary>
    /// Use specific provider for this country
    /// </summary>
    /// <param name="provider">Provider name (aws, azure, gcp, consul, database)</param>
    /// <returns>Parent builder for chaining</returns>
    public CountryConfigurationBuilder UseProvider(string provider)
    {
        _parent.AddCountryProvider(_countryCode, provider);
        return _parent;
    }
}

/// <summary>
/// Example usage and setup
/// </summary>
public static class ExampleUsage
{
    public static void ConfigureServices(IServiceCollection services, IConfiguration configuration)
    {
        // Basic setup
        services.AddTalmaConfiguration(configuration);

        // With options
        services.AddTalmaConfiguration(configuration, options =>
        {
            options.DefaultCacheTtl = TimeSpan.FromMinutes(15);
            options.EnableAuditLogging = true;
            options.MaxRetryAttempts = 5;
        });

        // With country-specific providers
        services.AddTalmaConfigurationWithCountries(configuration, countries =>
        {
            countries.ForCountry("PE").UseProvider("azure");   // Perú → Azure
            countries.ForCountry("CO").UseProvider("gcp");     // Colombia → GCP
            countries.ForCountry("MX").UseProvider("aws");     // México → AWS
            countries.ForCountry("EC").UseProvider("aws");     // Ecuador → AWS
        });
    }

    public static void ExampleServiceUsage()
    {
        // In any service constructor
        // public MyService(IConfigurationProvider configProvider) { ... }

        // Usage examples:
        // var emailConfig = await _configProvider.GetConfigurationAsync<EmailConfig>("email-settings", "tenant-pe-001");
        // var secret = await _configProvider.GetSecretAsync("database-password", "tenant-co-002");
        // var featureFlag = await _configProvider.GetConfigurationAsync<bool>("feature-new-ui", "tenant-mx-003");
    }
}
