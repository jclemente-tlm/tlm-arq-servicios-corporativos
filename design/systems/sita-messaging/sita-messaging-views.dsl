container sitaMessaging "sita_messaging_system" {
    include *

    // // Incluir sistemas directamente relacionados
    // include trackAndTrace
    // include airlines descartes
    // include configPlatform

    // // Excluir sistemas no relacionados directamente
    exclude apiGateway
    // exclude "appPeru -> trackAndTrace"
    // exclude "appEcuador -> trackAndTrace"
    // exclude "appColombia -> trackAndTrace"
    // exclude "appMexico -> trackAndTrace"
    // exclude "admin -> trackAndTrace"

    exclude "observabilitySystem -> trackAndTrace"
    exclude "observabilitySystem -> identity"
    exclude "observabilitySystem -> notification"
    exclude "trackAndTrace -> observabilitySystem"

    exclude "trackAndTrace -> configPlatform"

    title "[Diagrama de Contenedores] SITA Messaging System"
}

component sitaMessaging.eventProcessor "sita_messaging_system_event_processor" {
    include *

    // Exclusión inteligente de componentes de observabilidad para diagrama limpio
    exclude apiGateway
    // exclude observabilitySystem
    // exclude sitaMessaging.eventProcessor.healthCheck
    // exclude sitaMessaging.eventProcessor.metricsCollector
    // exclude sitaMessaging.eventProcessor.structuredLogger

    title "[Diagrama de Componentes] SITA Messaging System - Event Processor"
    description "Vista del procesador de eventos SITA y su conexión con Track & Trace"
}

component sitaMessaging.sender "sita_messaging_system_sender" {
    include *

    // Exclusión inteligente de componentes de observabilidad para diagrama limpio
    exclude apiGateway
    // exclude observabilitySystem
    // exclude sitaMessaging.sender.healthCheck
    // exclude sitaMessaging.sender.metricsCollector
    // exclude sitaMessaging.sender.structuredLogger

    title "[Diagrama de Componentes] SITA Messaging System - Message Sender"
    description "Vista del sender de mensajes SITA hacia aerolíneas y Descartes"
}
