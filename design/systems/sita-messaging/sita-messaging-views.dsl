container sitaMessaging "sita_messaging_system" {
    include *
    exclude apiGateway
    exclude "appPeru -> trackAndTrace"
    exclude "appEcuador -> trackAndTrace"
    exclude "appColombia -> trackAndTrace"
    exclude "appMexico -> trackAndTrace"

    exclude "admin -> trackAndTrace"
    // exclude "* -> trackAndTrace"
    // include "sitaMessaging.eventProcessor.eventConsumer -> trackAndTrace.eventsQueue"
    title "[Diagrama de Contenedores] SITA Messaging System"
}

component sitaMessaging.eventProcessor "sita_messaging_system_event_processor" {
    include *
    exclude apiGateway
    // exclude "* -> trackAndTrace"
    title "[Diagrama de Componentes] SITA Messaging System - Event Processor"
}

component sitaMessaging.sender "sita_messaging_system_sender" {
    include *
    exclude apiGateway
    title "[Diagrama de Componentes] SITA Messaging System - Message Sender"
}
