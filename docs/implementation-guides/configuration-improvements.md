# 🚀 Guía de Implementación: Mejoras de Configuración

## 📋 Overview

Esta guía describe cómo implementar las mejoras de configuración para sistemas multi-tenant y multi-país siguiendo las mejores prácticas de la industria.

---

## 🎯 Mejora 1: Configuration Caching Strategy

### Implementación en C #

```csharp
// Servicio de Configuration Manager mejorado
public class ConfigurationManager : IConfigurationManager
{
    private readonly IMemoryCache _cache;
    private readonly IParameterStoreService _parameterStore;
    private readonly ITenantConfigRepository _tenantRepo;
    private readonly ILogger<ConfigurationManager> _logger;
    private readonly IMetricsCollector _metrics;

    // TTL por tipo de configuración
    private readonly Dictionary<string, TimeSpan> _cacheTtl = new()
    {
        ["secrets"] = TimeSpan.FromMinutes(1),      // Secretos: cache corto
        ["feature-flags"] = TimeSpan.FromMinutes(5), // Feature flags: cache medio
        ["tenant-config"] = TimeSpan.FromMinutes(15), // Config tenant: cache largo
        ["system-config"] = TimeSpan.FromHours(1)    // Config sistema: cache muy largo
    };

    public async Task<T> GetConfigurationAsync<T>(string key, string tenantId, string country)
    {
        var cacheKey = $"config:{tenantId}:{country}:{key}";

        // 1. Intentar obtener del cache
        if (_cache.TryGetValue(cacheKey, out T cachedValue))
        {
            _metrics.IncrementCounter("config_cache_hits");
            return cachedValue;
        }

        _metrics.IncrementCounter("config_cache_misses");

        // 2. Obtener de fuente (Parameter Store + DB)
        var value = await GetFromSourceAsync<T>(key, tenantId, country);

        // 3. Almacenar en cache con TTL apropiado
        var ttl = GetTtlForKey(key);
        _cache.Set(cacheKey, value, ttl);

        return value;
    }

    private async Task<T> GetFromSourceAsync<T>(string key, string tenantId, string country)
    {
        // Jerarca de configuración: Tenant > País > Global
        try
        {
            // 1. Buscar configuración específica del tenant
            var tenantConfig = await _tenantRepo.GetConfigAsync<T>(tenantId, key);
            if (tenantConfig != null) return tenantConfig;

            // 2. Buscar configuración del país
            var countryConfig = await _parameterStore.GetAsync<T>($"/corporativo/{country}/{key}");
            if (countryConfig != null) return countryConfig;

            // 3. Buscar configuración global
            return await _parameterStore.GetAsync<T>($"/corporativo/global/{key}");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error obteniendo configuración {Key} para tenant {TenantId}", key, tenantId);
            throw;
        }
    }
}
```

### Configuración de Dependency Injection

```csharp
// En Program.cs o Startup.cs
services.AddMemoryCache(options =>
{
    options.SizeLimit = 1024; // Límite de entradas en cache
});

services.AddStackExchangeRedisCache(options =>
{
    options.Configuration = "your-redis-connection-string";
    options.InstanceName = "SitaMessaging";
});

services.AddScoped<IConfigurationManager, ConfigurationManager>();
```

---

## 🎯 Mejora 2: Feature Flags por País/Tenant

### Estructura en Parameter Store

```bash
# Feature flags por país
/corporativo/feature-flags/peru/sita-messaging = "enabled"
/corporativo/feature-flags/peru/email-notifications = "enabled"
/corporativo/feature-flags/ecuador/sita-messaging = "disabled"
/corporativo/feature-flags/colombia/whatsapp-processor = "enabled"
/corporativo/feature-flags/mexico/push-notifications = "beta"

# Feature flags por tenant (sobrescribe país)
/corporativo/feature-flags/tenant/airline-123/sita-messaging = "enabled"
/corporativo/feature-flags/tenant/cargo-456/email-batch-size = "1000"
```

### Implementación del Feature Flag Service

```csharp
public class FeatureFlagService : IFeatureFlagService
{
    private readonly IConfigurationManager _configManager;
    private readonly ILogger<FeatureFlagService> _logger;

    public async Task<bool> IsEnabledAsync(string feature, string tenantId, string country)
    {
        try
        {
            // Jerarca: Tenant > País > Global
            var key = $"feature-flags/{feature}";
            var value = await _configManager.GetConfigurationAsync<string>(key, tenantId, country);

            return value?.ToLowerInvariant() switch
            {
                "enabled" => true,
                "disabled" => false,
                "beta" => await IsTenantInBetaAsync(tenantId, feature),
                _ => false // Default disabled
            };
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Error checking feature flag {Feature}, defaulting to disabled", feature);
            return false; // Fail safe
        }
    }

    public async Task<T> GetFeatureConfigAsync<T>(string feature, string tenantId, string country, T defaultValue = default)
    {
        var key = $"feature-flags/{feature}/config";
        try
        {
            return await _configManager.GetConfigurationAsync<T>(key, tenantId, country) ?? defaultValue;
        }
        catch
        {
            return defaultValue;
        }
    }
}
```

