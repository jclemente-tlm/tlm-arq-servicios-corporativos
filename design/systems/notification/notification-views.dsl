container notification "notification_system" {
    include *

    // // Incluir proveedores de notificación y storage
    // include emailProvider smsProvider whatsappProvider pushProvider
    // include configPlatform

    // // Excluir sistemas que no interactúan directamente
    exclude apiGateway
    // exclude trackAndTrace sitaMessaging identity

    exclude "observabilitySystem -> sitaMessaging"

    title "[Diagrama de Contenedores] Notification System - Optimizado"
    description "Arquitectura simplificada con 3 contenedores: API, Processor y Database"
}

component notification.api "notification_system_api" {
    include *

    // Excluir solo componentes de observabilidad para limpiar telaraña
    exclude notification.api.healthCheck
    exclude notification.api.metricsCollector
    exclude notification.api.structuredLogger

    // Excluir sistemas externos
    exclude notification.processor
    exclude observabilitySystem

    title "[Diagrama de Componentes] Notification API - Business Logic"
    description "API REST enfocada en lógica de negocio sin observabilidad para claridad"
}

component notification.processor "notification_system_processor" {
    include *

    // Excluir solo componentes de observabilidad para limpiar telaraña
    exclude notification.processor.healthCheck
    exclude notification.processor.metricsCollector
    exclude notification.processor.structuredLogger

    // Excluir sistemas externos
    exclude notification.api
    exclude observabilitySystem
    exclude apiGateway identity sitaMessaging trackAndTrace

    title "[Diagrama de Componentes] Notification Processor - Business Logic"
    description "Procesador enfocado en lógica de negocio y handlers sin observabilidad para claridad"
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
