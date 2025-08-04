notification = softwareSystem "Notification System" {
    description "Orquesta el envío de notificaciones multicanal para aplicaciones corporativas."
    tags "Notification" "001 - Fase 1"

    // ========================================
    // DATA STORES - ARQUITECTURA DE ESQUEMAS SEPARADOS
    // ========================================
    // DECISIÓN ARQUITECTÓNICA: Fase 1 usa esquemas separados en misma PostgreSQL
    // - Schema 'business': Plantillas, configuraciones, historial de notificaciones
    // - Schema 'messaging': Reliable messaging (outbox, dead letter, channel routing)
    // VENTAJAS: Transaccionalidad ACID completa, routing por metadata, cero brokers externos
    // ESCALAMIENTO: Processors por canal filtran del mismo store usando topic/channel_type

    notificationDatabase = store "Notification Database" {
        description "Base de datos PostgreSQL con esquemas separados para gestión de notificaciones y reliable messaging con garantías ACID transaccionales."
        technology "PostgreSQL"
        tags "Database" "PostgreSQL" "Multi-Schema" "001 - Fase 1"

        businessSchema = component "Business Schema" {
            technology "PostgreSQL Schema"
            description "Esquema 'business' que contiene plantillas de notificación, configuraciones de canales, historial de envíos y configuraciones por tenant."
            tags "Database Schema" "Business Data" "001 - Fase 1"
        }

        messagingSchema = component "Messaging Schema" {
            technology "PostgreSQL Schema"
            description "Esquema 'messaging' que implementa reliable messaging con outbox pattern, routing por canal y dead letter store."
            tags "Database Schema" "Reliable Messaging" "001 - Fase 1"
        }

        // Tablas específicas como componentes del messaging schema
        reliableMessagesTable = component "Reliable Messages Table" {
            technology "PostgreSQL Table"
            description "Tabla principal para mensajes de notificación con routing por channel_type (EMAIL, SMS, WHATSAPP, PUSH) y filtrado por topic."
            tags "Database Table" "Message Store" "Channel Routing" "001 - Fase 1"
        }

        outboxTable = component "Outbox Table" {
            technology "PostgreSQL Table"
            description "Tabla de outbox pattern para publicación transaccional de notificaciones con garantías ACID."
            tags "Database Table" "Outbox Pattern" "001 - Fase 1"
        }

        deadLetterTable = component "Dead Letter Table" {
            technology "PostgreSQL Table"
            description "Tabla para notificaciones fallidas con análisis de errores por canal, retry automático y auditoría completa."
            tags "Database Table" "Dead Letter Queue" "001 - Fase 1"
        }

        // Tablas del business schema
        templatesTable = component "Templates Table" {
            technology "PostgreSQL Table"
            description "Tabla para plantillas de notificación con versionado, internacionalización y configuraciones por tenant."
            tags "Database Table" "Templates" "001 - Fase 1"
        }

        channelConfigTable = component "Channel Configuration Table" {
            technology "PostgreSQL Table"
            description "Tabla para configuraciones específicas de cada canal (límites, formatos, proveedores)."
            tags "Database Table" "Configuration" "001 - Fase 1"
        }
    }

    attachmentStorage = store "Attachment Storage" {
        technology "S3-Compatible Storage (AWS S3, MinIO, etc.)"
        description "Almacenamiento agnóstico via IStorageService interface. Proveedor configurable por tenant."
        tags "File Storage" "S3-Compatible" "Multi-Provider" "001 - Fase 1"
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

        reliableMessagePublisher = component "Reliable Message Publisher" {
            technology "C# .NET 8, IReliableMessagePublisher"
            description "Publisher agnóstico con garantías de entrega, outbox pattern y soporte para múltiples proveedores (PostgreSQL/RabbitMQ/Kafka)."
            tags "Messaging" "Reliability" "001 - Fase 1"
        }

        reliableMessageConsumer = component "Reliable Message Consumer" {
            technology "C# .NET 8, IReliableMessageConsumer"
            description "Consumer agnóstico con acknowledgments, retry patterns y procesamiento paralelo para alta throughput sin pérdida de mensajes."
            tags "Messaging" "Reliability" "001 - Fase 1"
        }

        outboxProcessor = component "Outbox Processor" {
            technology "C# .NET 8, Background Service"
            description "Procesa eventos del outbox hacia el message broker con garantías de entrega y retry exponencial."
            tags "Messaging" "Background" "001 - Fase 1"
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
            technology "C# .NET 8, IStorageService Interface"
            description "Gestiona archivos via abstracción IStorageService. Implementaciones: S3Provider, AzureBlobProvider, MinIOProvider."
            tags "001 - Fase 1"
        }

        tenantConfigurationRepository = component "Tenant Configuration Repository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Provee configuraciones específicas por tenant y país para personalización de notificaciones."
            tags "001 - Fase 1"
        }

        notificationConfigurationProvider = component "Notification Configuration Provider" {
            technology "C# .NET 8, IConfigurationProvider"
            description "Proveedor agnóstico de configuraciones de notificación con implementaciones intercambiables y cache local para baja latencia."
            tags "Configuración" "001 - Fase 1"
        }

        configurationCache = component "Local Configuration Cache" {
            technology "IMemoryCache"
            description "Cache local en memoria con polling inteligente (TTL: 15-30min, jitter: ±25%) para reducir consultas al proveedor externo."
            tags "Cache" "001 - Fase 1"
        }

        featureFlagService = component "Feature Flag Service" {
            technology "C# .NET 8, IConfigurationProvider"
            description "Servicio agnóstico para feature flags con soporte para diferentes proveedores de configuración y evaluación por tenant/país."
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

        reliableMessageConsumer = component "Reliable Message Consumer" {
            technology "C# .NET 8, IReliableMessageConsumer"
            description "Consumer agnóstico con acknowledgments, retry patterns y procesamiento paralelo para máximo throughput sin pérdida de mensajes."
            tags "Messaging" "Reliability" "001 - Fase 1"
        }

        orchestrationService = component "Orchestration Service" {
            technology "C# .NET 8"
            description "Valida, enriquece datos y distribuye mensajes al canal correspondiente según reglas de negocio."
            tags "001 - Fase 1"
        }

        templateEngine = component "Template Engine" {
            technology "C# .NET 8, Liquid Templates"
            description "Motor de plantillas que procesa templates almacenados en PostgreSQL con variables dinámicas, internacionalización y versionado por tenant."
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

        processorConfigurationManager = component "Processor Configuration Provider" {
            technology "C# .NET 8, IConfigurationProvider"
            description "Proveedor agnóstico de configuraciones de procesamiento con cache local y polling inteligente para plantillas dinámicas y parámetros de canal."
            tags "Configuración" "001 - Fase 1"
        }

        templateRepository = component "Template Repository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Repositorio especializado para gestión de plantillas en PostgreSQL con soporte para versionado, cache, filtrado por tenant/canal/idioma y validación de sintaxis."
            tags "Template" "001 - Fase 1"
        }

        templateCacheService = component "Template Cache Service" {
            technology "C# .NET 8, IMemoryCache"
            description "Cache en memoria para plantillas frecuentemente utilizadas con invalidación automática por cambios en BD y TTL configurable por tenant."
            tags "Cache" "Template" "001 - Fase 1"
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

        reliableSchedulerPublisher = component "Reliable Scheduler Publisher" {
            technology "C# .NET 8, IReliableMessagePublisher"
            description "Publisher agnóstico para notificaciones programadas con outbox pattern y garantías de entrega."
            tags "Messaging" "Reliability" "001 - Fase 1"
        }

        tenantConfigRepository = component "TenantConfigRepository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Provee configuraciones específicas por tenant."
            tags "001 - Fase 1"
        }

        configManager = component "Scheduler Configuration Provider" {
            technology "C# .NET 8, IConfigurationProvider"
            description "Proveedor agnóstico de configuraciones para scheduler con cache local: horarios, intervalos y políticas de programación."
            tags "Configuración" "001 - Fase 1"
        }
    }

    // Channel-Specific Processors
    emailProcessor = application "Email Processor" {
        technology "Worker Service, C# .NET 8"
        description "Procesador especializado para notificaciones por correo electrónico con soporte para adjuntos y HTML."
        tags "CSharp" "001 - Fase 1"

        emailReliableConsumer = component "Email Reliable Consumer" {
            technology "C# .NET 8, IReliableMessageConsumer"
            description "Consumer agnóstico para emails con acknowledgments, retry patterns y procesamiento paralelo para máximo throughput."
            tags "Messaging" "Reliability" "001 - Fase 1"
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

        emailConfigurationManager = component "Email Configuration Provider" {
            technology "C# .NET 8, IConfigurationProvider"
            description "Proveedor agnóstico para configuraciones de email con cache local: proveedores, credenciales y políticas de envío."
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

        smsReliableConsumer = component "SMS Reliable Consumer" {
            technology "C# .NET 8, IReliableMessageConsumer"
            description "Consumer agnóstico para SMS con acknowledgments, retry patterns y rate limiting para máximo throughput."
            tags "Messaging" "Reliability" "001 - Fase 1"
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

        smsConfigurationManager = component "SMS Configuration Provider" {
            technology "C# .NET 8, IConfigurationProvider"
            description "Proveedor agnóstico para configuraciones de SMS con cache local: credenciales de proveedores, políticas de routing y costos."
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

        whatsappReliableConsumer = component "WhatsApp Reliable Consumer" {
            technology "C# .NET 8, IReliableMessageConsumer"
            description "Consumer agnóstico para WhatsApp con acknowledgments, validation de templates y procesamiento confiable."
            tags "Messaging" "Reliability" "001 - Fase 1"
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

        whatsappConfigurationManager = component "WhatsApp Configuration Provider" {
            technology "C# .NET 8, IConfigurationProvider"
            description "Proveedor agnóstico para configuraciones de WhatsApp con cache local: tokens, webhooks, templates y políticas de uso."
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

        pushReliableConsumer = component "Push Reliable Consumer" {
            technology "C# .NET 8, IReliableMessageConsumer"
            description "Consumer agnóstico para push notifications con acknowledgments y procesamiento masivo de dispositivos."
            tags "Messaging" "Reliability" "001 - Fase 1"
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

        pushConfigurationManager = component "Push Configuration Provider" {
            technology "C# .NET 8, IConfigurationProvider"
            description "Proveedor agnóstico para configuraciones de push con cache local: certificados, tokens de servidor y políticas de entrega."
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

    // Flujo principal de API (Con reliable messaging)
    api.notificationController -> api.notificationService "Registra solicitud de notificación" "" "001 - Fase 1"
    api.notificationService -> api.requestValidator "Valida datos de la solicitud" "" "001 - Fase 1"
    api.notificationService -> api.reliableMessagePublisher "Publica notificación con outbox pattern" "" "001 - Fase 1"
    // API - Reliable messaging y storage
    api.reliableMessagePublisher -> notificationDatabase.outboxTable "Almacena en outbox transaccional (mismo BD)" "PostgreSQL" "001 - Fase 1"
    api.outboxProcessor -> notificationDatabase.reliableMessagesTable "Procesa outbox hacia message store" "PostgreSQL" "001 - Fase 1"

    // Flujo de adjuntos
    api.attachmentController -> api.attachmentService "Registra adjunto" "" "001 - Fase 1"
    api.attachmentService -> api.attachmentRepository "Accede a metadatos de adjuntos" "" "001 - Fase 1"
    api.attachmentService -> api.attachmentManager "Gestiona archivos adjuntos" "" "001 - Fase 1"
    api.attachmentManager -> attachmentStorage "Almacena archivo adjunto" "S3-Compatible API" "001 - Fase 1"
    // API - Configuración y attachments
    api.attachmentRepository -> notificationDatabase.businessSchema "Guarda metadatos de adjuntos" "Entity Framework Core" "001 - Fase 1"

    // API - Configuración (Cache-first pattern)
    api.notificationConfigurationProvider -> api.configurationCache "Cache-first: busca configuración" "" "001 - Fase 1"
    api.configurationCache -> configPlatform.configService "Cache miss: polling inteligente a Configuration Platform agnóstica (TTL: 30min)" "HTTPS/REST" "001 - Fase 1"
    api.featureFlagService -> api.configurationCache "Evalúa feature flags desde cache" "" "001 - Fase 1"
    api.notificationConfigurationProvider -> api.tenantConfigurationRepository "Configuraciones específicas por tenant" "" "001 - Fase 1"
    api.tenantConfigurationRepository -> notificationDatabase.businessSchema "Accede a configuraciones por tenant" "Entity Framework Core" "001 - Fase 1"

    // API - Observabilidad
    api.notificationConfigurationProvider -> api.metricsCollector "envía métricas de config" "" "001 - Fase 1"
    api.featureFlagService -> api.metricsCollector "envía métricas de feature flags" "" "001 - Fase 1"

    // Notification Processor - Flujo principal (Con reliable messaging)
    notificationDatabase.reliableMessagesTable -> notificationProcessor.reliableMessageConsumer "Entrega mensaje para procesamiento (polling desde messaging schema)" "PostgreSQL Polling" "001 - Fase 1"
    notificationProcessor.reliableMessageConsumer -> notificationProcessor.orchestrationService "Procesa mensaje de notificación" "" "001 - Fase 1"
    notificationProcessor.orchestrationService -> notificationProcessor.templateEngine "Genera mensaje por canal" "" "001 - Fase 1"
    notificationProcessor.orchestrationService -> notificationProcessor.channelDispatcher "Envía mensaje a canal" "" "001 - Fase 1"
    notificationProcessor.orchestrationService -> notificationProcessor.notificationRepository "Registra notificación procesada" "" "001 - Fase 1"

    // Notification Processor - Configuración
    notificationProcessor.orchestrationService -> notificationProcessor.processorConfigurationManager "Obtiene configuración y plantillas" "" "001 - Fase 1"
    notificationProcessor.processorConfigurationManager -> notificationProcessor.templateRepository "Obtiene plantillas" "" "001 - Fase 1"
    notificationProcessor.processorConfigurationManager -> notificationProcessor.processorTenantConfigRepository "Obtiene configuración por tenant" "" "001 - Fase 1"
    notificationProcessor.processorConfigurationManager -> notificationProcessor.channelConfigurationRepository "Obtiene configuración de canales" "" "001 - Fase 1"

    // Notification Processor - Template Engine y Cache
    notificationProcessor.templateEngine -> notificationProcessor.templateCacheService "Busca plantillas en cache" "" "001 - Fase 1"
    notificationProcessor.templateCacheService -> notificationProcessor.templateRepository "Cache miss: obtiene de BD" "" "001 - Fase 1"

    // Notification Processor - Bases de datos
    // Notification Processor - Persistencia
    notificationProcessor.notificationRepository -> notificationDatabase.businessSchema "Guarda notificación procesada" "Entity Framework Core" "001 - Fase 1"
    notificationProcessor.templateRepository -> notificationDatabase.templatesTable "Accede a plantillas" "Entity Framework Core" "001 - Fase 1"
    notificationProcessor.processorTenantConfigRepository -> notificationDatabase.businessSchema "Accede a configuración por tenant" "Entity Framework Core" "001 - Fase 1"
    notificationProcessor.channelConfigurationRepository -> notificationDatabase.channelConfigTable "Accede a configuración de canales" "Entity Framework Core" "001 - Fase 1"

    // Notification Processor - Distribución por canal (Reliable messaging)
    notificationProcessor.channelDispatcher -> notificationDatabase.reliableMessagesTable "Publica mensajes a canales específicos con routing por topic" "PostgreSQL" "001 - Fase 1"

    // Scheduler - Notificaciones programadas (Con reliable messaging)
    notificationScheduler.schedulerWorker -> notificationScheduler.schedulingService "Procesa notificaciones programadas" "" "001 - Fase 1"
    notificationScheduler.schedulingService -> notificationScheduler.scheduledNotificationRepository "Accede a notificaciones programadas" "" "001 - Fase 1"
    notificationScheduler.schedulingService -> notificationScheduler.reliableSchedulerPublisher "Publica notificaciones programadas con garantías" "" "001 - Fase 1"
    notificationScheduler.scheduledNotificationRepository -> notificationDatabase.businessSchema "Lee notificaciones programadas" "Entity Framework Core" "001 - Fase 1"
    notificationScheduler.reliableSchedulerPublisher -> notificationDatabase.reliableMessagesTable "Almacena notificaciones programadas con routing" "PostgreSQL" "001 - Fase 1"
    notificationScheduler.configManager -> notificationScheduler.tenantConfigRepository "Lee configuraciones por tenant" "Entity Framework Core" "001 - Fase 1"
    notificationScheduler.tenantConfigRepository -> notificationDatabase.businessSchema "Lee configuraciones por tenant" "Entity Framework Core" "001 - Fase 1"

    // Email Processor - Flujo principal (Con reliable messaging)
    notificationDatabase.reliableMessagesTable -> emailProcessor.emailReliableConsumer "Consume mensajes email (filtro por topic: notification.email)" "PostgreSQL Polling" "001 - Fase 1"
    emailProcessor.emailReliableConsumer -> emailProcessor.emailDeliveryService "Procesa mensaje de Email" "" "001 - Fase 1"
    emailProcessor.emailDeliveryService -> emailProcessor.emailRepository "Actualiza estado de Email" "" "001 - Fase 1"
    emailProcessor.emailDeliveryService -> emailProcessor.emailProviderAdapter "Envía mensaje a proveedor de Email" "" "001 - Fase 1"
    emailProcessor.emailDeliveryService -> emailProcessor.emailAttachmentFetcher "Obtiene adjuntos para envío" "" "001 - Fase 1"
    emailProcessor.emailRepository -> notificationDatabase.businessSchema "Actualiza estado de notificación email" "Entity Framework Core" "001 - Fase 1"
    emailProcessor.emailAttachmentFetcher -> attachmentStorage "Obtiene archivos adjuntos" "S3-Compatible API" "001 - Fase 1"

    // Email Processor - Configuración
    emailProcessor.emailConfigurationManager -> emailProcessor.emailTenantConfigRepository "Lee configuraciones por tenant" "Entity Framework Core" "001 - Fase 1"
    emailProcessor.emailConfigurationManager -> emailProcessor.emailChannelConfigRepository "Lee configuraciones de canal" "Entity Framework Core" "001 - Fase 1"
    emailProcessor.emailChannelConfigRepository -> notificationDatabase.channelConfigTable "Lee configuraciones de canal" "Entity Framework Core" "001 - Fase 1"

    // SMS Processor - Flujo (Con reliable messaging)
    notificationDatabase.reliableMessagesTable -> smsProcessor.smsReliableConsumer "Consume mensajes SMS (filtro por topic: notification.sms)" "PostgreSQL Polling" "001 - Fase 1"
    smsProcessor.smsReliableConsumer -> smsProcessor.smsDeliveryService "Procesa mensaje de SMS" "" "001 - Fase 1"
    smsProcessor.smsDeliveryService -> smsProcessor.smsRepository "Actualiza estado de notificación SMS" "" "001 - Fase 1"
    smsProcessor.smsDeliveryService -> smsProcessor.smsProviderAdapter "Envía mensaje a proveedor de SMS" "" "001 - Fase 1"
    smsProcessor.smsRepository -> notificationDatabase.businessSchema "Actualiza estado de notificación SMS" "Entity Framework Core" "001 - Fase 1"

    // SMS Processor - Configuración
    smsProcessor.smsConfigurationManager -> smsProcessor.smsTenantConfigRepository "Lee configuraciones por tenant" "Entity Framework Core" "001 - Fase 1"
    smsProcessor.smsConfigurationManager -> smsProcessor.smsChannelConfigRepository "Lee configuraciones de canal" "Entity Framework Core" "001 - Fase 1"
    smsProcessor.smsTenantConfigRepository -> notificationDatabase.businessSchema "Lee configuraciones por tenant" "Entity Framework Core" "001 - Fase 1"
    smsProcessor.smsChannelConfigRepository -> notificationDatabase.channelConfigTable "Lee configuraciones de canal" "Entity Framework Core" "001 - Fase 1"

    // WhatsApp Processor - Flujo (Con reliable messaging)
    notificationDatabase.reliableMessagesTable -> whatsappProcessor.whatsappReliableConsumer "Consume mensajes WhatsApp (filtro por topic: notification.whatsapp)" "PostgreSQL Polling" "001 - Fase 1"
    whatsappProcessor.whatsappReliableConsumer -> whatsappProcessor.whatsappDeliveryService "Procesa mensaje de WhatsApp" "" "001 - Fase 1"
    whatsappProcessor.whatsappDeliveryService -> whatsappProcessor.whatsappRepository "Actualiza estado de notificación WhatsApp" "" "001 - Fase 1"
    whatsappProcessor.whatsappDeliveryService -> whatsappProcessor.whatsappProviderAdapter "Envía mensaje a proveedor de WhatsApp" "" "001 - Fase 1"
    whatsappProcessor.whatsappDeliveryService -> whatsappProcessor.whatsappAttachmentFetcher "Obtiene adjuntos para envío" "" "001 - Fase 1"
    whatsappProcessor.whatsappRepository -> notificationDatabase.businessSchema "Actualiza estado de notificación WhatsApp" "Entity Framework Core" "001 - Fase 1"
    whatsappProcessor.whatsappAttachmentFetcher -> attachmentStorage "Obtiene archivos adjuntos" "S3-Compatible API" "001 - Fase 1"

    // WhatsApp Processor - Configuración
    whatsappProcessor.whatsappConfigurationManager -> whatsappProcessor.whatsappTenantConfigRepository "Lee configuraciones por tenant" "Entity Framework Core" "001 - Fase 1"
    whatsappProcessor.whatsappConfigurationManager -> whatsappProcessor.whatsappChannelConfigRepository "Lee configuraciones de canal" "Entity Framework Core" "001 - Fase 1"
    whatsappProcessor.whatsappTenantConfigRepository -> notificationDatabase.businessSchema "Lee configuraciones por tenant" "Entity Framework Core" "001 - Fase 1"
    whatsappProcessor.whatsappChannelConfigRepository -> notificationDatabase.channelConfigTable "Lee configuraciones de canal" "Entity Framework Core" "001 - Fase 1"

    // Push Processor - Flujo (Con reliable messaging)
    notificationDatabase.reliableMessagesTable -> pushProcessor.pushReliableConsumer "Consume mensajes push (filtro por topic: notification.push)" "PostgreSQL Polling" "001 - Fase 1"
    pushProcessor.pushReliableConsumer -> pushProcessor.pushDeliveryService "Procesa mensaje de Push" "" "001 - Fase 1"
    pushProcessor.pushDeliveryService -> pushProcessor.pushRepository "Actualiza estado de notificación Push" "" "001 - Fase 1"
    pushProcessor.pushDeliveryService -> pushProcessor.pushProviderAdapter "Envía mensaje a proveedor de Push" "" "001 - Fase 1"
    pushProcessor.pushDeliveryService -> pushProcessor.pushAttachmentFetcher "Obtiene adjuntos para envío" "" "001 - Fase 1"
    pushProcessor.pushRepository -> notificationDatabase.businessSchema "Actualiza estado de notificación Push" "Entity Framework Core" "001 - Fase 1"
    pushProcessor.pushAttachmentFetcher -> attachmentStorage "Obtiene archivos adjuntos" "S3-Compatible API" "001 - Fase 1"

    // Push Processor - Configuración
    pushProcessor.pushConfigurationManager -> pushProcessor.pushTenantConfigRepository "Lee configuraciones por tenant" "Entity Framework Core" "001 - Fase 1"
    pushProcessor.pushConfigurationManager -> pushProcessor.pushChannelConfigRepository "Lee configuraciones de canal" "Entity Framework Core" "001 - Fase 1"
    pushProcessor.pushTenantConfigRepository -> notificationDatabase.businessSchema "Lee configuraciones por tenant" "Entity Framework Core" "001 - Fase 1"
    pushProcessor.pushChannelConfigRepository -> notificationDatabase.channelConfigTable "Lee configuraciones de canal" "Entity Framework Core" "001 - Fase 1"

    // Dead Letter Handling - Manejo de errores confiable
    emailProcessor.emailProviderAdapter -> notificationDatabase.deadLetterTable "Envía mensaje fallido a DLQ durável" "PostgreSQL" "001 - Fase 1"
    smsProcessor.smsProviderAdapter -> notificationDatabase.deadLetterTable "Envía mensaje fallido a DLQ durável" "PostgreSQL" "001 - Fase 1"
    whatsappProcessor.whatsappProviderAdapter -> notificationDatabase.deadLetterTable "Envía mensaje fallido a DLQ durável" "PostgreSQL" "001 - Fase 1"
    pushProcessor.pushProviderAdapter -> notificationDatabase.deadLetterTable "Envía mensaje fallido a DLQ durável" "PostgreSQL" "001 - Fase 1"

    // Relaciones internas de la base de datos
    notificationDatabase.businessSchema -> notificationDatabase.templatesTable "Contiene tabla de plantillas" "" "001 - Fase 1"
    notificationDatabase.businessSchema -> notificationDatabase.channelConfigTable "Contiene tabla de configuraciones de canal" "" "001 - Fase 1"
    notificationDatabase.messagingSchema -> notificationDatabase.reliableMessagesTable "Contiene tabla de mensajes confiables" "" "001 - Fase 1"
    notificationDatabase.messagingSchema -> notificationDatabase.outboxTable "Contiene tabla de outbox" "" "001 - Fase 1"
    notificationDatabase.messagingSchema -> notificationDatabase.deadLetterTable "Contiene tabla de dead letters" "" "001 - Fase 1"

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

    // Configuración agnóstica con cache local (ya configurado en API)
    // Todos los servicios usan el mismo patrón: Cache local → Polling inteligente → Configuration Provider

    // Integración con proveedores externos
    emailProcessor.emailProviderAdapter -> emailProvider "Envía notificación a proveedor externo de Email" "HTTPS" "001 - Fase 1"
    smsProcessor.smsProviderAdapter -> smsProvider "Envía notificación a proveedor externo de SMS" "HTTPS" "001 - Fase 1"
    whatsappProcessor.whatsappProviderAdapter -> whatsappProvider "Envía notificación a proveedor externo de WhatsApp" "HTTPS" "001 - Fase 1"
    pushProcessor.pushProviderAdapter -> pushProvider "Envía notificación a proveedor externo de Push" "HTTPS" "001 - Fase 1"
}
