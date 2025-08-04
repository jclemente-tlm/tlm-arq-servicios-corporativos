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
        cacheMiddleware = component "Cache Middleware" {
            technology "Redis, ASP.NET Core Response Caching"
            description "Cache distribuido para respuestas API con invalidación inteligente por tenant y TTL configurable."
            tags "Performance" "001 - Fase 1"
        }

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

        // Componentes de seguridad
        webApplicationFirewall = component "Web Application Firewall" {
            technology "ModSecurity Core, OWASP CRS"
            description "Protección contra ataques comunes: SQL injection, XSS, DDoS con reglas actualizadas."
            tags "Security" "001 - Fase 1"
        }

        // Componente de observabilidad
        gatewayHealthAggregator = component "Gateway Health Aggregator" {
            technology "ASP.NET Core Health Checks"
            description "Agrega y expone estado de salud de todos los servicios downstream con dashboard centralizado."
            tags "Observability" "001 - Fase 1"
        }

        gatewayMetricsCollector = component "Gateway Metrics Collector" {
            technology "Prometheus Client"
            description "Recolecta métricas del gateway: throughput, latencia, tasa de errores por endpoint y tenant."
            tags "Observability" "001 - Fase 1"
        }

        gatewayLogger = component "Gateway Logger" {
            technology "Serilog"
            description "Logging estructurado de requests con correlationId, tenant context y métricas de performance."
            tags "Observability" "001 - Fase 1"
        }
    }

    // ========================================
    // PIPELINE DE MIDDLEWARE CORREGIDO
    // ========================================

    // Entrada: Seguridad y validación
    reverseProxyGateway.webApplicationFirewall -> reverseProxyGateway.authenticationMiddleware "Pipeline: WAF → Auth" "" "001 - Fase 1"
    reverseProxyGateway.authenticationMiddleware -> reverseProxyGateway.authorizationMiddleware "Pipeline: Auth → Authz" "" "001 - Fase 1"
    reverseProxyGateway.authorizationMiddleware -> reverseProxyGateway.tenantResolutionMiddleware "Pipeline: Authz → Tenant" "" "001 - Fase 1"

    // Procesamiento: Rate limiting y validación
    reverseProxyGateway.tenantResolutionMiddleware -> reverseProxyGateway.rateLimitingMiddleware "Pipeline: Tenant → Rate Limit" "" "001 - Fase 1"
    reverseProxyGateway.rateLimitingMiddleware -> reverseProxyGateway.schemaValidator "Pipeline: Rate Limit → Validation" "" "001 - Fase 1"
    reverseProxyGateway.schemaValidator -> reverseProxyGateway.cacheMiddleware "Pipeline: Validation → Cache" "" "001 - Fase 1"

    // Transformación y resiliencia
    reverseProxyGateway.cacheMiddleware -> reverseProxyGateway.transformationMiddleware "Pipeline: Cache → Transform" "" "001 - Fase 1"
    reverseProxyGateway.transformationMiddleware -> reverseProxyGateway.circuitBreakerHandler "Pipeline: Transform → Circuit Breaker" "" "001 - Fase 1"
    reverseProxyGateway.circuitBreakerHandler -> reverseProxyGateway.retryPolicyHandler "Pipeline: Circuit Breaker → Retry" "" "001 - Fase 1"
    reverseProxyGateway.retryPolicyHandler -> reverseProxyGateway.timeoutHandler "Pipeline: Retry → Timeout" "" "001 - Fase 1"

    // ========================================
    // RELACIONES INTERNAS - OBSERVABILIDAD
    // ========================================

    // Observabilidad cross-cutting
    reverseProxyGateway.gatewayLogger -> reverseProxyGateway.gatewayMetricsCollector "Correlaciona logs con métricas" "In-Memory" "001 - Fase 1"
    reverseProxyGateway.gatewayHealthAggregator -> reverseProxyGateway.circuitBreakerHandler "Monitorea estado de circuit breakers" "In-Memory" "001 - Fase 1"

    // ========================================
    // RELACIONES EXTERNAS - ACTORES
    // ========================================

    // Administradores y aplicaciones entran por WAF
    admin -> reverseProxyGateway.webApplicationFirewall "Gestiona configuraciones de servicios" "HTTPS" "001 - Fase 1"
    appPeru -> reverseProxyGateway.webApplicationFirewall "Realiza llamadas API tenant Peru" "HTTPS" "001 - Fase 1"
    appEcuador -> reverseProxyGateway.webApplicationFirewall "Realiza llamadas API tenant Ecuador" "HTTPS" "001 - Fase 1"
    appColombia -> reverseProxyGateway.webApplicationFirewall "Realiza llamadas API tenant Colombia" "HTTPS" "001 - Fase 1"
    appMexico -> reverseProxyGateway.webApplicationFirewall "Realiza llamadas API tenant Mexico" "HTTPS" "001 - Fase 1"

    // ========================================
    // RELACIONES EXTERNAS - SISTEMAS DOWNSTREAM
    // ========================================

    // Enrutamiento a servicios corporativos
    reverseProxyGateway.timeoutHandler -> notification.api "Enruta requests de notificaciones" "HTTPS" "001 - Fase 1"
    reverseProxyGateway.timeoutHandler -> trackAndTrace.trackingAPI "Enruta requests de tracking" "HTTPS" "001 - Fase 1"
    reverseProxyGateway.timeoutHandler -> sitaMessaging.eventProcessor "Enruta requests de mensajería SITA" "HTTPS" "001 - Fase 1"

    // Configuración dinámica
    configPlatform.configService -> reverseProxyGateway "Configuración dinámica de rutas y políticas" "HTTPS" "001 - Fase 1"
    configPlatform.configService -> reverseProxyGateway.cacheMiddleware "Configuración de TTL y políticas de cache" "HTTPS" "001 - Fase 1"
    configPlatform.configService -> reverseProxyGateway.rateLimitingMiddleware "Configuración de límites por tenant" "HTTPS" "001 - Fase 1"
}