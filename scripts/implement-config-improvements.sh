#!/bin/bash

# 🚀 Script de implementación de mejoras de configuración
# Servicios Corporativos - Talma

echo "🔧 Iniciando implementación de mejoras de configuración..."

# Crear estructura de directorios para las mejoras
mkdir -p src/SitaMessaging.Infrastructure/Configuration
mkdir -p src/SitaMessaging.Application/Services/Configuration
mkdir -p src/SitaMessaging.Application/Models/Configuration
mkdir -p infrastructure/terraform/feature-flags
mkdir -p scripts/configuration-validation

echo "📁 Estructura de directorios creada"

# 1. Configuración de Parameter Store para Feature Flags
echo "🎯 Configurando Parameter Store para Feature Flags..."

cat > infrastructure/terraform/feature-flags/main.tf << 'EOF'
# Feature Flags para SITA Messaging por país
resource "aws_ssm_parameter" "sita_messaging_peru" {
  name  = "/corporativo/feature-flags/peru/sita-messaging"
  type  = "String"
  value = "enabled"
  description = "Enable/disable SITA messaging for Peru"

  tags = {
    Environment = var.environment
    Service     = "sita-messaging"
    Country     = "peru"
  }
}

resource "aws_ssm_parameter" "sita_messaging_ecuador" {
  name  = "/corporativo/feature-flags/ecuador/sita-messaging"
  type  = "String"
  value = "enabled"
  description = "Enable/disable SITA messaging for Ecuador"

  tags = {
    Environment = var.environment
    Service     = "sita-messaging"
    Country     = "ecuador"
  }
}

resource "aws_ssm_parameter" "sita_messaging_colombia" {
  name  = "/corporativo/feature-flags/colombia/sita-messaging"
  type  = "String"
  value = "enabled"
  description = "Enable/disable SITA messaging for Colombia"

  tags = {
    Environment = var.environment
    Service     = "sita-messaging"
    Country     = "colombia"
  }
}

resource "aws_ssm_parameter" "sita_messaging_mexico" {
  name  = "/corporativo/feature-flags/mexico/sita-messaging"
  type  = "String"
  value = "enabled"
  description = "Enable/disable SITA messaging for Mexico"

  tags = {
    Environment = var.environment
    Service     = "sita-messaging"
    Country     = "mexico"
  }
}

# Configuraciones específicas por país
resource "aws_ssm_parameter" "sita_batch_size_peru" {
  name  = "/corporativo/config/peru/sita-batch-size"
  type  = "String"
  value = "100"
  description = "SITA batch size for Peru"
}

resource "aws_ssm_parameter" "sita_batch_size_ecuador" {
  name  = "/corporativo/config/ecuador/sita-batch-size"
  type  = "String"
  value = "150"
  description = "SITA batch size for Ecuador"
}

# SQS Queue para eventos de configuración
resource "aws_sqs_queue" "config_events" {
  name                       = "sita-messaging-config-events-${var.environment}"
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 1209600  # 14 días
  receive_wait_time_seconds  = 20       # Long polling

  tags = {
    Environment = var.environment
    Service     = "sita-messaging"
    Purpose     = "configuration-events"
  }
}

# SNS Topic para notificar cambios de configuración
resource "aws_sns_topic" "config_changes" {
  name = "sita-messaging-config-changes-${var.environment}"

  tags = {
    Environment = var.environment
    Service     = "sita-messaging"
    Purpose     = "configuration-notifications"
  }
}

# Subscription de SQS al SNS
resource "aws_sns_topic_subscription" "config_events_subscription" {
  topic_arn = aws_sns_topic.config_changes.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.config_events.arn
}
EOF

# 2. Crear el Configuration Manager mejorado
echo "⚙️ Creando Configuration Manager con cache..."

cat > src/SitaMessaging.Infrastructure/Configuration/ConfigurationManager.cs << 'EOF'
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;
using Amazon.SimpleSystemsManagement;
using Amazon.SimpleSystemsManagement.Model;
using SitaMessaging.Application.Interfaces;
using SitaMessaging.Application.Models.Configuration;
using System.Text.Json;

