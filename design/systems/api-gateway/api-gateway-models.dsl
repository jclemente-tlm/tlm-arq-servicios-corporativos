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

    // Relaciones del pipeline de middleware
    reverseProxyGateway.authenticationMiddleware -> reverseProxyGateway.tenantResolutionMiddleware "Pipeline flow" "" "001 - Fase 1"
    reverseProxyGateway.tenantResolutionMiddleware -> reverseProxyGateway.rateLimitingMiddleware "Pipeline flow" "" "001 - Fase 1"
    reverseProxyGateway.rateLimitingMiddleware -> reverseProxyGateway.circuitBreakerHandler "Pipeline flow" "" "001 - Fase 1"
    reverseProxyGateway.circuitBreakerHandler -> reverseProxyGateway.retryPolicyHandler "Pipeline flow" "" "001 - Fase 1"
    reverseProxyGateway.retryPolicyHandler -> reverseProxyGateway.timeoutHandler "Pipeline flow" "" "001 - Fase 1"
    reverseProxyGateway.timeoutHandler -> reverseProxyGateway.authorizationMiddleware "Pipeline flow" "" "001 - Fase 1"

    // Relaciones de actores externos
    admin -> reverseProxyGateway.authenticationMiddleware "Gestiona configuraciones de servicios" "HTTPS" "001 - Fase 1"
    appPeru -> reverseProxyGateway.authenticationMiddleware "Realiza llamadas API" "HTTPS" "001 - Fase 1"
    appEcuador -> reverseProxyGateway.authenticationMiddleware "Realiza llamadas API" "HTTPS" "001 - Fase 1"
    appColombia -> reverseProxyGateway.authenticationMiddleware "Realiza llamadas API" "HTTPS" "001 - Fase 1"
    appMexico -> reverseProxyGateway.authenticationMiddleware "Realiza llamadas API" "HTTPS" "001 - Fase 1"
}