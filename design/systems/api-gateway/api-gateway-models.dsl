apiGateway = softwareSystem "API Gateway" {
    description "Punto de entrada para todas las solicitudes a los microservicios."
    tags "API Gateway"

    yarp = application "YARP API Gateway" {
        technology "YARP"
        description "Proxy inverso que enruta solicitudes a los microservicios corporativos."
        tags "API Gateway"

        authentication = component "Authentication Middleware" {
            technology "Middleware"
            description "Middleware que autentica usuarios y genera tokens JWT."

            admin -> this "Gestiona configuraciones de servicios" "HTTPS"
            appPeru -> this "Hace llamadas API" "HTTPS"
            appEcuador -> this "Hace llamadas API" "HTTPS"
            appColombia -> this "Hace llamadas API" "HTTPS"
            appMexico -> this "Hace llamadas API" "HTTPS"
        }

        tenantResolution = component "Tenant Resolution Middleware" {
            technology "Middleware"
            description "Middleware que resuelve el inquilino (tenant) de la solicitud."

            authentication -> this "Llama a"
        }

        rateLimit = component "Rate Limiting Middleware" {
            technology "Middleware"
            description "Middleware que limita la cantidad de solicitudes por usuario."

            tenantResolution -> this "Llama a"
        }

        authorization = component "Authorization Middleware" {
            technology "Middleware"
            description "Middleware que valida los tokens JWT y verifica permisos."

            rateLimit -> this "Llama a"
        }
    }
}