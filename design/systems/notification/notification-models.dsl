notification = softwareSystem "Notification System" {
    description "Orquesta el envío de notificaciones multicanal para aplicaciones corporativas."
    tags "Notification" "001 - Fase 1"

    // Data Stores
    notificationDB = store "Notification Database" {
        technology "PostgreSQL"
        description "Base de datos principal para plantillas, configuraciones de canales, historial de envíos y notificaciones programadas."
        tags "Database" "PostgreSQL" "001 - Fase 1"
    }

    notificationQueue = store "Notification Queue" {
        technology "AWS SQS"
        description "Cola principal para recepción de solicitudes de notificación desde sistemas externos."
        tags "Message Bus" "AWS SQS" "001 - Fase 1"
    }

    failedNotificationsQueue = store "Failed Notifications Queue" {
        technology "AWS SQS"
        description "Cola para procesamiento de notificaciones fallidas con reintentos automáticos (Dead Letter Queue)."
        tags "Message Bus" "AWS SQS" "DLQ" "001 - Fase 1"
    }

    emailQueue = store "Email Queue" {
        technology "AWS SQS"
        description "Cola específica para procesamiento de notificaciones por correo electrónico."
        tags "Message Bus" "AWS SQS" "001 - Fase 1"
    }

    smsQueue = store "SMS Queue" {
        technology "AWS SQS"
        description "Cola específica para procesamiento de notificaciones SMS con integración a proveedores."
        tags "Message Bus" "AWS SQS" "001 - Fase 1"
    }

    whatsappQueue = store "WhatsApp Queue" {
        technology "AWS SQS"
        description "Cola específica para procesamiento de notificaciones WhatsApp Business API."
        tags "Message Bus" "AWS SQS" "001 - Fase 1"
    }

    pushQueue = store "Push Queue" {
        technology "AWS SQS"
        description "Cola específica para procesamiento de notificaciones push móviles (FCM/APNS)."
        tags "Message Bus" "AWS SQS" "001 - Fase 1"
    }

    attachmentStorage = store "Attachment Storage" {
        technology "AWS S3"
        description "Almacenamiento escalable para archivos adjuntos con versionado y políticas de lifecycle."
        tags "File Storage" "AWS S3" "001 - Fase 1"
    }

    configurationEventQueue = store "Configuration Event Queue" {
        description "Cola para eventos de cambios de configuración y actualizaciones de feature flags del sistema."
        technology "AWS SQS"
        tags "Message Bus" "SQS" "Configuration" "001 - Fase 1"
    }

    api = application "Notification API" {
        technology "ASP.NET Core, C# .NET 8"
        description "API REST para registro de notificaciones y adjuntos."
        tags "CSharp" "001 - Fase 1"

        notificationController = component "Notification Controller" {
            technology "ASP.NET Core, C# .NET 8"
            description "Expone endpoints REST para recepción y gestión de solicitudes de notificación multicanal."
            tags "001 - Fase 1"
        }

        notificationService = component "Notification Service" {
            technology "C# .NET 8"
            description "Procesa la lógica de negocio para solicitudes de notificación y aplica reglas de validación."
            tags "001 - Fase 1"
        }

        requestValidator = component "Request Validator" {
            technology "C# .NET 8, FluentValidation"
            description "Valida estructura, contenido y reglas de negocio en las solicitudes de notificación."
            tags "001 - Fase 1"
        }

        notificationPublisher = component "Notification Publisher" {
            technology "C# .NET 8, AWS SDK"
            description "Publica mensajes validados a las colas específicas de cada canal de notificación."
            tags "001 - Fase 1"
        }

        attachmentController = component "Attachment Controller" {
            technology "ASP.NET Core, C# .NET 8"
            description "Expone endpoints REST para carga, descarga y gestión de archivos adjuntos."
            tags "001 - Fase 1"
        }

        attachmentService = component "Attachment Service" {
            technology "C# .NET 8"
            description "Procesa operaciones de archivo: validación de formato, dimensiones y gestión de metadatos."
            tags "001 - Fase 1"
        }

        attachmentRepository = component "Attachment Repository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Gestiona el acceso a metadatos de archivos adjuntos en la base de datos."
            tags "001 - Fase 1"
        }

        attachmentManager = component "Attachment Manager" {
            technology "C# .NET 8, AWS SDK"
            description "Gestiona la carga, descarga y eliminación de archivos en almacenamiento S3."
            tags "001 - Fase 1"
        }

        tenantConfigurationRepository = component "Tenant Configuration Repository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Provee configuraciones específicas por tenant y país para personalización de notificaciones."
            tags "001 - Fase 1"
        }

        configurationManager = component "Configuration Manager" {
            technology "C# .NET 8, AWS SDK, IMemoryCache"
            description "Gestiona configuraciones dinámicas y secretos con cache inteligente y feature flags por país/tenant."
            tags "Configuración" "001 - Fase 1"
        }

        configurationCache = component "Configuration Cache" {
            technology "IMemoryCache, Redis"
            description "Cache distribuido para configuraciones con TTL diferenciado por tipo y invalidación selectiva."
            tags "Cache" "001 - Fase 1"
        }

        featureFlagService = component "Feature Flag Service" {
            technology "C#, AWS SDK"
            description "Gestiona habilitación de canales por país, límites de rate por tenant y personalización de templates."
            tags "Feature Flags" "001 - Fase 1"
        }

        // Componentes de Observabilidad
        healthCheck = component "Health Check" {
            technology "ASP.NET Core Health Checks"
            description "Expone endpoints /health, /health/ready, /health/live para monitoring."
            tags "Observability" "001 - Fase 1"
        }

        metricsCollector = component "Metrics Collector" {
            technology "Prometheus Client"
            description "Recolecta métricas de rendimiento: requests/sec, latencia, errores, config cache hit ratio, feature flag usage."
            tags "Observability" "001 - Fase 1"
        }

        logger = component "Structured Logger" {
            technology "Serilog"
            description "Logging estructurado con correlationId para trazabilidad."
            tags "Observability" "001 - Fase 1"
        }
    }

    notificationProcessor = application "Notification Processor" {
        technology "Worker Service, C# .NET 8"
        description "Procesador central que orquesta el envío multicanal de notificaciones con distribución inteligente."
        tags "CSharp" "001 - Fase 1"

        messageConsumer = component "Message Consumer" {
            technology "C# .NET 8, AWS SDK"
            description "Consume y procesa mensajes de notificación desde la cola principal con control de concurrencia."
            tags "001 - Fase 1"
        }

        orchestrationService = component "Orchestration Service" {
            technology "C# .NET 8"
            description "Valida, enriquece datos y distribuye mensajes al canal correspondiente según reglas de negocio."
            tags "001 - Fase 1"
        }

        templateEngine = component "Template Engine" {
            technology "C# .NET 8"
            description "Genera contenido final para cada canal aplicando plantillas con datos dinámicos y personalización."
            tags "Builder" "001 - Fase 1"
        }

        channelDispatcher = component "Channel Dispatcher" {
            technology "C# .NET 8, AWS SDK"
            description "Distribuye mensajes procesados a colas específicas de cada canal (Email, SMS, WhatsApp, Push)."
            tags "001 - Fase 1"
        }

        notificationRepository = component "Notification Repository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Gestiona persistencia de estados, historial y eventos de notificaciones procesadas."
            tags "001 - Fase 1"
        }

        processorConfigurationManager = component "Processor Configuration Manager" {
            technology "C# .NET 8, AWS SDK"
            description "Gestiona configuraciones de procesamiento, plantillas dinámicas y parámetros de canal."
            tags "Configuración" "001 - Fase 1"
        }

        templateRepository = component "Template Repository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Provee acceso versionado a plantillas de notificación con soporte para A/B testing."
            tags "Template" "001 - Fase 1"
        }

        processorTenantConfigRepository = component "Processor Tenant Config Repository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Provee configuraciones de procesamiento específicas por tenant y país."
            tags "001 - Fase 1"
        }

        channelConfigurationRepository = component "Channel Configuration Repository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Gestiona configuraciones específicas para cada canal: límites, formatos y validaciones."
            tags "Configuración" "001 - Fase 1"
        }

        // Componentes de Observabilidad
        metricsCollector = component "Metrics Collector" {
            technology "Prometheus Client"
            description "Recolecta métricas: messages processed/sec, processing time, queue depth."
            tags "Observability" "001 - Fase 1"
        }

        logger = component "Structured Logger" {
            technology "Serilog"
            description "Logging estructurado con correlationId para trazabilidad."
            tags "Observability" "001 - Fase 1"
        }
    }

    notificationScheduler = application "Notification Scheduler" {
        technology "Worker Service, C# .NET 8"
        description "Gestor de notificaciones programadas con soporte para envíos diferidos y recurrentes."
        tags "CSharp" "001 - Fase 1"

        schedulerWorker = component "Scheduler Worker" {
            technology "Worker Service, C# .NET 8"
            description "Ejecuta tareas programadas y procesa notificaciones pendientes según cronogramas configurados."
            tags "001 - Fase 1"
        }

        schedulingService = component "Scheduling Service" {
            technology "C# .NET 8"
            description "Gestiona la lógica de programación, validación de horarios y procesamiento de notificaciones diferidas."
            tags "001 - Fase 1"
        }

        scheduledNotificationRepository = component "Scheduled Notification Repository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Gestiona el acceso a notificaciones programadas con consultas optimizadas por fecha y estado."
            tags "001 - Fase 1"
        }

        publisher = component "Queue Publisher" {
            technology "C# .NET 8, AWS SDK"
            description "Envía notificaciones programadas a la cola de notificación."
            tags "001 - Fase 1"
        }

        tenantConfigRepository = component "TenantConfigRepository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Provee configuraciones específicas por tenant."
            tags "001 - Fase 1"
        }

        configManager = component "Configuration Manager" {
            technology "C# .NET 8, AWS SDK"
            description "Lee configuraciones y secretos desde repositorios y plataforma de configuración."
            tags "Configuración" "001 - Fase 1"
        }
    }

    // Channel-Specific Processors
    emailProcessor = application "Email Processor" {
        technology "Worker Service, C# .NET 8"
        description "Procesador especializado para notificaciones por correo electrónico con soporte para adjuntos y HTML."
        tags "CSharp" "001 - Fase 1"

        emailConsumer = component "Email Consumer" {
            technology "C# .NET 8, AWS SDK"
            description "Consume y procesa mensajes de la cola específica de notificaciones email con manejo de prioridades."
            tags "001 - Fase 1"
        }

        emailDeliveryService = component "Email Delivery Service" {
            technology "C# .NET 8"
            description "Gestiona la entrega de emails con validación de formato, antispam y gestión de rebotes."
            tags "001 - Fase 1"
        }

        emailRepository = component "Email Repository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Gestiona el estado y historial específico de notificaciones email con tracking de apertura."
            tags "001 - Fase 1"
        }

        emailProviderAdapter = component "Email Provider Adapter" {
            technology "C# .NET 8, AWS SDK"
            description "Integra con proveedores externos de email (AWS SES, SendGrid) con failover automático."
            tags "Integración" "001 - Fase 1"
        }

        emailAttachmentFetcher = component "Email Attachment Fetcher" {
            technology "C# .NET 8, AWS SDK"
            description "Obtiene y procesa archivos adjuntos desde almacenamiento con validación de seguridad."
            tags "001 - Fase 1"
        }

        emailTenantConfigRepository = component "Email Tenant Config Repository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Provee configuraciones específicas de email por tenant: remitentes, plantillas, límites."
            tags "001 - Fase 1"
        }

        emailConfigurationManager = component "Email Configuration Manager" {
            technology "C# .NET 8, AWS SDK"
            description "Gestiona configuraciones dinámicas de email: proveedores, credenciales y políticas de envío."
            tags "Configuración" "001 - Fase 1"
        }

        emailChannelConfigRepository = component "Email Channel Config Repository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Gestiona configuraciones específicas del canal email: formatos, validaciones y límites de envío."
            tags "Configuración" "001 - Fase 1"
        }
    }

    smsProcessor = application "SMS Processor" {
        technology "Worker Service, C# .NET 8"
        description "Procesador especializado para notificaciones SMS con validación de números y gestión de proveedores."
        tags "CSharp" "001 - Fase 1"

        smsConsumer = component "SMS Consumer" {
            technology "C# .NET 8, AWS SDK"
            description "Consume y procesa mensajes de la cola específica de notificaciones SMS con rate limiting."
            tags "001 - Fase 1"
        }

        smsDeliveryService = component "SMS Delivery Service" {
            technology "C# .NET 8"
            description "Gestiona el envío de SMS con validación de números, filtrado de contenido y gestión de costos."
            tags "001 - Fase 1"
        }

        smsRepository = component "SMS Repository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Gestiona el estado y historial específico de notificaciones SMS con tracking de entrega."
            tags "001 - Fase 1"
        }

        smsProviderAdapter = component "SMS Provider Adapter" {
            technology "C# .NET 8, AWS SDK"
            description "Integra con proveedores SMS (Twilio, AWS SNS) con selección automática por país y costo."
            tags "Integración" "001 - Fase 1"
        }

        smsTenantConfigRepository = component "SMS Tenant Config Repository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Provee configuraciones específicas de SMS por tenant: remitentes, límites de envío, proveedores preferidos."
            tags "001 - Fase 1"
        }

        smsConfigurationManager = component "SMS Configuration Manager" {
            technology "C# .NET 8, AWS SDK"
            description "Gestiona configuraciones dinámicas de SMS: credenciales de proveedores, políticas de routing y costos."
            tags "Configuración" "001 - Fase 1"
        }

        smsChannelConfigRepository = component "SMS Channel Config Repository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Gestiona configuraciones específicas del canal SMS: límites de caracteres, validaciones y tarifas."
            tags "Configuración" "001 - Fase 1"
        }
    }

    whatsappProcessor = application "WhatsApp Processor" {
        technology "Worker Service, C# .NET 8"
        description "Procesador especializado para WhatsApp Business API con soporte para multimedia y templates oficiales."
        tags "CSharp" "001 - Fase 1"

        whatsappConsumer = component "WhatsApp Consumer" {
            technology "C# .NET 8, AWS SDK"
            description "Consume y procesa mensajes de la cola específica de WhatsApp con validación de templates."
            tags "001 - Fase 1"
        }

        whatsappDeliveryService = component "WhatsApp Delivery Service" {
            technology "C# .NET 8"
            description "Gestiona el envío vía WhatsApp Business API con validación de templates y gestión de sesiones."
            tags "001 - Fase 1"
        }

        whatsappRepository = component "WhatsApp Repository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Gestiona el estado específico de WhatsApp con tracking de lectura y webhooks de estado."
            tags "001 - Fase 1"
        }

        whatsappProviderAdapter = component "WhatsApp Provider Adapter" {
            technology "C# .NET 8, AWS SDK"
            description "Integra con WhatsApp Business API y proveedores como Twilio WhatsApp con manejo de límites."
            tags "Integración" "001 - Fase 1"
        }

        whatsappAttachmentFetcher = component "WhatsApp Attachment Fetcher" {
            technology "C# .NET 8, AWS SDK"
            description "Procesa archivos multimedia para WhatsApp con conversión de formatos y optimización."
            tags "001 - Fase 1"
        }

        whatsappTenantConfigRepository = component "WhatsApp Tenant Config Repository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Provee configuraciones de WhatsApp por tenant: números verificados, templates aprobados, límites."
            tags "001 - Fase 1"
        }

        whatsappConfigurationManager = component "WhatsApp Configuration Manager" {
            technology "C# .NET 8, AWS SDK"
            description "Gestiona configuraciones dinámicas de WhatsApp: tokens, webhooks, templates y políticas de uso."
            tags "Configuración" "001 - Fase 1"
        }

        whatsappChannelConfigRepository = component "WhatsApp Channel Config Repository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Gestiona configuraciones específicas de WhatsApp: templates, límites de medios y validaciones."
            tags "Configuración" "001 - Fase 1"
        }
    }

    pushProcessor = application "Push Processor" {
        technology "Worker Service, C# .NET 8"
        description "Procesador especializado para notificaciones push móviles con soporte para FCM y APNS."
        tags "CSharp" "001 - Fase 1"

        pushConsumer = component "Push Consumer" {
            technology "C# .NET 8, AWS SDK"
            description "Consume y procesa mensajes de la cola específica de notificaciones push con gestión de dispositivos."
            tags "001 - Fase 1"
        }

        pushDeliveryService = component "Push Delivery Service" {
            technology "C# .NET 8"
            description "Gestiona el envío de push notifications con personalización por plataforma (iOS/Android)."
            tags "001 - Fase 1"
        }

        pushRepository = component "Push Repository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Gestiona el estado específico de push con tracking de entrega y gestión de tokens de dispositivos."
            tags "001 - Fase 1"
        }

        pushProviderAdapter = component "Push Provider Adapter" {
            technology "C# .NET 8, AWS SDK"
            description "Integra con FCM (Android) y APNS (iOS) con manejo automático de tokens expirados."
            tags "Integración" "001 - Fase 1"
        }

        pushAttachmentFetcher = component "Push Attachment Fetcher" {
            technology "C# .NET 8, AWS SDK"
            description "Procesa archivos multimedia para notificaciones push con optimización de tamaño."
            tags "001 - Fase 1"
        }

        pushTenantConfigRepository = component "Push Tenant Config Repository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Provee configuraciones de push por tenant: certificados, claves de API, configuraciones de aplicación."
            tags "001 - Fase 1"
        }

        pushConfigurationManager = component "Push Configuration Manager" {
            technology "C# .NET 8, AWS SDK"
            description "Gestiona configuraciones dinámicas de push: certificados, tokens de servidor y políticas de entrega."
            tags "Configuración" "001 - Fase 1"
        }

        pushChannelConfigRepository = component "Push Channel Config Repository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Gestiona configuraciones específicas de push: formatos por plataforma, límites y validaciones."
            tags "Configuración" "001 - Fase 1"
        }
    }

    // ========================================
    // RELACIONES INTERNAS - API
    // ========================================

    // Flujo principal de API
    api.notificationController -> api.notificationService "Registra solicitud de notificación" "" "001 - Fase 1"
    api.notificationService -> api.requestValidator "Valida datos de la solicitud" "" "001 - Fase 1"
    api.notificationService -> api.notificationPublisher "Encola notificación para procesamiento" "" "001 - Fase 1"
    api.notificationPublisher -> notificationQueue "Publica mensaje en la cola de notificaciones" "AWS SQS" "001 - Fase 1"

    // Flujo de adjuntos
    api.attachmentController -> api.attachmentService "Registra adjunto" "" "001 - Fase 1"
    api.attachmentService -> api.attachmentRepository "Accede a metadatos de adjuntos" "" "001 - Fase 1"
    api.attachmentService -> api.attachmentManager "Gestiona archivos adjuntos" "" "001 - Fase 1"
    api.attachmentManager -> attachmentStorage "Almacena archivo adjunto" "AWS S3" "001 - Fase 1"
    api.attachmentRepository -> notificationDB "Guarda metadatos de adjuntos" "Entity Framework Core" "001 - Fase 1"

    // API - Configuración
    api.configurationManager -> api.configurationCache "consulta cache" "" "001 - Fase 1"
    api.featureFlagService -> api.configurationCache "usa cache para flags" "" "001 - Fase 1"
    api.configurationManager -> api.tenantConfigurationRepository "Obtiene configuraciones por tenant" "" "001 - Fase 1"
    api.tenantConfigurationRepository -> notificationDB "Accede a configuraciones por tenant" "Entity Framework Core" "001 - Fase 1"

    // API - Observabilidad
    api.configurationManager -> api.metricsCollector "envía métricas de config" "" "001 - Fase 1"
    api.featureFlagService -> api.metricsCollector "envía métricas de feature flags" "" "001 - Fase 1"

    // Notification Processor - Flujo principal
    notificationQueue -> notificationProcessor.messageConsumer "Entrega mensaje para procesamiento" "AWS SQS" "001 - Fase 1"
    notificationProcessor.messageConsumer -> notificationProcessor.orchestrationService "Procesa mensaje de notificación" "" "001 - Fase 1"
    notificationProcessor.orchestrationService -> notificationProcessor.templateEngine "Genera mensaje por canal" "" "001 - Fase 1"
    notificationProcessor.orchestrationService -> notificationProcessor.channelDispatcher "Envía mensaje a canal" "" "001 - Fase 1"
    notificationProcessor.orchestrationService -> notificationProcessor.notificationRepository "Registra notificación procesada" "" "001 - Fase 1"

    // Notification Processor - Configuración
    notificationProcessor.orchestrationService -> notificationProcessor.processorConfigurationManager "Obtiene configuración y plantillas" "" "001 - Fase 1"
    notificationProcessor.processorConfigurationManager -> notificationProcessor.templateRepository "Obtiene plantillas" "" "001 - Fase 1"
    notificationProcessor.processorConfigurationManager -> notificationProcessor.processorTenantConfigRepository "Obtiene configuración por tenant" "" "001 - Fase 1"
    notificationProcessor.processorConfigurationManager -> notificationProcessor.channelConfigurationRepository "Obtiene configuración de canales" "" "001 - Fase 1"

    // Notification Processor - Bases de datos
    notificationProcessor.notificationRepository -> notificationDB "Guarda notificación procesada" "Entity Framework Core" "001 - Fase 1"
    notificationProcessor.templateRepository -> notificationDB "Accede a plantillas" "Entity Framework Core" "001 - Fase 1"
    notificationProcessor.processorTenantConfigRepository -> notificationDB "Accede a configuración por tenant" "Entity Framework Core" "001 - Fase 1"
    notificationProcessor.channelConfigurationRepository -> notificationDB "Accede a configuración de canales" "Entity Framework Core" "001 - Fase 1"

    // Notification Processor - Distribución por canal
    notificationProcessor.channelDispatcher -> emailQueue "Publica mensaje en cola Email" "AWS SQS" "001 - Fase 1"
    notificationProcessor.channelDispatcher -> smsQueue "Publica mensaje en cola SMS" "AWS SQS" "001 - Fase 1"
    notificationProcessor.channelDispatcher -> whatsappQueue "Publica mensaje en cola WhatsApp" "AWS SQS" "001 - Fase 1"
    notificationProcessor.channelDispatcher -> pushQueue "Publica mensaje en cola Push" "AWS SQS" "001 - Fase 1"

    // Scheduler - Notificaciones programadas
    notificationScheduler.schedulerWorker -> notificationScheduler.schedulingService "Procesa notificaciones programadas" "" "001 - Fase 1"
    notificationScheduler.schedulingService -> notificationScheduler.scheduledNotificationRepository "Accede a notificaciones programadas" "" "001 - Fase 1"
    notificationScheduler.schedulingService -> notificationScheduler.publisher "Publica notificaciones programadas" "" "001 - Fase 1"
    notificationScheduler.scheduledNotificationRepository -> notificationDB "Lee notificaciones programadas" "Entity Framework Core" "001 - Fase 1"
    notificationScheduler.publisher -> notificationQueue "Envía notificaciones programadas a la cola de notificación" "AWS SQS" "001 - Fase 1"
    notificationScheduler.configManager -> notificationScheduler.tenantConfigRepository "Lee configuraciones por tenant" "Entity Framework Core" "001 - Fase 1"
    notificationScheduler.tenantConfigRepository -> notificationDB "Lee configuraciones por tenant" "Entity Framework Core" "001 - Fase 1"

    // Email Processor - Flujo
    emailQueue -> emailProcessor.emailConsumer "Consume mensaje de Email" "AWS SQS" "001 - Fase 1"
    emailProcessor.emailConsumer -> emailProcessor.emailDeliveryService "Procesa mensaje de Email" "" "001 - Fase 1"
    emailProcessor.emailDeliveryService -> emailProcessor.emailRepository "Actualiza estado de Email" "" "001 - Fase 1"
    emailProcessor.emailDeliveryService -> emailProcessor.emailProviderAdapter "Envía mensaje a proveedor de Email" "" "001 - Fase 1"
    emailProcessor.emailDeliveryService -> emailProcessor.emailAttachmentFetcher "Obtiene adjuntos para envío" "" "001 - Fase 1"
    emailProcessor.emailRepository -> notificationDB "Actualiza estado de notificación email" "Entity Framework Core" "001 - Fase 1"
    emailProcessor.emailAttachmentFetcher -> attachmentStorage "Obtiene archivos adjuntos" "AWS S3" "001 - Fase 1"

    // Email Processor - Configuración
    emailProcessor.emailConfigurationManager -> emailProcessor.emailTenantConfigRepository "Lee configuraciones por tenant" "Entity Framework Core" "001 - Fase 1"
    emailProcessor.emailConfigurationManager -> emailProcessor.emailChannelConfigRepository "Lee configuraciones de canal" "Entity Framework Core" "001 - Fase 1"
    emailProcessor.emailChannelConfigRepository -> notificationDB "Lee configuraciones de canal" "Entity Framework Core" "001 - Fase 1"

    // SMS Processor - Flujo
    smsQueue -> smsProcessor.smsConsumer "Consume mensaje de SMS" "AWS SQS" "001 - Fase 1"
    smsProcessor.smsConsumer -> smsProcessor.smsDeliveryService "Procesa mensaje de SMS" "" "001 - Fase 1"
    smsProcessor.smsDeliveryService -> smsProcessor.smsRepository "Actualiza estado de notificación SMS" "" "001 - Fase 1"
    smsProcessor.smsDeliveryService -> smsProcessor.smsProviderAdapter "Envía mensaje a proveedor de SMS" "" "001 - Fase 1"
    smsProcessor.smsRepository -> notificationDB "Actualiza estado de notificación SMS" "Entity Framework Core" "001 - Fase 1"

    // SMS Processor - Configuración
    smsProcessor.smsConfigurationManager -> smsProcessor.smsTenantConfigRepository "Lee configuraciones por tenant" "Entity Framework Core" "001 - Fase 1"
    smsProcessor.smsConfigurationManager -> smsProcessor.smsChannelConfigRepository "Lee configuraciones de canal" "Entity Framework Core" "001 - Fase 1"
    smsProcessor.smsTenantConfigRepository -> notificationDB "Lee configuraciones por tenant" "Entity Framework Core" "001 - Fase 1"
    smsProcessor.smsChannelConfigRepository -> notificationDB "Lee configuraciones de canal" "Entity Framework Core" "001 - Fase 1"

    // WhatsApp Processor - Flujo
    whatsappQueue -> whatsappProcessor.whatsappConsumer "Consume mensaje de WhatsApp" "AWS SQS" "001 - Fase 1"
    whatsappProcessor.whatsappConsumer -> whatsappProcessor.whatsappDeliveryService "Procesa mensaje de WhatsApp" "" "001 - Fase 1"
    whatsappProcessor.whatsappDeliveryService -> whatsappProcessor.whatsappRepository "Actualiza estado de notificación WhatsApp" "" "001 - Fase 1"
    whatsappProcessor.whatsappDeliveryService -> whatsappProcessor.whatsappProviderAdapter "Envía mensaje a proveedor de WhatsApp" "" "001 - Fase 1"
    whatsappProcessor.whatsappDeliveryService -> whatsappProcessor.whatsappAttachmentFetcher "Obtiene adjuntos para envío" "" "001 - Fase 1"
    whatsappProcessor.whatsappRepository -> notificationDB "Actualiza estado de notificación WhatsApp" "Entity Framework Core" "001 - Fase 1"
    whatsappProcessor.whatsappAttachmentFetcher -> attachmentStorage "Obtiene archivos adjuntos" "AWS S3" "001 - Fase 1"

    // WhatsApp Processor - Configuración
    whatsappProcessor.whatsappConfigurationManager -> whatsappProcessor.whatsappTenantConfigRepository "Lee configuraciones por tenant" "Entity Framework Core" "001 - Fase 1"
    whatsappProcessor.whatsappConfigurationManager -> whatsappProcessor.whatsappChannelConfigRepository "Lee configuraciones de canal" "Entity Framework Core" "001 - Fase 1"
    whatsappProcessor.whatsappTenantConfigRepository -> notificationDB "Lee configuraciones por tenant" "Entity Framework Core" "001 - Fase 1"
    whatsappProcessor.whatsappChannelConfigRepository -> notificationDB "Lee configuraciones de canal" "Entity Framework Core" "001 - Fase 1"

    // Push Processor - Flujo
    pushQueue -> pushProcessor.pushConsumer "Consume mensaje de Push" "AWS SQS" "001 - Fase 1"
    pushProcessor.pushConsumer -> pushProcessor.pushDeliveryService "Procesa mensaje de Push" "" "001 - Fase 1"
    pushProcessor.pushDeliveryService -> pushProcessor.pushRepository "Actualiza estado de notificación Push" "" "001 - Fase 1"
    pushProcessor.pushDeliveryService -> pushProcessor.pushProviderAdapter "Envía mensaje a proveedor de Push" "" "001 - Fase 1"
    pushProcessor.pushDeliveryService -> pushProcessor.pushAttachmentFetcher "Obtiene adjuntos para envío" "" "001 - Fase 1"
    pushProcessor.pushRepository -> notificationDB "Actualiza estado de notificación Push" "Entity Framework Core" "001 - Fase 1"
    pushProcessor.pushAttachmentFetcher -> attachmentStorage "Obtiene archivos adjuntos" "AWS S3" "001 - Fase 1"

    // Push Processor - Configuración
    pushProcessor.pushConfigurationManager -> pushProcessor.pushTenantConfigRepository "Lee configuraciones por tenant" "Entity Framework Core" "001 - Fase 1"
    pushProcessor.pushConfigurationManager -> pushProcessor.pushChannelConfigRepository "Lee configuraciones de canal" "Entity Framework Core" "001 - Fase 1"
    pushProcessor.pushTenantConfigRepository -> notificationDB "Lee configuraciones por tenant" "Entity Framework Core" "001 - Fase 1"
    pushProcessor.pushChannelConfigRepository -> notificationDB "Lee configuraciones de canal" "Entity Framework Core" "001 - Fase 1"

    // Dead Letter Queue - Manejo de errores
    emailProcessor.emailProviderAdapter -> failedNotificationsQueue "Envía mensaje fallido a DLQ" "AWS SQS" "DLQ 001 - Fase 1"
    smsProcessor.smsProviderAdapter -> failedNotificationsQueue "Envía mensaje fallido a DLQ" "AWS SQS" "DLQ 001 - Fase 1"
    whatsappProcessor.whatsappProviderAdapter -> failedNotificationsQueue "Envía mensaje fallido a DLQ" "AWS SQS" "DLQ 001 - Fase 1"
    pushProcessor.pushProviderAdapter -> failedNotificationsQueue "Envía mensaje fallido a DLQ" "AWS SQS" "DLQ 001 - Fase 1"

    // ========================================
    // RELACIONES EXTERNAS - ACTORES
    // ========================================

    // Aplicaciones por país - API
    appPeru -> api.notificationController "Solicita envío de notificación" "HTTPS vía API Gateway" "001 - Fase 1"
    appEcuador -> api.notificationController "Solicita envío de notificación" "HTTPS vía API Gateway" "001 - Fase 1"
    appColombia -> api.notificationController "Solicita envío de notificación" "HTTPS vía API Gateway" "001 - Fase 1"
    appMexico -> api.notificationController "Solicita envío de notificación" "HTTPS vía API Gateway" "001 - Fase 1"

    // Aplicaciones por país - Adjuntos
    appPeru -> api.attachmentController "Solicita gestión de adjuntos" "HTTPS vía API Gateway" "001 - Fase 1"
    appEcuador -> api.attachmentController "Solicita gestión de adjuntos" "HTTPS vía API Gateway" "001 - Fase 1"
    appColombia -> api.attachmentController "Solicita gestión de adjuntos" "HTTPS vía API Gateway" "001 - Fase 1"
    appMexico -> api.attachmentController "Solicita gestión de adjuntos" "HTTPS vía API Gateway" "001 - Fase 1"

    // ========================================
    // RELACIONES EXTERNAS - SISTEMAS
    // ========================================

    // Integración con plataforma de configuración
    api.configurationManager -> configPlatform.configService "Obtiene configuraciones y secretos" "HTTPS" "001 - Fase 1"
    notificationScheduler.configManager -> configPlatform.configService "Lee configuraciones y secretos" "HTTPS" "001 - Fase 1"
    emailProcessor.emailConfigurationManager -> configPlatform.configService "Lee configuraciones y secretos" "HTTPS" "001 - Fase 1"
    smsProcessor.smsConfigurationManager -> configPlatform.configService "Lee configuraciones y secretos" "HTTPS" "001 - Fase 1"
    whatsappProcessor.whatsappConfigurationManager -> configPlatform.configService "Lee configuraciones y secretos" "HTTPS" "001 - Fase 1"
    pushProcessor.pushConfigurationManager -> configPlatform.configService "Lee configuraciones y secretos" "HTTPS" "001 - Fase 1"

    // Integración con proveedores externos
    emailProcessor.emailProviderAdapter -> emailProvider "Envía notificación a proveedor externo de Email" "HTTPS" "001 - Fase 1"
    smsProcessor.smsProviderAdapter -> smsProvider "Envía notificación a proveedor externo de SMS" "HTTPS" "001 - Fase 1"
    whatsappProcessor.whatsappProviderAdapter -> whatsappProvider "Envía notificación a proveedor externo de WhatsApp" "HTTPS" "001 - Fase 1"
    pushProcessor.pushProviderAdapter -> pushProvider "Envía notificación a proveedor externo de Push" "HTTPS" "001 - Fase 1"
}
