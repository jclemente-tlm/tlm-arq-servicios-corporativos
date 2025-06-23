identity = softwareSystem "Identity System" {
    description "Servicio centralizado de autenticación y autorización mediante tokens JWT."

    service = application "Identity Service" {
        technology "Keycloak"
        description "Gestiona autenticación, autorización y emisión de tokens JWT"
    }

    db = store "Identity DB" {
        technology "PostgreSQL"
        description "Almacena configuraciones, credenciales, y roles"
        tags "Database" "PostgreSQL"
    }

    service -> db "Lee y escribe datos"
    admin -> service "Administra clientes y configuración" "vía API Gateway"
    appPeru -> service "Solicita autenticación" "HTTPS vía API Gateway"
    appEcuador -> service "Solicita autenticación" "HTTPS vía API Gateway"
    appColombia -> service "Solicita autenticación" "HTTPS vía API Gateway"
    appMexico -> service "Solicita autenticación" "HTTPS vía API Gateway"

    apiGateway.yarp.authorization -> service "Redirige solicitudes a" "HTTPS"
}