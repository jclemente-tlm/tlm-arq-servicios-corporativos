// ========================================
// CONFIGURACIÓN AGNÓSTICA - PATRÓN FACTORY
// ========================================

using Amazon.SecretsManager;
using Amazon.SystemsManagement;
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using Google.Cloud.SecretManager.V1;
using Microsoft.Extensions.Caching.Memory;

namespace Talma.CorporateServices.Configuration;

// ========================================
// INTERFAZ AGNÓSTICA - SIN DEPENDENCIAS ESPECÍFICAS
// ========================================
public interface IConfigurationProvider
{
    Task<T> GetConfigurationAsync<T>(string key, string tenant = null);
    Task<string> GetSecretAsync(string secretName, string tenant = null);
    Task InvalidateCacheAsync(string pattern = null);
    Task<bool> IsHealthyAsync();
}

// ========================================
// FACTORY PATTERN - INCLUYE TODOS LOS PROVEEDORES
// ========================================
public class ConfigurationProviderFactory
{
    public static IConfigurationProvider Create(
        string providerType,
        IConfiguration config,
        IMemoryCache cache,
        ILogger<IConfigurationProvider> logger)
    {
        var baseProvider = providerType.ToLower() switch
        {
            "aws" => new AwsConfigurationProvider(
                config.GetSection("ConfigurationProvider:AWS"), logger),
            "azure" => new AzureConfigurationProvider(
                config.GetSection("ConfigurationProvider:Azure"), logger),
            "gcp" => new GcpConfigurationProvider(
                config.GetSection("ConfigurationProvider:GCP"), logger),
            "consul" => new ConsulConfigurationProvider(
                config.GetSection("ConfigurationProvider:Consul"), logger),
            "database" => new DatabaseConfigurationProvider(
                config.GetSection("ConfigurationProvider:Database"), logger),
            "http" => new HttpConfigurationProvider(
                config.GetSection("ConfigurationProvider:Http"), logger),
            _ => throw new ArgumentException($"Unknown provider: {providerType}")
        };

        // Siempre wrap con cache y observabilidad
        var cachedProvider = new CachedConfigurationProvider(baseProvider, cache, logger);
        var instrumentedProvider = new InstrumentedConfigurationProvider(cachedProvider, logger);

        return instrumentedProvider;
    }
}

// ========================================
// IMPLEMENTACIÓN AWS - USANDO SDK
// ========================================
public class AwsConfigurationProvider : IConfigurationProvider
{
    private readonly IAmazonSystemsManagement _ssmClient;
    private readonly IAmazonSecretsManager _secretsClient;
    private readonly ILogger _logger;
    private readonly string _parameterPrefix;

    public AwsConfigurationProvider(IConfigurationSection config, ILogger logger)
    {
        _logger = logger;
        _parameterPrefix = config["ParameterStorePrefix"] ?? "/talma/prod";

        var awsOptions = new AmazonSystemsManagementConfig
        {
            RegionEndpoint = Amazon.RegionEndpoint.GetBySystemName(
                config["Region"] ?? "us-east-1")
        };

        _ssmClient = new AmazonSystemsManagementClient(awsOptions);
        _secretsClient = new AmazonSecretsManagerClient(awsOptions);
    }

    public async Task<T> GetConfigurationAsync<T>(string key, string tenant = null)
    {
        var parameterName = BuildParameterName(key, tenant);

        try
        {
            var request = new GetParameterRequest
            {
                Name = parameterName,
                WithDecryption = true
            };

            var response = await _ssmClient.GetParameterAsync(request);
            return JsonSerializer.Deserialize<T>(response.Parameter.Value)!;
        }
        catch (ParameterNotFoundException)
        {
            _logger.LogWarning("Parameter {ParameterName} not found", parameterName);
            throw new ConfigurationNotFoundException(parameterName);
        }
    }

    public async Task<string> GetSecretAsync(string secretName, string tenant = null)
    {
        var fullSecretName = BuildSecretName(secretName, tenant);

        try
        {
            var request = new GetSecretValueRequest
            {
                SecretId = fullSecretName
            };

            var response = await _secretsClient.GetSecretValueAsync(request);
            return response.SecretString;
        }
        catch (ResourceNotFoundException)
        {
            _logger.LogWarning("Secret {SecretName} not found", fullSecretName);
            throw new ConfigurationNotFoundException(fullSecretName);
        }
    }

    private string BuildParameterName(string key, string? tenant) =>
        tenant != null ? $"{_parameterPrefix}/{tenant}/{key}" : $"{_parameterPrefix}/global/{key}";

    private string BuildSecretName(string key, string? tenant) =>
        tenant != null ? $"talma/{tenant}/{key}" : $"talma/global/{key}";
}

// ========================================
// IMPLEMENTACIÓN AZURE - USANDO SDK
// ========================================
public class AzureConfigurationProvider : IConfigurationProvider
{
    private readonly SecretClient _secretClient;
    private readonly ILogger _logger;
    private readonly string _keyVaultUrl;

