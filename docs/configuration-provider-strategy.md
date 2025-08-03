# 🔧 Estrategia de Cambio de Proveedores de Configuración

## 📋 Resumen Ejecutivo

La arquitectura agnóstica implementada permite cambiar proveedores de configuración (AWS → Azure → GCP) **sin redespliegue de aplicaciones** y **sin desarrollo adicional significativo**.

## 🎯 Beneficios de la Arquitectura Actual

### ✅ **Ya Implementado**
- **Interfaz Agnóstica**: `IConfigurationProvider` abstrae la implementación
- **Cache Local**: Reduce dependencia del proveedor externo
- **Polling Inteligente**: Minimiza llamadas al proveedor
- **Factory Pattern**: Intercambio dinámico de implementaciones

### ✅ **Cambio Sin Impacto**
- **Sin Redespliegue**: Solo cambio de configuración
- **Sin Desarrollo Extra**: Implementaciones intercambiables
- **Gradual por Tenant**: Feature flags para migración controlada
- **Rollback Inmediato**: Reversión instantánea por configuración

## 🔄 Estrategias de Migración

### **1. Configuration-Driven (Recomendado)**

```csharp
// appsettings.{Environment}.json
{
  "ConfigurationProvider": {
    "Type": "AWS", // Cambiar a "Azure", "GCP"
    "FallbackType": "Database", // Backup local
    "AWS": {
      "Region": "us-east-1",
      "ParameterStorePrefix": "/talma/prod"
    },
    "Azure": {
      "KeyVaultUrl": "https://talma-{country}-kv.vault.azure.net/",
      "TenantId": "12345678-1234-1234-1234-123456789abc"
    },
    "GCP": {
      "ProjectId": "talma-corp-services-{country}",
      "SecretManagerPrefix": "talma-prod"
    }
  }
}
```

**Proceso de Cambio:**
1. Migrar secretos/configuraciones al nuevo proveedor
2. Actualizar `appsettings.{Environment}.json`
3. Reiniciar servicios (no redesplegar)
4. Validar funcionamiento
5. Limpiar proveedor anterior

### **2. Migración Gradual por País**

```yaml
# docker-compose.{country}.yml
environment:
  - CONFIGURATION_PROVIDER_TYPE=Azure  # Perú → Azure
  - CONFIGURATION_PROVIDER_TYPE=GCP    # Colombia → GCP
  - CONFIGURATION_PROVIDER_TYPE=AWS    # México → AWS
```

### **3. Feature Flags para Migración A/B**

```csharp
public class CountryAwareConfigurationProvider : IConfigurationProvider
{
    public async Task<T> GetConfigurationAsync<T>(string key, string tenant = null)
    {
        var country = await GetTenantCountryAsync(tenant);

        var provider = country switch
        {
            "PE" => _azureProvider,   // Perú → Azure
            "CO" => _gcpProvider,     // Colombia → GCP
            "MX" => _awsProvider,     // México → AWS
            "EC" => _awsProvider,     // Ecuador → AWS
            _ => _defaultProvider
        };

        return await provider.GetConfigurationAsync<T>(key, tenant);
    }
}
```

## 🌍 Casos de Uso por Región

### **Escenario 1: Soberanía de Datos**
```
Perú → Azure (Regulación local requiere datos en región brasileña)
Colombia → GCP (Mejor latencia desde São Paulo)
México → AWS (Infraestructura existente)
Ecuador → AWS (Mismo proveedor que México)
```

### **Escenario 2: Costos Optimizados**
```
Desarrollo → Database (Sin costos cloud)
Testing → AWS (Tier gratuito)
Producción → Azure/GCP (Contratos empresariales)
```

### **Escenario 3: Migración Progresiva**
```
Semana 1: Notifications → Azure (validación)
Semana 2: SITA Messaging → Azure (escalamiento)
Semana 3: Identity → Azure (componente crítico)
Semana 4: Track & Trace → Azure (completar migración)
```

## 🔧 Implementación Técnica

### **Factory Pattern Implementado**

