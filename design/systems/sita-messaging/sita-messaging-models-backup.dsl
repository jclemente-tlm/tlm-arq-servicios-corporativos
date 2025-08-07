sitaMessaging = softwareSystem "SITA Messaging" {
    description "Sistema de generación y entrega de mensajes SITA"
    tags "SITA Messaging" "001 - Fase 1"

    // ========================================
    // DATA STORES - ARQUITECTURA SIMPLE
    // ========================================
    // DECISIóN: PostgreSQL como cola inicial, migración futura a SNS+SQS según volumen
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

    // Event Processor - Ingesta y generación
    eventProcessor = container "Event Processor" {
        technology "C#, .NET 8, Worker Service"
        description "Consume eventos de Track & Trace y genera archivos SITA"
        tags "CSharp" "001 - Fase 1"

        eventConsumer = component "Event Consumer" {
            technology "C#, .NET 8"
            description "Consume eventos de Track & Trace desde cola PostgreSQL"
            tags "Event Processing" "001 - Fase 1"
        }

        eventOrchestrator = component "Event Orchestrator" {
            technology "C#, .NET 8"
            description "Orquesta generación de archivos SITA y registro de mensajes para envío"
            tags "Event Orchestration" "001 - Fase 1"
        }

        sitaFileGenerator = component "SITA File Generator" {
            technology "C#, .NET 8"
            description "Genera archivos SITA según templates por partner"
            tags "File Generation" "001 - Fase 1"
        }

        configManager = component "Configuration Manager" {
            technology "C#, .NET 8"
            description "Gestiona configuraciones agnósticas desde plataforma externa"
            tags "Configuration" "001 - Fase 1"
        }

        tenantConfigManager = component "Tenant Configuration Manager" {
            technology "C#, .NET 8, EF Core"
            description "Gestiona configuraciones híbridas por tenant (plataforma + BD local)"
            tags "Multi-Tenant" "Configuration" "001 - Fase 1"
        }

        // Observabilidad esencial
        healthCheck = component "Health Check" {
            technology "ASP.NET Core Health Checks"
            description "Valida salud del Event Processor"
            tags "Observability" "001 - Fase 1"
        }

        metricsCollector = component "Metrics Collector" {
            technology "Prometheus.NET"
            description "Recolecta métricas de procesamiento de eventos"
            tags "Observability" "001 - Fase 1"
        }

        structuredLogger = component "Structured Logger" {
            technology "Serilog"
            description "Logging estructurado para trazabilidad"
            tags "Observability" "001 - Fase 1"
        }

        dynamicConfigProcessor = component "Dynamic Configuration Processor" {
            technology "C#, FluentValidation, HttpClient"
            description "Consulta cambios de configuración con polling inteligente (5min), valida nuevas configuraciones contra esquemas y actualiza cache dinámicamente sin reinicio."
            tags "Configuration Events" "Feature Flags" "001 - Fase 1"
        }
    }

    fileStorage = store "SITA File Storage" {
        technology "S3-Compatible Storage (AWS S3, MinIO, etc.)"
        description "Storage agnóstico via IStorageService interface. Proveedor configurable: S3, Azure Blob, MinIO, etc."
        tags "File Storage" "S3-Compatible" "Multi-Provider" "001 - Fase 1"
    }

    sender = container "Message Sender" {
        technology "C#, .NET 8, Background Service"
        description "Envía archivos SITA generados a partners externos"
        tags "CSharp" "Background Service" "001 - Fase 1"

        fileFetcher = component "File Fetcher" {
            technology "C#, .NET 8"
            description "Recupera archivos SITA desde storage para envío"
            tags "File Management" "001 - Fase 1"
        }

        partnerSender = component "Partner Sender" {
            technology "C#, .NET 8, HttpClient"
            description "Envía archivos a partners SITA externos"
            tags "External Communication" "001 - Fase 1"
        }

        deliveryTracker = component "Delivery Tracker" {
            technology "C#, .NET 8"
            description "Rastrea confirmaciones de entrega de partners"
            tags "Tracking" "001 - Fase 1"
        }

        configManager = component "Configuration Manager" {
            technology "C#, .NET 8"
            description "Gestiona configuraciones agnósticas desde plataforma externa"
            tags "Configuration" "001 - Fase 1"
        }

        tenantConfigManager = component "Tenant Configuration Manager" {
            technology "C#, .NET 8, EF Core"
            description "Gestiona configuraciones híbridas por tenant (plataforma + BD local)"
            tags "Multi-Tenant" "Configuration" "001 - Fase 1"
        }

        // Observabilidad esencial
        healthCheck = component "Health Check" {
            technology "ASP.NET Core Health Checks"
            description "Valida salud del Message Sender"
            tags "Observability" "001 - Fase 1"
        }

        metricsCollector = component "Metrics Collector" {
            technology "Prometheus.NET"
            description "Recolecta métricas de envío a partners"
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
    eventProcessor.eventOrchestrator -> eventProcessor.sitaFileGenerator "Solicita generación de archivo SITA" "In-Memory" "001 - Fase 1"
    eventProcessor.eventOrchestrator -> sitaMessagingDatabase.deliveryLog "Registra mensaje para envío posterior" "PostgreSQL" "001 - Fase 1"
    eventProcessor.sitaFileGenerator -> eventProcessor.tenantConfigManager "Consulta configuración híbrida por tenant" "In-Memory" "001 - Fase 1"
    eventProcessor.tenantConfigManager -> eventProcessor.configManager "Consulta configuración dinámica" "In-Memory" "001 - Fase 1"
    eventProcessor.tenantConfigManager -> sitaMessagingDatabase.configuration "Lee metadatos estáticos tenant" "PostgreSQL" "001 - Fase 1"
    eventProcessor.sitaFileGenerator -> sitaMessagingDatabase.templates "Lee templates SITA" "PostgreSQL" "001 - Fase 1"
    eventProcessor.sitaFileGenerator -> sitaMessagingDatabase.configuration "Lee configuración por tenant" "PostgreSQL" "001 - Fase 1"
    eventProcessor.sitaFileGenerator -> fileStorage "Almacena archivos SITA generados" "S3-Compatible API" "001 - Fase 1"

    // Sender - Flujo principal
    sender.fileFetcher -> fileStorage "Recupera archivos SITA" "S3-Compatible API" "001 - Fase 1"
    sender.partnerSender -> sender.tenantConfigManager "Consulta configuración híbrida partners" "In-Memory" "001 - Fase 1"
    sender.tenantConfigManager -> sender.configManager "Consulta credenciales dinámicas" "In-Memory" "001 - Fase 1"
    sender.tenantConfigManager -> sitaMessagingDatabase.configuration "Lee metadatos estáticos tenant" "PostgreSQL" "001 - Fase 1"
    sender.partnerSender -> airlines "Envía archivos a aerolíneas" "HTTPS/Email" "001 - Fase 1"
    sender.partnerSender -> descartes "Envía archivos a Descartes" "HTTPS/FTP" "001 - Fase 1"
    sender.deliveryTracker -> sitaMessagingDatabase.deliveryLog "Actualiza estado de entregas" "PostgreSQL" "001 - Fase 1"

    // ========================================
    // RELACIONES EXTERNAS - CONFIGURACIÓN
    // ========================================

    // Configuración externa - Solo config managers acceden directamente
    eventProcessor.configManager -> configPlatform.configService "Obtiene configuración por tenant" "HTTPS/REST" "001 - Fase 1"
    sender.configManager -> configPlatform.configService "Obtiene credenciales y configuración partners" "HTTPS/REST" "001 - Fase 1"

    // ========================================
    // OBSERVABILIDAD - EVENT PROCESSOR
    // ========================================

    // Health Checks
    eventProcessor.healthCheck -> sitaMessagingDatabase "Ejecuta health check" "PostgreSQL" "001 - Fase 1"
    eventProcessor.healthCheck -> fileStorage "Verifica conectividad storage" "S3-Compatible API" "001 - Fase 1"

    // Logging estructurado
    eventProcessor.eventConsumer -> eventProcessor.structuredLogger "Registra procesamiento de eventos" "Serilog" "001 - Fase 1"
    eventProcessor.eventOrchestrator -> eventProcessor.structuredLogger "Registra orquestación y transacciones" "Serilog" "001 - Fase 1"
    eventProcessor.sitaFileGenerator -> eventProcessor.structuredLogger "Registra generación de archivos" "Serilog" "001 - Fase 1"
    eventProcessor.configManager -> eventProcessor.structuredLogger "Registra acceso a configuraciones" "Serilog" "001 - Fase 1"
    eventProcessor.tenantConfigManager -> eventProcessor.structuredLogger "Registra configuración híbrida por tenant" "Serilog" "001 - Fase 1"
    eventProcessor.healthCheck -> eventProcessor.structuredLogger "Registra health checks" "Serilog" "001 - Fase 1"

    // Métricas
    eventProcessor.eventConsumer -> eventProcessor.metricsCollector "Publica métricas de eventos" "Prometheus" "001 - Fase 1"
    eventProcessor.eventOrchestrator -> eventProcessor.metricsCollector "Publica métricas de orquestación" "Prometheus" "001 - Fase 1"
    eventProcessor.sitaFileGenerator -> eventProcessor.metricsCollector "Publica métricas de generación" "Prometheus" "001 - Fase 1"
    eventProcessor.configManager -> eventProcessor.metricsCollector "Publica métricas de configuración" "Prometheus" "001 - Fase 1"
    eventProcessor.tenantConfigManager -> eventProcessor.metricsCollector "Publica métricas de configuración híbrida" "Prometheus" "001 - Fase 1"
    eventProcessor.healthCheck -> eventProcessor.metricsCollector "Publica métricas de health status" "Prometheus" "001 - Fase 1"

    // ========================================
    // OBSERVABILIDAD - SENDER
    // ========================================

    // Health Checks
    sender.healthCheck -> sitaMessagingDatabase "Ejecuta health check" "PostgreSQL" "001 - Fase 1"
    sender.healthCheck -> fileStorage "Verifica conectividad storage" "S3-Compatible API" "001 - Fase 1"

    // Logging estructurado
    sender.fileFetcher -> sender.structuredLogger "Registra descarga de archivos" "Serilog" "001 - Fase 1"
    sender.partnerSender -> sender.structuredLogger "Registra envíos a partners" "Serilog" "001 - Fase 1"
    sender.deliveryTracker -> sender.structuredLogger "Registra confirmaciones de entrega" "Serilog" "001 - Fase 1"
    sender.configManager -> sender.structuredLogger "Registra acceso a configuraciones" "Serilog" "001 - Fase 1"
    sender.tenantConfigManager -> sender.structuredLogger "Registra configuración híbrida por tenant" "Serilog" "001 - Fase 1"
    sender.healthCheck -> sender.structuredLogger "Registra health checks" "Serilog" "001 - Fase 1"

    // Métricas
    sender.fileFetcher -> sender.metricsCollector "Publica métricas de descarga" "Prometheus" "001 - Fase 1"
    sender.partnerSender -> sender.metricsCollector "Publica métricas de envío" "Prometheus" "001 - Fase 1"
    sender.deliveryTracker -> sender.metricsCollector "Publica métricas de tracking" "Prometheus" "001 - Fase 1"
    sender.configManager -> sender.metricsCollector "Publica métricas de configuración" "Prometheus" "001 - Fase 1"
    sender.tenantConfigManager -> sender.metricsCollector "Publica métricas de configuración híbrida" "Prometheus" "001 - Fase 1"
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
