apiGateway = softwareSystem "Enterprise API Gateway" {
    description "Gateway corporativo de alta disponibilidad con autenticación, autorización y políticas de resiliencia para microservicios."
    tags "API Gateway" "001 - Fase 1"

    reverseProxyGateway = application "Reverse Proxy Gateway" {
        technology "YARP"
        description "Proxy inverso inteligente con balanceeo de carga y enrutamiento dinámico a microservicios corporativos."
        tags "API Gateway" "001 - Fase 1"

        // Componente de seguridad unificado
        securityMiddleware = component "Security Middleware" {
            technology "ASP.NET Core Middleware, JWT"
            description "Valida tokens JWT y aplica políticas de autorización por tenant y rol"
            tags "Middleware" "Security" "001 - Fase 1"
        }

        tenantResolutionMiddleware = component "Tenant Resolution Middleware" {
            technology "ASP.NET Core Middleware"
            description "Extrae y valida contexto de tenant desde headers o claims JWT"
            tags "Middleware" "001 - Fase 1"
        }

        rateLimitingMiddleware = component "Rate Limiting Middleware" {
            technology "ASP.NET Core Middleware, Redis"
            description "Aplica límites de velocidad diferenciados por tenant y endpoint"
            tags "Middleware" "001 - Fase 1"
        }

        // Resiliencia y tolerancia a fallos
        resilienceMiddleware = component "Resilience Middleware" {
            technology "Polly"
            description "Implementa circuit breakers y reintentos para llamadas downstream"
            tags "Middleware" "Resilience" "001 - Fase 1"
        }

        // Componente de procesamiento de datos unificado
        dataProcessingMiddleware = component "Data Processing Middleware" {
            technology "ASP.NET Core Middleware, JSON Schema"
            description "Valida esquemas de entrada y transforma payloads según versión API"
            tags "Middleware" "Processing" "001 - Fase 1"
        }

        // Cache opcional para fase 2
        cacheMiddleware = component "Cache Middleware" {
            technology "Redis, ASP.NET Core Response Caching"
            description "Cache distribuido con invalidación inteligente"
            tags "Performance" "002 - Fase 2"
        }

        secretsAndConfigs = component "SecretsAndConfigs (Cross-Cutting)" {
            technology "NuGet (AWS Secrets Manager, AppConfig)"
            description "Provee acceso centralizado a configuraciones y secretos"
            tags "Configuration" "Cross-Cutting"
        }

        observability = component "Observability\n(Cross-Cutting)" {
            technology "NuGet (Serilog, Prometheus, HealthChecks)"
            description "Provee logging estructurado, métricas y health checks"
            tags "Observability" "Cross-Cutting"
        }

        // // Componentes de observabilidad
        // healthCheck = component "Health Check" {
        //     technology "ASP.NET Core Health Checks"
        //     description "Monitorea salud del gateway y servicios downstream corporativos"
        //     tags "Observability" "001 - Fase 1"
        // }
    }

    reverseProxyGateway.securityMiddleware -> identity.keycloakServer "Genera tokens JWT" "HTTPS" "001 - Fase 1"

    // Seguridad y contexto
    reverseProxyGateway.securityMiddleware -> reverseProxyGateway.tenantResolutionMiddleware "Pasa a resolución tenant" "Pipeline" "001 - Fase 1"

    // Rate limiting y procesamiento
    reverseProxyGateway.tenantResolutionMiddleware -> reverseProxyGateway.rateLimitingMiddleware "Pasa a rate limiting" "Pipeline" "001 - Fase 1"
    reverseProxyGateway.rateLimitingMiddleware -> reverseProxyGateway.dataProcessingMiddleware "Pasa a procesamiento" "Pipeline" "001 - Fase 1"

    // Resiliencia y downstream
    reverseProxyGateway.dataProcessingMiddleware -> reverseProxyGateway.resilienceMiddleware "Pasa a resiliencia" "Pipeline" "001 - Fase 1"


    reverseProxyGateway.secretsAndConfigs -> configPlatform.configService "Lee secretos y configuraciones" "HTTPS/REST" "001 - Fase 1"
    reverseProxyGateway.observability  -> observabilitySystem "Envía logs, métricas y health checks" "HTTPS/REST" "001 - Fase 1"

    appPeru -> reverseProxyGateway.securityMiddleware "Realiza llamadas API" "HTTPS" "001 - Fase 1"
    appEcuador -> reverseProxyGateway.securityMiddleware "Realiza llamadas API" "HTTPS" "001 - Fase 1"
    appColombia -> reverseProxyGateway.securityMiddleware "Realiza llamadas API" "HTTPS" "001 - Fase 1"
    appMexico -> reverseProxyGateway.securityMiddleware "Realiza llamadas API" "HTTPS" "001 - Fase 1"

}