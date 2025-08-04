apiGateway = softwareSystem "Enterprise API Gateway" {
    description "Gateway corporativo de alta disponibilidad con autenticación, autorización y políticas de resiliencia para microservicios."
    tags "API Gateway" "001 - Fase 1"

    reverseProxyGateway = application "Reverse Proxy Gateway" {
        technology "YARP"
        description "Proxy inverso inteligente con balanceeo de carga y enrutamiento dinámico a microservicios corporativos."
        tags "API Gateway" "001 - Fase 1"

        // Componente de seguridad unificado
        securityMiddleware = component "Security Middleware" {
            technology "ASP.NET Core Middleware"
            description "Autenticación y autorización con JWT/OAuth2"
            tags "Middleware" "Security" "001 - Fase 1"
        }

        tenantResolutionMiddleware = component "Tenant Resolution Middleware" {
            technology "ASP.NET Core Middleware"
            description "Identifica y resuelve contexto de tenant"
            tags "Middleware" "001 - Fase 1"
        }

        rateLimitingMiddleware = component "Rate Limiting Middleware" {
            technology "ASP.NET Core Middleware"
            description "Limitación de velocidad con políticas por tenant"
            tags "Middleware" "001 - Fase 1"
        }

        // Componente de resiliencia unificado
        resilienceHandler = component "Resilience Handler" {
            technology "Polly"
            description "Circuit breakers, retries y timeouts"
            tags "Middleware" "Resilience" "001 - Fase 1"
        }

        // Componente de procesamiento de datos unificado
        dataProcessingMiddleware = component "Data Processing Middleware" {
            technology "ASP.NET Core Middleware, JSON Schema"
            description "Validación de esquemas y transformación de datos"
            tags "Middleware" "Processing" "001 - Fase 1"
        }

        // Cache opcional para fase 2
        cacheMiddleware = component "Cache Middleware" {
            technology "Redis, ASP.NET Core Response Caching"
            description "Cache distribuido con invalidación inteligente"
            tags "Performance" "002 - Fase 2"
        }

        // Componentes de observabilidad
        healthCheck = component "Health Check" {
            technology "ASP.NET Core Health Checks"
            description "Monitoreo de salud de servicios downstream"
            tags "Observability" "001 - Fase 1"
        }

        metricsCollector = component "Metrics Collector" {
            technology "Prometheus.NET"
            description "Recolección de métricas de performance y uso"
            tags "Observability" "001 - Fase 1"
        }

        structuredLogger = component "Structured Logger" {
            technology "Serilog"
            description "Logging estructurado con correlación de requests"
            tags "Observability" "001 - Fase 1"
        }

        // Configuración dinámica
        dynamicConfigProcessor = component "Dynamic Configuration Processor" {
            technology "C#, FluentValidation, HttpClient"
            description "Polling de configuración con hot reload"
            tags "Configuration Events" "Feature Flags" "001 - Fase 1"
        }
    }

    // ========================================
    // PIPELINE DE MIDDLEWARE OPTIMIZADO
    // ========================================

    // Seguridad y contexto
    reverseProxyGateway.securityMiddleware -> reverseProxyGateway.tenantResolutionMiddleware "Pasa a resolución tenant" "Pipeline" "001 - Fase 1"

    // Rate limiting y procesamiento
    reverseProxyGateway.tenantResolutionMiddleware -> reverseProxyGateway.rateLimitingMiddleware "Pasa a rate limiting" "Pipeline" "001 - Fase 1"
    reverseProxyGateway.rateLimitingMiddleware -> reverseProxyGateway.dataProcessingMiddleware "Pasa a procesamiento" "Pipeline" "001 - Fase 1"

    // Resiliencia y downstream
    reverseProxyGateway.dataProcessingMiddleware -> reverseProxyGateway.resilienceHandler "Pasa a resiliencia" "Pipeline" "001 - Fase 1"

    // Cache opcional (Fase 2) - se insertaría entre rate limiting y data processing
    // reverseProxyGateway.rateLimitingMiddleware -> reverseProxyGateway.cacheMiddleware "Pipeline: Rate Limit → Cache" "" "002 - Fase 2"
    // reverseProxyGateway.cacheMiddleware -> reverseProxyGateway.dataProcessingMiddleware "Pipeline: Cache → Data Processing" "" "002 - Fase 2"

    // ========================================
    // RELACIONES INTERNAS - OBSERVABILIDAD
    // ========================================

    // Observabilidad cross-cutting
    reverseProxyGateway.structuredLogger -> reverseProxyGateway.metricsCollector "Correlaciona logs y métricas" "In-Memory" "001 - Fase 1"
    reverseProxyGateway.healthCheck -> reverseProxyGateway.resilienceHandler "Evalúa estado resiliencia" "In-Memory" "001 - Fase 1"

    // Observabilidad de middleware crítico
    reverseProxyGateway.securityMiddleware -> reverseProxyGateway.structuredLogger "Registra eventos auth" "In-Memory" "001 - Fase 1"
    reverseProxyGateway.tenantResolutionMiddleware -> reverseProxyGateway.structuredLogger "Registra resolución tenant" "In-Memory" "001 - Fase 1"
    reverseProxyGateway.rateLimitingMiddleware -> reverseProxyGateway.metricsCollector "Reporta métricas rate limit" "In-Memory" "001 - Fase 1"
    reverseProxyGateway.resilienceHandler -> reverseProxyGateway.metricsCollector "Reporta estado breakers" "In-Memory" "001 - Fase 1"

    // ========================================
    // RELACIONES EXTERNAS - ACTORES
    // ========================================

    // Administradores y aplicaciones entran por seguridad unificada
    // admin -> reverseProxyGateway.securityMiddleware "Gestiona configuraciones de servicios" "HTTPS" "001 - Fase 1"
    appPeru -> reverseProxyGateway.securityMiddleware "Realiza llamadas API tenant Peru" "HTTPS" "001 - Fase 1"
    appEcuador -> reverseProxyGateway.securityMiddleware "Realiza llamadas API tenant Ecuador" "HTTPS" "001 - Fase 1"
    appColombia -> reverseProxyGateway.securityMiddleware "Realiza llamadas API tenant Colombia" "HTTPS" "001 - Fase 1"
    appMexico -> reverseProxyGateway.securityMiddleware "Realiza llamadas API tenant Mexico" "HTTPS" "001 - Fase 1"

    // ========================================
    // RELACIONES EXTERNAS - SISTEMAS DOWNSTREAM
    // ========================================

    // Enrutamiento a servicios corporativos
    reverseProxyGateway.resilienceHandler -> notification.api "Enruta a notificaciones" "HTTPS" "001 - Fase 1"
    reverseProxyGateway.resilienceHandler -> trackAndTrace.trackingAPI "Enruta a tracking" "HTTPS" "001 - Fase 1"

    // Health checks de servicios downstream
    reverseProxyGateway.healthCheck -> notification.api "Verifica disponibilidad" "HTTPS" "001 - Fase 1"
    reverseProxyGateway.healthCheck -> trackAndTrace.trackingAPI "Verifica disponibilidad" "HTTPS" "001 - Fase 1"

    // ========================================
    // RELACIONES DE CONFIGURACIÓN DINÁMICA
    // ========================================

    // Configuración dinámica vía polling (patrón correcto)
    reverseProxyGateway.dynamicConfigProcessor -> configPlatform.configService "Consulta configuración" "HTTPS/REST" "001 - Fase 1"

    // Invalidación selectiva de cache tras cambios de configuración
    reverseProxyGateway.dynamicConfigProcessor -> reverseProxyGateway.securityMiddleware "Invalida cache seguridad" "In-Memory" "001 - Fase 1"
    reverseProxyGateway.dynamicConfigProcessor -> reverseProxyGateway.rateLimitingMiddleware "Invalida cache rate limits" "In-Memory" "001 - Fase 1"
    reverseProxyGateway.dynamicConfigProcessor -> reverseProxyGateway.dataProcessingMiddleware "Invalida cache esquemas" "In-Memory" "001 - Fase 1"

    // Configuración opcional para Fase 2
    // reverseProxyGateway.dynamicConfigProcessor -> reverseProxyGateway.cacheMiddleware "Invalida políticas de TTL de cache al detectar cambios" "In-Memory" "002 - Fase 2"
}