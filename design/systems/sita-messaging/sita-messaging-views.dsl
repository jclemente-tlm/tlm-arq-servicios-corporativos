container sitaMessaging "sita_messaging_system" {
    include *

    // Incluir sistemas directamente relacionados
    include trackAndTrace
    include airlines descartes
    include configPlatform

    // Excluir sistemas no relacionados directamente
    exclude apiGateway identity notification
    exclude "appPeru -> trackAndTrace"
    exclude "appEcuador -> trackAndTrace"
    exclude "appColombia -> trackAndTrace"
    exclude "appMexico -> trackAndTrace"
    exclude "admin -> trackAndTrace"

    title "[Diagrama de Contenedores] SITA Messaging System"
}

component sitaMessaging.eventProcessor "sita_messaging_system_event_processor" {
    include *

    // Incluir solo elementos directamente relacionados con el procesador
    include trackAndTrace.trackingAPI
    include configPlatform

    // Excluir otros sistemas
    exclude apiGateway identity notification
    exclude airlines descartes
    exclude emailProvider smsProvider whatsappProvider pushProvider

    title "[Diagrama de Componentes] SITA Messaging System - Event Processor"
    description "Vista del procesador de eventos SITA y su conexión con Track & Trace"
}

component sitaMessaging.sender "sita_messaging_system_sender" {
    include *

    // Incluir solo elementos directamente relacionados con el sender
    include airlines descartes
    include configPlatform

    // Excluir otros sistemas
    exclude apiGateway identity notification trackAndTrace
    exclude emailProvider smsProvider whatsappProvider pushProvider

    title "[Diagrama de Componentes] SITA Messaging System - Message Sender"
    description "Vista del sender de mensajes SITA hacia aerolíneas y Descartes"
}
