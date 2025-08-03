#!/bin/bash

# 🚀 Script para aplicar mejoras de configuración a TODOS los servicios
# Servicios Corporativos - Talma

echo "🔧 Aplicando mejoras de configuración a todos los servicios..."

# Función para añadir mejoras de configuración a un servicio
apply_config_improvements() {
    local service_name=$1
    local service_file=$2
    local feature_examples=$3

    echo "🎯 Aplicando mejoras a $service_name..."

    # Crear backup
    cp "$service_file" "${service_file}.backup"

    # Script Python para realizar las mejoras de manera inteligente
    cat > apply_improvements.py << EOF
import re
import sys

def apply_improvements(file_path, service_name, feature_examples):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Mejorar Configuration Managers existentes
    # Patrón: configManager = component "Configuration Manager" {
    pattern = r'(configManager = component "Configuration Manager" \{[^}]*?)technology "([^"]*)"([^}]*?)description "([^"]*)"([^}]*?\})'

    def replace_config_manager(match):
        tech = match.group(2)
        desc = match.group(4)

        # Mejorar technology
        new_tech = tech
        if "IMemoryCache" not in tech:
            new_tech = tech + ", IMemoryCache"

        # Mejorar description
        new_desc = desc
        if "cache" not in desc.lower():
            new_desc = desc + " Incluye cache inteligente con TTL diferenciado y feature flags por país/tenant."

        return f'''configManager = component "Configuration Manager" {{
            technology "{new_tech}"
            description "{new_desc}"
            tags "Configuración" "001 - Fase 1"
        }}

        configCache = component "Configuration Cache" {{
            technology "IMemoryCache, Redis"
            description "Cache distribuido para configuraciones de {service_name} con TTL optimizado por tipo de configuración."
            tags "Cache" "001 - Fase 1"

            configManager -> this "consulta cache" "" "001 - Fase 1"
        }}

        featureFlagService = component "Feature Flag Service" {{
            technology "C#, AWS SDK"
            description "Gestiona feature flags por país y tenant para {service_name}: {feature_examples}."
            tags "Feature Flags" "001 - Fase 1"

            this -> configCache "usa cache para flags" "" "001 - Fase 1"
        }}'''

    # Aplicar mejoras solo al primer Configuration Manager encontrado
    # (para evitar duplicaciones)
    content = re.sub(pattern, replace_config_manager, content, count=1, flags=re.DOTALL)

    # Buscar métricas collector y mejorarlas
    metrics_pattern = r'(metricsCollector = component "Metrics Collector" \{[^}]*?)description "([^"]*)"([^}]*?\})'

    def improve_metrics(match):
        desc = match.group(2)
        new_desc = desc
        if "config" not in desc.lower():
            new_desc = desc + ", config cache hit ratio, feature flag usage."

        return f'''metricsCollector = component "Metrics Collector" {{
            technology "prometheus-net"
            description "{new_desc}"
            tags "Observability" "001 - Fase 1"

            configManager -> this "envía métricas de config" "" "001 - Fase 1"
            featureFlagService -> this "envía métricas de feature flags" "" "001 - Fase 1"
        }}'''

    content = re.sub(metrics_pattern, improve_metrics, content, count=1, flags=re.DOTALL)

    # Añadir queue para eventos de configuración antes del final del sistema
    if "configEventQueue" not in content and "= softwareSystem" in content:
        # Buscar el final del softwareSystem y añadir la queue antes
        system_end_pattern = r'(\s+)\/\/ Configuración multi-tenant y secretos - patrón estándar del proyecto'

        config_queue = '''
    configEventQueue = store "Configuration Event Queue" {
        description "Cola SQS para eventos de cambios de configuración y feature flags de ''' + service_name + '''"
        technology "AWS SQS"
        tags "Message Bus" "SQS" "Configuration" "001 - Fase 1"
    }

    // Configuración multi-tenant y secretos - patrón estándar del proyecto'''

        content = re.sub(system_end_pattern, config_queue, content)

    # Añadir conexiones para feature flags
    if "feature flags por país/tenant" not in content:
        # Buscar el final de las conexiones de configuración y añadir feature flags
        config_end_pattern = r'(.*secretsService "Lee configuraciones y secretos" "" "001 - Fase 1")'

        feature_connections = r'''\1

    // Feature flags y configuración dinámica para ''' + service_name + '''
    // Los feature flags se obtienen a través del mismo Configuration Manager
    // Ejemplos: ''' + feature_examples + '''
    // Configuración jerárquica: Tenant > País > Global'''

        content = re.sub(config_end_pattern, feature_connections, content)

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

    print(f"✅ Mejoras aplicadas a {service_name}")

if __name__ == "__main__":
    file_path = sys.argv[1]
    service_name = sys.argv[2]
    feature_examples = sys.argv[3]
    apply_improvements(file_path, service_name, feature_examples)
EOF

    # Ejecutar el script Python
    python3 apply_improvements.py "$service_file" "$service_name" "$feature_examples"

    # Limpiar archivo temporal
    rm apply_improvements.py
}

