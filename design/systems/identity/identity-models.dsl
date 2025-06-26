identity = softwareSystem "Identity System" {
    description "Servicio centralizado de autenticación y autorización mediante tokens JWT."
    tags "Identity" "001 - Fase 1"

    service = application "Identity Service" {
        technology "Keycloak"
        description "Gestiona autenticación, autorización y emisión de tokens JWT"
        tags "Keycloak" "001 - Fase 1"
    }

    db = store "Identity DB" {
        technology "PostgreSQL"
        description "Almacena configuraciones, credenciales, y roles"
        tags "Database" "PostgreSQL" "001 - Fase 1"
    }

    service -> db "Lee y escribe datos"
    admin -> service "Administra clientes y configuración" "vía API Gateway" "001 - Fase 1"
    appPeru -> service "Solicita autenticación" "HTTPS vía API Gateway" "001 - Fase 1"
    appEcuador -> service "Solicita autenticación" "HTTPS vía API Gateway" "001 - Fase 1"
    appColombia -> service "Solicita autenticación" "HTTPS vía API Gateway"
    appMexico -> service "Solicita autenticación" "HTTPS vía API Gateway"

    apiGateway.yarp.authorization -> service "Redirige solicitudes a" "HTTPS" "001 - Fase 1"
}