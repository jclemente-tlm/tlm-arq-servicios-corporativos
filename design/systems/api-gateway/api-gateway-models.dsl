apiGateway = softwareSystem "Enterprise API Gateway" {
    description "Gateway corporativo de alta disponibilidad con autenticación, autorización y políticas de resiliencia para microservicios."
    tags "API Gateway" "001 - Fase 1"

    reverseProxyGateway = application "Reverse Proxy Gateway" {
        technology "YARP"
        description "Proxy inverso inteligente con balanceeo de carga y enrutamiento dinámico a microservicios corporativos."
        tags "API Gateway" "001 - Fase 1"

        authenticationMiddleware = component "Authentication Middleware" {
            technology "ASP.NET Core Middleware"
            description "Middleware de autenticación con soporte para JWT, OAuth2 y validación de certificados digitales."
            tags "Middleware" "001 - Fase 1"
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

        // Componentes de resiliencia
        circuitBreakerHandler = component "Circuit Breaker Handler" {
            technology "Polly"
            description "Implementa patrón Circuit Breaker con métricas en tiempo real para prevenir cascadas de fallos."
            tags "Middleware" "Resilience" "001 - Fase 1"
        }

        retryPolicyHandler = component "Retry Policy Handler" {
            technology "Polly"
            description "Gestiona políticas de reintento inteligente con backoff exponencial y jitter configurable."
            tags "Middleware" "Resilience" "001 - Fase 1"
        }

        timeoutHandler = component "Timeout Handler" {
            technology "ASP.NET Core Middleware"
            description "Gestiona timeouts configurables por endpoint para evitar requests colgantes y optimizar recursos."
            tags "Middleware" "Resilience" "001 - Fase 1"
        }

        authorizationMiddleware = component "Authorization Middleware" {
            technology "ASP.NET Core Middleware"
            description "Middleware de autorización con RBAC y validación de permisos granulares por recurso."
            tags "Middleware" "001 - Fase 1"
        }

        // Componentes de transformación y validación
        transformationMiddleware = component "Transformation Middleware" {
            technology "ASP.NET Core Middleware"
            description "Transformación de requests/responses, mapeo de headers, versionado API y conversión de formatos."
            tags "Middleware" "001 - Fase 1"
        }

        schemaValidator = component "Schema Validator" {
            technology "JSON Schema, Swagger/OpenAPI"
            description "Validación automática de requests/responses contra especificaciones OpenAPI por endpoint."
            tags "Validation" "001 - Fase 1"
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
    }

    // ========================================
    // PIPELINE DE MIDDLEWARE SIMPLIFICADO
    // ========================================

    // Entrada: Autenticación y autorización
    reverseProxyGateway.authenticationMiddleware -> reverseProxyGateway.authorizationMiddleware "Pipeline: Auth → Authz" "" "001 - Fase 1"
    reverseProxyGateway.authorizationMiddleware -> reverseProxyGateway.tenantResolutionMiddleware "Pipeline: Authz → Tenant" "" "001 - Fase 1"

    // Procesamiento: Rate limiting y validación
    reverseProxyGateway.tenantResolutionMiddleware -> reverseProxyGateway.rateLimitingMiddleware "Pipeline: Tenant → Rate Limit" "" "001 - Fase 1"
    reverseProxyGateway.rateLimitingMiddleware -> reverseProxyGateway.schemaValidator "Pipeline: Rate Limit → Validation" "" "001 - Fase 1"

    // Transformación y resiliencia
    reverseProxyGateway.schemaValidator -> reverseProxyGateway.transformationMiddleware "Pipeline: Validation → Transform" "" "001 - Fase 1"
    reverseProxyGateway.transformationMiddleware -> reverseProxyGateway.circuitBreakerHandler "Pipeline: Transform → Circuit Breaker" "" "001 - Fase 1"
    reverseProxyGateway.circuitBreakerHandler -> reverseProxyGateway.retryPolicyHandler "Pipeline: Circuit Breaker → Retry" "" "001 - Fase 1"
    reverseProxyGateway.retryPolicyHandler -> reverseProxyGateway.timeoutHandler "Pipeline: Retry → Timeout" "" "001 - Fase 1"

    // Cache opcional (Fase 2) - se insertaría entre validation y transform
    // reverseProxyGateway.schemaValidator -> reverseProxyGateway.cacheMiddleware "Pipeline: Validation → Cache" "" "002 - Fase 2"
    // reverseProxyGateway.cacheMiddleware -> reverseProxyGateway.transformationMiddleware "Pipeline: Cache → Transform" "" "002 - Fase 2"

    // ========================================
    // RELACIONES INTERNAS - OBSERVABILIDAD
    // ========================================

    // Observabilidad cross-cutting
    reverseProxyGateway.structuredLogger -> reverseProxyGateway.metricsCollector "Correlaciona logs con métricas" "In-Memory" "001 - Fase 1"
    reverseProxyGateway.healthCheck -> reverseProxyGateway.circuitBreakerHandler "Monitorea estado de circuit breakers" "In-Memory" "001 - Fase 1"

    // ========================================
    // RELACIONES EXTERNAS - ACTORES
    // ========================================

    // Administradores y aplicaciones entran por autenticación (WAF manejado por infraestructura)
    admin -> reverseProxyGateway.authenticationMiddleware "Gestiona configuraciones de servicios" "HTTPS" "001 - Fase 1"
    appPeru -> reverseProxyGateway.authenticationMiddleware "Realiza llamadas API tenant Peru" "HTTPS" "001 - Fase 1"
    appEcuador -> reverseProxyGateway.authenticationMiddleware "Realiza llamadas API tenant Ecuador" "HTTPS" "001 - Fase 1"
    appColombia -> reverseProxyGateway.authenticationMiddleware "Realiza llamadas API tenant Colombia" "HTTPS" "001 - Fase 1"
    appMexico -> reverseProxyGateway.authenticationMiddleware "Realiza llamadas API tenant Mexico" "HTTPS" "001 - Fase 1"

    // ========================================
    // RELACIONES EXTERNAS - SISTEMAS DOWNSTREAM
    // ========================================

    // Enrutamiento a servicios corporativos
    reverseProxyGateway.timeoutHandler -> notification.api "Enruta requests de notificaciones" "HTTPS" "001 - Fase 1"
    reverseProxyGateway.timeoutHandler -> trackAndTrace.trackingAPI "Enruta requests de tracking" "HTTPS" "001 - Fase 1"
    reverseProxyGateway.timeoutHandler -> sitaMessaging.eventProcessor "Enruta requests de mensajería SITA" "HTTPS" "001 - Fase 1"

    // Configuración dinámica
    configPlatform.configService -> reverseProxyGateway "Configuración dinámica de rutas y políticas" "HTTPS" "001 - Fase 1"
    configPlatform.configService -> reverseProxyGateway.rateLimitingMiddleware "Configuración de límites por tenant" "HTTPS" "001 - Fase 1"
    // configPlatform.configService -> reverseProxyGateway.cacheMiddleware "Configuración de TTL y políticas de cache" "HTTPS" "002 - Fase 2"
}