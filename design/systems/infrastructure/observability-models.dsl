observabilitySystem = softwareSystem "Observability Platform" {
    description "Plataforma centralizada de observabilidad, monitoreo y alertas para toda la arquitectura de microservicios."
    tags "Observability" "001 - Fase 1"

    // Stack de Métricas
    prometheus = application "Prometheus" {
        technology "Prometheus"
        description "Sistema de monitoreo y base de datos de series temporales para métricas."
        tags "Prometheus" "Metrics" "001 - Fase 1"

        metricsServer = component "Metrics Server" {
            technology "Prometheus"
            description "Recolecta y almacena métricas de todos los microservicios mediante scraping HTTP."
            tags "001 - Fase 1"
        }

        alertManager = component "Alert Manager" {
            technology "Prometheus AlertManager"
            description "Procesa reglas de alertas y envía notificaciones a canales configurados (email, Slack, webhooks)."
            tags "001 - Fase 1"
        }

        pushGateway = component "Push Gateway" {
            technology "Prometheus Push Gateway"
            description "Recibe métricas de jobs batch y servicios efímeros que no pueden ser scrapeados."
            tags "001 - Fase 1"
        }
    }

    // Stack de Visualización
    grafana = application "Grafana" {
        technology "Grafana"
        description "Plataforma de dashboards y visualización de métricas y logs."
        tags "Grafana" "Visualization" "001 - Fase 1"

        visualizationDashboards = component "Visualization Dashboards" {
            technology "Grafana Dashboards"
            description "Paneles de control personalizados para visualización de métricas de negocio y operacionales."
            tags "001 - Fase 1"
        }

        alertingEngine = component "Alerting Engine" {
            technology "Grafana Alerts"
            description "Motor de alertas unificado con reglas configurables y múltiples canales de notificación."
            tags "001 - Fase 1"
        }

        accessControl = component "Access Control" {
            technology "Grafana RBAC"
            description "Control de acceso basado en roles para dashboards y funcionalidades por usuario."
            tags "001 - Fase 1"
        }
    }

    // Stack de Logging
    loki = application "Loki" {
        technology "Grafana Loki"
        description "Sistema de agregación y consulta de logs distribuidos."
        tags "Loki" "Logging" "001 - Fase 1"

        logsAggregator = component "Logs Aggregator" {
            technology "Loki"
            description "Centraliza y indexa logs de todos los microservicios con etiquetas para consultas eficientes."
            tags "001 - Fase 1"
        }

        logsCollector = component "Logs Collector" {
            technology "Promtail"
            description "Agente distribuido que recolecta logs de archivos y containers, enviándolos a Loki."
            tags "001 - Fase 1"
        }
    }

    // Stack de Tracing (Fase 2)
    jaeger = application "Jaeger" {
        technology "Jaeger"
        description "Sistema de tracing distribuido para seguimiento de requests entre servicios."
        tags "Jaeger" "Tracing" "002 - Fase 2"

        tracingCollector = component "Tracing Collector" {
            technology "Jaeger"
            description "Recolecta spans de trazabilidad distribuida de todos los microservicios."
            tags "002 - Fase 2"
        }

        tracingUI = component "Tracing UI" {
            technology "Jaeger UI"
            description "Interfaz web para consultar, filtrar y visualizar trazas distribuidas de requests."
            tags "002 - Fase 2"
        }

        tracingAgent = component "Tracing Agent" {
            technology "Jaeger Agent"
            description "Agente local que bufferiza spans y los reenvía al collector de manera optimizada."
            tags "002 - Fase 2"
        }
    }

    // Almacenamiento
    shortTermMetrics = store "Short Term Metrics" {
        technology "Prometheus TSDB"
        description "Base de datos de series temporales para métricas de alta frecuencia con retención de 15 días."
        tags "Storage" "TSDB" "001 - Fase 1"
    }

    longTermMetrics = store "Long Term Metrics" {
        technology "AWS S3 + Thanos"
        description "Almacenamiento de largo plazo para métricas históricas con compresión y retención de 2+ años."
        tags "Storage" "S3" "002 - Fase 2"
    }

    distributedLogs = store "Distributed Logs" {
        technology "AWS S3"
        description "Almacenamiento escalable de logs con compresión, particionado y políticas de lifecycle."
        tags "Storage" "S3" "001 - Fase 1"
    }

    distributedTraces = store "Distributed Traces" {
        technology "Elasticsearch/Cassandra"
        description "Almacenamiento de trazas distribuidas con indexado por correlationId y filtrado eficiente."
        tags "Storage" "Elasticsearch" "002 - Fase 2"
    }

    // Relaciones internas
    prometheus.metricsServer -> shortTermMetrics "Almacena métricas" "Prometheus TSDB" "001 - Fase 1"
    prometheus.alertManager -> notification.api.notificationController "Envía alertas" "HTTPS" "001 - Fase 1"
    grafana.visualizationDashboards -> prometheus.metricsServer "Query métricas" "PromQL" "001 - Fase 1"
    grafana.visualizationDashboards -> loki.logsAggregator "Query logs" "LogQL" "001 - Fase 1"
    grafana.alertingEngine -> notification.api.notificationController "Envía alertas" "HTTPS" "001 - Fase 1"
    loki.logsAggregator -> distributedLogs "Almacena logs" "AWS S3" "001 - Fase 1"
    jaeger.tracingCollector -> distributedTraces "Almacena traces" "" "002 - Fase 2"

    // Relaciones con servicios monitoreados - Metrics
    prometheus.metricsServer -> notification.api.healthCheck "Scrape métricas y health" "HTTP" "001 - Fase 1"
    prometheus.metricsServer -> trackAndTrace.trackingAPI.metricsCollector "Scrape métricas unificadas (ingest + query)" "HTTP" "001 - Fase 1"
    prometheus.metricsServer -> trackAndTrace.trackingEventProcessor.metricsCollector "Scrape métricas" "HTTP" "001 - Fase 1"
    prometheus.metricsServer -> sitaMessaging.eventProcessor.metricsCollector "Scrape métricas" "HTTP" "001 - Fase 1"
    prometheus.metricsServer -> sitaMessaging.sender.metricsCollector "Scrape métricas" "HTTP" "001 - Fase 1"
    prometheus.metricsServer -> identity.keycloakServer "Scrape métricas nativas de Keycloak" "HTTP" "001 - Fase 1"
    prometheus.metricsServer -> apiGateway.reverseProxyGateway.healthCheck "Scrape métricas y health" "HTTP" "001 - Fase 1"

    loki.logsCollector -> notification.api.structuredLogger "Recolecta logs del API" "File System" "001 - Fase 1"
    loki.logsCollector -> notification.processor.structuredLogger "Recolecta logs del processor" "File System" "001 - Fase 1"
    loki.logsCollector -> trackAndTrace.trackingAPI.structuredLogger "Recolecta logs unificados (ingest + query)" "File System" "001 - Fase 1"
    loki.logsCollector -> trackAndTrace.trackingEventProcessor.structuredLogger "Recolecta logs" "File System" "001 - Fase 1"
    loki.logsCollector -> sitaMessaging.eventProcessor.structuredLogger "Recolecta logs" "File System" "001 - Fase 1"
    loki.logsCollector -> sitaMessaging.sender.structuredLogger "Recolecta logs" "File System" "001 - Fase 1"
    loki.logsCollector -> identity.keycloakServer "Recolecta logs nativos de Keycloak" "File System" "001 - Fase 1"

    // Health Checks monitoring
    prometheus.metricsServer -> notification.api.healthCheck "Health check" "HTTP" "001 - Fase 1"
    prometheus.metricsServer -> notification.processor.healthCheck "Health check" "HTTP" "001 - Fase 1"
    prometheus.metricsServer -> trackAndTrace.trackingAPI.healthCheck "Health check unificado (ingest + query)" "HTTP" "001 - Fase 1"
    prometheus.metricsServer -> trackAndTrace.trackingEventProcessor.healthCheck "Health check" "HTTP" "001 - Fase 1"
    prometheus.metricsServer -> trackAndTrace.trackingDashboard.healthCheck "Health check" "HTTP" "001 - Fase 1"
    prometheus.metricsServer -> sitaMessaging.eventProcessor.healthCheck "Health check" "HTTP" "001 - Fase 1"
    prometheus.metricsServer -> sitaMessaging.sender.healthCheck "Health check" "HTTP" "001 - Fase 1"
    prometheus.metricsServer -> apiGateway.reverseProxyGateway.healthCheck "Health check" "HTTP" "001 - Fase 1"
    prometheus.metricsServer -> identity.keycloakServer "Health check nativo de Keycloak" "HTTP" "001 - Fase 1"

    // Metrics collection
    prometheus.metricsServer -> notification.api.metricsCollector "Scrape métricas" "HTTP" "001 - Fase 1"
    prometheus.metricsServer -> notification.processor.metricsCollector "Scrape métricas" "HTTP" "001 - Fase 1"
    prometheus.metricsServer -> trackAndTrace.trackingAPI.metricsCollector "Scrape métricas" "HTTP" "001 - Fase 1"
    prometheus.metricsServer -> trackAndTrace.trackingDashboard.metricsCollector "Scrape métricas" "HTTP" "001 - Fase 1"
    prometheus.metricsServer -> apiGateway.reverseProxyGateway.metricsCollector "Scrape métricas" "HTTP" "001 - Fase 1"

    // Logs collection
    loki.logsCollector -> apiGateway.reverseProxyGateway.structuredLogger "Recolecta logs" "File System" "001 - Fase 1"
    loki.logsCollector -> trackAndTrace.trackingDashboard.structuredLogger "Recolecta logs" "File System" "001 - Fase 1"

    // Usuarios y acceso
    admin -> grafana.visualizationDashboards "Monitorea servicios" "HTTPS" "001 - Fase 1"
    operationalUser -> grafana.visualizationDashboards "Monitorea operaciones" "HTTPS" "001 - Fase 1"
}
