sitaMessaging = softwareSystem "SITA Messaging" {
    description "Sistema de generación y entrega de mensajes SITA"
    tags "SITA Messaging" "001 - Fase 1"

    // ========================================
    // DATA STORES - ARQUITECTURA SIMPLE
    // ========================================
    // DECISIÓN: PostgreSQL como cola inicial, migración futura a SNS+SQS según volumen
    // INTEGRACIÓN: Consume eventos de Track & Trace
    // DELIVERY: Genera y envía archivos SITA a partners

    sitaMessagingDatabase = store "SITA Messaging Database" {
        description "PostgreSQL para datos SITA y cola de eventos"
        technology "PostgreSQL"
        tags "Database" "PostgreSQL" "001 - Fase 1"

        eventsQueue = component "Events Queue Table" {
            technology "PostgreSQL Table"
            description "Cola de eventos de Track & Trace para procesamiento SITA"
            tags "Database Table" "Event Queue" "001 - Fase 1"
        }

        templates = component "Templates Table" {
            technology "PostgreSQL Table"
            description "Templates SITA por partner y tipo de mensaje"
            tags "Database Table" "Templates" "001 - Fase 1"
        }

        configuration = component "Configuration Table" {
            technology "PostgreSQL Table"
            description "Configuración por tenant y partner"
            tags "Database Table" "Configuration" "001 - Fase 1"
        }

        deliveryLog = component "Delivery Log Table" {
            technology "PostgreSQL Table"
            description "Log de entregas y confirmaciones de partners"
            tags "Database Table" "Audit" "001 - Fase 1"
        }
    }

    fileStorage = store "SITA File Storage" {
        technology "S3-Compatible Storage"
        description "Storage agnóstico para archivos SITA generados"
        tags "File Storage" "S3-Compatible" "001 - Fase 1"
    }

    // ========================================
    // EVENT PROCESSOR - INGESTA Y GENERACIÓN
    // ========================================
    eventProcessor = container "Event Processor" {
        technology "C#, .NET 8, Worker Service"
        description "Consume eventos de Track & Trace y genera archivos SITA"
        tags "CSharp" "001 - Fase 1"

        eventConsumer = component "Event Consumer" {
            technology "C#, .NET 8"
            description "Consume y deserializa eventos de Track & Trace desde cola PostgreSQL"
            tags "Event Processing" "001 - Fase 1"
        }

        eventOrchestrator = component "Event Orchestrator" {
            technology "C#, .NET 8"
            description "Coordina generación de archivos SITA y registro de mensajes para envío"
            tags "Event Orchestration" "001 - Fase 1"
        }

        templateEngine = component "Template Engine" {
            technology "C#, .NET 8, Scriban"
            description "Carga y procesa plantillas SITA específicas por partner y tipo de mensaje"
            tags "Template Processing" "001 - Fase 1"
        }

        sitaFileGenerator = component "SITA File Generator" {
            technology "C#, .NET 8"
            description "Genera archivos SITA finales usando plantillas procesadas"
            tags "File Generation" "001 - Fase 1"
        }

        configManager = component "Configuration Manager" {
            technology "C#, .NET 8, EF Core"
            description "Gestiona configuraciones del servicio y por tenant"
            tags "Configuration" "Multi-Tenant" "001 - Fase 1"
        }

        // Observabilidad esencial
        healthCheck = component "Health Check" {
            technology "ASP.NET Core Health Checks"
            description "Valida salud del Event Processor"
            tags "Observability" "001 - Fase 1"
        }

        metricsCollector = component "Metrics Collector" {
            technology "Prometheus.NET"
            description "Recolecta métricas de procesamiento"
            tags "Observability" "001 - Fase 1"
        }

        structuredLogger = component "Structured Logger" {
            technology "Serilog"
            description "Logging estructurado para trazabilidad"
            tags "Observability" "001 - Fase 1"
        }
    }

    // ========================================
    // MESSAGE SENDER - ENVÍO A PARTNERS
    // ========================================
    sender = container "Message Sender" {
        technology "C#, .NET 8, Background Service"
        description "Envía archivos SITA generados a partners externos"
        tags "CSharp" "Background Service" "001 - Fase 1"

        sendingWorker = component "Sending Worker" {
            technology "C#, .NET 8, Quartz.NET"
            description "Orquesta envío programado de archivos SITA a partners externos"
            tags "Worker Service" "Scheduling" "001 - Fase 1"
        }

        fileFetcher = component "File Fetcher" {
            technology "C#, .NET 8, S3 SDK"
            description "Obtiene archivos SITA generados desde storage para envío a partners"
            tags "File Retrieval" "001 - Fase 1"
        }

        partnerSender = component "Partner Sender" {
            technology "C#, .NET 8, SFTP Client"
            description "Transmite archivos SITA a partners externos vía SFTP/HTTP"
            tags "Partner Integration" "001 - Fase 1"
        }

        deliveryTracker = component "Delivery Tracker" {
            technology "C#, .NET 8"
            description "Registra confirmaciones de entrega y actualiza estado de mensajes"
            tags "Delivery Tracking" "001 - Fase 1"
        }

        configManager = component "Configuration Manager" {
            technology "C#, .NET 8, EF Core"
            description "Gestiona configuraciones del servicio y por tenant"
            tags "Configuration" "Multi-Tenant" "001 - Fase 1"
        }

        // Observabilidad esencial
        healthCheck = component "Health Check" {
            technology "ASP.NET Core Health Checks"
            description "Valida salud del Message Sender"
            tags "Observability" "001 - Fase 1"
        }

        metricsCollector = component "Metrics Collector" {
            technology "Prometheus.NET"
            description "Recolecta métricas de envío"
            tags "Observability" "001 - Fase 1"
        }

        structuredLogger = component "Structured Logger" {
            technology "Serilog"
            description "Logging estructurado para trazabilidad"
            tags "Observability" "001 - Fase 1"
        }
    }

    // ========================================
    // RELACIONES INTERNAS - ACCESO A DATOS
    // ========================================

    // Event Processor - Flujo principal
    eventProcessor.eventConsumer -> sitaMessagingDatabase.eventsQueue "Consume eventos de Track & Trace" "PostgreSQL" "001 - Fase 1"
    eventProcessor.eventConsumer -> eventProcessor.eventOrchestrator "Delega eventos para procesamiento" "In-Memory" "001 - Fase 1"
    eventProcessor.eventOrchestrator -> eventProcessor.templateEngine "Solicita procesamiento de plantilla" "In-Memory" "001 - Fase 1"
    eventProcessor.templateEngine -> sitaMessagingDatabase.templates "Lee templates SITA por partner" "PostgreSQL" "001 - Fase 1"
    eventProcessor.templateEngine -> eventProcessor.sitaFileGenerator "Entrega plantilla procesada" "In-Memory" "001 - Fase 1"
    eventProcessor.sitaFileGenerator -> fileStorage "Almacena archivos SITA generados" "S3-Compatible API" "001 - Fase 1"
    eventProcessor.eventOrchestrator -> sitaMessagingDatabase.deliveryLog "Registra mensaje para envío posterior" "PostgreSQL" "001 - Fase 1"

    // Event Processor - Uso de configuración (vía DI, no acceso directo)
    // Nota: Componentes reciben IConfigurationService por constructor
    # eventProcessor.sitaFileGenerator -> sitaMessagingDatabase.configuration "Lee configuración de templates por tenant" "PostgreSQL" "001 - Fase 1"
    eventProcessor.eventOrchestrator -> sitaMessagingDatabase.configuration "Lee reglas de procesamiento por tenant" "PostgreSQL" "001 - Fase 1"

    // Sender - Flujo principal orquestado por sendingWorker
    sender.sendingWorker -> sitaMessagingDatabase.deliveryLog "Consulta archivos pendientes de envío" "PostgreSQL" "001 - Fase 1"
    sender.sendingWorker -> sender.fileFetcher "Solicita descarga de archivos específicos" "In-Memory" "001 - Fase 1"
    sender.fileFetcher -> fileStorage "Recupera archivos SITA desde storage" "S3-Compatible API" "001 - Fase 1"
    sender.sendingWorker -> sender.partnerSender "Coordina envío de archivos" "In-Memory" "001 - Fase 1"
    sender.partnerSender -> airlines "Envía archivos a aerolíneas" "HTTPS/Email" "001 - Fase 1"
    sender.partnerSender -> descartes "Envía archivos a Descartes" "HTTPS/FTP" "001 - Fase 1"
    sender.sendingWorker -> sender.deliveryTracker "Coordina actualización de estado" "In-Memory" "001 - Fase 1"
    sender.deliveryTracker -> sitaMessagingDatabase.deliveryLog "Actualiza estado de entregas" "PostgreSQL" "001 - Fase 1"

    // Sender - Uso de configuración (vía DI, no acceso directo)
    // Nota: Componentes reciben IConfigurationService por constructor
    # sender.partnerSender -> sitaMessagingDatabase.configuration "Lee credenciales y configuración partners" "PostgreSQL" "001 - Fase 1"
    # sender.deliveryTracker -> sitaMessagingDatabase.configuration "Lee configuración de tracking" "PostgreSQL" "001 - Fase 1"

    // ========================================
    // RELACIONES EXTERNAS - CONFIGURACIÓN
    // ========================================

    // Configuración externa - Solo config managers acceden directamente
    eventProcessor.configManager -> configPlatform.configService "Obtiene configuración por tenant" "HTTPS/REST" "001 - Fase 1"
    eventProcessor.configManager -> sitaMessagingDatabase.configuration "Lee metadatos estáticos tenant" "PostgreSQL" "001 - Fase 1"
    sender.configManager -> configPlatform.configService "Obtiene credenciales partners" "HTTPS/REST" "001 - Fase 1"
    sender.configManager -> sitaMessagingDatabase.configuration "Lee metadatos estáticos tenant" "PostgreSQL" "001 - Fase 1"

    // ========================================
    // OBSERVABILIDAD - EVENT PROCESSOR
    // ========================================

    // Health Checks
    eventProcessor.healthCheck -> sitaMessagingDatabase "Ejecuta health check" "PostgreSQL" "001 - Fase 1"
    eventProcessor.healthCheck -> fileStorage "Verifica conectividad storage" "S3-Compatible API" "001 - Fase 1"

    // Logging estructurado
    eventProcessor.eventConsumer -> eventProcessor.structuredLogger "Registra procesamiento de eventos" "Serilog" "001 - Fase 1"
    eventProcessor.eventOrchestrator -> eventProcessor.structuredLogger "Registra orquestación y transacciones" "Serilog" "001 - Fase 1"
    eventProcessor.templateEngine -> eventProcessor.structuredLogger "Registra procesamiento de plantillas" "Serilog" "001 - Fase 1"
    eventProcessor.sitaFileGenerator -> eventProcessor.structuredLogger "Registra generación de archivos" "Serilog" "001 - Fase 1"
    eventProcessor.healthCheck -> eventProcessor.structuredLogger "Registra health checks" "Serilog" "001 - Fase 1"

    // Métricas
    eventProcessor.eventConsumer -> eventProcessor.metricsCollector "Publica métricas de eventos" "Prometheus" "001 - Fase 1"
    eventProcessor.eventOrchestrator -> eventProcessor.metricsCollector "Publica métricas de orquestación" "Prometheus" "001 - Fase 1"
    eventProcessor.templateEngine -> eventProcessor.metricsCollector "Publica métricas de templates" "Prometheus" "001 - Fase 1"
    eventProcessor.sitaFileGenerator -> eventProcessor.metricsCollector "Publica métricas de generación" "Prometheus" "001 - Fase 1"
    eventProcessor.healthCheck -> eventProcessor.metricsCollector "Publica métricas de health status" "Prometheus" "001 - Fase 1"

    // ========================================
    // OBSERVABILIDAD - SENDER
    // ========================================

    // Health Checks
    sender.healthCheck -> sitaMessagingDatabase "Ejecuta health check" "PostgreSQL" "001 - Fase 1"
    sender.healthCheck -> fileStorage "Verifica conectividad storage" "S3-Compatible API" "001 - Fase 1"

    // Logging estructurado
    sender.sendingWorker -> sender.structuredLogger "Registra orquestación de envíos" "Serilog" "001 - Fase 1"
    sender.fileFetcher -> sender.structuredLogger "Registra descarga de archivos" "Serilog" "001 - Fase 1"
    sender.partnerSender -> sender.structuredLogger "Registra envíos a partners" "Serilog" "001 - Fase 1"
    sender.deliveryTracker -> sender.structuredLogger "Registra confirmaciones de entrega" "Serilog" "001 - Fase 1"
    sender.healthCheck -> sender.structuredLogger "Registra health checks" "Serilog" "001 - Fase 1"

    // Métricas
    sender.sendingWorker -> sender.metricsCollector "Publica métricas de scheduling" "Prometheus" "001 - Fase 1"
    sender.fileFetcher -> sender.metricsCollector "Publica métricas de descarga" "Prometheus" "001 - Fase 1"
    sender.partnerSender -> sender.metricsCollector "Publica métricas de envío" "Prometheus" "001 - Fase 1"
    sender.deliveryTracker -> sender.metricsCollector "Publica métricas de tracking" "Prometheus" "001 - Fase 1"
    sender.healthCheck -> sender.metricsCollector "Publica métricas de health status" "Prometheus" "001 - Fase 1"

    // ========================================
    // RELACIONES EXTERNAS - OBSERVABILIDAD
    // ========================================

    // Métricas
    sitaMessaging.eventProcessor.metricsCollector -> observabilitySystem.metricsCollector "Expone métricas de procesamiento" "HTTP" "001 - Fase 1"
    sitaMessaging.sender.metricsCollector -> observabilitySystem.metricsCollector "Expone métricas de envío" "HTTP" "001 - Fase 1"

    // Health Checks
    sitaMessaging.eventProcessor.healthCheck -> observabilitySystem.metricsCollector "Expone health checks Processor" "HTTP" "001 - Fase 1"
    sitaMessaging.sender.healthCheck -> observabilitySystem.metricsCollector "Expone health checks Sender" "HTTP" "001 - Fase 1"

    // Logs estructurados
    sitaMessaging.eventProcessor.structuredLogger -> observabilitySystem.logAggregator "Envía logs estructurados Processor" "HTTP" "001 - Fase 1"
    sitaMessaging.sender.structuredLogger -> observabilitySystem.logAggregator "Envía logs estructurados Sender" "HTTP" "001 - Fase 1"

    // Tracing distribuido (Fase 2)
    sitaMessaging.eventProcessor.structuredLogger -> observabilitySystem.tracingPlatform "Envía trazas distribuidas Processor" "OpenTelemetry" "002 - Fase 2"
    sitaMessaging.sender.structuredLogger -> observabilitySystem.tracingPlatform "Envía trazas distribuidas Sender" "OpenTelemetry" "002 - Fase 2"
}