### Uso en el SITA Generation Service

```csharp
public class SitaGenerationService : ISitaGenerationService
{
    private readonly IFeatureFlagService _featureFlags;

    public async Task<bool> ProcessEventAsync(TrackTraceEvent eventData)
    {
        // Verificar si SITA está habilitado para este tenant/país
        var sitaEnabled = await _featureFlags.IsEnabledAsync(
            "sita-messaging",
            eventData.TenantId,
            eventData.Country
        );

        if (!sitaEnabled)
        {
            _logger.LogInformation("SITA messaging disabled for tenant {TenantId} in {Country}",
                eventData.TenantId, eventData.Country);
            return false;
        }

        // Obtener configuración específica del feature
        var batchSize = await _featureFlags.GetFeatureConfigAsync<int>(
            "sita-batch-size",
            eventData.TenantId,
            eventData.Country,
            defaultValue: 100
        );

        // Procesar con configuración dinámica...
        return await ProcessWithBatchSizeAsync(eventData, batchSize);
    }
}
```

---

## 🎯 Mejora 3: Configuration Event Updates

### Configuración de SNS/SQS para eventos de config

```csharp
public class ConfigurationEventProcessor : BackgroundService
{
    private readonly IAmazonSQS _sqsClient;
    private readonly IMemoryCache _cache;
    private readonly ILogger<ConfigurationEventProcessor> _logger;

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                var messages = await _sqsClient.ReceiveMessageAsync(new ReceiveMessageRequest
                {
                    QueueUrl = "config-events-queue-url",
                    MaxNumberOfMessages = 10,
                    WaitTimeSeconds = 20 // Long polling
                });

                foreach (var message in messages.Messages)
                {
                    await ProcessConfigurationChangeAsync(message);
                    await _sqsClient.DeleteMessageAsync("queue-url", message.ReceiptHandle);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing configuration events");
                await Task.Delay(TimeSpan.FromSeconds(30), stoppingToken);
            }
        }
    }

    private async Task ProcessConfigurationChangeAsync(Message message)
    {
        var configEvent = JsonSerializer.Deserialize<ConfigurationChangeEvent>(message.Body);

        switch (configEvent.Type)
        {
            case "ParameterStoreUpdate":
                await InvalidateCacheForParameterAsync(configEvent.Key);
                break;
            case "FeatureFlagUpdate":
                await InvalidateFeatureFlagCacheAsync(configEvent.Key);
                break;
            case "TenantConfigUpdate":
                await InvalidateTenantCacheAsync(configEvent.TenantId);
                break;
        }

        _logger.LogInformation("Processed configuration change: {Type} - {Key}",
            configEvent.Type, configEvent.Key);
    }
}

public record ConfigurationChangeEvent(
    string Type,
    string Key,
    string TenantId,
    string Country,
    DateTime Timestamp
);
```

---

## 🎯 Mejora 4: Configuration Metrics

### Métricas con Prometheus

```csharp
public class ConfigurationMetrics
{
    private readonly Counter _cacheHits = Metrics
        .CreateCounter("config_cache_hits_total", "Total configuration cache hits");

    private readonly Counter _cacheMisses = Metrics
        .CreateCounter("config_cache_misses_total", "Total configuration cache misses");

    private readonly Histogram _configLoadTime = Metrics
        .CreateHistogram("config_load_duration_seconds", "Configuration load time");

    private readonly Gauge _cacheSize = Metrics
        .CreateGauge("config_cache_size", "Current configuration cache size");

    private readonly Counter _featureFlagUsage = Metrics
        .CreateCounter("feature_flag_usage_total", "Feature flag usage", new[] { "flag", "tenant", "country", "enabled" });

    public void RecordCacheHit() => _cacheHits.Inc();
    public void RecordCacheMiss() => _cacheMisses.Inc();
    public void RecordConfigLoadTime(double seconds) => _configLoadTime.Observe(seconds);
    public void UpdateCacheSize(int size) => _cacheSize.Set(size);

    public void RecordFeatureFlagUsage(string flag, string tenant, string country, bool enabled)
    {
        _featureFlagUsage.WithLabels(flag, tenant, country, enabled.ToString()).Inc();
    }
}
```

---

## 🎯 Mejora 5: Configuration Validation

### Validador de configuraciones

