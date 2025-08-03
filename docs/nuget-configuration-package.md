# 📦 Talma.CorporateServices.Configuration

## Librería NuGet Corporativa para Configuración Agnóstica

### 🎯 **Objetivo**
Centralizar toda la lógica de configuración agnóstica en una librería reutilizable para todos los microservicios de Talma.

### 📦 **Estructura del Package**

```
Talma.CorporateServices.Configuration/
├── src/
│   ├── Interfaces/
│   │   ├── IConfigurationProvider.cs
│   │   ├── IConfigurationCache.cs
│   │   └── IConfigurationAudit.cs
│   ├── Providers/
│   │   ├── AwsConfigurationProvider.cs
│   │   ├── AzureConfigurationProvider.cs
│   │   ├── GcpConfigurationProvider.cs
│   │   ├── ConsulConfigurationProvider.cs
│   │   ├── DatabaseConfigurationProvider.cs
│   │   └── HttpConfigurationProvider.cs
│   ├── Cache/
│   │   ├── MemoryCacheConfigurationProvider.cs
│   │   └── DistributedCacheConfigurationProvider.cs
│   ├── Factory/
│   │   └── ConfigurationProviderFactory.cs
│   ├── Extensions/
│   │   └── ServiceCollectionExtensions.cs
│   ├── Health/
│   │   └── ConfigurationProviderHealthCheck.cs
│   ├── Models/
│   │   ├── ConfigurationProviderOptions.cs
│   │   └── ConfigurationAuditEvent.cs
│   └── Exceptions/
│       └── ConfigurationNotFoundException.cs
├── tests/
│   ├── Unit/
│   └── Integration/
├── docs/
│   ├── README.md
│   └── CHANGELOG.md
└── Talma.CorporateServices.Configuration.csproj
```

### ⚡ **Uso en Microservicios**

```csharp
// Program.cs - UNA SOLA LÍNEA
services.AddTalmaConfiguration(Configuration);

// Injection en cualquier servicio
public class NotificationService
{
    private readonly IConfigurationProvider _configProvider;

    public NotificationService(IConfigurationProvider configProvider)
    {
        _configProvider = configProvider;
    }

    public async Task SendAsync(string template, string tenant)
    {
        var config = await _configProvider.GetConfigurationAsync<EmailConfig>("email-settings", tenant);
        // ... usar config
    }
}
```

### 🔧 **Features Incluidas**

#### ✅ **Multi-Provider Support**
- AWS (Systems Manager + Secrets Manager)
- Azure (Key Vault)
- Google Cloud (Secret Manager)
- HashiCorp Consul
- PostgreSQL Database
- HTTP/REST APIs

#### ✅ **Caching Inteligente**
- Memory Cache local
- Distributed Cache (Redis)
- TTL configurables por tipo
- Invalidación por patrones
- Jitter para evitar thundering herd

#### ✅ **Observabilidad Completa**
- OpenTelemetry integration
- Structured logging con Serilog
- Health checks
- Métricas Prometheus
- Audit trail

#### ✅ **Resiliencia**
- Circuit breaker
- Retry policies
- Fallback providers
- Graceful degradation

### 🚀 **Configuración por Ambiente**

```json
// appsettings.Development.json
{
  "TalmaConfiguration": {
    "Provider": "database",
    "CacheTtl": "00:05:00",
    "Database": {
      "ConnectionString": "Host=localhost;Database=config;..."
    }
  }
}

// appsettings.Production.json
{
  "TalmaConfiguration": {
    "Provider": "azure",
    "FallbackProvider": "database",
    "CacheTtl": "00:30:00",
    "Azure": {
      "KeyVaultUrl": "https://talma-{country}-kv.vault.azure.net/"
    }
  }
}
```

### 📈 **Versionado Semantic**

```
v1.0.0 - Core functionality (AWS + Database)
v1.1.0 - Azure provider
v1.2.0 - GCP provider
v1.3.0 - Consul provider
v2.0.0 - Breaking changes (new cache interface)
```

### 🏗️ **Pipeline CI/CD**

```yaml
# azure-pipelines.yml
trigger:
  branches:
    include:
    - main
    - develop
  paths:
    include:
    - src/Talma.CorporateServices.Configuration/*

stages:
- stage: Build
  jobs:
  - job: BuildAndTest
    steps:
    - task: DotNetCoreCLI@2
      displayName: 'Build'
      inputs:
        command: 'build'
        projects: 'src/**/*.csproj'

    - task: DotNetCoreCLI@2
      displayName: 'Test'
      inputs:
        command: 'test'
        projects: 'tests/**/*.csproj'
        arguments: '--collect:"XPlat Code Coverage"'

- stage: Pack
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
  jobs:
  - job: PackageAndPublish
    steps:
    - task: DotNetCoreCLI@2
      displayName: 'Pack NuGet'
      inputs:
        command: 'pack'
        packagesToPack: 'src/**/*.csproj'
        versioningScheme: 'byBuildNumber'

    - task: NuGetCommand@2
      displayName: 'Push to Internal Feed'
      inputs:
        command: 'push'
        packagesToPush: '$(Build.ArtifactStagingDirectory)/**/*.nupkg'
        nuGetFeedType: 'internal'
        publishVstsFeed: 'talma-corporate-services'
```

