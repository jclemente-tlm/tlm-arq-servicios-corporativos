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
            description "Middleware unificado de autenticación y autorización con soporte para JWT, OAuth2, RBAC y validación de certificados digitales."
            tags "Middleware" "Security" "001 - Fase 1"
        }

        tenantResolutionMiddleware = component "Tenant Resolution Middleware" {
            technology "ASP.NET Core Middleware"
            description "Middleware que identifica y resuelve contexto de tenant desde headers, subdominios o tokens."
            tags "Middleware" "001 - Fase 1"
        }

        rateLimitingMiddleware = component "Rate Limiting Middleware" {
            technology "ASP.NET Core Middleware"
            description "Middleware de limitación de velocidad con políticas personalizables por tenant y endpoint."
            tags "Middleware" "001 - Fase 1"
        }

        // Componente de resiliencia unificado
        resilienceHandler = component "Resilience Handler" {
            technology "Polly"
            description "Gestiona patrones de resiliencia unificados: Circuit Breaker, Retry con backoff exponencial, Timeout y Bulkhead para prevenir cascadas de fallos."
            tags "Middleware" "Resilience" "001 - Fase 1"
        }

        // Componente de procesamiento de datos unificado
        dataProcessingMiddleware = component "Data Processing Middleware" {
            technology "ASP.NET Core Middleware, JSON Schema"
            description "Middleware unificado para validación de esquemas OpenAPI, transformación de requests/responses, mapeo de headers y versionado API."
            tags "Middleware" "Processing" "001 - Fase 1"
        }

        // Cache opcional para fase 2
        cacheMiddleware = component "Cache Middleware" {
            technology "Redis, ASP.NET Core Response Caching"
            description "Cache distribuido para respuestas API con invalidación inteligente por tenant y TTL configurable."
            tags "Performance" "002 - Fase 2"
        }

        // Componentes de observabilidad
        healthCheck = component "Health Check" {
            technology "ASP.NET Core Health Checks"
            description "Monitorea salud del gateway: conectividad a servicios downstream, estado de circuit breakers y performance de endpoints"
            tags "Observability" "001 - Fase 1"
        }

        metricsCollector = component "Metrics Collector" {
            technology "Prometheus.NET"
            description "Recolecta métricas del gateway: throughput, latencia por endpoint, tasa de errores, circuit breaker status y rate limiting"
            tags "Observability" "001 - Fase 1"
        }

        structuredLogger = component "Structured Logger" {
            technology "Serilog"
            description "Logging estructurado de requests con correlationId, tenant context, métricas de performance y trazabilidad completa"
            tags "Observability" "001 - Fase 1"
        }

        // Configuración dinámica
        dynamicConfigProcessor = component "Dynamic Configuration Processor" {
            technology "C#, .NET 8, FluentValidation"
            description "Detecta cambios de configuración con polling inteligente, valida nuevas configuraciones y actualiza cache dinámicamente sin reinicio del Gateway."
            tags "Configuration Events" "Feature Flags" "001 - Fase 1"
        }
    }

    // ========================================
    // PIPELINE DE MIDDLEWARE OPTIMIZADO
    // ========================================

    // Seguridad y contexto
    reverseProxyGateway.securityMiddleware -> reverseProxyGateway.tenantResolutionMiddleware "Pipeline: Security → Tenant" "" "001 - Fase 1"

    // Rate limiting y procesamiento
    reverseProxyGateway.tenantResolutionMiddleware -> reverseProxyGateway.rateLimitingMiddleware "Pipeline: Tenant → Rate Limit" "" "001 - Fase 1"
    reverseProxyGateway.rateLimitingMiddleware -> reverseProxyGateway.dataProcessingMiddleware "Pipeline: Rate Limit → Data Processing" "" "001 - Fase 1"

    // Resiliencia y downstream
    reverseProxyGateway.dataProcessingMiddleware -> reverseProxyGateway.resilienceHandler "Pipeline: Data Processing → Resilience" "" "001 - Fase 1"

    // Cache opcional (Fase 2) - se insertaría entre rate limiting y data processing
    // reverseProxyGateway.rateLimitingMiddleware -> reverseProxyGateway.cacheMiddleware "Pipeline: Rate Limit → Cache" "" "002 - Fase 2"
    // reverseProxyGateway.cacheMiddleware -> reverseProxyGateway.dataProcessingMiddleware "Pipeline: Cache → Data Processing" "" "002 - Fase 2"

    // ========================================
    // RELACIONES INTERNAS - OBSERVABILIDAD
    // ========================================

    // Observabilidad cross-cutting
    reverseProxyGateway.structuredLogger -> reverseProxyGateway.metricsCollector "Correlaciona logs con métricas" "In-Memory" "001 - Fase 1"
    reverseProxyGateway.healthCheck -> reverseProxyGateway.resilienceHandler "Monitorea estado de patrones de resiliencia" "In-Memory" "001 - Fase 1"

    // ========================================
    // RELACIONES EXTERNAS - ACTORES
    // ========================================

    // Administradores y aplicaciones entran por seguridad unificada
    admin -> reverseProxyGateway.securityMiddleware "Gestiona configuraciones de servicios" "HTTPS" "001 - Fase 1"
    appPeru -> reverseProxyGateway.securityMiddleware "Realiza llamadas API tenant Peru" "HTTPS" "001 - Fase 1"
    appEcuador -> reverseProxyGateway.securityMiddleware "Realiza llamadas API tenant Ecuador" "HTTPS" "001 - Fase 1"
    appColombia -> reverseProxyGateway.securityMiddleware "Realiza llamadas API tenant Colombia" "HTTPS" "001 - Fase 1"
    appMexico -> reverseProxyGateway.securityMiddleware "Realiza llamadas API tenant Mexico" "HTTPS" "001 - Fase 1"

    // ========================================
    // RELACIONES EXTERNAS - SISTEMAS DOWNSTREAM
    // ========================================

    // Enrutamiento a servicios corporativos
    reverseProxyGateway.resilienceHandler -> notification.api "Enruta requests de notificaciones" "HTTPS" "001 - Fase 1"
    reverseProxyGateway.resilienceHandler -> trackAndTrace.trackingAPI "Enruta requests de tracking" "HTTPS" "001 - Fase 1"
    reverseProxyGateway.resilienceHandler -> sitaMessaging.eventProcessor "Enruta requests de mensajería SITA" "HTTPS" "001 - Fase 1"

    // Configuración dinámica
    configPlatform.configService -> reverseProxyGateway "Configuración dinámica de rutas y políticas" "HTTPS" "001 - Fase 1"
    configPlatform.configService -> reverseProxyGateway.rateLimitingMiddleware "Configuración de límites por tenant" "HTTPS" "001 - Fase 1"

    // Dynamic Configuration Relations
    reverseProxyGateway.dynamicConfigProcessor -> configPlatform.configService "Consulta cambios de configuración con polling" "HTTPS/REST" "001 - Fase 1"
    reverseProxyGateway.dynamicConfigProcessor -> reverseProxyGateway.securityMiddleware "Invalida cache específico al detectar cambios" "In-Memory" "001 - Fase 1"
    // configPlatform.configService -> reverseProxyGateway.cacheMiddleware "Configuración de TTL y políticas de cache" "HTTPS" "002 - Fase 2"
}