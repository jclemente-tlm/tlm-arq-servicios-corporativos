container notification "notification_system" {
    include *

    // Incluir proveedores de notificación y storage
    include emailProvider smsProvider whatsappProvider pushProvider
    include configPlatform

    // Excluir sistemas que no interactúan directamente
    exclude apiGateway
    exclude trackAndTrace sitaMessaging identity

    title "[Diagrama de Contenedores] Notification System - Optimizado"
    description "Arquitectura simplificada con 3 contenedores: API, Processor y Database"
}

component notification.api "notification_system_api" {
    include *

    // Incluir solo elementos directamente relacionados con el API
    include configPlatform

    // Excluir el processor (no interactúa directamente con el API)
    exclude notification.processor
    exclude emailProvider smsProvider whatsappProvider pushProvider

    title "[Diagrama de Componentes] Notification API - Optimizado"
    description "API REST simplificada con componentes esenciales y sin duplicación"
}

component notification.processor "notification_system_processor" {
    include *

    // Incluir proveedores de notificación y configuración
    include emailProvider smsProvider whatsappProvider pushProvider
    include configPlatform

    // Excluir el API (separación de responsabilidades)
    exclude notification.api
    exclude apiGateway identity sitaMessaging trackAndTrace

    title "[Diagrama de Componentes] Notification Processor - Unificado"
    description "Procesador unificado con channel handlers integrados en lugar de contenedores separados"
}
