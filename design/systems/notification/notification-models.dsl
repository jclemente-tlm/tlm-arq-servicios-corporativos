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
            description "Registra logging estructurado con correlationId único, captura tenant context y almacena metadata de requests para trazabilidad completa"
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
            description "Consumer principal con acknowledgments y retry."
            tags "Messaging" "001 - Fase 1"
        }

        orchestratorService = component "Orchestrator Service" {
            technology "C# Service"
            description "Orquesta el procesamiento y routing por canal."
            tags "Orchestration" "001 - Fase 1"
        }

        templateEngine = component "Template Engine" {
            technology "Liquid Templates"
            description "Motor de plantillas con cache inteligente."
            tags "Templates" "001 - Fase 1"
        }

        // Channel Handlers - Componentes livianos en lugar de contenedores
        emailHandler = component "Email Handler" {
            technology "Email Provider Client"
            description "Handler especializado para procesamiento de emails."
            tags "Email" "Handler" "001 - Fase 1"
        }

        smsHandler = component "SMS Handler" {
            technology "SMS Provider Client"
            description "Handler especializado para procesamiento de SMS."
            tags "SMS" "Handler" "001 - Fase 1"
        }

        whatsappHandler = component "WhatsApp Handler" {
            technology "WhatsApp Provider Client"
            description "Handler especializado para procesamiento de WhatsApp."
            tags "WhatsApp" "Handler" "001 - Fase 1"
        }

        pushHandler = component "Push Handler" {
            technology "Push Provider Client"
            description "Handler especializado para notificaciones push."
            tags "Push" "Handler" "001 - Fase 1"
        }

        schedulerService = component "Scheduler Service" {
            technology "Background Service"
            description "Gestión de notificaciones programadas"
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
            description "Operaciones de datos con alta concurrencia"
            tags "Repository" "001 - Fase 1"
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
    appPeru -> api.notificationController "Consulta estado e historial" "HTTPS via API Gateway" "001 - Fase 1"
    appEcuador -> api.notificationController "Consulta estado e historial" "HTTPS via API Gateway" "001 - Fase 1"
    appColombia -> api.notificationController "Consulta estado e historial" "HTTPS via API Gateway" "001 - Fase 1"
    appMexico -> api.notificationController "Consulta estado e historial" "HTTPS via API Gateway" "001 - Fase 1"

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
    api.dynamicConfigProcessor -> configPlatform.configService "Consulta cambios de configuración con polling" "HTTPS/REST" "001 - Fase 1"
    api.dynamicConfigProcessor -> api.configurationService "Invalida cache específico al detectar cambios" "In-Memory" "001 - Fase 1"
    processor.dynamicConfigProcessor -> configPlatform.configService "Consulta cambios de configuración con polling" "HTTPS/REST" "001 - Fase 1"
    processor.dynamicConfigProcessor -> processor.configurationService "Invalida cache específico al detectar cambios" "In-Memory" "001 - Fase 1"

    // External Provider Relations
    processor.emailHandler -> emailProvider "Envía email" "HTTPS/SMTP" "001 - Fase 1"
    processor.smsHandler -> smsProvider "Envía SMS" "HTTPS/API" "001 - Fase 1"
    processor.whatsappHandler -> whatsappProvider "Envía WhatsApp" "HTTPS/API" "001 - Fase 1"
    processor.pushHandler -> pushProvider "Envía push" "HTTPS/API" "001 - Fase 1"
}
