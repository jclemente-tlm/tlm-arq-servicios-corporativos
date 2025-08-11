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

    // ========================================
    // QUEUES - SQS (EXTERNAS)
    // ========================================
    ingestionQueue = store "Ingestion Queue" {
        technology "Amazon SQS"
        description "Cola de ingesta de notificaciones para desacoplar la recepción del procesamiento"
        tags "Message Bus" "SQS" "001 - Fase 1"
    }
    emailQueue = store "Email Queue" {
        technology "Amazon SQS"
        description "Cola específica para procesamiento de notificaciones de email"
        tags "Message Bus" "SQS" "001 - Fase 1"
    }
    smsQueue = store "SMS Queue" {
        technology "Amazon SQS"
        description "Cola específica para procesamiento de notificaciones SMS"
        tags "Message Bus" "SQS" "001 - Fase 1"
    }
    whatsappQueue = store "WhatsApp Queue" {
        technology "Amazon SQS"
        description "Cola específica para procesamiento de notificaciones WhatsApp"
        tags "Message Bus" "SQS" "001 - Fase 1"
    }
    pushQueue = store "Push Queue" {
        technology "Amazon SQS"
        description "Cola específica para procesamiento de notificaciones push"
        tags "Message Bus" "SQS" "001 - Fase 1"
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
    // NOTIFICATION PROCESSOR - UNIFICADO (OBSOLETO, DEFINICIÓN COMENTADA)
    // ========================================
    // (El bloque comentado se mantiene solo como referencia histórica, no debe usarse en relaciones ni documentación activa)

    notificationProcessor = application "Notification Processor" {
        technology "Worker Service, C# .NET 8"
        description "Procesa y envía notificaciones multicanal. No gestiona eventos ni realiza consultas."
        tags "CSharp" "001 - Fase 1"

        messageConsumer = component "Consumer" {
            technology "C# .NET 8, AWS SDK"
            description "Consume mensajes desde la cola solicitudes de notificación."
            tags "001 - Fase 1"
        }

        orchestratorService = component "Service" {
            technology "C# .NET 8"
            description "Valida datos, construye el mensaje y lo distribuye al canal correspondiente."
            tags "001 - Fase 1"
        }

        messageBuilder = component "Message Builder" {
            technology "C# .NET 8"
            description "Genera el mensaje final para cada canal utilizando plantillas y datos de entrada."
            tags "Builder" "001 - Fase 1"
        }

        templateEngine = component "Template Engine" {
            technology "C#, Liquid Templates"
            description "Renderiza plantillas con soporte i18n y variables dinámicas"
            tags "Templates" "001 - Fase 1"
        }

        adapter = component "Adapter" {
            technology "C# .NET 8, AWS SDK"
            description "Envía el mensaje procesado a la cola específica del canal (Email, SMS, WhatsApp, Push)."
            tags "001 - Fase 1"
        }

        repository = component "Repository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Guarda el estado y eventos de las notificaciones procesadas en la base de datos."
            tags "001 - Fase 1"
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

    scheduler = application "Notification Scheduler" {
        technology "Worker Service, C# .NET 8"
        description "Gestiona el envío de notificaciones programadas."
        tags "CSharp" "001 - Fase 1"

        worker = component "Scheduler Worker" {
            technology "Worker Service, C# .NET 8"
            description "Ejecuta tareas programadas para enviar notificaciones pendientes."
            tags "001 - Fase 1"
        }

        service = component "Service" {
            technology "C# .NET 8"
            description "Procesa y programa el envío de notificaciones."
            tags "001 - Fase 1"
        }

        repository = component "Repository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Acceso a notificaciones programadas en la base de datos."
            tags "001 - Fase 1"
        }

        publisher = component "Queue Publisher" {
            technology "C# .NET 8, AWS SDK"
            description "Envía notificaciones programadas a la cola de notificación."
            tags "001 - Fase 1"
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

    // Procesadores de Canal
    emailProcessor = application "Email Processor" {
        technology "Worker Service, C# .NET 8"
        description "Procesa y envía notificaciones por email."
        tags "CSharp" "001 - Fase 1"

        consumer = component "Consumer" {
            technology "C# .NET 8, AWS SDK"
            description "Consume mensajes de la cola de notificación Email."
            tags "001 - Fase 1"
        }

        service = component "Service" {
            technology "C# .NET 8"
            description "Procesa y envía notificaciones por email."
            tags "001 - Fase 1"
        }

        repository = component "Repository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Actualiza el estado de las notificaciones enviadas por email."
            tags "001 - Fase 1"
        }

        adapter = component "Adapter" {
            technology "C# .NET 8, AWS SDK"
            description "Envía notificaciones al proveedor externo de email."
            tags "Integración" "001 - Fase 1"
        }

        attachmentFetcher = component "Attachment Fetcher" {
            technology "C# .NET 8, AWS SDK"
            description "Obtiene archivos adjuntos desde almacenamiento."
            tags "001 - Fase 1"
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

    smsProcessor = application "SMS Processor" {
        technology "Worker Service, C# .NET 8"
        description "Procesa y envía notificaciones SMS."
        tags "CSharp" "001 - Fase 1"

        consumer = component "Consumer" {
            technology "C# .NET 8, AWS SDK"
            description "Consume mensajes de la cola notificación SMS."
            tags "001 - Fase 1"
        }

        service = component "Service" {
            technology "C# .NET 8"
            description "Procesa y envía notificaciones SMS."
            tags "001 - Fase 1"
        }

        repository = component "Repository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Actualiza el estado de las notificaciones enviadas por SMS."
            tags "001 - Fase 1"
        }

        adapter = component "Adapter" {
            technology "C# .NET 8, AWS SDK"
            description "Envía notificaciones al proveedor externo de SMS."
            tags "Integración" "001 - Fase 1"
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

    whatsappProcessor = application "WhatsApp Processor" {
        technology "Worker Service, C# .NET 8"
        description "Procesa y envía notificaciones WhatsApp."
        tags "CSharp" "001 - Fase 1"

        consumer = component "Consumer" {
            technology "C# .NET 8, AWS SDK"
            description "Consume mensajes de la cola notificación WhatsApp."
            tags "001 - Fase 1"
        }

        service = component "Service" {
            technology "C# .NET 8"
            description "Procesa y envía notificaciones WhatsApp."
            tags "001 - Fase 1"
        }

        repository = component "Repository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Actualiza el estado de las notificaciones enviadas por WhatsApp."
            tags "001 - Fase 1"
        }

        adapter = component "Adapter" {
            technology "C# .NET 8, AWS SDK"
            description "Envía notificaciones al proveedor externo de WhatsApp."
            tags "Integración" "001 - Fase 1"
        }

        attachmentFetcher = component "Attachment Fetcher" {
            technology "C# .NET 8, AWS SDK"
            description "Obtiene archivos adjuntos desde almacenamiento."
            tags "001 - Fase 1"
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

    pushProcessor = application "Push Processor" {
        technology "Worker Service, C# .NET 8"
        description "Procesa y envía notificaciones Push."
        tags "CSharp" "001 - Fase 1"

        consumer = component "Consumer" {
            technology "C# .NET 8, AWS SDK"
            description "Consume mensajes de la cola notificación Push."
            tags "001 - Fase 1"
        }

        service = component "Service" {
            technology "C# .NET 8"
            description "Procesa y envía notificaciones Push."
            tags "001 - Fase 1"
        }

        repository = component "Repository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Actualiza el estado de las notificaciones enviadas por Push."
            tags "001 - Fase 1"
        }

        adapter = component "Adapter" {
            technology "C# .NET 8, AWS SDK"
            description "Envía notificaciones al proveedor externo de Push."
            tags "Integración" "001 - Fase 1"
        }

        attachmentFetcher = component "Attachment Fetcher" {
            technology "C# .NET 8, AWS SDK"
            description "Obtiene archivos adjuntos desde almacenamiento."
            tags "001 - Fase 1"
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
    // RELACIONES INTERNAS - OPTIMIZADAS
    // ========================================

    // === RELACIONES INTERNAS: API ===
    // Relaciones agrupadas por componente origen
    appPeru -> api.notificationController "Solicita envió de notificación" "HTTPS via API Gateway" "001 - Fase 1"
    appEcuador -> api.notificationController "Solicita envió de notificación" "HTTPS via API Gateway" "001 - Fase 1"
    appColombia -> api.notificationController "Solicita envió de notificación" "HTTPS via API Gateway" "001 - Fase 1"
    appMexico -> api.notificationController "Solicita envió de notificación" "HTTPS via API Gateway" "001 - Fase 1"
    appPeru -> api.attachmentController "Solicita carga de archivos adjuntos" "HTTPS via API Gateway" "001 - Fase 1"
    appEcuador -> api.attachmentController "Solicita carga de archivos adjuntos" "HTTPS via API Gateway" "001 - Fase 1"
    appColombia -> api.attachmentController "Solicita carga de archivos adjuntos" "HTTPS via API Gateway" "001 - Fase 1"
    appMexico -> api.attachmentController "Solicita carga de archivos adjuntos" "HTTPS via API Gateway" "001 - Fase 1"
    api.notificationController -> api.requestValidator "Valida requests de notificaciones" "C#" "001 - Fase 1"
    api.notificationController -> api.messagePublisher "Publica mensajes validados" "C#" "001 - Fase 1"
    api.attachmentController -> api.requestValidator "Valida requests de attachments" "C#" "001 - Fase 1"
    api.attachmentController -> api.attachmentService "Orquesta operaciones de archivos" "C#" "001 - Fase 1"
    api.attachmentService -> api.attachmentRepository "Gestiona metadatos" "Entity Framework" "001 - Fase 1"
    api.attachmentService -> attachmentStorage "Almacena archivos adjuntos" "S3-Compatible" "001 - Fase 1"
    api.attachmentRepository -> notificationDatabase.attachmentMetadataTable "Persiste metadatos" "PostgreSQL" "001 - Fase 1"
    api.requestValidator -> notificationDatabase.configTable "Lee reglas de validación por tenant" "PostgreSQL" "001 - Fase 1"
    api.messagePublisher -> notificationDatabase.configTable "Lee configuración de canales" "PostgreSQL" "001 - Fase 1"
    api.configManager -> configPlatform.configService "Obtiene configuración externa" "HTTPS/REST" "001 - Fase 1"
    api.configManager -> notificationDatabase.configTable "Lee metadatos estáticos tenant" "PostgreSQL" "001 - Fase 1"
    api.messagePublisher -> ingestionQueue "Publica en cola de ingesta" "SQS" "001 - Fase 1"
    api.healthCheck -> notificationDatabase "Ejecuta health check" "PostgreSQL" "001 - Fase 1"
    api.healthCheck -> attachmentStorage "Verifica conectividad storage" "S3-Compatible API" "001 - Fase 1"
    api.notificationController -> api.structuredLogger "Registra requests de notificaciones" "Serilog" "001 - Fase 1"
    api.attachmentController -> api.structuredLogger "Registra requests de attachments" "Serilog" "001 - Fase 1"
    api.requestValidator -> api.structuredLogger "Registra validaciones" "Serilog" "001 - Fase 1"
    api.messagePublisher -> api.structuredLogger "Registra publicación de mensajes" "Serilog" "001 - Fase 1"
    api.attachmentService -> api.structuredLogger "Registra operaciones de archivos" "Serilog" "001 - Fase 1"
    api.healthCheck -> api.structuredLogger "Registra health checks" "Serilog" "001 - Fase 1"
    api.notificationController -> api.metricsCollector "Publica métricas de requests" "Prometheus" "001 - Fase 1"
    api.attachmentController -> api.metricsCollector "Publica métricas de attachments" "Prometheus" "001 - Fase 1"
    api.requestValidator -> api.metricsCollector "Publica métricas de validación" "Prometheus" "001 - Fase 1"
    api.messagePublisher -> api.metricsCollector "Publica métricas de publicación" "Prometheus" "001 - Fase 1"
    api.attachmentService -> api.metricsCollector "Publica métricas de archivos" "Prometheus" "001 - Fase 1"
    api.healthCheck -> api.metricsCollector "Publica métricas de health status" "Prometheus" "001 - Fase 1"

    // === RELACIONES INTERNAS: PROCESSOR ===
    notificationProcessor.configManager -> configPlatform.configService "Obtiene configuración externa" "HTTPS/REST" "001 - Fase 1"
    notificationProcessor.configManager -> notificationDatabase.configTable "Lee configuración local y por tenant" "PostgreSQL" "001 - Fase 1"
    notificationProcessor.messageConsumer -> notificationProcessor.orchestratorService "Delega procesamiento" "C#" "001 - Fase 1"
    notificationProcessor.orchestratorService -> notificationProcessor.templateEngine "Renderiza plantillas" "C#" "001 - Fase 1"
    notificationProcessor.templateEngine -> notificationDatabase.templatesTable "Lee plantillas" "PostgreSQL" "001 - Fase 1"
    notificationProcessor.templateEngine -> notificationDatabase.configTable "Lee configuración de templates" "PostgreSQL" "001 - Fase 1"
    notificationProcessor.messageConsumer -> ingestionQueue "Consume solicitudes de notificación" "SQS" "001 - Fase 1"
    notificationProcessor.adapter -> emailQueue "Encola notificación email" "SQS" "SNS, 001 - Fase 1"
    notificationProcessor.adapter -> smsQueue "Encola notificación SMS" "SQS" "SNS, 001 - Fase 1"
    notificationProcessor.adapter -> whatsappQueue "Encola notificación WhatsApp" "SQS" "SNS,001 - Fase 1"
    notificationProcessor.adapter -> pushQueue "Encola notificación push" "SQS" "SNS, 001 - Fase 1"
    notificationProcessor.healthCheck -> notificationDatabase "Ejecuta health check" "PostgreSQL" "001 - Fase 1"
    notificationProcessor.messageConsumer -> notificationProcessor.structuredLogger "Registra consumo de mensajes" "Serilog" "001 - Fase 1"
    notificationProcessor.orchestratorService -> notificationProcessor.structuredLogger "Registra orquestación" "Serilog" "001 - Fase 1"
    notificationProcessor.templateEngine -> notificationProcessor.structuredLogger "Registra renderizado de plantillas" "Serilog" "001 - Fase 1"
    notificationProcessor.healthCheck -> notificationProcessor.structuredLogger "Registra health checks" "Serilog" "001 - Fase 1"
    notificationProcessor.messageConsumer -> notificationProcessor.metricsCollector "Publica métricas de consumo" "Prometheus" "001 - Fase 1"
    notificationProcessor.orchestratorService -> notificationProcessor.metricsCollector "Publica métricas de orquestación" "Prometheus" "001 - Fase 1"
    notificationProcessor.templateEngine -> notificationProcessor.metricsCollector "Publica métricas de templates" "Prometheus" "001 - Fase 1"
    notificationProcessor.healthCheck -> notificationProcessor.metricsCollector "Publica métricas de health status" "Prometheus" "001 - Fase 1"
    notificationProcessor.orchestratorService -> notificationProcessor.repository "Guarda estado y eventos de notificación" "Entity Framework" "001 - Fase 1"
    notificationProcessor.orchestratorService -> notificationProcessor.messageBuilder "Construye mensaje final" "C#" "001 - Fase 1"
    notificationProcessor.orchestratorService -> notificationProcessor.adapter "Envía mensaje a canal" "C#" "001 - Fase 1"
    notificationProcessor.repository -> notificationDatabase.messagesTable "Guarda y actualiza notificaciones procesadas" "PostgreSQL" "001 - Fase 1"

    // === RELACIONES INTERNAS: SCHEDULER ===
    scheduler.configManager -> configPlatform.configService "Obtiene configuración externa" "HTTPS/REST" "001 - Fase 1"
    scheduler.configManager -> notificationDatabase.configTable "Lee configuración local y por tenant" "PostgreSQL" "001 - Fase 1"
    scheduler.publisher -> ingestionQueue "Publica notificaciones programadas" "SQS" "001 - Fase 1"
    scheduler.repository -> notificationDatabase.messagesTable "Lee notificaciones programadas proximas a enviar" "PostgreSQL" "001 - Fase 1"
    scheduler.worker -> scheduler.service "Delega ejecución programada" "C#" "001 - Fase 1"
    scheduler.service -> scheduler.repository "Accede a notificaciones programadas" "C#" "001 - Fase 1"
    scheduler.service -> scheduler.publisher "Publica notificaciones programadas" "C#" "001 - Fase 1"

    // === RELACIONES INTERNAS: PROCESADORES DE CANAL ===
    emailProcessor.configManager -> configPlatform.configService "Obtiene configuración externa" "HTTPS/REST" "001 - Fase 1"
    emailProcessor.configManager -> notificationDatabase.configTable "Lee configuración local y por tenant" "PostgreSQL" "001 - Fase 1"
    emailProcessor.consumer -> emailQueue "Consume email queue" "SQS" "001 - Fase 1"
    emailProcessor.adapter -> emailProvider "Envía notificaciones a proveedor externo de email" "SMTP/REST" "001 - Fase 1"
    emailProcessor.repository -> notificationDatabase.messagesTable "Actualiza estado de notificación email" "PostgreSQL" "001 - Fase 1"
    emailProcessor.attachmentFetcher -> attachmentStorage "Obtiene archivos adjuntos para email" "S3-Compatible" "001 - Fase 1"
    emailProcessor.consumer -> emailProcessor.service "Delega procesamiento de email" "C#" "001 - Fase 1"
    emailProcessor.service -> emailProcessor.adapter "Envía mensaje a proveedor externo" "C#" "001 - Fase 1"
    emailProcessor.service -> emailProcessor.repository "Actualiza estado de notificación" "C#" "001 - Fase 1"
    emailProcessor.service -> emailProcessor.attachmentFetcher "Obtiene archivos adjuntos" "C#" "001 - Fase 1"
    smsProcessor.configManager -> configPlatform.configService "Obtiene configuración externa" "HTTPS/REST" "001 - Fase 1"
    smsProcessor.configManager -> notificationDatabase.configTable "Lee configuración local y por tenant" "PostgreSQL" "001 - Fase 1"
    smsProcessor.consumer -> smsQueue "Consume SMS queue" "SQS" "001 - Fase 1"
    smsProcessor.adapter -> smsProvider "Envía notificaciones a proveedor externo de SMS" "REST/SMPP" "001 - Fase 1"
    smsProcessor.repository -> notificationDatabase.messagesTable "Actualiza estado de notificación SMS" "PostgreSQL" "001 - Fase 1"
    smsProcessor.consumer -> smsProcessor.service "Delega procesamiento de SMS" "C#" "001 - Fase 1"
    smsProcessor.service -> smsProcessor.adapter "Envía mensaje a proveedor externo" "C#" "001 - Fase 1"
    smsProcessor.service -> smsProcessor.repository "Actualiza estado de notificación" "C#" "001 - Fase 1"
    whatsappProcessor.configManager -> configPlatform.configService "Obtiene configuración externa" "HTTPS/REST" "001 - Fase 1"
    whatsappProcessor.configManager -> notificationDatabase.configTable "Lee configuración local y por tenant" "PostgreSQL" "001 - Fase 1"
    whatsappProcessor.consumer -> whatsappQueue "Consume WhatsApp queue" "SQS" "001 - Fase 1"
    whatsappProcessor.adapter -> whatsappProvider "Envía notificaciones a proveedor externo de WhatsApp" "REST" "001 - Fase 1"
    whatsappProcessor.repository -> notificationDatabase.messagesTable "Actualiza estado de notificación WhatsApp" "PostgreSQL" "001 - Fase 1"
    whatsappProcessor.attachmentFetcher -> attachmentStorage "Obtiene archivos adjuntos para WhatsApp" "S3-Compatible" "001 - Fase 1"
    whatsappProcessor.consumer -> whatsappProcessor.service "Delega procesamiento de WhatsApp" "C#" "001 - Fase 1"
    whatsappProcessor.service -> whatsappProcessor.adapter "Envía mensaje a proveedor externo" "C#" "001 - Fase 1"
    whatsappProcessor.service -> whatsappProcessor.repository "Actualiza estado de notificación" "C#" "001 - Fase 1"
    whatsappProcessor.service -> whatsappProcessor.attachmentFetcher "Obtiene archivos adjuntos" "C#" "001 - Fase 1"
    pushProcessor.configManager -> configPlatform.configService "Obtiene configuración externa" "HTTPS/REST" "001 - Fase 1"
    pushProcessor.configManager -> notificationDatabase.configTable "Lee configuración local y por tenant" "PostgreSQL" "001 - Fase 1"
    pushProcessor.consumer -> pushQueue "Consume push queue" "SQS" "001 - Fase 1"
    pushProcessor.adapter -> pushProvider "Envía notificaciones a proveedor externo de Push" "REST" "001 - Fase 1"
    pushProcessor.repository -> notificationDatabase.messagesTable "Actualiza estado de notificación Push" "PostgreSQL" "001 - Fase 1"
    pushProcessor.attachmentFetcher -> attachmentStorage "Obtiene archivos adjuntos para Push" "S3-Compatible" "001 - Fase 1"
    pushProcessor.consumer -> pushProcessor.service "Delega procesamiento de Push" "C#" "001 - Fase 1"
    pushProcessor.service -> pushProcessor.adapter "Envía mensaje a proveedor externo" "C#" "001 - Fase 1"
    pushProcessor.service -> pushProcessor.repository "Actualiza estado de notificación" "C#" "001 - Fase 1"
    pushProcessor.service -> pushProcessor.attachmentFetcher "Obtiene archivos adjuntos" "C#" "001 - Fase 1"

    // Enrutamiento a servicios corporativos
    apiGateway.reverseProxyGateway.resilienceHandler -> notification.api "Enruta a notificaciones" "HTTPS" "001 - Fase 1"

    // Health checks de servicios downstream
    apiGateway.reverseProxyGateway.healthCheck -> notification.api "Verifica disponibilidad" "HTTPS" "001 - Fase 1"
}