# Aplicar mejoras a cada servicio
echo "📋 Aplicando mejoras servicio por servicio..."

# 1. Notification System
apply_config_improvements \
    "Notification System" \
    "design/systems/notification/notification-models.dsl" \
    "habilitar/deshabilitar canales por país, límites de rate por tenant, templates personalizadas"

# 2. Track & Trace
apply_config_improvements \
    "Track & Trace" \
    "design/systems/track-and-trace/track-and-trace-models.dsl" \
    "habilitar tipos de eventos por país, configurar enriquecimiento por tenant, auditoría avanzada"

# 3. Identity System
if [ -f "design/systems/identity/identity-models.dsl" ]; then
    apply_config_improvements \
        "Identity System" \
        "design/systems/identity/identity-models.dsl" \
        "configurar proveedores OAuth por país, políticas de autenticación por tenant, timeouts personalizados"
fi

# 4. API Gateway
if [ -f "design/systems/api-gateway/api-gateway-models.dsl" ]; then
    apply_config_improvements \
        "API Gateway" \
        "design/systems/api-gateway/api-gateway-models.dsl" \
        "rate limiting por país, circuit breaker personalizado por tenant, routing dinámico"
fi

# Crear configuraciones específicas por servicio
echo "📁 Creando configuraciones específicas por servicio..."

# Terraform para feature flags de todos los servicios
cat > infrastructure/terraform/feature-flags/all-services.tf << 'EOF'
# Feature Flags para Notification System
resource "aws_ssm_parameter" "notification_email_peru" {
  name  = "/corporativo/feature-flags/peru/notification-email"
  type  = "String"
  value = "enabled"
  description = "Enable/disable email notifications for Peru"
}

resource "aws_ssm_parameter" "notification_sms_ecuador" {
  name  = "/corporativo/feature-flags/ecuador/notification-sms"
  type  = "String"
  value = "enabled"
  description = "Enable/disable SMS notifications for Ecuador"
}

resource "aws_ssm_parameter" "notification_whatsapp_colombia" {
  name  = "/corporativo/feature-flags/colombia/notification-whatsapp"
  type  = "String"
  value = "enabled"
  description = "Enable/disable WhatsApp notifications for Colombia"
}

resource "aws_ssm_parameter" "notification_push_mexico" {
  name  = "/corporativo/feature-flags/mexico/notification-push"
  type  = "String"
  value = "enabled"
  description = "Enable/disable Push notifications for Mexico"
}

# Feature Flags para Track & Trace
resource "aws_ssm_parameter" "track_trace_enrichment_peru" {
  name  = "/corporativo/feature-flags/peru/track-trace-enrichment"
  type  = "String"
  value = "enabled"
  description = "Enable/disable event enrichment for Peru"
}

resource "aws_ssm_parameter" "track_trace_realtime_ecuador" {
  name  = "/corporativo/feature-flags/ecuador/track-trace-realtime"
  type  = "String"
  value = "enabled"
  description = "Enable/disable real-time tracking for Ecuador"
}

# Feature Flags para Identity System
resource "aws_ssm_parameter" "identity_oauth_colombia" {
  name  = "/corporativo/feature-flags/colombia/identity-oauth-providers"
  type  = "String"
  value = "enabled"
  description = "Enable/disable additional OAuth providers for Colombia"
}

# Feature Flags para API Gateway
resource "aws_ssm_parameter" "gateway_rate_limiting_global" {
  name  = "/corporativo/feature-flags/global/gateway-advanced-rate-limiting"
  type  = "String"
  value = "enabled"
  description = "Enable/disable advanced rate limiting features"
}