```csharp
// Program.cs / Startup.cs
services.AddSingleton<IConfigurationProvider>(provider =>
{
    var config = provider.GetRequiredService<IConfiguration>();
    var logger = provider.GetRequiredService<ILogger<Program>>();

    return CreateConfigurationProvider(config, logger);
});

private static IConfigurationProvider CreateConfigurationProvider(
    IConfiguration config, ILogger logger)
{
    var providerType = config["ConfigurationProvider:Type"];
    var fallbackType = config["ConfigurationProvider:FallbackType"];

    logger.LogInformation("Initializing {ProviderType} configuration provider", providerType);

    var primaryProvider = providerType?.ToLower() switch
    {
        "aws" => new AwsConfigurationProvider(
            config.GetSection("ConfigurationProvider:AWS")),
        "azure" => new AzureConfigurationProvider(
            config.GetSection("ConfigurationProvider:Azure")),
        "gcp" => new GcpConfigurationProvider(
            config.GetSection("ConfigurationProvider:GCP")),
        "database" => new DatabaseConfigurationProvider(
            config.GetSection("ConfigurationProvider:Database")),
        _ => throw new InvalidOperationException($"Unsupported provider: {providerType}")
    };

    // Fallback provider para resiliencia
    if (!string.IsNullOrEmpty(fallbackType))
    {
        var fallbackProvider = CreateFallbackProvider(fallbackType, config);
        return new FallbackConfigurationProvider(primaryProvider, fallbackProvider);
    }

    return primaryProvider;
}
```

### **Implementaciones por Proveedor**

```csharp
// AWS Implementation
public class AwsConfigurationProvider : IConfigurationProvider
{
    private readonly IAmazonSystemsManagement _ssmClient;
    private readonly IAmazonSecretsManager _secretsClient;

    public async Task<T> GetConfigurationAsync<T>(string key, string tenant = null)
    {
        var parameterName = BuildParameterName(key, tenant);
        var response = await _ssmClient.GetParameterAsync(new GetParameterRequest
        {
            Name = parameterName,
            WithDecryption = true
        });

        return JsonSerializer.Deserialize<T>(response.Parameter.Value);
    }
}

// Azure Implementation
public class AzureConfigurationProvider : IConfigurationProvider
{
    private readonly SecretClient _secretClient;

    public async Task<T> GetConfigurationAsync<T>(string key, string tenant = null)
    {
        var secretName = BuildSecretName(key, tenant);
        var response = await _secretClient.GetSecretAsync(secretName);

        return JsonSerializer.Deserialize<T>(response.Value.Value);
    }
}

// GCP Implementation
public class GcpConfigurationProvider : IConfigurationProvider
{
    private readonly SecretManagerServiceClient _client;

    public async Task<T> GetConfigurationAsync<T>(string key, string tenant = null)
    {
        var secretName = BuildSecretName(key, tenant);
        var response = await _client.AccessSecretVersionAsync(secretName);

        return JsonSerializer.Deserialize<T>(response.Payload.Data.ToStringUtf8());
    }
}
```

## 📊 Matriz de Decisión

| Criterio | AWS | Azure | GCP | Database |
|----------|-----|-------|-----|----------|
| **Costo** | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Latencia** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Compliance** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Disponibilidad** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Facilidad Migración** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

## 🚀 Proceso de Migración

### **Fase 1: Preparación (1-2 días)**
1. **Auditar configuraciones actuales**
   ```bash
   # Exportar configuraciones de AWS
   aws ssm get-parameters-by-path --path /talma/prod --recursive
   ```

2. **Configurar nuevo proveedor**
   ```bash
   # Azure: Crear Key Vault y secretos
   az keyvault create --name talma-pe-kv --resource-group talma-pe-rg

   # GCP: Crear proyecto y secretos
   gcloud secrets create talma-db-connection --data-file=connection.json
   ```

### **Fase 2: Migración de Datos (2-4 horas)**
```bash
# Script automatizado de migración
./scripts/migrate-configuration.sh \
  --source-provider aws \
  --target-provider azure \
  --environment prod \
  --country PE
```

### **Fase 3: Cambio de Configuración (5 minutos)**
```bash
# Actualizar configuración
kubectl patch configmap app-config \
  -p '{"data":{"ConfigurationProvider__Type":"Azure"}}'

# Reiniciar pods (rolling restart)
kubectl rollout restart deployment/notification-api
```