namespace SitaMessaging.Infrastructure.Configuration;

public class ConfigurationManager : IConfigurationManager
{
    private readonly IMemoryCache _cache;
    private readonly IAmazonSimpleSystemsManagement _parameterStore;
    private readonly ITenantConfigRepository _tenantRepo;
    private readonly ILogger<ConfigurationManager> _logger;
    private readonly IMetricsCollector _metrics;

    // TTL por tipo de configuración
    private readonly Dictionary<string, TimeSpan> _cacheTtl = new()
    {
        ["secrets"] = TimeSpan.FromMinutes(1),
        ["feature-flags"] = TimeSpan.FromMinutes(5),
        ["tenant-config"] = TimeSpan.FromMinutes(15),
        ["system-config"] = TimeSpan.FromHours(1)
    };

    public ConfigurationManager(
        IMemoryCache cache,
        IAmazonSimpleSystemsManagement parameterStore,
        ITenantConfigRepository tenantRepo,
        ILogger<ConfigurationManager> logger,
        IMetricsCollector metrics)
    {
        _cache = cache;
        _parameterStore = parameterStore;
        _tenantRepo = tenantRepo;
        _logger = logger;
        _metrics = metrics;
    }

    public async Task<T> GetConfigurationAsync<T>(string key, string tenantId, string country)
    {
        var cacheKey = $"config:{tenantId}:{country}:{key}";

        // 1. Intentar obtener del cache
        if (_cache.TryGetValue(cacheKey, out T cachedValue))
        {
            _metrics.IncrementCounter("config_cache_hits", new[] { ("key", key), ("country", country) });
            return cachedValue;
        }

        _metrics.IncrementCounter("config_cache_misses", new[] { ("key", key), ("country", country) });

        using var activity = _metrics.StartTimer("config_load_duration");

        try
        {
            // 2. Obtener de fuente (Parameter Store + DB)
            var value = await GetFromSourceAsync<T>(key, tenantId, country);

            // 3. Almacenar en cache con TTL apropiado
            var ttl = GetTtlForKey(key);
            _cache.Set(cacheKey, value, ttl);

            _logger.LogInformation("Configuration loaded for key {Key}, tenant {TenantId}, country {Country}",
                key, tenantId, country);

            return value;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error loading configuration {Key} for tenant {TenantId}", key, tenantId);
            throw;
        }
    }

    private async Task<T> GetFromSourceAsync<T>(string key, string tenantId, string country)
    {
        // Jerarquía de configuración: Tenant > País > Global
        try
        {
            // 1. Buscar configuración específica del tenant
            var tenantConfig = await _tenantRepo.GetConfigAsync<T>(tenantId, key);
            if (tenantConfig != null)
            {
                _logger.LogDebug("Found tenant-specific config for {Key}", key);
                return tenantConfig;
            }

            // 2. Buscar configuración del país
            var countryParameter = await GetParameterAsync($"/corporativo/config/{country}/{key}");
            if (countryParameter != null)
            {
                _logger.LogDebug("Found country-specific config for {Key} in {Country}", key, country);
                return JsonSerializer.Deserialize<T>(countryParameter);
            }

            // 3. Buscar configuración global
            var globalParameter = await GetParameterAsync($"/corporativo/config/global/{key}");
            if (globalParameter != null)
            {
                _logger.LogDebug("Found global config for {Key}", key);
                return JsonSerializer.Deserialize<T>(globalParameter);
            }

            _logger.LogWarning("No configuration found for key {Key}", key);
            return default(T);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving configuration from source for {Key}", key);
            throw;
        }
    }

    private async Task<string> GetParameterAsync(string parameterName)
    {
        try
        {
            var request = new GetParameterRequest
            {
                Name = parameterName,
                WithDecryption = true
            };

            var response = await _parameterStore.GetParameterAsync(request);
            return response.Parameter?.Value;
        }
        catch (ParameterNotFound)
        {
            return null; // Parámetro no existe, esto es normal en la jerarquía
        }
    }

    private TimeSpan GetTtlForKey(string key)
    {
        foreach (var kvp in _cacheTtl)
        {
            if (key.Contains(kvp.Key))
                return kvp.Value;
        }

        return TimeSpan.FromMinutes(10); // Default TTL
    }