    public AzureConfigurationProvider(IConfigurationSection config, ILogger logger)
    {
        _logger = logger;
        _keyVaultUrl = config["KeyVaultUrl"] ?? throw new ArgumentException("KeyVaultUrl is required");

        var credential = new DefaultAzureCredential();
        _secretClient = new SecretClient(new Uri(_keyVaultUrl), credential);
    }

    public async Task<T> GetConfigurationAsync<T>(string key, string tenant = null)
    {
        var secretName = BuildSecretName(key, tenant);

        try
        {
            var response = await _secretClient.GetSecretAsync(secretName);
            return JsonSerializer.Deserialize<T>(response.Value.Value)!;
        }
        catch (RequestFailedException ex) when (ex.Status == 404)
        {
            _logger.LogWarning("Secret {SecretName} not found in Key Vault", secretName);
            throw new ConfigurationNotFoundException(secretName);
        }
    }

    public async Task<string> GetSecretAsync(string secretName, string tenant = null)
    {
        var fullSecretName = BuildSecretName(secretName, tenant);

        try
        {
            var response = await _secretClient.GetSecretAsync(fullSecretName);
            return response.Value.Value;
        }
        catch (RequestFailedException ex) when (ex.Status == 404)
        {
            _logger.LogWarning("Secret {SecretName} not found in Key Vault", fullSecretName);
            throw new ConfigurationNotFoundException(fullSecretName);
        }
    }

    private string BuildSecretName(string key, string? tenant) =>
        tenant != null ? $"talma-{tenant}-{key}" : $"talma-global-{key}";
}

// ========================================
// IMPLEMENTACIÓN GCP - USANDO SDK
// ========================================
public class GcpConfigurationProvider : IConfigurationProvider
{
    private readonly SecretManagerServiceClient _client;
    private readonly ILogger _logger;
    private readonly string _projectId;

    public GcpConfigurationProvider(IConfigurationSection config, ILogger logger)
    {
        _logger = logger;
        _projectId = config["ProjectId"] ?? throw new ArgumentException("ProjectId is required");
        _client = SecretManagerServiceClient.Create();
    }

    public async Task<T> GetConfigurationAsync<T>(string key, string tenant = null)
    {
        var secretName = BuildSecretName(key, tenant);

        try
        {
            var request = new AccessSecretVersionRequest
            {
                Name = new SecretVersionName(_projectId, secretName, "latest").ToString()
            };

            var response = await _client.AccessSecretVersionAsync(request);
            var secretValue = response.Payload.Data.ToStringUtf8();

            return JsonSerializer.Deserialize<T>(secretValue)!;
        }
        catch (RpcException ex) when (ex.StatusCode == StatusCode.NotFound)
        {
            _logger.LogWarning("Secret {SecretName} not found in GCP Secret Manager", secretName);
            throw new ConfigurationNotFoundException(secretName);
        }
    }

    private string BuildSecretName(string key, string? tenant) =>
        tenant != null ? $"talma-{tenant}-{key}" : $"talma-global-{key}";
}

// ========================================
// IMPLEMENTACIÓN HTTP - AGNÓSTICA COMPLETA
// ========================================
public class HttpConfigurationProvider : IConfigurationProvider
{
    private readonly HttpClient _httpClient;
    private readonly ILogger _logger;
    private readonly ConfigurationProviderOptions _options;

    public HttpConfigurationProvider(IConfigurationSection config, ILogger logger)
    {
        _logger = logger;
        _options = config.Get<ConfigurationProviderOptions>()!;

        _httpClient = new HttpClient
        {
            BaseAddress = new Uri(_options.BaseUrl),
            Timeout = TimeSpan.FromSeconds(_options.TimeoutSeconds)
        };

        // Configurar headers de autenticación según el proveedor
        ConfigureAuthentication();
    }

    public async Task<T> GetConfigurationAsync<T>(string key, string tenant = null)
    {
        var endpoint = BuildEndpoint(key, tenant);

        try
        {
            var response = await _httpClient.GetAsync(endpoint);
            response.EnsureSuccessStatusCode();

            var content = await response.Content.ReadAsStringAsync();
            return JsonSerializer.Deserialize<T>(content)!;
        }
        catch (HttpRequestException ex)
        {
            _logger.LogError(ex, "Failed to get configuration {Key} from {Endpoint}", key, endpoint);
            throw new ConfigurationNotFoundException(key);
        }
    }

    private string BuildEndpoint(string key, string? tenant)
    {
        var basePath = tenant != null ? $"/{tenant}/{key}" : $"/global/{key}";

        return _options.Provider.ToLower() switch
        {
            "aws" => $"/systems-manager/parameters{basePath}",
            "azure" => $"/secrets{basePath}?api-version=7.4",
            "gcp" => $"/v1/projects/{_options.ProjectId}/secrets{basePath}:access",
            "consul" => $"/v1/kv/talma{basePath}",
            _ => basePath
        };
    }

