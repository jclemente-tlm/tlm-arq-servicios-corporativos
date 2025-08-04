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
            description "Valida salud del gateway: verifica conectividad a servicios downstream, monitorea estado de circuit breakers y evalúa performance de endpoints críticos"
            tags "Observability" "001 - Fase 1"
        }

        metricsCollector = component "Metrics Collector" {
            technology "Prometheus.NET"
            description "Recolecta métricas del gateway: registra throughput por tenant, mide latencia por endpoint, cuenta tasa de errores, reporta circuit breaker status y monitorea rate limiting"
            tags "Observability" "001 - Fase 1"
        }

        structuredLogger = component "Structured Logger" {
            technology "Serilog"
            description "Registra logging estructurado de requests con correlationId único, captura tenant context, almacena métricas de performance y mantiene trazabilidad completa end-to-end"
            tags "Observability" "001 - Fase 1"
        }

        // Configuración dinámica
        dynamicConfigProcessor = component "Dynamic Configuration Processor" {
            technology "C#, FluentValidation, HttpClient"
            description "Consulta cambios de configuración con polling inteligente, valida nuevas configuraciones contra esquemas, actualiza cache dinámicamente e invalida configuraciones específicas sin reinicio del Gateway."
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
    reverseProxyGateway.structuredLogger -> reverseProxyGateway.metricsCollector "Correlaciona logs con métricas para análisis unificado" "In-Memory" "001 - Fase 1"
    reverseProxyGateway.healthCheck -> reverseProxyGateway.resilienceHandler "Evalúa estado de patrones de resiliencia para health checks" "In-Memory" "001 - Fase 1"

    // Observabilidad de middleware crítico
    reverseProxyGateway.securityMiddleware -> reverseProxyGateway.structuredLogger "Registra eventos de autenticación y autorización" "In-Memory" "001 - Fase 1"
    reverseProxyGateway.tenantResolutionMiddleware -> reverseProxyGateway.structuredLogger "Registra resolución de tenant context" "In-Memory" "001 - Fase 1"
    reverseProxyGateway.rateLimitingMiddleware -> reverseProxyGateway.metricsCollector "Reporta métricas de rate limiting por tenant" "In-Memory" "001 - Fase 1"
    reverseProxyGateway.resilienceHandler -> reverseProxyGateway.metricsCollector "Reporta estado de circuit breakers y retries" "In-Memory" "001 - Fase 1"

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
    reverseProxyGateway.resilienceHandler -> notification.api "Enruta requests hacia API de notificaciones con resiliencia" "HTTPS" "001 - Fase 1"
    reverseProxyGateway.resilienceHandler -> trackAndTrace.trackingAPI "Enruta requests hacia API de tracking con circuit breaker" "HTTPS" "001 - Fase 1"

    // Health checks de servicios downstream
    reverseProxyGateway.healthCheck -> notification.api "Verifica disponibilidad del servicio de notificaciones" "HTTPS" "001 - Fase 1"
    reverseProxyGateway.healthCheck -> trackAndTrace.trackingAPI "Verifica disponibilidad del servicio de tracking" "HTTPS" "001 - Fase 1"

    // Autenticación con Identity System
    reverseProxyGateway.securityMiddleware -> identity.keycloakServer "Valida tokens JWT mediante token introspection" "HTTPS" "001 - Fase 1"

    // ========================================
    // RELACIONES DE CONFIGURACIÓN DINÁMICA
    // ========================================

    // Configuración dinámica vía polling (patrón correcto)
    reverseProxyGateway.dynamicConfigProcessor -> configPlatform.configService "Consulta cambios de configuración con polling inteligente" "HTTPS/REST" "001 - Fase 1"

    // Invalidación selectiva de cache tras cambios de configuración
    reverseProxyGateway.dynamicConfigProcessor -> reverseProxyGateway.securityMiddleware "Invalida cache de políticas de seguridad al detectar cambios" "In-Memory" "001 - Fase 1"
    reverseProxyGateway.dynamicConfigProcessor -> reverseProxyGateway.rateLimitingMiddleware "Invalida cache de límites por tenant al detectar cambios" "In-Memory" "001 - Fase 1"
    reverseProxyGateway.dynamicConfigProcessor -> reverseProxyGateway.dataProcessingMiddleware "Invalida cache de esquemas de validación al detectar cambios" "In-Memory" "001 - Fase 1"

    // Configuración opcional para Fase 2
    // reverseProxyGateway.dynamicConfigProcessor -> reverseProxyGateway.cacheMiddleware "Invalida políticas de TTL de cache al detectar cambios" "In-Memory" "002 - Fase 2"
}