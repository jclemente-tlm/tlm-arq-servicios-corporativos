container notification "notification_system" {
    include *

    // Incluir proveedores de notificación
    include emailProvider smsProvider whatsappProvider pushProvider
    include configPlatform

    // Excluir sistemas que no interactúan directamente
    exclude apiGateway
    exclude trackAndTrace sitaMessaging identity

    title "[Diagrama de Contenedores] Notification System"
}

component notification.api "notification_system_api" {
    include *

    // Incluir solo elementos directamente relacionados con el API
    include configPlatform

    // Excluir procesadores y proveedores (no interactúan directamente con el API)
    exclude apiGateway identity sitaMessaging trackAndTrace
    exclude emailProvider smsProvider whatsappProvider pushProvider
    exclude notification.emailProcessor notification.smsProcessor notification.whatsappProcessor notification.pushProcessor

    title "[Diagrama de Componentes] Notification System - API"
    description "Vista del API de notificaciones sin procesadores específicos"
}

component notification.notificationProcessor "notification_system_processor" {
    include *

    // Incluir configuración y cola de eventos
    include configPlatform

    // Excluir otros sistemas y procesadores específicos
    exclude apiGateway identity sitaMessaging trackAndTrace
    exclude emailProvider smsProvider whatsappProvider pushProvider
    exclude notification.emailProcessor notification.smsProcessor notification.whatsappProcessor notification.pushProcessor

    title "[Diagrama de Componentes] Notification System - Processor"
    description "Vista del procesador central de notificaciones"
}

component notification.emailProcessor "notification_system_email_processor" {
    include *

    // Incluir solo elementos directamente relacionados con email
    include emailProvider
    include configPlatform

    // Excluir otros sistemas y procesadores
    exclude apiGateway identity sitaMessaging trackAndTrace
    exclude smsProvider whatsappProvider pushProvider
    exclude notification.smsProcessor notification.whatsappProcessor notification.pushProcessor

    title "[Diagrama de Componentes] Notification System - Email Processor"
    description "Vista especializada del procesador de email y su proveedor"
}

component notification.smsProcessor "notification_system_sms_processor" {
    include *

    // Incluir solo elementos directamente relacionados con SMS
    include smsProvider
    include configPlatform

    // Excluir otros sistemas y procesadores
    exclude apiGateway identity sitaMessaging trackAndTrace
    exclude emailProvider whatsappProvider pushProvider
    exclude notification.emailProcessor notification.whatsappProcessor notification.pushProcessor

    title "[Diagrama de Componentes] Notification System - SMS Processor"
    description "Vista especializada del procesador de SMS y su proveedor"
}

component notification.whatsappProcessor "notification_system_whatsapp_processor" {
    include *

    // Incluir solo elementos directamente relacionados con WhatsApp
    include whatsappProvider
    include configPlatform

    // Excluir otros sistemas y procesadores
    exclude apiGateway identity sitaMessaging trackAndTrace
    exclude emailProvider smsProvider pushProvider
    exclude notification.emailProcessor notification.smsProcessor notification.pushProcessor

    title "[Diagrama de Componentes] Notification System - WhatsApp Processor"
    description "Vista especializada del procesador de WhatsApp y su proveedor"
}

component notification.pushProcessor "notification_system_push_processor" {
    include *

    // Incluir solo elementos directamente relacionados con Push
    include pushProvider
    include configPlatform

    // Excluir otros sistemas y procesadores
    exclude apiGateway identity sitaMessaging trackAndTrace
    exclude emailProvider smsProvider whatsappProvider
    exclude notification.emailProcessor notification.smsProcessor notification.whatsappProcessor

    title "[Diagrama de Componentes] Notification System - Push Processor"
    description "Vista especializada del procesador de push notifications y su proveedor"
}