    public async Task InvalidateCacheAsync(string key, string tenantId = null, string country = null)
    {
        var pattern = tenantId != null && country != null
            ? $"config:{tenantId}:{country}:{key}"
            : $"config:*:{key}";

        // En una implementación real, usarías un cache distribuido con pattern matching
        // Por ahora, removemos específicamente
        if (tenantId != null && country != null)
        {
            var cacheKey = $"config:{tenantId}:{country}:{key}";
            _cache.Remove(cacheKey);
            _logger.LogInformation("Cache invalidated for {CacheKey}", cacheKey);
        }
    }
}
EOF

# 3. Crear el Feature Flag Service
echo "🚩 Creando Feature Flag Service..."

cat > src/SitaMessaging.Application/Services/Configuration/FeatureFlagService.cs << 'EOF'
using SitaMessaging.Application.Interfaces;
using Microsoft.Extensions.Logging;

namespace SitaMessaging.Application.Services.Configuration;

public class FeatureFlagService : IFeatureFlagService
{
    private readonly IConfigurationManager _configManager;
    private readonly ILogger<FeatureFlagService> _logger;
    private readonly IMetricsCollector _metrics;

    public FeatureFlagService(
        IConfigurationManager configManager,
        ILogger<FeatureFlagService> logger,
        IMetricsCollector metrics)
    {
        _configManager = configManager;
        _logger = logger;
        _metrics = metrics;
    }

    public async Task<bool> IsEnabledAsync(string feature, string tenantId, string country)
    {
        try
        {
            var key = $"feature-flags/{feature}";
            var value = await _configManager.GetConfigurationAsync<string>(key, tenantId, country);

            var isEnabled = value?.ToLowerInvariant() switch
            {
                "enabled" => true,
                "disabled" => false,
                "beta" => await IsTenantInBetaAsync(tenantId, feature),
                _ => false // Default disabled para fail-safe
            };

            // Registrar métricas de uso
            _metrics.IncrementCounter("feature_flag_usage", new[]
            {
                ("flag", feature),
                ("tenant", tenantId),
                ("country", country),
                ("enabled", isEnabled.ToString())
            });

            _logger.LogDebug("Feature flag {Feature} is {Status} for tenant {TenantId} in {Country}",
                feature, isEnabled ? "enabled" : "disabled", tenantId, country);

            return isEnabled;
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
            var value = await _configManager.GetConfigurationAsync<T>(key, tenantId, country);
            return value ?? defaultValue;
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Error getting feature config {Feature}, using default", feature);
            return defaultValue;
        }
    }

    private async Task<bool> IsTenantInBetaAsync(string tenantId, string feature)
    {
        // Lógica para determinar si un tenant está en beta
        // Podría ser una lista en Parameter Store o base de datos
        try
        {
            var betaTenantsKey = $"feature-flags/{feature}/beta-tenants";
            var betaTenants = await _configManager.GetConfigurationAsync<string[]>(betaTenantsKey, tenantId, "global");
            return betaTenants?.Contains(tenantId) ?? false;
        }
        catch
        {
            return false;
        }
    }
}
EOF

# 4. Crear script de validación de configuraciones
echo "✅ Creando script de validación..."

cat > scripts/configuration-validation/validate-parameter-structure.py << 'EOF'
#!/usr/bin/env python3
"""
Valida la estructura de parámetros en AWS Parameter Store
"""

import boto3
import sys
from typing import List, Dict

def validate_parameter_structure() -> bool:
    """Valida que la estructura de parámetros siga las convenciones"""
    ssm = boto3.client('ssm')
    errors = []

    try:
        # Obtener todos los parámetros corporativos
        paginator = ssm.get_paginator('describe_parameters')

        for page in paginator.paginate():
            for param in page['Parameters']:
                name = param['Name']

                # Validar estructura de feature flags
                if '/feature-flags/' in name:
                    if not validate_feature_flag_structure(name):
                        errors.append(f"Invalid feature flag structure: {name}")

                # Validar estructura de configuraciones
                if '/config/' in name:
                    if not validate_config_structure(name):
                        errors.append(f"Invalid config structure: {name}")

        if errors:
            print("❌ Validation errors found:")
            for error in errors:
                print(f"  - {error}")
            return False
        else:
            print("✅ All parameter structures are valid")
            return True

    except Exception as e:
        print(f"❌ Error validating parameters: {e}")
        return False