### 🔒 **Seguridad**

#### **Secrets Management**
```csharp
// Secrets nunca en código
await _configProvider.GetSecretAsync("database-password", tenant);
await _configProvider.GetSecretAsync("api-key-sendgrid", tenant);
```

#### **Audit Trail**
```csharp
// Automático en cada llamada
public async Task<T> GetConfigurationAsync<T>(string key, string tenant)
{
    _audit.LogAccess(key, tenant, _userId, _correlationId);
    // ... obtener valor
    _audit.LogSuccess(key, tenant, _userId, _correlationId);
}
```

### 📊 **Métricas Automáticas**

```prometheus
# Métricas expuestas automáticamente
talma_config_requests_total{provider="azure",status="success"} 1234
talma_config_cache_hits_total{provider="azure"} 890
talma_config_cache_misses_total{provider="azure"} 344
talma_config_request_duration_seconds{provider="azure",quantile="0.95"} 0.012
```

### 🌍 **Multi-Tenant & Multi-Country**

```csharp
// Configuración automática por país
services.AddTalmaConfiguration(Configuration, options =>
{
    options.ConfigureCountryProviders(country =>
    {
        country.ForCountry("PE").UseProvider("azure");
        country.ForCountry("CO").UseProvider("gcp");
        country.ForCountry("MX").UseProvider("aws");
        country.ForCountry("EC").UseProvider("aws");
    });
});

// Uso transparente
var config = await _configProvider.GetConfigurationAsync<T>("key", "tenant-pe-001");
// Automáticamente usa Azure para Perú
```

### 📚 **Documentación Auto-generada**

```xml
<!-- XML Documentation -->
/// <summary>
/// Gets configuration value for the specified key and tenant.
/// Automatically handles caching, fallbacks, and provider selection.
/// </summary>
/// <typeparam name="T">Type to deserialize configuration to</typeparam>
/// <param name="key">Configuration key</param>
/// <param name="tenant">Tenant identifier (optional)</param>
/// <returns>Deserialized configuration value</returns>
/// <exception cref="ConfigurationNotFoundException">Thrown when key is not found</exception>
public async Task<T> GetConfigurationAsync<T>(string key, string tenant = null)
```

### 🎯 **Migration Path**

#### **Fase 1: Crear el Package (1 semana)**
```bash
# 1. Crear proyecto
dotnet new classlib -n Talma.CorporateServices.Configuration

# 2. Agregar dependencies
dotnet add package Microsoft.Extensions.Configuration
dotnet add package Microsoft.Extensions.DependencyInjection
dotnet add package AWSSDK.SystemsManagement
dotnet add package Azure.Security.KeyVault.Secrets

# 3. Implementar interfaces y providers

# 4. Crear tests unitarios

# 5. Publicar a feed interno
dotnet pack
dotnet nuget push -s "TalmaCorporateServices"
```

#### **Fase 2: Migrar Identity Service (2 días)**
```bash
# 1. Agregar package reference
dotnet add package Talma.CorporateServices.Configuration

# 2. Reemplazar implementación existente
# services.AddSingleton<IConfigurationProvider>(...)
# ↓
# services.AddTalmaConfiguration(Configuration);

# 3. Testing y validación
```

#### **Fase 3: Migrar Otros Servicios (1 semana)**
- Notification System
- SITA Messaging
- Track & Trace
- Future services

### ✅ **Beneficios del NuGet Package**

| Aspecto | Sin Package | Con Package | Beneficio |
|---------|-------------|-------------|-----------|
| **Desarrollo** | 6 horas × 4 servicios = 24h | 1 línea × 4 servicios = 4h | **-83% tiempo** |
| **Mantenimiento** | 4 implementaciones separadas | 1 implementación central | **-75% esfuerzo** |
| **Testing** | 4 suites de testing | 1 suite comprehensive | **-75% testing** |
| **Bugs** | 4 × probabilidad | 1 × probabilidad | **-75% bugs** |
| **Features** | Desarrollo individual | Features automáticas | **+100% features** |
| **Consistency** | Divergencia inevitable | Consistencia garantizada | **+∞ consistency** |

### 🏆 **ROI Calculation**

#### **Inversión Inicial**
- Desarrollo package: 40 horas (1 semana)
- Setup CI/CD: 8 horas
- Documentación: 8 horas
- **Total: 56 horas**

#### **Ahorro por Servicio**
- Sin package: 6 horas desarrollo + 2 horas testing = 8 horas
- Con package: 0.5 horas integración + 0.5 horas testing = 1 hora
- **Ahorro: 7 horas por servicio**

#### **Break-even**
- 56 horas ÷ 7 horas = **8 servicios**
- Con 4 servicios actuales + 4 futuros = **ROI inmediato**

#### **Ahorro Anual**
- Mantenimiento: 50% menos esfuerzo
- Nuevas features: 80% menos desarrollo
- Bug fixing: 75% menos tiempo
- **Ahorro estimado: 200+ horas/año**
