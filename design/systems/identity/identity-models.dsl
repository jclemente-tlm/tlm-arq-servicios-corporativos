identity = softwareSystem "Identity System" {
    description "Servicio centralizado de autenticación y autorización mediante tokens JWT."
    tags "Identity" "001 - Fase 1"

    service = application "Identity Service" {
        technology "Keycloak"
        description "Gestiona autenticación, autorización y emisión de tokens JWT"
        tags "Keycloak" "001 - Fase 1"

        // Componentes de Observabilidad para Keycloak
        healthCheck = component "Health Check" {
            technology "Keycloak Health Check"
            description "Expone endpoints /health para monitoring de Keycloak."
            tags "Observability" "001 - Fase 1"
        }

        metricsCollector = component "Metrics Collector" {
            technology "Prometheus Client"
            description "Recolecta métricas: logins/sec, token validation rate, failed authentications, config cache hit ratio, feature flag usage."
            tags "Observability" "001 - Fase 1"
        }

        logger = component "Structured Logger" {
            technology "Serilog"
            description "Logging estructurado de eventos de autenticación y autorización."
            tags "Observability" "001 - Fase 1"
        }

        configManager = component "Configuration Manager" {
            technology "C# .NET 8"
            description "Lee configuraciones y secretos desde repositorios y plataforma de configuración. Incluye cache inteligente con TTL diferenciado y feature flags por país/tenant."
            tags "Configuración" "001 - Fase 1"
        }

        configCache = component "Configuration Cache" {
            technology "Redis"
            description "Cache distribuido para configuraciones de Identity System con TTL optimizado por tipo de configuración."
            tags "Cache" "001 - Fase 1"
        }

        featureFlagService = component "Feature Flag Service" {
            technology "C# .NET 8"
            description "Gestiona feature flags por país y tenant para Identity System: configurar proveedores OAuth por país, políticas de autenticación por tenant, timeouts personalizados."
            tags "Feature Flags" "001 - Fase 1"
        }
    }

    db = store "Identity DB" {
        technology "PostgreSQL"
        description "Almacena configuraciones, credenciales, y roles"
        tags "Database" "PostgreSQL" "001 - Fase 1"
    }

    configEventQueue = store "Configuration Event Queue" {
        description "Cola SQS para eventos de cambios de configuración y feature flags de Identity System"
        technology "AWS SQS"
        tags "Message Bus" "SQS" "Configuration" "001 - Fase 1"
    }

    // ========================================
    // RELACIONES INTERNAS DEL SISTEMA
    // ========================================

    // Relaciones básicas del servicio
    service -> db "Lee y escribe datos de usuarios y configuración" "PostgreSQL" "001 - Fase 1"

    // Relaciones de componentes de configuración
    service.configManager -> service.configCache "consulta cache" "" "001 - Fase 1"
    service.featureFlagService -> service.configCache "usa cache para flags" "" "001 - Fase 1"

    // Relaciones de observabilidad
    service.configManager -> service.metricsCollector "envía métricas de config" "" "001 - Fase 1"
    service.featureFlagService -> service.metricsCollector "envía métricas de feature flags" "" "001 - Fase 1"

    // ========================================
    // RELACIONES EXTERNAS - ACTORES
    // ========================================

    // Administrador
    admin -> service "Administra clientes y configuración" "HTTPS vía API Gateway" "001 - Fase 1"

    // Aplicaciones por país
    appPeru -> service "Solicita autenticación" "HTTPS vía API Gateway" "001 - Fase 1"
    appEcuador -> service "Solicita autenticación" "HTTPS vía API Gateway" "001 - Fase 1"
    appColombia -> service "Solicita autenticación" "HTTPS vía API Gateway" "001 - Fase 1"
    appMexico -> service "Solicita autenticación" "HTTPS vía API Gateway" "001 - Fase 1"

    // ========================================
    // RELACIONES EXTERNAS - SISTEMAS
    // ========================================

    // Integración con API Gateway
    apiGateway.yarp.authorization -> service "Redirige solicitudes de autorización" "HTTPS" "001 - Fase 1"

    // Integración con plataforma de configuración
    service.configManager -> configPlatform.configService "Lee configuraciones y secretos" "HTTPS" "001 - Fase 1"
    service.configManager -> configPlatform.secretsService "Lee secretos y credenciales" "HTTPS" "001 - Fase 1"
}