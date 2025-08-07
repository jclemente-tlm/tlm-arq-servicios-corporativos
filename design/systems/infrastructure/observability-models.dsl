// ========================================
// OBSERVABILITY SYSTEM - EXTERNAL STACK
// ========================================

observabilitySystem = softwareSystem "Observability Platform" {
    description "Stack empresarial de observabilidad para monitoreo transversal de aplicaciones y servicios"
    tags "External System" "Observability" "001 - Fase 1"

    // Stack de observabilidad externo
    dashboardEngine = container "Grafana Dashboard Engine" {
        technology "Grafana OSS/Enterprise"
        description "Dashboards y alertas para monitoreo"
        tags "External" "Dashboard" "001 - Fase 1"
    }

    metricsCollector = container "Prometheus Metrics Platform" {
        technology "Prometheus + AlertManager + Exporters"
        description "Recolección y almacenamiento de métricas"
        tags "External" "Metrics" "001 - Fase 1"
    }

    logAggregator = container "Loki Log Aggregation" {
        technology "Grafana Loki + Promtail"
        description "Centralización y consulta de logs"
        tags "External" "Logging" "001 - Fase 1"
    }

    tracingPlatform = container "Jaeger Tracing Platform" {
        technology "Jaeger All-in-One + OpenTelemetry"
        description "Seguimiento de requests entre servicios"
        tags "External" "Tracing" "002 - Fase 2"
    }
}

// ========================================
// RELACIONES CON SERVICIOS CORPORATIVOS
// ========================================
// NOTA: Las relaciones de observabilidad se han movido a los archivos de modelo
// de cada servicio correspondiente para mayor cohesión y claridad.
// Ver: api-gateway-models.dsl, notification-models.dsl, track-and-trace-models.dsl,
//      sita-messaging-models.dsl, identity-models.dsl

// Acceso de administradores
admin -> observabilitySystem.dashboardEngine "Consulta dashboards y alertas" "HTTPS" "001 - Fase 1"
operationalUser -> observabilitySystem.dashboardEngine "Monitorea operaciones" "HTTPS" "001 - Fase 1"
