// Vista general del sistema de observabilidad
systemContext observabilitySystem "observability_overview" {
    include observabilitySystem
    include notification identity trackAndTrace sitaMessaging apiGateway
    include admin operationalUser
    title "[Observabilidad] Stack de Monitoreo y Alertas"
    description "Vista general del ecosistema de observabilidad que monitorea todos los microservicios."
}

// Vista detallada de métricas y monitoreo
container observabilitySystem "observability_metrics" {
    include observabilitySystem.prometheus
    include observabilitySystem.grafana
    include observabilitySystem.shortTermMetrics
    include observabilitySystem.longTermMetrics
    title "[Métricas] Stack de Prometheus y Grafana"
    description "Vista detallada del sistema de métricas, dashboards y alertas."
}

// Vista de logging centralizado
container observabilitySystem "observability_logging" {
    include observabilitySystem.loki
    include observabilitySystem.distributedLogs
    title "[Logging] Sistema de Logs Centralizados"
    description "Vista del sistema de agregación y consulta de logs distribuidos."
}

// Vista de health checks - Sistema completo
systemLandscape "health_monitoring" {
    include observabilitySystem
    include notification identity trackAndTrace sitaMessaging apiGateway
    title "[Health Checks] Monitoreo de Salud de Servicios"
    description "Vista de sistemas monitoreados por la plataforma de observabilidad."
}

// // Vista detallada de health checks por componentes
// component observabilitySystem.prometheus "prometheus_health_monitoring" {
//     include observabilitySystem.prometheus.server
//     title "[Prometheus] Health Check Monitoring"
//     description "Vista detallada del servidor Prometheus y sus conexiones de health check."
// }

// // Vista de métricas por servicio - API
// component notification.api "notification_api_observability" {
//     include notification.api.healthCheck
//     include notification.api.metricsCollector
//     include notification.api.logger
//     title "[Notification API] Componentes de Observabilidad"
//     description "Vista detallada de los componentes de observabilidad del API de notificaciones."
// }

// // Vista de métricas por servicio - Processor
// component notification.notificationProcessor "notification_processor_observability" {
//     include notification.notificationProcessor.metricsCollector
//     include notification.notificationProcessor.logger
//     title "[Notification Processor] Componentes de Observabilidad"
//     description "Vista detallada de los componentes de observabilidad del procesador de notificaciones."
// }

// // Vista de métricas de Track & Trace - API Unificada
// component trackAndTrace.trackingAPI "track_trace_api_observability" {
//     include trackAndTrace.trackingAPI.healthCheck
//     include trackAndTrace.trackingAPI.metricsCollector
//     include trackAndTrace.trackingAPI.logger
//     title "[Track & Trace API] Componentes de Observabilidad Unificada"
//     description "Vista detallada de los componentes de observabilidad del API unificado (ingest + query) con métricas CQRS."
// }

// // Vista de métricas de Track & Trace - Event Processor
// component trackAndTrace.trackingEventProcessor "track_trace_processor_observability" {
//     include trackAndTrace.trackingEventProcessor.metricsCollector
//     include trackAndTrace.trackingEventProcessor.logger
//     title "[Track & Trace Processor] Componentes de Observabilidad"
//     description "Vista detallada de los componentes de observabilidad del procesador de eventos."
// }

// // Vista de tracing distribuido (Fase 2)
// container observabilitySystem "distributed_tracing" {
//     include observabilitySystem.jaeger
//     include observabilitySystem.distributedTraces
//     title "[Tracing] Sistema de Trazas Distribuidas"
//     description "Vista del sistema de tracing distribuido para seguimiento de requests entre servicios."
// }

// // Vista de métricas SITA Messaging - API
// component sitaMessaging.api "sita_messaging_api_observability" {
//     include sitaMessaging.api.metricsCollector
//     include sitaMessaging.api.logger
//     title "[SITA Messaging API] Componentes de Observabilidad"
//     description "Vista detallada de los componentes de observabilidad del API de mensajería SITA."
// }

// // Vista de métricas SITA Messaging - Event Processor
// component sitaMessaging.eventProcessor "sita_messaging_processor_observability" {
//     include sitaMessaging.eventProcessor.metricsCollector
//     include sitaMessaging.eventProcessor.logger
//     title "[SITA Messaging Processor] Componentes de Observabilidad"
//     description "Vista detallada de los componentes de observabilidad del procesador de eventos SITA."
// }

// // Vista de métricas Identity Service
// component identity.service "identity_service_observability" {
//     include identity.service.metricsCollector
//     include identity.service.logger
//     title "[Identity Service] Componentes de Observabilidad"
//     description "Vista detallada de los componentes de observabilidad del servicio de identidad."
// }