# Configuraciones específicas por país
resource "aws_ssm_parameter" "notification_rate_limit_peru" {
  name  = "/corporativo/config/peru/notification-rate-limit"
  type  = "String"
  value = "1000"
  description = "Notification rate limit per minute for Peru"
}

resource "aws_ssm_parameter" "track_trace_batch_size_ecuador" {
  name  = "/corporativo/config/ecuador/track-trace-batch-size"
  type  = "String"
  value = "500"
  description = "Event processing batch size for Ecuador"
}

# SQS Queues para eventos de configuración por servicio
resource "aws_sqs_queue" "notification_config_events" {
  name                       = "notification-config-events-${var.environment}"
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 1209600
  receive_wait_time_seconds  = 20

  tags = {
    Environment = var.environment
    Service     = "notification"
    Purpose     = "configuration-events"
  }
}

resource "aws_sqs_queue" "track_trace_config_events" {
  name                       = "track-trace-config-events-${var.environment}"
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 1209600
  receive_wait_time_seconds  = 20

  tags = {
    Environment = var.environment
    Service     = "track-trace"
    Purpose     = "configuration-events"
  }
}
EOF

# Crear guía de implementación específica para cada servicio
echo "📚 Creando guías de implementación por servicio..."

cat > docs/implementation-guides/notification-config-improvements.md << 'EOF'
# 🔔 Notification System - Mejoras de Configuración

## Feature Flags Específicos

### Por Canal y País
```bash
# Email por país
/corporativo/feature-flags/peru/notification-email = "enabled"
/corporativo/feature-flags/ecuador/notification-email = "enabled"
/corporativo/feature-flags/colombia/notification-email = "enabled"
/corporativo/feature-flags/mexico/notification-email = "enabled"

# SMS por país
/corporativo/feature-flags/peru/notification-sms = "disabled"
/corporativo/feature-flags/ecuador/notification-sms = "enabled"
/corporativo/feature-flags/colombia/notification-sms = "enabled"
/corporativo/feature-flags/mexico/notification-sms = "enabled"

# WhatsApp por país
/corporativo/feature-flags/peru/notification-whatsapp = "beta"
/corporativo/feature-flags/ecuador/notification-whatsapp = "enabled"
/corporativo/feature-flags/colombia/notification-whatsapp = "enabled"
/corporativo/feature-flags/mexico/notification-whatsapp = "enabled"

# Push por país
/corporativo/feature-flags/peru/notification-push = "enabled"
/corporativo/feature-flags/ecuador/notification-push = "enabled"
/corporativo/feature-flags/colombia/notification-push = "enabled"
/corporativo/feature-flags/mexico/notification-push = "enabled"
```

### Configuraciones Dinámicas
```bash
# Rate limiting por país
/corporativo/config/peru/notification-rate-limit = "1000"
/corporativo/config/ecuador/notification-rate-limit = "800"
/corporativo/config/colombia/notification-rate-limit = "1200"
/corporativo/config/mexico/notification-rate-limit = "1500"

# Batch sizes por canal
/corporativo/config/global/email-batch-size = "100"
/corporativo/config/global/sms-batch-size = "50"
/corporativo/config/global/whatsapp-batch-size = "200"
/corporativo/config/global/push-batch-size = "500"
```

## Implementación en C#

```csharp
// En NotificationService
public class NotificationService : INotificationService
{
    private readonly IFeatureFlagService _featureFlags;

    public async Task<bool> ProcessNotificationAsync(NotificationRequest request)
    {
        // Verificar si el canal está habilitado para este país
        var channelEnabled = await _featureFlags.IsEnabledAsync(
            $"notification-{request.Channel.ToLower()}",
            request.TenantId,
            request.Country
        );

        if (!channelEnabled)
        {
            _logger.LogInformation("Channel {Channel} disabled for {Country}",
                request.Channel, request.Country);
            return false;
        }

        // Obtener configuración específica
        var rateLimit = await _featureFlags.GetFeatureConfigAsync<int>(
            "notification-rate-limit",
            request.TenantId,
            request.Country,
            defaultValue: 1000
        );

        // Procesar con configuración dinámica...
        return await ProcessWithRateLimitAsync(request, rateLimit);
    }
}
```

## Casos de Uso Específicos

