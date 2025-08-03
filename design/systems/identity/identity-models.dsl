identity = softwareSystem "Identity & Authentication System" {
    description "Servicio centralizado de autenticación y autorización empresarial con soporte para JWT y múltiples proveedores OAuth."
    tags "Identity" "001 - Fase 1"

    identityService = application "Identity Service" {
        technology "Keycloak"
        description "Plataforma de gestión de identidad y acceso con autenticación multifactor y federación de identidades."
        tags "Keycloak" "001 - Fase 1"

        // Componentes de Observabilidad para Keycloak
        healthCheck = component "Health Check" {
            technology "Keycloak Health Check"
            description "Expone endpoints de salud con verificación de conectividad a base de datos y proveedores externos."
            tags "Observability" "001 - Fase 1"
        }

        metricsCollector = component "Metrics Collector" {
            technology "Prometheus Client"
            description "Recolecta métricas de identidad: logins/sec, tasa de validación de tokens, autenticaciones fallidas por tenant."
            tags "Observability" "001 - Fase 1"
        }

        logger = component "Structured Logger" {
            technology "Serilog"
            description "Logging estructurado de eventos de seguridad, autenticación y autorización con correlationId."
            tags "Observability" "001 - Fase 1"
        }

        identityConfigurationManager = component "Identity Configuration Manager" {
            technology "C# .NET 8"
            description "Gestiona configuraciones dinámicas de seguridad, proveedores OAuth y políticas por tenant."
            tags "Configuración" "001 - Fase 1"
        }

        identityConfigurationCache = component "Identity Configuration Cache" {
            technology "Redis"
            description "Cache distribuido para configuraciones de seguridad con invalidación selectiva y TTL por tipo de política."
            tags "Cache" "001 - Fase 1"
        }

        securityFeatureFlagService = component "Security Feature Flag Service" {
            technology "C# .NET 8"
            description "Gestiona feature flags de seguridad: proveedores OAuth por país, políticas MFA por tenant, timeouts personalizados."
            tags "Feature Flags" "001 - Fase 1"
        }
    }

    identityDatabase = store "Identity Database" {
        technology "PostgreSQL"
        description "Base de datos segura para usuarios, roles, permisos y configuraciones de autenticación por tenant."
        tags "Database" "PostgreSQL" "001 - Fase 1"
    }

    identityConfigurationEventQueue = store "Identity Configuration Event Queue" {
        description "Cola para eventos de cambios de configuración de seguridad y actualizaciones de feature flags."
        technology "AWS SQS"
        tags "Message Bus" "SQS" "Configuration" "001 - Fase 1"
    }

    // ========================================
    // RELACIONES INTERNAS DEL SISTEMA
    // ========================================

    // Relaciones básicas del servicio
    identityService -> identityDatabase "Gestiona datos de usuarios, roles y configuración de seguridad" "PostgreSQL" "001 - Fase 1"

    // Relaciones de componentes de configuración
    identityService.identityConfigurationManager -> identityService.identityConfigurationCache "Consulta cache de configuraciones" "" "001 - Fase 1"
    identityService.securityFeatureFlagService -> identityService.identityConfigurationCache "Consulta feature flags desde cache" "" "001 - Fase 1"

    // Relaciones de observabilidad
    identityService.identityConfigurationManager -> identityService.metricsCollector "Envía métricas de configuración" "" "001 - Fase 1"
    identityService.securityFeatureFlagService -> identityService.metricsCollector "Envía métricas de feature flags de seguridad" "" "001 - Fase 1"

    // ========================================
    // RELACIONES EXTERNAS - ACTORES
    // ========================================

    // Administrador
    admin -> identityService "Administra usuarios, roles y configuraciones de seguridad" "HTTPS vía API Gateway" "001 - Fase 1"

    // Aplicaciones por país
    appPeru -> identityService "Solicita autenticación" "HTTPS vía API Gateway" "001 - Fase 1"
    appEcuador -> identityService "Solicita autenticación" "HTTPS vía API Gateway" "001 - Fase 1"
    appColombia -> identityService "Solicita autenticación" "HTTPS vía API Gateway" "001 - Fase 1"
    appMexico -> identityService "Solicita autenticación" "HTTPS vía API Gateway" "001 - Fase 1"

    // ========================================
    // RELACIONES EXTERNAS - SISTEMAS
    // ========================================

    // Integración con API Gateway
    apiGateway.reverseProxyGateway.authorizationMiddleware -> identityService "Redirige solicitudes de autorización" "HTTPS" "001 - Fase 1"

    // Integración con plataforma de configuración
    identityService.identityConfigurationManager -> configPlatform.configService "Lee configuraciones y secretos" "HTTPS" "001 - Fase 1"
    identityService.identityConfigurationManager -> configPlatform.secretsService "Lee secretos y credenciales" "HTTPS" "001 - Fase 1"
}