    private void ConfigureAuthentication()
    {
        // Configurar headers según el proveedor
        if (!string.IsNullOrEmpty(_options.ApiKey))
        {
            _httpClient.DefaultRequestHeaders.Add("X-API-Key", _options.ApiKey);
        }

        if (!string.IsNullOrEmpty(_options.BearerToken))
        {
            _httpClient.DefaultRequestHeaders.Authorization =
                new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", _options.BearerToken);
        }
    }
}

// ========================================
// CACHE WRAPPER - PATRÓN CACHE-FIRST
// ========================================
public class CachedConfigurationProvider : IConfigurationProvider
{
    private readonly IConfigurationProvider _inner;
    private readonly IMemoryCache _cache;
    private readonly ILogger _logger;
    private readonly TimeSpan _defaultTtl = TimeSpan.FromMinutes(30);

    public CachedConfigurationProvider(
        IConfigurationProvider inner,
        IMemoryCache cache,
        ILogger logger)
    {
        _inner = inner;
        _cache = cache;
        _logger = logger;
    }

    public async Task<T> GetConfigurationAsync<T>(string key, string tenant = null)
    {
        var cacheKey = BuildCacheKey(key, tenant);

        if (_cache.TryGetValue(cacheKey, out T cachedValue))
        {
            _logger.LogDebug("Configuration cache hit for {Key}", cacheKey);
            return cachedValue;
        }

        _logger.LogDebug("Configuration cache miss for {Key}, fetching from provider", cacheKey);

        var value = await _inner.GetConfigurationAsync<T>(key, tenant);

        // Cache con TTL + jitter para evitar thundering herd
        var ttl = _defaultTtl.Add(TimeSpan.FromMinutes(Random.Shared.Next(-5, 5)));
        _cache.Set(cacheKey, value, ttl);

        return value;
    }

    public async Task InvalidateCacheAsync(string pattern = null)
    {
        if (pattern == null)
        {
            // Clear all cache
            if (_cache is MemoryCache mc)
            {
                mc.Clear();
            }
        }
        else
        {
            // Pattern-based invalidation (implementation depends on cache provider)
            _logger.LogInformation("Cache pattern invalidation requested: {Pattern}", pattern);
        }

        await _inner.InvalidateCacheAsync(pattern);
    }

    private string BuildCacheKey(string key, string? tenant) =>
        tenant != null ? $"config:{tenant}:{key}" : $"config:global:{key}";
}

// ========================================
// INSTRUMENTACIÓN Y OBSERVABILIDAD
// ========================================
public class InstrumentedConfigurationProvider : IConfigurationProvider
{
    private readonly IConfigurationProvider _inner;
    private readonly ILogger _logger;

    public InstrumentedConfigurationProvider(IConfigurationProvider inner, ILogger logger)
    {
        _inner = inner;
        _logger = logger;
    }

    public async Task<T> GetConfigurationAsync<T>(string key, string tenant = null)
    {
        using var activity = Activity.StartActivity("GetConfiguration");
        activity?.SetTag("config.key", key);
        activity?.SetTag("config.tenant", tenant);

        var stopwatch = Stopwatch.StartNew();
        try
        {
            var result = await _inner.GetConfigurationAsync<T>(key, tenant);

            _logger.LogDebug("Configuration retrieved successfully: {Key} in {Duration}ms",
                key, stopwatch.ElapsedMilliseconds);

            return result;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to get configuration: {Key}", key);
            throw;
        }
        finally
        {
            stopwatch.Stop();
        }
    }

    // Implementar otros métodos...
}

// ========================================
// CONFIGURACIÓN Y MODELOS
// ========================================
public class ConfigurationProviderOptions
{
    public string Provider { get; set; } = "aws";
    public string BaseUrl { get; set; } = "";
    public string ProjectId { get; set; } = "";
    public string ApiKey { get; set; } = "";
    public string BearerToken { get; set; } = "";
    public int TimeoutSeconds { get; set; } = 30;
}

public class ConfigurationNotFoundException : Exception
{
    public ConfigurationNotFoundException(string key) : base($"Configuration not found: {key}")
    {
    }
}

// ========================================
// REGISTRO EN STARTUP
// ========================================
public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddConfigurationProvider(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        var providerType = configuration["ConfigurationProvider:Type"] ?? "aws";

        services.AddSingleton<IConfigurationProvider>(provider =>
        {
            var config = provider.GetRequiredService<IConfiguration>();
            var cache = provider.GetRequiredService<IMemoryCache>();
            var logger = provider.GetRequiredService<ILogger<IConfigurationProvider>>();

            return ConfigurationProviderFactory.Create(providerType, config, cache, logger);
        });

        // Health checks para todos los proveedores
        services.AddHealthChecks()
            .AddCheck<ConfigurationProviderHealthCheck>("configuration-provider");

        return services;
    }
}
