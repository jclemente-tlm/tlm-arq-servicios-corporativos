notification = softwareSystem "Notification System" {
    description "Sistema corporativo de notificaciones multicanal multi-tenant para email, SMS, WhatsApp y Push con procesamiento asíncrono y plantillas dinámicas."
    tags "Notification" "001 - Fase 1"

    notificationDatabase = store "Notification Database" {
        description "PostgreSQL con esquemas para notificaciones"
        technology "PostgreSQL"
        tags "Database" "PostgreSQL" "001 - Fase 1"
    }

    emailQueue = store "Email Queue" {
        technology "SQS"
        description "Cola específica para procesamiento de notificaciones de email"
        tags "Message Bus" "SQS" "001 - Fase 1"
    }
    smsQueue = store "SMS Queue" {
        technology "SQS"
        description "Cola específica para procesamiento de notificaciones SMS"
        tags "Message Bus" "SQS" "002 - Fase 2"
    }
    whatsappQueue = store "WhatsApp Queue" {
        technology "SQS"
        description "Cola específica para procesamiento de notificaciones WhatsApp"
        tags "Message Bus" "SQS" "002 - Fase 2"
    }
    pushQueue = store "Push Queue" {
        technology "SQS"
        description "Cola específica para procesamiento de notificaciones push"
        tags "Message Bus" "SQS" "002 - Fase 2"
    }

    attachmentStorage = store "Attachment Storage" {
        technology "S3-Compatible Storage"
        description "Storage agnóstico para archivos adjuntos"
        tags "File Storage" "S3-Compatible" "001 - Fase 1"
    }

    api = application "Notification API" {
        technology "ASP.NET Core"
        description "API REST para recepción de notificaciones"
        tags "API" "001 - Fase 1"

        notificationController = component "Notification Controller" {
            technology "ASP.NET Core"
            description "Endpoints RESTful para notificaciones"
            tags "Controller" "Notifications" "001 - Fase 1"
        }

        notificationService = component "Notification Service" {
            technology "C#, .NET 8"
            description "Valida datos, construye el mensaje y lo distribuye al canal correspondiente."
            tags "Service" "001 - Fase 1"
        }

        notificationRepository = component "Notification Repository" {
            technology "C#, .NET 8, Entity Framework Core"
            description "Gestiona notificaciones en la base de datos."
            tags "Repository" "001 - Fase 1"
        }

        scheduledNotificationRepository = component "Scheduled Notification Repository" {
            technology "C#, .NET 8, Entity Framework Core"
            description "Gestiona notificaciones programadas en la base de datos."
            tags "Repository" "001 - Fase 1"
        }

        notificationRequestValidator = component "Notification Request Validator" {
            technology "C#, .NET 8, FluentValidation"
            description "Valida formato JSON, límites de tamaño y reglas por tenant"
            tags "Validation" "001 - Fase 1"
        }

        attachmentRequestValidator = component "Attachment Request Validator" {
            technology "C#, .NET 8, FluentValidation"
            description "Valida formato JSON, límites de tamaño y reglas por tenant"
            tags "Validation" "001 - Fase 1"
        }

        messageBuilder = component "Message Builder" {
            technology "C#, .NET 8"
            description "Genera el mensaje final para cada canal utilizando plantillas y datos de entrada."
            tags "Builder" "001 - Fase 1"
        }

        templateEngine = component "Template Engine" {
            technology "Liquid Templates"
            description "Genera cuerpo de mensajes en el API"
            tags "Templates" "001 - Fase 1"
        }

        templateRepository = component "Template Repository" {
            technology "C#, .NET 8, Entity Framework Core"
            description "Acceso a plantillas de notificación en la base de datos."
            tags "Repository" "Templates" "001 - Fase 1"
        }

        channelPublisher = component "Channel Publisher" {
            technology "Reliable Messaging"
            description "Publica mensajes directamente a colas por canal"
            tags "Messaging" "001 - Fase 1"
        }

        attachmentController = component "Attachment Controller" {
            technology "ASP.NET Core"
            description "Endpoints RESTful para attachments"
            tags "Controller" "Attachments" "001 - Fase 1"
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

        tenantSettingsRepository = component "TenantSettings Repository" {
            technology "C#, .NET 8, EF Core"
            description "Gestiona configuraciones por tenant del sistema"
            tags "Repository" "TenantSettings"
        }

        secretsAndConfigs = component "SecretsAndConfigs (Cross-Cutting)" {
            technology "NuGet (AWS Secrets Manager, AppConfig)"
            description "Provee acceso centralizado a configuraciones y secretos"
            tags "Configuration" "Cross-Cutting"
        }

        observability = component "Observability\n(Cross-Cutting)" {
            technology "NuGet (Serilog, Prometheus, HealthChecks)"
            description "Provee logging estructurado, métricas y health checks"
            tags "Observability" "Cross-Cutting"
        }
    }

    scheduler = application "Scheduler Service" {
        technology "Worker Service, C# .NET 8"
        description "Gestiona el envío de notificaciones programadas."
        tags "CSharp" "002 - Fase 2"

        worker = component "Scheduler Worker" {
            technology "Worker Service, C# .NET 8"
            description "Ejecuta tareas programadas para enviar notificaciones pendientes."
            tags "001 - Fase 1"
        }

        service = component "Scheduled Notification Service" {
            technology "C# .NET 8"
            description "Procesa y programa el envío de notificaciones."
            tags "001 - Fase 1"
        }

        scheduledNotificationRepository = component "Scheduled Notification Repository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Gestiona notificaciones programadas en la base de datos."
            tags "001 - Fase 1"
        }

        publisher = component "Channel Publisher" {
            technology "Reliable Messaging"
            description "Publica mensajes directamente a colas por canal"
            tags "Messaging" "001 - Fase 1"
        }

        tenantSettingsRepository = component "TenantSettings Repository" {
            technology "C#, .NET 8, EF Core"
            description "Gestiona configuraciones por tenant del sistema"
            tags "Repository" "TenantSettings"
        }

        secretsAndConfigs = component "SecretsAndConfigs (Cross-Cutting)" {
            technology "NuGet (AWS Secrets Manager, AppConfig)"
            description "Provee acceso centralizado a configuraciones y secretos"
            tags "Configuration" "Cross-Cutting"
        }

        observability = component "Observability\n(Cross-Cutting)" {
            technology "NuGet (Serilog, Prometheus, HealthChecks)"
            description "Provee logging estructurado, métricas y health checks"
            tags "Observability" "Cross-Cutting"
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

        emailNotificationService = component "Email Notification Service" {
            technology "C# .NET 8"
            description "Procesa y envía notificaciones por email."
            tags "001 - Fase 1"
        }

        emailNotificationRepository = component "Email Notification Repository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Actualiza el estado de las notificaciones enviadas por email."
            tags "001 - Fase 1"
        }

        emailProviderAdapter = component "Email Provider Adapter" {
            technology "C# .NET 8"
            description "Envía notificaciones al proveedor externo de email."
            tags "Integración" "001 - Fase 1"
        }

        attachmentFetcher = component "Attachment Fetcher" {
            technology "C# .NET 8, AWS SDK"
            description "Obtiene archivos adjuntos desde almacenamiento."
            tags "001 - Fase 1"
        }

        secretsAndConfigs = component "SecretsAndConfigs (Cross-Cutting)" {
            technology "NuGet (AWS Secrets Manager, AppConfig)"
            description "Provee acceso centralizado a configuraciones y secretos"
            tags "Configuration" "Cross-Cutting"
        }

        observability = component "Observability\n(Cross-Cutting)" {
            technology "NuGet (Serilog, Prometheus, HealthChecks)"
            description "Provee logging estructurado, métricas y health checks"
            tags "Observability" "Cross-Cutting"
        }
    }

    smsProcessor = application "SMS Processor" {
        technology "Worker Service, C# .NET 8"
        description "Procesa y envía notificaciones SMS."
        tags "CSharp" "002 - Fase 2"

        consumer = component "Consumer" {
            technology "C# .NET 8, AWS SDK"
            description "Consume mensajes de la cola notificación SMS."
            tags "001 - Fase 1"
        }

        smsNotificationService = component "SMS Notification Service" {
            technology "C# .NET 8"
            description "Procesa y envía notificaciones SMS."
            tags "001 - Fase 1"
        }

        smsNotificationRepository = component "SMS Notification Repository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Actualiza el estado de las notificaciones enviadas por SMS."
            tags "001 - Fase 1"
        }

        smsProviderAdapter = component "SMS Provider Adapter" {
            technology "C# .NET 8"
            description "Envía notificaciones al proveedor externo de SMS."
            tags "Integración" "001 - Fase 1"
        }

        secretsAndConfigs = component "SecretsAndConfigs (Cross-Cutting)" {
            technology "NuGet (AWS Secrets Manager, AppConfig)"
            description "Provee acceso centralizado a configuraciones y secretos"
            tags "Configuration" "Cross-Cutting"
        }

        observability = component "Observability\n(Cross-Cutting)" {
            technology "NuGet (Serilog, Prometheus, HealthChecks)"
            description "Provee logging estructurado, métricas y health checks"
            tags "Observability" "Cross-Cutting"
        }
    }

    whatsAppProcessor = application "WhatsApp Processor" {
        technology "Worker Service, C# .NET 8"
        description "Procesa y envía notificaciones WhatsApp."
        tags "CSharp" "002 - Fase 2"

        consumer = component "Consumer" {
            technology "C# .NET 8, AWS SDK"
            description "Consume mensajes de la cola notificación WhatsApp."
            tags "001 - Fase 1"
        }

        whatsAppNotificationService = component "WhatsApp Notification Service" {
            technology "C# .NET 8"
            description "Procesa y envía notificaciones WhatsApp."
            tags "001 - Fase 1"
        }

        whatsAppNotificationRepository = component "WhatsApp Notification Repository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Actualiza el estado de las notificaciones enviadas por WhatsApp."
            tags "001 - Fase 1"
        }

        whatsAppProviderAdapter = component "WhatsApp Provider Adapter" {
            technology "C# .NET 8"
            description "Envía notificaciones al proveedor externo de WhatsApp."
            tags "Integración" "001 - Fase 1"
        }

        attachmentFetcher = component "Attachment Fetcher" {
            technology "C# .NET 8, AWS SDK"
            description "Obtiene archivos adjuntos desde almacenamiento."
            tags "001 - Fase 1"
        }

        secretsAndConfigs = component "SecretsAndConfigs (Cross-Cutting)" {
            technology "NuGet (AWS Secrets Manager, AppConfig)"
            description "Provee acceso centralizado a configuraciones y secretos"
            tags "Configuration" "Cross-Cutting"
        }

        observability = component "Observability\n(Cross-Cutting)" {
            technology "NuGet (Serilog, Prometheus, HealthChecks)"
            description "Provee logging estructurado, métricas y health checks"
            tags "Observability" "Cross-Cutting"
        }
    }

    pushProcessor = application "Push Processor" {
        technology "Worker Service, C# .NET 8"
        description "Procesa y envía notificaciones Push."
        tags "CSharp" "002 - Fase 2"

        consumer = component "Consumer" {
            technology "C# .NET 8, AWS SDK"
            description "Consume mensajes de la cola notificación Push."
            tags "001 - Fase 1"
        }

        pushNotificationService = component "Push Notification Service" {
            technology "C# .NET 8"
            description "Procesa y envía notificaciones Push."
            tags "001 - Fase 1"
        }

        pushNotificationRepository = component "Push Notification Repository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Actualiza el estado de las notificaciones enviadas por Push."
            tags "001 - Fase 1"
        }

        pushProviderAdapter = component "Push Provider Adapter" {
            technology "C# .NET 8, AWS SDK"
            description "Envía notificaciones al proveedor externo de Push."
            tags "Integración" "001 - Fase 1"
        }

        attachmentFetcher = component "Attachment Fetcher" {
            technology "C# .NET 8, AWS SDK"
            description "Obtiene archivos adjuntos desde almacenamiento S3-compatible para incluir en notificaciones Push."
            tags "001 - Fase 1"
        }

        secretsAndConfigs = component "SecretsAndConfigs (Cross-Cutting)" {
            technology "NuGet (AWS Secrets Manager, AppConfig)"
            description "Provee acceso centralizado a configuraciones y secretos"
            tags "Configuration" "Cross-Cutting"
        }

        observability = component "Observability\n(Cross-Cutting)" {
            technology "NuGet (Serilog, Prometheus, HealthChecks)"
            description "Provee logging estructurado, métricas y health checks"
            tags "Observability" "Cross-Cutting"
        }
    }

    appPeru -> api.notificationController "Solicita envío de notificación" "HTTPS via API Gateway" "001 - Fase 1"
    appEcuador -> api.notificationController "Solicita envío de notificación" "HTTPS via API Gateway" "001 - Fase 1"
    appColombia -> api.notificationController "Solicita envío de notificación" "HTTPS via API Gateway" "001 - Fase 1"
    appMexico -> api.notificationController "Solicita envío de notificación" "HTTPS via API Gateway" "001 - Fase 1"
    appPeru -> api.attachmentController "Solicita carga de archivos adjuntos" "HTTPS via API Gateway" "001 - Fase 1"
    appEcuador -> api.attachmentController "Solicita carga de archivos adjuntos" "HTTPS via API Gateway" "001 - Fase 1"
    appColombia -> api.attachmentController "Solicita carga de archivos adjuntos" "HTTPS via API Gateway" "001 - Fase 1"
    appMexico -> api.attachmentController "Solicita carga de archivos adjuntos" "HTTPS via API Gateway" "001 - Fase 1"

    api.notificationController -> api.notificationRequestValidator "Valida requests de notificaciones" "" "001 - Fase 1"
    api.attachmentController -> api.attachmentRequestValidator "Valida requests de attachments" "" "001 - Fase 1"
    api.attachmentController -> api.attachmentService "Orquesta operaciones de archivos" "" "001 - Fase 1"
    api.attachmentService -> api.attachmentRepository "Gestiona metadatos" "" "001 - Fase 1"
    api.attachmentService -> attachmentStorage "Almacena archivos adjuntos" "S3-Compatible" "001 - Fase 1"
    api.attachmentRepository -> notificationDatabase "Persiste metadatos" "EF Core/PostgreSQL" "001 - Fase 1"
    api.secretsAndConfigs -> configPlatform.configService "Obtiene configuración externa" "HTTPS/REST" "001 - Fase 1"
    api.tenantSettingsRepository -> notificationDatabase "Lee configuraciones por tenant" "EF Core/PostgreSQL" "001 - Fase 1"
    api.observability  -> observabilitySystem "Envía logs, métricas y health checks" "HTTPS/REST" "001 - Fase 1"


    api.notificationController -> api.notificationService "Genera mensaje" "" "001 - Fase 1"
    api.notificationService -> api.messageBuilder "Genera mensaje" "" "001 - Fase 1"
    api.messageBuilder -> api.templateEngine "Renderiza plantilla" "" "001 - Fase 1"
    api.notificationService -> api.notificationRepository "Registra notificación" "" "001 - Fase 1"
    api.notificationService -> api.scheduledNotificationRepository "Registra notificaciones programadas" "" "001 - Fase 1"
    api.notificationRepository -> notificationDatabase "Registra notificación" "EF Core/PostgreSQL" "001 - Fase 1"
    api.scheduledNotificationRepository -> notificationDatabase "Registra notificaciones programadas" "EF Core/PostgreSQL" "001 - Fase 1"
    api.templateEngine -> api.templateRepository "Lee plantilla" "" "001 - Fase 1"
    api.templateRepository -> notificationDatabase "Lee plantilla" "EF Core/PostgreSQL" "001 - Fase 1"
    api.notificationService -> api.tenantSettingsRepository "Lee configuración por tenant" "" "001 - Fase 1"

    api.notificationService -> api.channelPublisher "Publica en cola por canal" "" "001 - Fase 1"

    api.channelPublisher -> emailQueue "Encola notificación email" "SQS" "001 - Fase 1"
    api.channelPublisher -> smsQueue "Encola notificación SMS" "SQS" "002 - Fase 2"
    api.channelPublisher -> whatsappQueue "Encola notificación WhatsApp" "SQS" "002 - Fase 2"
    api.channelPublisher -> pushQueue "Encola notificación Push" "SQS" "002 - Fase 2"

    emailProcessor -> emailProvider "Envía email" "SMTP/REST" "001 - Fase 1"
    smsProcessor -> smsProvider "Envía SMS" "HTTPS/API" "001 - Fase 1"
    pushProcessor -> pushProvider "Envía push" "HTTPS/API" "001 - Fase 1"

    scheduler.publisher -> emailQueue "Encola notificación email" "SQS" "002 - Fase 2"
    scheduler.publisher -> smsQueue "Encola notificación SMS" "SQS" "002 - Fase 2"
    scheduler.publisher -> whatsappQueue "Encola notificación WhatsApp" "SQS" "002 - Fase 2"
    scheduler.publisher -> pushQueue "Encola notificación Push" "SQS" "002 - Fase 2"

    scheduler.secretsAndConfigs -> configPlatform.configService "Obtiene configuración externa" "HTTPS/REST" "002 - Fase 2"
    scheduler.scheduledNotificationRepository -> notificationDatabase "Lee notificaciones programadas próximas a enviar" "EF Core/PostgreSQL" "001 - Fase 1"
    scheduler.service -> scheduler.scheduledNotificationRepository "Accede a notificaciones programadas" "" "001 - Fase 1"
    scheduler.service -> scheduler.publisher "Publica notificaciones programadas" "" "001 - Fase 1"
    scheduler.worker -> scheduler.service "Ejecuta tareas programadas" "" "001 - Fase 1"
    scheduler.service -> scheduler.tenantSettingsRepository "Lee configuración por tenant" "" "001 - Fase 1"
    scheduler.tenantSettingsRepository -> notificationDatabase "Lee configuraciones por tenant" "EF Core/PostgreSQL" "001 - Fase 1"
    scheduler.observability  -> observabilitySystem "Envía logs, métricas y health checks" "HTTPS/REST" "001 - Fase 1"


    emailProcessor.secretsAndConfigs -> configPlatform.configService "Obtiene configuración externa" "HTTPS/REST" "001 - Fase 1"
    emailProcessor.consumer -> emailQueue "Consume email queue" "SQS" "001 - Fase 1"
    emailProcessor.emailProviderAdapter -> emailProvider "Envía notificaciones a proveedor externo de email" "SMTP/REST" "001 - Fase 1"
    emailProcessor.emailNotificationRepository -> notificationDatabase "Actualiza estado de notificación email" "EF Core/PostgreSQL" "001 - Fase 1"
    emailProcessor.attachmentFetcher -> attachmentStorage "Obtiene archivos adjuntos para email" "S3-Compatible" "001 - Fase 1"
    emailProcessor.consumer -> emailProcessor.emailNotificationService "Delega procesamiento de email" "" "001 - Fase 1"
    emailProcessor.emailNotificationService -> emailProcessor.emailProviderAdapter "Envía mensaje a proveedor externo" "" "001 - Fase 1"
    emailProcessor.emailNotificationService -> emailProcessor.emailNotificationRepository "Actualiza estado de notificación" "" "001 - Fase 1"
    emailProcessor.emailNotificationService -> emailProcessor.attachmentFetcher "Obtiene archivos adjuntos" "" "001 - Fase 1"
    emailProcessor.observability  -> observabilitySystem "Envía logs, métricas y health checks" "HTTPS/REST" "001 - Fase 1"

    smsProcessor.secretsAndConfigs -> configPlatform.configService "Obtiene configuración externa" "HTTPS/REST" "002 - Fase 2"
    smsProcessor.consumer -> smsQueue "Consume SMS queue" "SQS" "002 - Fase 2"
    smsProcessor.smsProviderAdapter -> smsProvider "Envía notificaciones a proveedor externo de SMS" "REST/SMPP" "001 - Fase 1"
    smsProcessor.smsNotificationRepository -> notificationDatabase "Actualiza estado de notificación SMS" "EF Core/PostgreSQL" "001 - Fase 1"
    smsProcessor.consumer -> smsProcessor.smsNotificationService "Delega procesamiento de SMS" "" "001 - Fase 1"
    smsProcessor.smsNotificationService -> smsProcessor.smsProviderAdapter "Envía mensaje a proveedor externo" "" "001 - Fase 1"
    smsProcessor.smsNotificationService -> smsProcessor.smsNotificationRepository "Actualiza estado de notificación" "" "001 - Fase 1"
    smsProcessor.observability  -> observabilitySystem "Envía logs, métricas y health checks" "HTTPS/REST" "001 - Fase 1"

    whatsAppProcessor.secretsAndConfigs -> configPlatform.configService "Obtiene configuración externa" "HTTPS/REST" "002 - Fase 2"
    whatsAppProcessor.consumer -> whatsAppQueue "Consume WhatsApp queue" "SQS" "002 - Fase 2"
    whatsAppProcessor.whatsAppProviderAdapter -> whatsappProvider "Envía notificaciones WhatsApp" "HTTPS/API" "001 - Fase 1"
    whatsAppProcessor.whatsAppNotificationRepository -> notificationDatabase "Actualiza estado de notificación WhatsApp" "EF Core/PostgreSQL" "001 - Fase 1"
    whatsAppProcessor.attachmentFetcher -> attachmentStorage "Obtiene archivos adjuntos para WhatsApp" "S3-Compatible" "002 - Fase 2"
    whatsAppProcessor.consumer -> whatsAppProcessor.whatsAppNotificationService "Delega procesamiento de WhatsApp" "" "001 - Fase 1"
    whatsAppProcessor.whatsAppNotificationService -> whatsAppProcessor.whatsAppProviderAdapter "Envía mensaje a proveedor externo" "" "001 - Fase 1"
    whatsAppProcessor.whatsAppNotificationService -> whatsAppProcessor.whatsAppNotificationRepository "Actualiza estado de notificación" "" "001 - Fase 1"
    whatsAppProcessor.whatsAppNotificationService -> whatsAppProcessor.attachmentFetcher "Obtiene archivos adjuntos" "" "001 - Fase 1"
    whatsAppProcessor.observability  -> observabilitySystem "Envía logs, métricas y health checks" "HTTPS/REST" "001 - Fase 1"

    pushProcessor.secretsAndConfigs -> configPlatform.configService "Obtiene configuración externa" "HTTPS/REST" "002 - Fase 2"
    pushProcessor.consumer -> pushQueue "Consume push queue" "SQS" "002 - Fase 2"
    pushProcessor.pushProviderAdapter -> pushProvider "Envía notificaciones a proveedor externo de Push" "HTTPS/API" "001 - Fase 1"
    pushProcessor.pushNotificationRepository -> notificationDatabase "Actualiza estado de notificación Push" "EF Core/PostgreSQL" "001 - Fase 1"
    pushProcessor.attachmentFetcher -> attachmentStorage "Obtiene archivos adjuntos para Push" "S3-Compatible" "002 - Fase 2"
    pushProcessor.consumer -> pushProcessor.pushNotificationService "Delega procesamiento de Push" "" "001 - Fase 1"
    pushProcessor.pushNotificationService -> pushProcessor.pushProviderAdapter "Envía mensaje a proveedor externo" "" "001 - Fase 1"
    pushProcessor.pushNotificationService -> pushProcessor.pushNotificationRepository "Actualiza estado de notificación" "" "001 - Fase 1"
    pushProcessor.pushNotificationService -> pushProcessor.attachmentFetcher "Obtiene archivos adjuntos" "" "001 - Fase 1"
    pushProcessor.observability  -> observabilitySystem "Envía logs, métricas y health checks" "HTTPS/REST" "001 - Fase 1"

    // Enrutamiento a servicios corporativos
    apiGateway.reverseProxyGateway.resilienceMiddleware -> notification.api "Enruta a notificaciones" "HTTPS" "001 - Fase 1"

    // // Health checks de servicios downstream
    // apiGateway.reverseProxyGateway.healthCheck -> notification.api "Verifica disponibilidad" "HTTPS" "001 - Fase 1"
}
