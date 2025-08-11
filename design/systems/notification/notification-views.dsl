container notification "notification_system" {
    include *

    // // Incluir proveedores de notificación y storage
    // include emailProvider smsProvider whatsappProvider pushProvider
    // include configPlatform

    // // Excluir sistemas que no interactúan directamente
    exclude apiGateway
    // exclude trackAndTrace sitaMessaging identity

    exclude "observabilitySystem -> sitaMessaging"

    title "[Diagrama de Contenedores] Notification System"
}

component notification.api "notification_system_api" {
    include *

    // Excluir solo componentes de observabilidad para limpiar telaraña
    exclude notification.api.healthCheck
    exclude notification.api.metricsCollector
    exclude notification.api.structuredLogger

    // Excluir sistemas externos
    exclude notification.notificationProcessor
    exclude observabilitySystem

    title "[Diagrama de Componentes] Notification System - Notification API"
}

component notification.notificationProcessor "notification_system_processor" {
    include *

    // Excluir solo componentes de observabilidad para limpiar telaraña
    exclude notification.scheduler
    exclude notification.notificationProcessor.healthCheck
    exclude notification.notificationProcessor.metricsCollector
    exclude notification.notificationProcessor.structuredLogger

    // Excluir sistemas externos
    exclude notification.api
    exclude observabilitySystem
    exclude apiGateway identity sitaMessaging trackAndTrace

    title "[Diagrama de Componentes] Notification System - Notification Processor"
}

component notification.scheduler "notification_system_scheduler" {
    include *

    // Excluir solo componentes de observabilidad para limpiar telaraña
    exclude notification.scheduler.healthCheck
    exclude notification.scheduler.metricsCollector
    exclude notification.scheduler.structuredLogger

    // Excluir sistemas externos
    exclude observabilitySystem

    exclude apiGateway
    title "[Diagrama de Componentes] Notification System - Scheduler"
}

component notification.emailProcessor "notification_system_email_processor" {
    include *

    // Excluir solo componentes de observabilidad para limpiar telaraña
    exclude notification.emailProcessor.healthCheck
    exclude notification.emailProcessor.metricsCollector
    exclude notification.emailProcessor.structuredLogger

    // Excluir sistemas externos
    exclude observabilitySystem

    exclude apiGateway
    title "[Diagrama de Componentes] Notification System - Email Processor"
}

component notification.smsProcessor "notification_system_sms_processor" {
    include *

    // Excluir solo componentes de observabilidad para limpiar telaraña
    exclude notification.smsProcessor.healthCheck
    exclude notification.smsProcessor.metricsCollector
    exclude notification.smsProcessor.structuredLogger

    // Excluir sistemas externos
    exclude observabilitySystem

    exclude apiGateway
    title "[Diagrama de Componentes] Notification System - SMS Processor"
}

component notification.whatsappProcessor "notification_system_whatsapp_processor" {
    include *

    // Excluir solo componentes de observabilidad para limpiar telaraña
    exclude notification.whatsappProcessor.healthCheck
    exclude notification.whatsappProcessor.metricsCollector
    exclude notification.whatsappProcessor.structuredLogger

    // Excluir sistemas externos
    exclude observabilitySystem

    exclude apiGateway
    title "[Diagrama de Componentes] Notification System - WhatsApp Processor"
}

component notification.pushProcessor "notification_system_push_processor" {
    include *

    // Excluir solo componentes de observabilidad para limpiar telaraña
    exclude notification.pushProcessor.healthCheck
    exclude notification.pushProcessor.metricsCollector
    exclude notification.pushProcessor.structuredLogger

    // Excluir sistemas externos
    exclude observabilitySystem

    exclude apiGateway
    title "[Diagrama de Componentes] Notification System - Push Processor"
}

# // ========================================
# // VISTAS ESPECIALIZADAS - OBSERVABILIDAD
# // ========================================

# component notification.api "notification_system_api_observability" {
#     include *

#     // Excluir todos los demás sistemas y componentes
#     # exclude notification.api.metricsCollector
#     # exclude notification.api.structuredLogger
#     # exclude notification.api.healthCheck
#     # exclude notification.processor
#     # exclude apiGateway identity sitaMessaging trackAndTrace
#     # exclude configPlatform emailProvider smsProvider whatsappProvider pushProvider

#     include notification.api.metricsCollector
#     include notification.api.structuredLogger
#     include notification.api.healthCheck

#     title "[Diagrama de Observabilidad] Notification API - Monitoring"
#     description "Vista especializada de observabilidad: métricas, logs y health checks del API"
# }

# component notification.processor "notification_system_processor_observability" {
#     include notification.processor
#     include observabilitySystem

#     // Excluir todos los demás sistemas y componentes
#     # exclude notification.api
#     # exclude apiGateway identity sitaMessaging trackAndTrace
#     # exclude configPlatform emailProvider smsProvider whatsappProvider pushProvider

#     title "[Diagrama de Observabilidad] Notification Processor - Monitoring"
#     description "Vista especializada de observabilidad: métricas, logs y health checks del Processor"
# }
