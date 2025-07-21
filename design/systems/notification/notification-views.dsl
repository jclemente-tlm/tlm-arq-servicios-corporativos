container notification "notification_system" {
    include *
    exclude apiGateway configPlatform
    exclude "* -> trackAndTrace"
    title "[Diagrama de Contenedores] Notification System"
}

container notification "notification_system_fase_1" {
    include *
    exclude apiGateway
    // exclude "* -> trackAndTrace"
    exclude notification.scheduler notification.smsProcessor notification.whatsappProcessor notification.pushProcessor
    exclude smsProvider whatsappProvider pushProvider
    title "[Diagrama de Contenedores] Notification System - Fase 1"
}

component notification.api "notification_system_api" {
    include *
    exclude apiGateway
    exclude "* -> trackAndTrace"
    title "[Diagrama de Componentes] Notification System - API"
}

component notification.scheduler "notification_system_scheduler" {
    include *
    exclude apiGateway
    title "[Diagrama de Componentes] Notification System - Scheduler"
}

component notification.emailProcessor "notification_system_email_processor" {
    include *
    exclude apiGateway
    title "[Diagrama de Componentes] Notification System - Email Processor"
}

component notification.smsProcessor "notification_system_sms_processor" {
    include *
    exclude apiGateway
    title "[Diagrama de Componentes] Notification System - SMS Processor"
}

component notification.whatsappProcessor "notification_system_whatsapp_processor" {
    include *
    exclude apiGateway
    title "[Diagrama de Componentes] Notification System - WhatsApp Processor"
}

component notification.pushProcessor "notification_system_push_processor" {
    include *
    exclude apiGateway
    title "[Diagrama de Componentes] Notification System - Push Processor"
}