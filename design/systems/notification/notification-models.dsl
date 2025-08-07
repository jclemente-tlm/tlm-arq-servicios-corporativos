notification = softwareSystem "Notification System" {
    description "Sistema de notificaciones multicanal"
    tags "Notification" "001 - Fase 1"

    // ========================================
    // DATA STORE - OPTIMIZADO
    // ========================================

    notificationDatabase = store "Notification Database" {
        description "PostgreSQL con esquemas para notificaciones"
        technology "PostgreSQL"
        tags "Database" "PostgreSQL" "001 - Fase 1"

        // Componentes esenciales del esquema
        messagesTable = component "Messages Table" {
            technology "PostgreSQL Table"
            description "Tabla principal para mensajes con routing"
            tags "Database Table" "Messages" "001 - Fase 1"
        }

        templatesTable = component "Templates Table" {
            technology "PostgreSQL Table"
            description "Plantillas con versionado e i18n"
            tags "Database Table" "Templates" "001 - Fase 1"
        }

        configTable = component "Configuration Table" {
            technology "PostgreSQL Table"
            description "Configuraciones por tenant y canal"
            tags "Database Table" "Configuration" "001 - Fase 1"
        }
    }

    attachmentStorage = store "Attachment Storage" {
        technology "S3-Compatible Storage"
        description "Storage agnóstico para archivos adjuntos."
        tags "File Storage" "S3-Compatible" "001 - Fase 1"
    }

    // ========================================
    // NOTIFICATION API - SIMPLIFICADO
    // ========================================

    api = application "Notification API" {
        technology "ASP.NET Core"
        description "API REST para recepción de notificaciones"
        tags "API" "001 - Fase 1"

        // Componentes esenciales
        notificationController = component "Notification Controller" {
            technology "ASP.NET Core"
            description "Endpoints REST para notificaciones: /send, /status, /attachments"
            tags "Controller" "001 - Fase 1"
        }

        requestValidator = component "Request Validator" {
            technology "FluentValidation"
            description "Validación de estructura y reglas de negocio"
            tags "Validation" "001 - Fase 1"
        }

        messagePublisher = component "Message Publisher" {
            technology "Reliable Messaging"
            description "Publisher con outbox pattern"
            tags "Messaging" "001 - Fase 1"
        }

        configurationService = component "Configuration Service" {
            technology "IConfigurationProvider"
            description "Servicio de configuración con cache local"
            tags "Configuration" "001 - Fase 1"
        }

        dynamicConfigProcessor = component "Dynamic Configuration Processor" {
            technology "C#, FluentValidation, HttpClient"
            description "Polling de configuración con hot reload"
            tags "Configuration Events" "Feature Flags" "001 - Fase 1"
        }

        attachmentService = component "Attachment Service" {
            technology "S3-Compatible Client"
            description "Gestión de archivos adjuntos"
            tags "Storage" "001 - Fase 1"
        }

        // Observabilidad esencial
        healthCheck = component "Health Check" {
            technology "ASP.NET Core Health Checks"
            description "Monitoreo de salud del API"
            tags "Observability" "001 - Fase 1"
        }

        metricsCollector = component "Metrics Collector" {
            technology "Prometheus.NET"
            description "Recolección de métricas del API"
            tags "Observability" "001 - Fase 1"
        }

        structuredLogger = component "Structured Logger" {
            technology "Serilog"
            description "Logging estructurado con correlationId, tenant context y metadata de requests"
            tags "Observability" "001 - Fase 1"
        }
    }

    // ========================================
    // NOTIFICATION PROCESSOR - UNIFICADO
    // ========================================

    processor = application "Notification Processor" {
        technology "Worker Service"
        description "Procesador unificado con channel handlers especializados."
        tags "Processor" "001 - Fase 1"

        messageConsumer = component "Message Consumer" {
            technology "Reliable Messaging"
            description "Consumer principal con acknowledgments, retry policies y dead letter handling"
            tags "Messaging" "001 - Fase 1"
        }

        orchestratorService = component "Orchestrator Service" {
            technology "C# Service"
            description "Orquesta el procesamiento, routing por canal y manejo de prioridades"
            tags "Orchestration" "001 - Fase 1"
        }

        templateEngine = component "Template Engine" {
            technology "Liquid Templates"
            description "Motor de plantillas con cache, i18n y personalización por tenant"
            tags "Templates" "001 - Fase 1"
        }

        // Channel Handlers - Componentes livianos en lugar de contenedores
        emailHandler = component "Email Handler" {
            technology "Email Provider Client"
            description "Handler especializado para emails con retry, templates y attachments"
            tags "Email" "Handler" "001 - Fase 1"
        }

        smsHandler = component "SMS Handler" {
            technology "SMS Provider Client"
            description "Handler especializado para SMS con límites de caracteres y routing"
            tags "SMS" "Handler" "001 - Fase 1"
        }

        whatsappHandler = component "WhatsApp Handler" {
            technology "WhatsApp Provider Client"
            description "Handler especializado para WhatsApp con templates y media support"
            tags "WhatsApp" "Handler" "001 - Fase 1"
        }

        pushHandler = component "Push Handler" {
            technology "Push Provider Client"
            description "Handler especializado para push notifications con targeting"
            tags "Push" "Handler" "001 - Fase 1"
        }

        schedulerService = component "Scheduler Service" {
            technology "Background Service"
            description "Gestión de notificaciones programadas con cron jobs y time zones"
            tags "Scheduling" "001 - Fase 1"
        }

        configurationService = component "Configuration Service" {
            technology "IConfigurationProvider"
            description "Servicio de configuración con cache distribuido"
            tags "Configuration" "001 - Fase 1"
        }

        dynamicConfigProcessor = component "Dynamic Configuration Processor" {
            technology "C#, FluentValidation, HttpClient"
            description "Polling de configuración con hot reload"
            tags "Configuration Events" "Feature Flags" "001 - Fase 1"
        }

        notificationRepository = component "Notification Repository" {
            technology "Entity Framework Core"
            description "Operaciones de datos con alta concurrencia, audit trail y soft deletes"
            tags "Repository" "001 - Fase 1"
        }

        attachmentFetcher = component "Attachment Fetcher" {
            technology "S3-Compatible Client"
            description "Componente especializado para recuperar archivos del storage con cache, retry y validación"
            tags "Storage" "File Management" "001 - Fase 1"
        }

        // Componentes de Observabilidad
        healthCheck = component "Health Check" {
            technology "ASP.NET Core Health Checks"
            description "Monitoreo de salud del Processor"
            tags "Observability" "001 - Fase 1"
        }

        metricsCollector = component "Metrics Collector" {
            technology "Prometheus.NET"
            description "Métricas de procesamiento y canales"
            tags "Observability" "001 - Fase 1"
        }

        structuredLogger = component "Structured Logger" {
            technology "Serilog"
            description "Logging estructurado con correlación"
            tags "Observability" "001 - Fase 1"
        }
    }

    // ========================================
    // RELACIONES INTERNAS - OPTIMIZADAS
    // ========================================

    // Aplicaciones por país - Operaciones de consulta (Queries)
    appPeru -> api.notificationController "Solicita envió de notificación" "HTTPS via API Gateway" "001 - Fase 1"
    appEcuador -> api.notificationController "Solicita envió de notificación" "HTTPS via API Gateway" "001 - Fase 1"
    appColombia -> api.notificationController "Solicita envió de notificación" "HTTPS via API Gateway" "001 - Fase 1"
    appMexico -> api.notificationController "Solicita envió de notificación" "HTTPS via API Gateway" "001 - Fase 1"

    // API Internal Relations
    api.notificationController -> api.requestValidator "Valida requests" "C#" "001 - Fase 1"
    api.notificationController -> api.messagePublisher "Publica mensaje" "Reliable Messaging" "001 - Fase 1"
    api.notificationController -> api.attachmentService "Gestiona adjuntos" "C#" "001 - Fase 1"
    api.messagePublisher -> notificationDatabase.messagesTable "Persiste mensaje" "PostgreSQL" "001 - Fase 1"
    api.configurationService -> configPlatform.configService "Lee configuración" "HTTPS" "001 - Fase 1"
    api.attachmentService -> attachmentStorage "Almacena archivos" "S3-Compatible" "001 - Fase 1"

    // Processor Internal Relations
    processor.messageConsumer -> notificationDatabase.messagesTable "Consume mensajes" "PostgreSQL" "001 - Fase 1"
    processor.messageConsumer -> processor.orchestratorService "Procesa mensaje" "C#" "001 - Fase 1"
    processor.orchestratorService -> processor.templateEngine "Procesa plantilla" "C#" "001 - Fase 1"
    processor.templateEngine -> notificationDatabase.templatesTable "Lee plantillas" "PostgreSQL" "001 - Fase 1"

    // Channel Handler Relations
    processor.orchestratorService -> processor.emailHandler "Envía email" "C#" "001 - Fase 1"
    processor.orchestratorService -> processor.smsHandler "Envía SMS" "C#" "001 - Fase 1"
    processor.orchestratorService -> processor.whatsappHandler "Envía WhatsApp" "C#" "001 - Fase 1"
    processor.orchestratorService -> processor.pushHandler "Envía push" "C#" "001 - Fase 1"

    // Scheduling Relations
    processor.schedulerService -> notificationDatabase.messagesTable "Procesa programados" "PostgreSQL" "001 - Fase 1"
    processor.schedulerService -> processor.orchestratorService "Ejecuta programación" "C#" "001 - Fase 1"

    // Configuration Relations
    processor.configurationService -> configPlatform.configService "Lee configuración" "HTTPS" "001 - Fase 1"
    processor.notificationRepository -> notificationDatabase "Operaciones CRUD" "PostgreSQL" "001 - Fase 1"

    // Dynamic Configuration Relations
    api.dynamicConfigProcessor -> configPlatform.configService "Consulta cambios config" "HTTPS/REST" "001 - Fase 1"
    api.dynamicConfigProcessor -> api.configurationService "Invalida cache" "In-Memory" "001 - Fase 1"
    processor.dynamicConfigProcessor -> configPlatform.configService "Consulta cambios config" "HTTPS/REST" "001 - Fase 1"
    processor.dynamicConfigProcessor -> processor.configurationService "Invalida cache" "In-Memory" "001 - Fase 1"

    // External Provider Relations
    processor.emailHandler -> emailProvider "Envía email" "HTTPS/SMTP" "001 - Fase 1"
    processor.smsHandler -> smsProvider "Envía SMS" "HTTPS/API" "001 - Fase 1"
    processor.whatsappHandler -> whatsappProvider "Envía WhatsApp" "HTTPS/API" "001 - Fase 1"
    processor.pushHandler -> pushProvider "Envía push" "HTTPS/API" "001 - Fase 1"

    // Storage Relations - AttachmentFetcher gestiona acceso al storage
    processor.attachmentFetcher -> attachmentStorage "Gestiona acceso a archivos con cache y retry" "S3-Compatible" "001 - Fase 1"
    
    // Handlers usan AttachmentFetcher para obtener archivos
    processor.emailHandler -> processor.attachmentFetcher "Solicita archivos adjuntos para emails" "C#" "001 - Fase 1"
    processor.whatsappHandler -> processor.attachmentFetcher "Solicita archivos multimedia para WhatsApp" "C#" "001 - Fase 1"
    processor.pushHandler -> processor.attachmentFetcher "Solicita imágenes para notificaciones push" "C#" "001 - Fase 1"

    // ========================================
    // OBSERVABILIDAD - NOTIFICATION API
    // ========================================

    // Health Checks
    api.healthCheck -> notificationDatabase "Ejecuta health check" "PostgreSQL" "001 - Fase 1"
    api.healthCheck -> attachmentStorage "Verifica conectividad storage" "S3-Compatible" "001 - Fase 1"
    api.healthCheck -> configPlatform.configService "Verifica configuraciones críticas" "HTTPS/REST" "001 - Fase 1"

    // Logging estructurado
    api.notificationController -> api.structuredLogger "Registra requests y responses" "Serilog" "001 - Fase 1"
    api.requestValidator -> api.structuredLogger "Registra validaciones fallidas" "Serilog" "001 - Fase 1"
    api.messagePublisher -> api.structuredLogger "Registra publicación de mensajes" "Serilog" "001 - Fase 1"
    api.configurationService -> api.structuredLogger "Registra cache hit/miss config" "Serilog" "001 - Fase 1"
    api.attachmentService -> api.structuredLogger "Registra operaciones de storage" "Serilog" "001 - Fase 1"
    api.dynamicConfigProcessor -> api.structuredLogger "Registra cambios de configuración" "Serilog" "001 - Fase 1"
    api.healthCheck -> api.structuredLogger "Registra health checks" "Serilog" "001 - Fase 1"

    // Métricas de negocio y técnicas
    api.notificationController -> api.metricsCollector "Publica métricas de requests" "Prometheus" "001 - Fase 1"
    api.requestValidator -> api.metricsCollector "Publica métricas de validación" "Prometheus" "001 - Fase 1"
    api.messagePublisher -> api.metricsCollector "Publica métricas de throughput" "Prometheus" "001 - Fase 1"
    api.configurationService -> api.metricsCollector "Publica métricas de cache" "Prometheus" "001 - Fase 1"
    api.attachmentService -> api.metricsCollector "Publica métricas de storage" "Prometheus" "001 - Fase 1"
    api.dynamicConfigProcessor -> api.metricsCollector "Publica métricas de configuración dinámica" "Prometheus" "001 - Fase 1"
    api.healthCheck -> api.metricsCollector "Publica métricas de health status" "Prometheus" "001 - Fase 1"

    // Observabilidad cross-cutting
    api.structuredLogger -> api.metricsCollector "Correlaciona logs y métricas" "In-Memory" "001 - Fase 1"

    // ========================================
    // OBSERVABILIDAD - NOTIFICATION PROCESSOR
    // ========================================

    // Health Checks
    processor.healthCheck -> notificationDatabase "Ejecuta health check" "PostgreSQL" "001 - Fase 1"
    processor.healthCheck -> configPlatform.configService "Verifica configuraciones críticas" "HTTPS/REST" "001 - Fase 1"

    // Logging estructurado
    processor.messageConsumer -> processor.structuredLogger "Registra consumo de mensajes" "Serilog" "001 - Fase 1"
    processor.orchestratorService -> processor.structuredLogger "Registra orquestación" "Serilog" "001 - Fase 1"
    processor.templateEngine -> processor.structuredLogger "Registra procesamiento de templates" "Serilog" "001 - Fase 1"
    processor.emailHandler -> processor.structuredLogger "Registra envíos de email" "Serilog" "001 - Fase 1"
    processor.smsHandler -> processor.structuredLogger "Registra envíos de SMS" "Serilog" "001 - Fase 1"
    processor.whatsappHandler -> processor.structuredLogger "Registra envíos de WhatsApp" "Serilog" "001 - Fase 1"
    processor.pushHandler -> processor.structuredLogger "Registra envíos de push" "Serilog" "001 - Fase 1"
    processor.schedulerService -> processor.structuredLogger "Registra tareas programadas" "Serilog" "001 - Fase 1"
    processor.configurationService -> processor.structuredLogger "Registra cache hit/miss config" "Serilog" "001 - Fase 1"
    processor.notificationRepository -> processor.structuredLogger "Registra operaciones de datos" "Serilog" "001 - Fase 1"
    processor.dynamicConfigProcessor -> processor.structuredLogger "Registra cambios de configuración" "Serilog" "001 - Fase 1"
    processor.healthCheck -> processor.structuredLogger "Registra health checks" "Serilog" "001 - Fase 1"

    // Métricas de negocio y técnicas
    processor.messageConsumer -> processor.metricsCollector "Publica métricas de consumo" "Prometheus" "001 - Fase 1"
    processor.orchestratorService -> processor.metricsCollector "Publica métricas de orquestación" "Prometheus" "001 - Fase 1"
    processor.templateEngine -> processor.metricsCollector "Publica métricas de templates" "Prometheus" "001 - Fase 1"
    processor.emailHandler -> processor.metricsCollector "Publica métricas de email" "Prometheus" "001 - Fase 1"
    processor.smsHandler -> processor.metricsCollector "Publica métricas de SMS" "Prometheus" "001 - Fase 1"
    processor.whatsappHandler -> processor.metricsCollector "Publica métricas de WhatsApp" "Prometheus" "001 - Fase 1"
    processor.pushHandler -> processor.metricsCollector "Publica métricas de push" "Prometheus" "001 - Fase 1"
    processor.schedulerService -> processor.metricsCollector "Publica métricas de scheduling" "Prometheus" "001 - Fase 1"
    processor.configurationService -> processor.metricsCollector "Publica métricas de cache" "Prometheus" "001 - Fase 1"
    processor.notificationRepository -> processor.metricsCollector "Publica métricas de query performance" "Prometheus" "001 - Fase 1"
    processor.dynamicConfigProcessor -> processor.metricsCollector "Publica métricas de configuración dinámica" "Prometheus" "001 - Fase 1"
    processor.healthCheck -> processor.metricsCollector "Publica métricas de health status" "Prometheus" "001 - Fase 1"

    // Observabilidad cross-cutting
    processor.structuredLogger -> processor.metricsCollector "Correlaciona logs y métricas" "In-Memory" "001 - Fase 1"

    // ========================================
    // RELACIONES EXTERNAS - OBSERVABILIDAD
    // ========================================

    // Métricas
    notification.api.metricsCollector -> observabilitySystem.metricsCollector "Expone métricas de performance" "HTTP" "001 - Fase 1"
    notification.processor.metricsCollector -> observabilitySystem.metricsCollector "Expone métricas de procesamiento" "HTTP" "001 - Fase 1"

    // Health Checks
    notification.api.healthCheck -> observabilitySystem.metricsCollector "Expone health checks API" "HTTP" "001 - Fase 1"
    notification.processor.healthCheck -> observabilitySystem.metricsCollector "Expone health checks Processor" "HTTP" "001 - Fase 1"

    // Logs estructurados
    notification.api.structuredLogger -> observabilitySystem.logAggregator "Envía logs estructurados API" "HTTP" "001 - Fase 1"
    notification.processor.structuredLogger -> observabilitySystem.logAggregator "Envía logs estructurados Processor" "HTTP" "001 - Fase 1"

    // Tracing distribuido (Fase 2)
    notification.api.structuredLogger -> observabilitySystem.tracingPlatform "Envía trazas distribuidas API" "OpenTelemetry" "002 - Fase 2"
    notification.processor.structuredLogger -> observabilitySystem.tracingPlatform "Envía trazas distribuidas Processor" "OpenTelemetry" "002 - Fase 2"
}
