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
    include observabilitySystem.metricsStorage
    title "[Métricas] Stack de Prometheus y Grafana"
    description "Vista detallada del sistema de métricas, dashboards y alertas."
}

// Vista de logging centralizado
container observabilitySystem "observability_logging" {
    include observabilitySystem.loki
    include observabilitySystem.logsStorage
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

// // Vista de métricas de Track & Trace - Ingest API
// component trackAndTrace.ingestApi "track_trace_ingest_observability" {
//     include trackAndTrace.ingestApi.healthCheck
//     include trackAndTrace.ingestApi.metricsCollector
//     include trackAndTrace.ingestApi.logger
//     title "[Track & Trace Ingest] Componentes de Observabilidad"
//     description "Vista detallada de los componentes de observabilidad del API de ingesta."
// }

// // Vista de métricas de Track & Trace - Query API
// component trackAndTrace.queryApi "track_trace_query_observability" {
//     include trackAndTrace.queryApi.healthCheck
//     include trackAndTrace.queryApi.metricsCollector
//     include trackAndTrace.queryApi.logger
//     title "[Track & Trace Query] Componentes de Observabilidad"
//     description "Vista detallada de los componentes de observabilidad del API de consultas."
// }

// // Vista de métricas de Track & Trace - Event Processor
// component trackAndTrace.eventProcessor "track_trace_processor_observability" {
//     include trackAndTrace.eventProcessor.metricsCollector
//     include trackAndTrace.eventProcessor.logger
//     title "[Track & Trace Processor] Componentes de Observabilidad"
//     description "Vista detallada de los componentes de observabilidad del procesador de eventos."
// }

// // Vista de tracing distribuido (Fase 2)
// container observabilitySystem "distributed_tracing" {
//     include observabilitySystem.jaeger
//     include observabilitySystem.tracingStorage
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