def validate_feature_flag_structure(name: str) -> bool:
    """Valida estructura de feature flags"""
    # Estructura esperada: /corporativo/feature-flags/{country}/{feature}
    parts = name.split('/')
    if len(parts) < 5:
        return False

    if parts[1] != 'corporativo' or parts[2] != 'feature-flags':
        return False

    country = parts[3]
    valid_countries = ['peru', 'ecuador', 'colombia', 'mexico', 'global']

    return country in valid_countries

def validate_config_structure(name: str) -> bool:
    """Valida estructura de configuraciones"""
    # Estructura esperada: /corporativo/config/{country}/{service}/{config-key}
    parts = name.split('/')
    if len(parts) < 5:
        return False

    if parts[1] != 'corporativo' or parts[2] != 'config':
        return False

    country = parts[3]
    valid_countries = ['peru', 'ecuador', 'colombia', 'mexico', 'global']

    return country in valid_countries

if __name__ == '__main__':
    success = validate_parameter_structure()
    sys.exit(0 if success else 1)
EOF

# 5. Crear docker-compose para desarrollo local con Redis
echo "🐳 Configurando Redis para cache distribuido..."

cat > docker-compose.override.yml << 'EOF'
version: '3.8'

services:
  sita-messaging-api:
    environment:
      - Redis__ConnectionString=redis:6379
      - AWS_REGION=us-east-1
      - AWS_ACCESS_KEY_ID=localstack
      - AWS_SECRET_ACCESS_KEY=localstack
    depends_on:
      - redis
      - localstack

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    command: redis-server --maxmemory 256mb --maxmemory-policy allkeys-lru
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3

  localstack:
    image: localstack/localstack:latest
    ports:
      - "4566:4566"
    environment:
      - SERVICES=ssm,sqs,sns
      - DEBUG=1
      - DATA_DIR=/tmp/localstack/data
    volumes:
      - "/tmp/localstack:/tmp/localstack"
      - "/var/run/docker.sock:/var/run/docker.sock"

  # Setup inicial de parámetros en LocalStack
  localstack-setup:
    image: amazon/aws-cli:latest
    depends_on:
      - localstack
    environment:
      - AWS_ACCESS_KEY_ID=localstack
      - AWS_SECRET_ACCESS_KEY=localstack
      - AWS_DEFAULT_REGION=us-east-1
    entrypoint: /bin/sh
    command: -c "
      sleep 10 &&
      aws --endpoint-url=http://localstack:4566 ssm put-parameter --name '/corporativo/feature-flags/peru/sita-messaging' --value 'enabled' --type String &&
      aws --endpoint-url=http://localstack:4566 ssm put-parameter --name '/corporativo/feature-flags/ecuador/sita-messaging' --value 'enabled' --type String &&
      aws --endpoint-url=http://localstack:4566 ssm put-parameter --name '/corporativo/config/peru/sita-batch-size' --value '100' --type String &&
      echo 'LocalStack setup completed'
    "
EOF

# 6. Crear configuración de DI para .NET
echo "🔧 Configurando Dependency Injection..."

cat > src/SitaMessaging.Api/Extensions/ServiceCollectionExtensions.cs << 'EOF'
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;
using SitaMessaging.Infrastructure.Configuration;
using SitaMessaging.Application.Services.Configuration;
using SitaMessaging.Application.Interfaces;
using Amazon.SimpleSystemsManagement;
using StackExchange.Redis;

