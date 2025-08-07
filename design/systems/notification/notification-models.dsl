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

        attachmentMetadataTable = component "Attachment Metadata Table" {
            technology "PostgreSQL Table"
            description "Metadatos de archivos adjuntos"
            tags "Database Table" "Attachments" "001 - Fase 1"
        }
    }

    attachmentStorage = store "Attachment Storage" {
        technology "S3-Compatible Storage"
        description "Storage agnóstico para archivos adjuntos"
        tags "File Storage" "S3-Compatible" "001 - Fase 1"
    }

    // ========================================
    // NOTIFICATION API - SIMPLIFICADO
    // ========================================

    api = application "Notification API" {
        technology "ASP.NET Core"
        description "API REST para recepción de notificaciones"
        tags "API" "001 - Fase 1"

        notificationController = component "Notification Controller" {
            technology "ASP.NET Core"
            description "Endpoints RESTful para notificaciones"
            tags "Controller" "Notifications" "001 - Fase 1"
        }

        attachmentController = component "Attachment Controller" {
            technology "ASP.NET Core"
            description "Endpoints RESTful para attachments"
            tags "Controller" "Attachments" "001 - Fase 1"
        }

        requestValidator = component "Request Validator" {
            technology "C#, FluentValidation"
            description "Valida formato JSON, límites de tamaño y reglas por tenant"
            tags "Validation" "001 - Fase 1"
        }

        messagePublisher = component "Message Publisher" {
            technology "C#, .NET 8, PostgreSQL"
            description "Publica mensajes a cola con garantía de entrega (outbox pattern)"
            tags "Messaging" "001 - Fase 1"
        }

        attachmentService = component "Attachment Service" {
            technology "C#, .NET 8, S3 SDK"
            description "Coordina subida, validación y almacenamiento de archivos adjuntos"
            tags "Business Logic" "001 - Fase 1"
        }

        attachmentRepository = component "Attachment Repository" {
            technology "Entity Framework Core"
            description "Acceso a datos de metadatos de attachments"
            tags "Data Access" "001 - Fase 1"
        }

        configManager = component "Configuration Manager" {
            technology "C#, .NET 8, EF Core"
            description "Gestiona configuraciones del servicio y por tenant"
            tags "Configuration" "Multi-Tenant" "001 - Fase 1"
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
            description "Logging estructurado con correlación"
            tags "Observability" "001 - Fase 1"
        }
    }

    // ========================================
    // NOTIFICATION PROCESSOR - UNIFICADO
    // ========================================

    processor = application "Notification Processor" {
        technology "Worker Service"
        description "Procesador unificado con channel handlers especializados"
        tags "Processor" "001 - Fase 1"

        messageConsumer = component "Message Consumer" {
            technology "C#, .NET 8, PostgreSQL"
            description "Consume mensajes con retry automático y manejo de errores"
            tags "Messaging" "001 - Fase 1"
        }

        orchestratorService = component "Orchestrator Service" {
            technology "C#, .NET 8"
            description "Decide canal de envío, coordina template engine y delega a handlers"
            tags "Business Logic" "001 - Fase 1"
        }

        templateEngine = component "Template Engine" {
            technology "C#, Liquid Templates"
            description "Renderiza plantillas con soporte i18n y variables dinámicas"
            tags "Templates" "001 - Fase 1"
        }

        schedulerService = component "Scheduler Service" {
            technology "C#, Quartz.NET"
            description "Programa y ejecuta notificaciones diferidas según fecha/hora"
            tags "Scheduling" "001 - Fase 1"
        }

        notificationRepository = component "Notification Repository" {
            technology "Entity Framework Core"
            description "Acceso a datos de notificaciones"
            tags "Data Access" "001 - Fase 1"
        }

        attachmentFetcher = component "Attachment Fetcher" {
            technology "C#, .NET 8, S3 SDK"
            description "Obtiene archivos adjuntos y metadatos para envío de notificaciones"
            tags "Attachment Retrieval" "001 - Fase 1"
        }

        // Channel Handlers
        emailHandler = component "Email Handler" {
            technology "C#, SMTP Client"
            description "Envía emails con soporte para adjuntos y HTML"
            tags "Email" "Handler" "001 - Fase 1"
        }

        smsHandler = component "SMS Handler" {
            technology "C#, SMS API Client"
            description "Envía SMS con validación de formato y límites"
            tags "SMS" "Handler" "001 - Fase 1"
        }

        whatsappHandler = component "WhatsApp Handler" {
            technology "C#, WhatsApp Business API"
            description "Envía mensajes WhatsApp con soporte para adjuntos"
            tags "WhatsApp" "Handler" "001 - Fase 1"
        }

        pushHandler = component "Push Handler" {
            technology "C#, Push Service SDK"
            description "Envía push notifications a dispositivos móviles"
            tags "Push" "Handler" "001 - Fase 1"
        }

        configManager = component "Configuration Manager" {
            technology "C#, .NET 8, EF Core"
            description "Gestiona configuraciones del servicio y por tenant"
            tags "Configuration" "Multi-Tenant" "001 - Fase 1"
        }

        // Observabilidad esencial
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

    appPeru -> api.attachmentController "Solicita carga de archivos adjuntos" "HTTPS via API Gateway" "001 - Fase 1"
    appEcuador -> api.attachmentController "Solicita carga de archivos adjuntos" "HTTPS via API Gateway" "001 - Fase 1"
    appColombia -> api.attachmentController "Solicita carga de archivos adjuntos" "HTTPS via API Gateway" "001 - Fase 1"
    appMexico -> api.attachmentController "Solicita carga de archivos adjuntos" "HTTPS via API Gateway" "001 - Fase 1"

    // API - Flujo principal
    api.notificationController -> api.requestValidator "Valida requests de notificaciones" "C#" "001 - Fase 1"
    api.notificationController -> api.messagePublisher "Publica mensajes validados" "C#" "001 - Fase 1"
    api.attachmentController -> api.requestValidator "Valida requests de attachments" "C#" "001 - Fase 1"
    api.attachmentController -> api.attachmentService "Orquesta operaciones de archivos" "C#" "001 - Fase 1"
    api.attachmentService -> api.attachmentRepository "Gestiona metadatos" "Entity Framework" "001 - Fase 1"
    api.attachmentService -> attachmentStorage "Almacena archivos binarios" "S3-Compatible" "001 - Fase 1"
    api.attachmentRepository -> notificationDatabase.attachmentMetadataTable "Persiste metadatos" "PostgreSQL" "001 - Fase 1"

    // API - Uso de configuración (vía DI, no acceso directo)
    // Nota: Controllers y servicios reciben IConfigurationService por constructor
    api.requestValidator -> notificationDatabase.configTable "Lee reglas de validación por tenant" "PostgreSQL" "001 - Fase 1"
    api.messagePublisher -> notificationDatabase.configTable "Lee configuración de canales" "PostgreSQL" "001 - Fase 1"

    // API - Configuración externa (solo configManager accede directamente)
    api.configManager -> configPlatform.configService "Obtiene configuración externa" "HTTPS/REST" "001 - Fase 1"
    api.configManager -> notificationDatabase.configTable "Lee metadatos estáticos tenant" "PostgreSQL" "001 - Fase 1"

    // Processor - Flujo principal
    processor.messageConsumer -> notificationDatabase.messagesTable "Consume mensajes" "PostgreSQL" "001 - Fase 1"
    processor.messageConsumer -> processor.orchestratorService "Delega procesamiento" "C#" "001 - Fase 1"
    processor.orchestratorService -> processor.templateEngine "Renderiza plantillas" "C#" "001 - Fase 1"
    processor.orchestratorService -> processor.schedulerService "Programa notificaciones diferidas" "C#" "001 - Fase 1"
    processor.schedulerService -> processor.notificationRepository "Consulta notificaciones pendientes" "Entity Framework" "001 - Fase 1"
    processor.schedulerService -> processor.notificationRepository "Marca como listas para envío" "Entity Framework" "001 - Fase 1"
    processor.schedulerService -> notificationDatabase.messagesTable "Crea mensajes desde notificaciones programadas" "PostgreSQL" "001 - Fase 1"
    processor.templateEngine -> notificationDatabase.templatesTable "Lee plantillas" "PostgreSQL" "001 - Fase 1"
    
    // Attachment Fetcher - Solo handlers que necesitan adjuntos
    processor.emailHandler -> processor.attachmentFetcher "Obtiene adjuntos para email" "C#" "001 - Fase 1"
    processor.whatsappHandler -> processor.attachmentFetcher "Obtiene adjuntos para WhatsApp" "C#" "001 - Fase 1"
    processor.attachmentFetcher -> attachmentStorage "Obtiene archivos con metadatos embebidos" "S3 API" "001 - Fase 1"
    processor.notificationRepository -> notificationDatabase.messagesTable "Accede a datos de notificaciones" "PostgreSQL" "001 - Fase 1"

    // Channel Handlers
    processor.orchestratorService -> processor.emailHandler "Envía email" "C#" "001 - Fase 1"
    processor.orchestratorService -> processor.smsHandler "Envía SMS" "C#" "001 - Fase 1"
    processor.orchestratorService -> processor.whatsappHandler "Envía WhatsApp" "C#" "001 - Fase 1"
    processor.orchestratorService -> processor.pushHandler "Envía push notification" "C#" "001 - Fase 1"

    // Processor - Uso de configuración (vía DI, no acceso directo)
    // Nota: Servicios reciben IConfigurationService por constructor
    processor.orchestratorService -> notificationDatabase.configTable "Lee configuración de canales por tenant" "PostgreSQL" "001 - Fase 1"
    processor.templateEngine -> notificationDatabase.configTable "Lee configuración de templates" "PostgreSQL" "001 - Fase 1"
    # processor.emailHandler -> notificationDatabase.configTable "Lee credenciales SMTP" "PostgreSQL" "001 - Fase 1"
    # processor.smsHandler -> notificationDatabase.configTable "Lee credenciales SMS" "PostgreSQL" "001 - Fase 1"
    # processor.whatsappHandler -> notificationDatabase.configTable "Lee credenciales WhatsApp" "PostgreSQL" "001 - Fase 1"
    # processor.pushHandler -> notificationDatabase.configTable "Lee credenciales Push" "PostgreSQL" "001 - Fase 1"

// External Provider Relations
    processor.emailHandler -> emailProvider "Envía email" "HTTPS/SMTP" "001 - Fase 1"
    processor.smsHandler -> smsProvider "Envía SMS" "HTTPS/API" "001 - Fase 1"
    processor.whatsappHandler -> whatsappProvider "Envía WhatsApp" "HTTPS/API" "001 - Fase 1"
    processor.pushHandler -> pushProvider "Envía push" "HTTPS/API" "001 - Fase 1"

    // Processor - Configuración externa (solo configManager accede directamente)
    processor.configManager -> configPlatform.configService "Obtiene configuración externa" "HTTPS/REST" "001 - Fase 1"
    processor.configManager -> notificationDatabase.configTable "Lee metadatos estáticos tenant" "PostgreSQL" "001 - Fase 1"

    // ========================================
    // OBSERVABILIDAD - API
    // ========================================

    // Health Checks
    api.healthCheck -> notificationDatabase "Ejecuta health check" "PostgreSQL" "001 - Fase 1"
    api.healthCheck -> attachmentStorage "Verifica conectividad storage" "S3-Compatible API" "001 - Fase 1"

    // Logging estructurado
    api.notificationController -> api.structuredLogger "Registra requests de notificaciones" "Serilog" "001 - Fase 1"
    api.attachmentController -> api.structuredLogger "Registra requests de attachments" "Serilog" "001 - Fase 1"
    api.requestValidator -> api.structuredLogger "Registra validaciones" "Serilog" "001 - Fase 1"
    api.messagePublisher -> api.structuredLogger "Registra publicación de mensajes" "Serilog" "001 - Fase 1"
    api.attachmentService -> api.structuredLogger "Registra operaciones de archivos" "Serilog" "001 - Fase 1"
    api.healthCheck -> api.structuredLogger "Registra health checks" "Serilog" "001 - Fase 1"

    // Métricas
    api.notificationController -> api.metricsCollector "Publica métricas de requests" "Prometheus" "001 - Fase 1"
    api.attachmentController -> api.metricsCollector "Publica métricas de attachments" "Prometheus" "001 - Fase 1"
    api.requestValidator -> api.metricsCollector "Publica métricas de validación" "Prometheus" "001 - Fase 1"
    api.messagePublisher -> api.metricsCollector "Publica métricas de publicación" "Prometheus" "001 - Fase 1"
    api.attachmentService -> api.metricsCollector "Publica métricas de archivos" "Prometheus" "001 - Fase 1"
    api.healthCheck -> api.metricsCollector "Publica métricas de health status" "Prometheus" "001 - Fase 1"

    // ========================================
    // OBSERVABILIDAD - PROCESSOR
    // ========================================

    // Health Checks
    processor.healthCheck -> notificationDatabase "Ejecuta health check" "PostgreSQL" "001 - Fase 1"

    // Logging estructurado
    processor.messageConsumer -> processor.structuredLogger "Registra consumo de mensajes" "Serilog" "001 - Fase 1"
    processor.orchestratorService -> processor.structuredLogger "Registra orquestación" "Serilog" "001 - Fase 1"
    processor.templateEngine -> processor.structuredLogger "Registra renderizado de plantillas" "Serilog" "001 - Fase 1"
    processor.emailHandler -> processor.structuredLogger "Registra envíos de email" "Serilog" "001 - Fase 1"
    processor.smsHandler -> processor.structuredLogger "Registra envíos de SMS" "Serilog" "001 - Fase 1"
    processor.whatsappHandler -> processor.structuredLogger "Registra envíos de WhatsApp" "Serilog" "001 - Fase 1"
    processor.pushHandler -> processor.structuredLogger "Registra envíos de push" "Serilog" "001 - Fase 1"
    processor.schedulerService -> processor.structuredLogger "Registra tareas programadas" "Serilog" "001 - Fase 1"
    processor.healthCheck -> processor.structuredLogger "Registra health checks" "Serilog" "001 - Fase 1"

    // Métricas
    processor.messageConsumer -> processor.metricsCollector "Publica métricas de consumo" "Prometheus" "001 - Fase 1"
    processor.orchestratorService -> processor.metricsCollector "Publica métricas de orquestación" "Prometheus" "001 - Fase 1"
    processor.templateEngine -> processor.metricsCollector "Publica métricas de templates" "Prometheus" "001 - Fase 1"
    processor.emailHandler -> processor.metricsCollector "Publica métricas de email" "Prometheus" "001 - Fase 1"
    processor.smsHandler -> processor.metricsCollector "Publica métricas de SMS" "Prometheus" "001 - Fase 1"
    processor.whatsappHandler -> processor.metricsCollector "Publica métricas de WhatsApp" "Prometheus" "001 - Fase 1"
    processor.pushHandler -> processor.metricsCollector "Publica métricas de push" "Prometheus" "001 - Fase 1"
    processor.schedulerService -> processor.metricsCollector "Publica métricas de scheduling" "Prometheus" "001 - Fase 1"
    processor.healthCheck -> processor.metricsCollector "Publica métricas de health status" "Prometheus" "001 - Fase 1"

    // ========================================
    // RELACIONES EXTERNAS - CONSUMIDORES
    // ========================================

    // Sistemas que consumen Notification API
    // NOTA: Las referencias externas se modelarán cuando los componentes estén definidos correctamente
    // trackAndTrace -> notification.api.notificationController "Solicita notificaciones de eventos" "HTTPS/REST" "001 - Fase 1"
    // sitaMessaging -> notification.api.notificationController "Solicita notificaciones de entrega" "HTTPS/REST" "001 - Fase 1"
    // apiGateway -> notification.api.notificationController "Enruta requests de notificaciones" "HTTPS/REST" "001 - Fase 1"

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
