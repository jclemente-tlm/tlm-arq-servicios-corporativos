container iataMessaging "iata_messaging_system" {
    include *
    exclude apiGateway iataMessaging.scheduler
    exclude "appPeru -> trackAndTrace"
    exclude "appEcuador -> trackAndTrace"
    exclude "appColombia -> trackAndTrace"
    exclude "appMexico -> trackAndTrace"

    exclude "admin -> trackAndTrace"
    // exclude "* -> trackAndTrace"
    // include "iataMessaging.eventProcessor.eventConsumer -> trackAndTrace.eventsQueue"
    title "[Diagrama de Contenedores] IATA Messaging System"
}

component iataMessaging.api "iata_messaging_system_api" {
    include *
    exclude apiGateway
    // exclude "* -> trackAndTrace"
    title "[Diagrama de Componentes] IATA Messaging System - API"
}

component iataMessaging.sender "iata_messaging_system_sender" {
    include *
    exclude apiGateway
    title "[Diagrama de Componentes] IATA Messaging System - Message Sender"
}
