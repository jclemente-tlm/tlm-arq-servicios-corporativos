observabilitySystem = softwareSystem "Observability Platform" {
    description "Plataforma centralizada de observabilidad, monitoreo y alertas para toda la arquitectura de microservicios."
    tags "Observability" "001 - Fase 1"

    // Stack de Métricas
    prometheus = application "Prometheus" {
        technology "Prometheus"
        description "Sistema de monitoreo y base de datos de series temporales para métricas."
        tags "Prometheus" "Metrics" "001 - Fase 1"

        server = component "Prometheus Server" {
            technology "Prometheus"
            description "Servidor principal que scrapes métricas de todos los servicios."
            tags "001 - Fase 1"
        }

        alertManager = component "Alert Manager" {
            technology "Prometheus AlertManager"
            description "Gestiona alertas basadas en métricas y las envía a canales configurados."
            tags "001 - Fase 1"
        }

        pushGateway = component "Push Gateway" {
            technology "Prometheus Push Gateway"
            description "Gateway para recibir métricas de jobs batch o servicios sin scraping."
            tags "001 - Fase 1"
        }
    }

    // Stack de Visualización
    grafana = application "Grafana" {
        technology "Grafana"
        description "Plataforma de dashboards y visualización de métricas y logs."
        tags "Grafana" "Visualization" "001 - Fase 1"

        dashboards = component "Dashboards" {
            technology "Grafana Dashboards"
            description "Dashboards predefinidos para cada microservicio y métricas de negocio."
            tags "001 - Fase 1"
        }

        alerting = component "Grafana Alerting" {
            technology "Grafana Alerts"
            description "Sistema de alertas unificado con múltiples canales de notificación."
            tags "001 - Fase 1"
        }

        userManagement = component "User Management" {
            technology "Grafana Auth"
            description "Gestión de usuarios y permisos para acceso a dashboards."
            tags "001 - Fase 1"
        }
    }

    // Stack de Logging
    loki = application "Loki" {
        technology "Grafana Loki"
        description "Sistema de agregación y consulta de logs distribuidos."
        tags "Loki" "Logging" "001 - Fase 1"

        logAggregator = component "Log Aggregator" {
            technology "Loki"
            description "Agrega logs de todos los servicios con labels para filtrado."
            tags "001 - Fase 1"
        }

        promtail = component "Promtail" {
            technology "Promtail"
            description "Agente que recolecta logs de cada servicio y los envía a Loki."
            tags "001 - Fase 1"
        }
    }

    // Stack de Tracing (Fase 2)
    jaeger = application "Jaeger" {
        technology "Jaeger"
        description "Sistema de tracing distribuido para seguimiento de requests entre servicios."
        tags "Jaeger" "Tracing" "002 - Fase 2"

        collector = component "Jaeger Collector" {
            technology "Jaeger"
            description "Recolecta spans de tracing de todos los servicios."
            tags "002 - Fase 2"
        }

        query = component "Jaeger Query" {
            technology "Jaeger UI"
            description "Interface web para consultar y visualizar trazas distribuidas."
            tags "002 - Fase 2"
        }

        agent = component "Jaeger Agent" {
            technology "Jaeger Agent"
            description "Agente local que recolecta spans y los envía al collector."
            tags "002 - Fase 2"
        }
    }

    // Almacenamiento
    metricsStorage = store "Metrics Storage" {
        technology "Prometheus TSDB"
        description "Base de datos de series temporales para métricas de corto plazo (15 días)."
        tags "Storage" "TSDB" "001 - Fase 1"
    }

    longTermStorage = store "Long Term Storage" {
        technology "AWS S3 + Thanos"
        description "Almacenamiento de largo plazo para métricas históricas (2+ años)."
        tags "Storage" "S3" "002 - Fase 2"
    }

    logsStorage = store "Logs Storage" {
        technology "AWS S3"
        description "Almacenamiento de logs con compresión y lifecycle policies."
        tags "Storage" "S3" "001 - Fase 1"
    }

    tracingStorage = store "Tracing Storage" {
        technology "Elasticsearch/Cassandra"
        description "Almacenamiento de traces distribuidos con indexado eficiente."
        tags "Storage" "Elasticsearch" "002 - Fase 2"
    }

    // Relaciones internas
    prometheus.server -> metricsStorage "Almacena métricas" "001 - Fase 1"
    prometheus.alertManager -> notification.api.controller "Envía alertas" "HTTPS" "001 - Fase 1"
    grafana.dashboards -> prometheus.server "Query métricas" "PromQL" "001 - Fase 1"
    grafana.dashboards -> loki.logAggregator "Query logs" "LogQL" "001 - Fase 1"
    grafana.alerting -> notification.api.controller "Envía alertas" "HTTPS" "001 - Fase 1"
    loki.logAggregator -> logsStorage "Almacena logs" "S3 API" "001 - Fase 1"
    jaeger.collector -> tracingStorage "Almacena traces" "002 - Fase 2"

    // Relaciones con servicios monitoreados - Metrics
    prometheus.server -> notification.api.metricsCollector "Scrape métricas" "/metrics" "001 - Fase 1"
    prometheus.server -> trackAndTrace.ingestApi.metricsCollector "Scrape métricas" "/metrics" "001 - Fase 1"
    prometheus.server -> trackAndTrace.queryApi.metricsCollector "Scrape métricas" "/metrics" "001 - Fase 1"
    prometheus.server -> trackAndTrace.eventProcessor.metricsCollector "Scrape métricas" "/metrics" "001 - Fase 1"
    prometheus.server -> sitaMessaging.eventProcessor.metricsCollector "Scrape métricas" "/metrics" "001 - Fase 1"
    prometheus.server -> sitaMessaging.sender.metricsCollector "Scrape métricas" "/metrics" "001 - Fase 1"
    prometheus.server -> identity.service.metricsCollector "Scrape métricas" "/metrics" "001 - Fase 1"
    prometheus.server -> apiGateway.yarp.healthCheck "Scrape métricas y health" "/metrics" "001 - Fase 1"

    loki.promtail -> notification.api.logger "Recolecta logs" "Log files" "001 - Fase 1"
    loki.promtail -> notification.notificationProcessor.logger "Recolecta logs" "Log files" "001 - Fase 1"
    loki.promtail -> trackAndTrace.ingestApi.logger "Recolecta logs" "Log files" "001 - Fase 1"
    loki.promtail -> trackAndTrace.queryApi.logger "Recolecta logs" "Log files" "001 - Fase 1"
    loki.promtail -> trackAndTrace.eventProcessor.logger "Recolecta logs" "Log files" "001 - Fase 1"
    loki.promtail -> sitaMessaging.eventProcessor.logger "Recolecta logs" "Log files" "001 - Fase 1"
    loki.promtail -> sitaMessaging.sender.logger "Recolecta logs" "Log files" "001 - Fase 1"
    loki.promtail -> identity.service.logger "Recolecta logs" "Log files" "001 - Fase 1"

    // Health Checks monitoring
    prometheus.server -> notification.api.healthCheck "Health check" "/health" "001 - Fase 1"
    prometheus.server -> trackAndTrace.ingestApi "Health check" "/health" "001 - Fase 1"
    prometheus.server -> trackAndTrace.queryApi "Health check" "/health" "001 - Fase 1"
    prometheus.server -> sitaMessaging.eventProcessor "Health check" "/health" "001 - Fase 1"
    prometheus.server -> sitaMessaging.sender "Health check" "/health" "001 - Fase 1"
    prometheus.server -> identity.service "Health check" "/health" "001 - Fase 1"

    // Usuarios y acceso
    admin -> grafana.dashboards "Monitorea servicios" "HTTPS" "001 - Fase 1"
    operationalUser -> grafana.dashboards "Monitorea operaciones" "HTTPS" "001 - Fase 1"
}