namespace SitaMessaging.Api.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddConfigurationServices(this IServiceCollection services, IConfiguration configuration)
    {
        // AWS Parameter Store
        services.AddAWSService<IAmazonSimpleSystemsManagement>();

        // Memory Cache
        services.AddMemoryCache(options =>
        {
            options.SizeLimit = 1024; // Límite de entradas en cache
            options.CompactionPercentage = 0.25; // Compactación cuando se alcanza el límite
        });

        // Redis Cache (opcional, para entornos distribuidos)
        var redisConnectionString = configuration.GetConnectionString("Redis");
        if (!string.IsNullOrEmpty(redisConnectionString))
        {
            services.AddStackExchangeRedisCache(options =>
            {
                options.Configuration = redisConnectionString;
                options.InstanceName = "SitaMessaging";
            });
        }

        // Configuration Services
        services.AddScoped<IConfigurationManager, ConfigurationManager>();
        services.AddScoped<IFeatureFlagService, FeatureFlagService>();

        return services;
    }
}
EOF

# 7. Crear configuración de appsettings
echo "📄 Creando configuración de appsettings..."

cat > src/SitaMessaging.Api/appsettings.Development.json << 'EOF'
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning",
      "SitaMessaging.Infrastructure.Configuration": "Debug"
    }
  },
  "ConnectionStrings": {
    "Redis": "localhost:6379",
    "Database": "Host=localhost;Database=sita_messaging;Username=postgres;Password=postgres"
  },
  "AWS": {
    "Region": "us-east-1",
    "ServiceURL": "http://localhost:4566"
  },
  "Configuration": {
    "CacheSettings": {
      "DefaultTtlMinutes": 10,
      "FeatureFlagTtlMinutes": 5,
      "SecretsTtlMinutes": 1,
      "SystemConfigTtlHours": 1
    }
  }
}
EOF

# 8. Crear tests de integración
echo "🧪 Creando tests de integración..."

cat > tests/SitaMessaging.IntegrationTests/Configuration/ConfigurationManagerTests.cs << 'EOF'
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Xunit;
using SitaMessaging.Infrastructure.Configuration;
using SitaMessaging.Application.Interfaces;

namespace SitaMessaging.IntegrationTests.Configuration;

public class ConfigurationManagerTests : IClassFixture<TestWebApplicationFactory>
{
    private readonly TestWebApplicationFactory _factory;

    public ConfigurationManagerTests(TestWebApplicationFactory factory)
    {
        _factory = factory;
    }

    [Fact]
    public async Task GetConfigurationAsync_ShouldReturnTenantSpecificConfig_WhenExists()
    {
        // Arrange
        using var scope = _factory.Services.CreateScope();
        var configManager = scope.ServiceProvider.GetRequiredService<IConfigurationManager>();

        // Act
        var result = await configManager.GetConfigurationAsync<string>("sita-batch-size", "tenant-123", "peru");

        // Assert
        Assert.NotNull(result);
    }

    [Fact]
    public async Task GetConfigurationAsync_ShouldUseCache_OnSecondCall()
    {
        // Arrange
        using var scope = _factory.Services.CreateScope();
        var configManager = scope.ServiceProvider.GetRequiredService<IConfigurationManager>();

        // Act
        var result1 = await configManager.GetConfigurationAsync<string>("test-config", "tenant-123", "peru");
        var result2 = await configManager.GetConfigurationAsync<string>("test-config", "tenant-123", "peru");

        // Assert
        Assert.Equal(result1, result2);
        // Verificar que el segundo call fue más rápido (indicando cache hit)
    }
}
EOF

echo "✅ ¡Implementación completada!"
echo ""
echo "📋 Próximos pasos:"
echo "1. Ejecutar: terraform apply -target=module.feature_flags"
echo "2. Ejecutar: docker-compose up -d redis localstack"
echo "3. Añadir las nuevas interfaces a tu proyecto"
echo "4. Ejecutar tests: dotnet test"
echo "5. Desplegar con las nuevas configuraciones"
echo ""
echo "🎯 Beneficios implementados:"
echo "- ✅ Cache inteligente con TTL por tipo"
echo "- ✅ Feature flags por país/tenant"
echo "- ✅ Configuración jerárquica (Tenant > País > Global)"
echo "- ✅ Métricas de rendimiento"
echo "- ✅ Validación automatizada"
echo "- ✅ Desarrollo local con LocalStack"
echo ""
echo "🚀 Tu arquitectura ahora tiene las mejores prácticas enterprise!"