### 1. Rollout Gradual de WhatsApp
- Perú: `beta` (solo algunos tenants)
- Ecuador: `enabled` (todos los tenants)
- Colombia: `enabled`
- México: `enabled`

### 2. Rate Limiting por País
- Perú: 1000 msg/min (regulaciones estrictas)
- Ecuador: 800 msg/min
- Colombia: 1200 msg/min
- México: 1500 msg/min (mayor volumen)

### 3. Configuración de Templates
- Templates específicas por país y cultura
- Feature flags para A/B testing de templates
- Cache inteligente para templates frecuentes
EOF

cat > docs/implementation-guides/track-trace-config-improvements.md << 'EOF'
# 📍 Track & Trace - Mejoras de Configuración

## Feature Flags Específicos

### Por Funcionalidad y País
```bash
# Event enrichment por país
/corporativo/feature-flags/peru/track-trace-enrichment = "enabled"
/corporativo/feature-flags/ecuador/track-trace-enrichment = "enabled"
/corporativo/feature-flags/colombia/track-trace-enrichment = "beta"
/corporativo/feature-flags/mexico/track-trace-enrichment = "enabled"

# Real-time tracking
/corporativo/feature-flags/peru/track-trace-realtime = "enabled"
/corporativo/feature-flags/ecuador/track-trace-realtime = "disabled"
/corporativo/feature-flags/colombia/track-trace-realtime = "enabled"
/corporativo/feature-flags/mexico/track-trace-realtime = "enabled"

# Advanced analytics
/corporativo/feature-flags/global/track-trace-analytics = "beta"
```

### Configuraciones Dinámicas
```bash
# Batch sizes por país
/corporativo/config/peru/track-trace-batch-size = "100"
/corporativo/config/ecuador/track-trace-batch-size = "500"
/corporativo/config/colombia/track-trace-batch-size = "300"
/corporativo/config/mexico/track-trace-batch-size = "200"

# Retention policies
/corporativo/config/peru/track-trace-retention-days = "90"
/corporativo/config/ecuador/track-trace-retention-days = "120"
/corporativo/config/colombia/track-trace-retention-days = "60"
/corporativo/config/mexico/track-trace-retention-days = "180"
```

## Implementación en C#

```csharp
// En EventProcessor
public class EventProcessor : IEventProcessor
{
    private readonly IFeatureFlagService _featureFlags;

    public async Task<bool> ProcessEventAsync(TrackingEvent eventData)
    {
        // Verificar si enrichment está habilitado
        var enrichmentEnabled = await _featureFlags.IsEnabledAsync(
            "track-trace-enrichment",
            eventData.TenantId,
            eventData.Country
        );

        if (enrichmentEnabled)
        {
            await EnrichEventAsync(eventData);
        }

        // Verificar si real-time está habilitado
        var realtimeEnabled = await _featureFlags.IsEnabledAsync(
            "track-trace-realtime",
            eventData.TenantId,
            eventData.Country
        );

        if (realtimeEnabled)
        {
            await PublishRealtimeEventAsync(eventData);
        }

        return await StoreEventAsync(eventData);
    }
}
```

## Casos de Uso Específicos

### 1. Enriquecimiento de Eventos
- Control granular por país y tenant
- Diferentes niveles de enriquecimiento
- Optimización de recursos por región

### 2. Políticas de Retención
- Cumplimiento de regulaciones locales
- Optimización de storage por país
- Configuración dinámica sin restart

### 3. Real-time vs Batch Processing
- Real-time para países con alta demanda
- Batch processing para optimizar costos
- Configuración híbrida por tenant
EOF

# Crear docker-compose actualizado para desarrollo local
echo "🐳 Actualizando docker-compose para desarrollo multi-servicio..."

cat > docker-compose.dev-all-services.yml << 'EOF'
version: '3.8'

