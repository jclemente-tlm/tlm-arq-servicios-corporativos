apiGateway = softwareSystem "API Gateway" {
    description "Punto de entrada para todas las solicitudes a los microservicios."
    tags "API Gateway" "001 - Fase 1"

    yarp = application "YARP API Gateway" {
        technology "YARP"
        description "Proxy inverso que enruta solicitudes a los microservicios corporativos."
        tags "API Gateway" "001 - Fase 1"

        authentication = component "Authentication Middleware" {
            technology "Middleware"
            description "Middleware que autentica usuarios y genera tokens JWT."
            tags "Middleware" "001 - Fase 1"

            admin -> this "Gestiona configuraciones de servicios" "HTTPS" "001 - Fase 1"
            appPeru -> this "Hace llamadas API" "HTTPS" "001 - Fase 1"
            appEcuador -> this "Hace llamadas API" "HTTPS" "001 - Fase 1"
            appColombia -> this "Hace llamadas API" "HTTPS"
            appMexico -> this "Hace llamadas API" "HTTPS"
        }

        tenantResolution = component "Tenant Resolution Middleware" {
            technology "Middleware"
            description "Middleware que resuelve el inquilino (tenant) de la solicitud."
            tags "Middleware" "001 - Fase 1"

            authentication -> this "Llama a" "" "001 - Fase 1"
        }

        rateLimit = component "Rate Limiting Middleware" {
            technology "Middleware"
            description "Middleware que limita la cantidad de solicitudes por usuario."
            tags "Middleware" "001 - Fase 1"

            tenantResolution -> this "Llama a" "" "001 - Fase 1"
        }

        authorization = component "Authorization Middleware" {
            technology "Middleware"
            description "Middleware que valida los tokens JWT y verifica permisos."
            tags "Middleware" "001 - Fase 1"

            rateLimit -> this "Llama a" "" "001 - Fase 1"
        }
    }
}