```csharp
public class ConfigurationValidator : IConfigurationValidator
{
    private readonly ILogger<ConfigurationValidator> _logger;

    public async Task<ValidationResult> ValidateAsync<T>(string key, T value, ConfigurationContext context)
    {
        var result = new ValidationResult();

        try
        {
            // Validaciones específicas por tipo de configuración
            result = key switch
            {
                var k when k.StartsWith("feature-flags/") => ValidateFeatureFlag(value, context),
                var k when k.Contains("email/") => await ValidateEmailConfigAsync(value, context),
                var k when k.Contains("sita/") => ValidateSitaConfig(value, context),
                _ => ValidationResult.Success()
            };

            if (result.IsValid)
            {
                _logger.LogInformation("Configuration validation passed for {Key}", key);
            }
            else
            {
                _logger.LogWarning("Configuration validation failed for {Key}: {Errors}",
                    key, string.Join(", ", result.Errors));
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error validating configuration {Key}", key);
            result = ValidationResult.Failure($"Validation error: {ex.Message}");
        }

        return result;
    }

    private ValidationResult ValidateFeatureFlag<T>(T value, ConfigurationContext context)
    {
        var stringValue = value?.ToString()?.ToLowerInvariant();
        var validValues = new[] { "enabled", "disabled", "beta" };

        if (!validValues.Contains(stringValue))
        {
            return ValidationResult.Failure($"Feature flag must be one of: {string.Join(", ", validValues)}");
        }

        return ValidationResult.Success();
    }
}

public record ValidationResult(bool IsValid, IEnumerable<string> Errors)
{
    public static ValidationResult Success() => new(true, Array.Empty<string>());
    public static ValidationResult Failure(string error) => new(false, new[] { error });
    public static ValidationResult Failure(IEnumerable<string> errors) => new(false, errors);
}
```

---

## 🛠️ Configuración del Pipeline CI/CD

### GitHub Actions para validación de configuraciones

```yaml
# .github/workflows/config-validation.yml
name: Configuration Validation

on:
  pull_request:
    paths:
      - 'infrastructure/terraform/**'
      - 'scripts/configuration/**'

jobs:
  validate-configuration:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Validate Parameter Store configs
        run: |
          # Validar estructura de parámetros
          python scripts/validate-parameter-structure.py

      - name: Test multi-tenant isolation
        run: |
          # Verificar que las configuraciones no se crucen entre tenants
          python scripts/test-tenant-isolation.py

      - name: Validate feature flag schemas
        run: |
          # Validar que los feature flags tienen el formato correcto
          python scripts/validate-feature-flags.py
```

---

## 📊 Dashboards y Alertas

### Grafana Dashboard para Configuration Metrics

```json
{
  "dashboard": {
    "title": "Configuration Management",
    "panels": [
      {
        "title": "Cache Hit Ratio",
        "targets": [
          {
            "expr": "rate(config_cache_hits_total[5m]) / (rate(config_cache_hits_total[5m]) + rate(config_cache_misses_total[5m])) * 100"
          }
        ]
      },
      {
        "title": "Feature Flag Usage by Country",
        "targets": [
          {
            "expr": "sum by (country, flag) (rate(feature_flag_usage_total[5m]))"
          }
        ]
      },
      {
        "title": "Configuration Load Time",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(config_load_duration_seconds_bucket[5m]))"
          }
        ]
      }
    ]
  }
}
```

### Alertas en Prometheus

```yaml
# alerts/configuration.yml
groups:
  - name: configuration
    rules:
      - alert: ConfigCacheHitRatioLow
        expr: rate(config_cache_hits_total[5m]) / (rate(config_cache_hits_total[5m]) + rate(config_cache_misses_total[5m])) < 0.8
        for: 5m
        annotations:
          summary: "Configuration cache hit ratio is below 80%"

      - alert: ConfigLoadTimeHigh
        expr: histogram_quantile(0.95, rate(config_load_duration_seconds_bucket[5m])) > 2
        for: 3m
        annotations:
          summary: "95th percentile of configuration load time is above 2 seconds"
```

---

## 🚀 Plan de Implementación

### Fase 1: Cache y Feature Flags (Semana 1-2)

1. ✅ Implementar Configuration Manager con cache
2. ✅ Añadir Feature Flag Service
3. ✅ Configurar métricas básicas
4. ✅ Testing unitario y de integración

### Fase 2: Eventos y Validación (Semana 3-4)

1. ✅ Implementar Configuration Event Processor
2. ✅ Añadir Configuration Validator
3. ✅ Configurar SQS para eventos de config
4. ✅ Pipeline de validación en CI/CD

### Fase 3: Observabilidad y Optimización (Semana 5-6)

1. ✅ Dashboards en Grafana
2. ✅ Alertas en Prometheus
3. ✅ Disaster recovery testing
4. ✅ Performance optimization

---

## 💡 Beneficios Esperados

### Rendimiento

- **80% reducción** en llamadas a AWS Parameter Store
- **60% mejora** en tiempo de respuesta de configuraciones
- **Cache hit ratio** esperado > 85%

### Operacional

- **Zero-downtime** configuration updates
- **Feature flags** para rollouts graduales por país
- **Rollback automático** en caso de configuraciones inválidas

### Observabilidad

- **Visibilidad completa** del uso de configuraciones
- **Alertas proactivas** para problemas de configuración
- **Métricas** de rendimiento por tenant/país

Esta implementación mantiene la simplicidad mientras añade las capacidades enterprise que necesitas para escalar a múltiples países sin complicaciones. 🚀