services:
  # Redis compartido para cache de configuraciones
  redis-config:
    image: redis:7-alpine
    ports:
      - "6380:6379"
    command: redis-server --maxmemory 512mb --maxmemory-policy allkeys-lru
    volumes:
      - redis-config-data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3

  # LocalStack para AWS services
  localstack-all:
    image: localstack/localstack:latest
    ports:
      - "4566:4566"
    environment:
      - SERVICES=ssm,sqs,sns,s3
      - DEBUG=1
      - DATA_DIR=/tmp/localstack/data
    volumes:
      - "/tmp/localstack:/tmp/localstack"
      - "/var/run/docker.sock:/var/run/docker.sock"

  # Setup de parámetros para todos los servicios
  setup-all-configs:
    image: amazon/aws-cli:latest
    depends_on:
      - localstack-all
    environment:
      - AWS_ACCESS_KEY_ID=localstack
      - AWS_SECRET_ACCESS_KEY=localstack
      - AWS_DEFAULT_REGION=us-east-1
    entrypoint: /bin/sh
    command: -c "
      sleep 15 &&

      # Notification System feature flags
      aws --endpoint-url=http://localstack-all:4566 ssm put-parameter --name '/corporativo/feature-flags/peru/notification-email' --value 'enabled' --type String &&
      aws --endpoint-url=http://localstack-all:4566 ssm put-parameter --name '/corporativo/feature-flags/peru/notification-sms' --value 'disabled' --type String &&
      aws --endpoint-url=http://localstack-all:4566 ssm put-parameter --name '/corporativo/feature-flags/peru/notification-whatsapp' --value 'beta' --type String &&
      aws --endpoint-url=http://localstack-all:4566 ssm put-parameter --name '/corporativo/feature-flags/peru/notification-push' --value 'enabled' --type String &&

      # Track & Trace feature flags
      aws --endpoint-url=http://localstack-all:4566 ssm put-parameter --name '/corporativo/feature-flags/peru/track-trace-enrichment' --value 'enabled' --type String &&
      aws --endpoint-url=http://localstack-all:4566 ssm put-parameter --name '/corporativo/feature-flags/peru/track-trace-realtime' --value 'enabled' --type String &&

      # SITA Messaging feature flags
      aws --endpoint-url=http://localstack-all:4566 ssm put-parameter --name '/corporativo/feature-flags/peru/sita-messaging' --value 'enabled' --type String &&

      # Configuraciones por país
      aws --endpoint-url=http://localstack-all:4566 ssm put-parameter --name '/corporativo/config/peru/notification-rate-limit' --value '1000' --type String &&
      aws --endpoint-url=http://localstack-all:4566 ssm put-parameter --name '/corporativo/config/peru/track-trace-batch-size' --value '100' --type String &&
      aws --endpoint-url=http://localstack-all:4566 ssm put-parameter --name '/corporativo/config/peru/sita-batch-size' --value '100' --type String &&

      # Ecuador
      aws --endpoint-url=http://localstack-all:4566 ssm put-parameter --name '/corporativo/config/ecuador/notification-rate-limit' --value '800' --type String &&
      aws --endpoint-url=http://localstack-all:4566 ssm put-parameter --name '/corporativo/config/ecuador/track-trace-batch-size' --value '500' --type String &&

      echo 'All services configuration setup completed'
    "

volumes:
  redis-config-data:

networks:
  default:
    name: corporativo-network
EOF

echo "✅ ¡Mejoras aplicadas a todos los servicios!"
echo ""
echo "📊 Resumen de mejoras implementadas:"
echo "🔔 Notification System: Feature flags por canal y país, cache inteligente"
echo "📍 Track & Trace: Feature flags por funcionalidad, configuración dinámica"
echo "🚀 SITA Messaging: Ya tenía las mejoras (modelo de referencia)"
echo "🔐 Identity System: Feature flags para proveedores OAuth (si existe)"
echo "🌐 API Gateway: Feature flags para rate limiting (si existe)"
echo ""
echo "🎯 Beneficios obtenidos:"
echo "- ✅ Configuración unificada en todos los servicios"
echo "- ✅ Feature flags por país y tenant en cada servicio"
echo "- ✅ Cache inteligente con TTL diferenciado"
echo "- ✅ Métricas de configuración consistentes"
echo "- ✅ Preparado para crecimiento multi-país"
echo ""
echo "📝 Próximos pasos:"
echo "1. Revisar los archivos modificados"
echo "2. Ejecutar: docker-compose -f docker-compose.dev-all-services.yml up -d"
echo "3. Implementar los Configuration Managers mejorados en cada servicio"
echo "4. Ejecutar tests de integración"
echo "5. Desplegar gradualmente por servicio"
echo ""
echo "🚀 ¡Tu arquitectura multi-tenant está ahora optimizada para todos los servicios!"