### **Fase 4: Validación (15 minutos)**
```bash
# Verificar health checks
kubectl get pods -l app=notification-api
curl https://api.talma.pe/health

# Validar métricas
curl https://prometheus.talma.pe/api/v1/query?query=configuration_provider_calls_total
```

## 🔒 Consideraciones de Seguridad

### **Rotación de Secretos**
```csharp
// Implementación agnóstica de rotación
public class SecretRotationService
{
    public async Task RotateSecretAsync(string secretName, string newValue)
    {
        // 1. Crear nueva versión en proveedor
        await _configProvider.CreateSecretVersionAsync(secretName, newValue);

        // 2. Invalidar cache local
        await _configProvider.InvalidateCacheAsync($"secret:{secretName}");

        // 3. Notificar a todas las instancias
        await _eventBus.PublishAsync(new SecretRotatedEvent(secretName));

        // 4. Programar eliminación de versión anterior
        await _scheduler.ScheduleAsync(new DeleteOldSecretVersionJob(secretName),
            TimeSpan.FromDays(7));
    }
}
```

### **Audit Trail Agnóstico**
```csharp
public class ConfigurationAuditService
{
    public async Task LogConfigurationAccessAsync(string key, string tenant,
        string provider, string operation)
    {
        var auditEvent = new ConfigurationAuditEvent
        {
            Key = key,
            Tenant = tenant,
            Provider = provider,
            Operation = operation,
            Timestamp = DateTimeOffset.UtcNow,
            UserId = _contextAccessor.HttpContext?.User?.Identity?.Name
        };

        await _auditRepository.SaveAsync(auditEvent);
    }
}
```

## 🎯 Recomendaciones

### **Estrategia Recomendada: Híbrida por País**
1. **Perú**: Azure (compliance local)
2. **Colombia**: GCP (mejor latencia regional)
3. **México/Ecuador**: AWS (infraestructura existente)
4. **Desarrollo**: Database (cero costos)

### **Timeline de Implementación**
- **Día 1**: Implementar factory pattern
- **Semana 1**: Migrar ambiente desarrollo
- **Semana 2**: Migrar ambiente testing
- **Semana 3**: Migrar ambiente staging
- **Semana 4**: Migrar producción (rolling deployment)

### **Monitoreo Post-Migración**
```csharp
// Métricas específicas por proveedor
services.AddSingleton<IConfigurationProvider>(provider =>
{
    var baseProvider = CreateConfigurationProvider(config, logger);
    return new InstrumentedConfigurationProvider(baseProvider, metrics);
});

public class InstrumentedConfigurationProvider : IConfigurationProvider
{
    public async Task<T> GetConfigurationAsync<T>(string key, string tenant = null)
    {
        using var activity = _activitySource.StartActivity("GetConfiguration");
        activity?.SetTag("provider", _providerType);
        activity?.SetTag("key", key);
        activity?.SetTag("tenant", tenant);

        var stopwatch = Stopwatch.StartNew();
        try
        {
            var result = await _inner.GetConfigurationAsync<T>(key, tenant);
            _metrics.IncrementCounter("configuration_requests_total",
                new[] { ("provider", _providerType), ("status", "success") });
            return result;
        }
        catch (Exception ex)
        {
            _metrics.IncrementCounter("configuration_requests_total",
                new[] { ("provider", _providerType), ("status", "error") });
            throw;
        }
        finally
        {
            _metrics.RecordHistogram("configuration_request_duration",
                stopwatch.ElapsedMilliseconds,
                new[] { ("provider", _providerType) });
        }
    }
}
```

## ✅ Conclusión

**La arquitectura agnóstica ya implementada te permite:**

1. ✅ **Cambiar proveedores sin redespliegue** (solo reinicio)
2. ✅ **Migración gradual por país/tenant** (feature flags)
3. ✅ **Rollback inmediato** (cambio de configuración)
4. ✅ **Cero desarrollo adicional** (interfaces ya abstraídas)
5. ✅ **Audit trail completo** (rastreabilidad de cambios)
6. ✅ **Monitoreo por proveedor** (métricas diferenciadas)

**El ROI de esta arquitectura es inmediato**: flexibilidad total para optimizar costos, cumplir regulaciones locales y adaptarse a cambios de negocio sin impacto técnico.
