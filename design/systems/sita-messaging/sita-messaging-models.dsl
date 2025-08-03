sitaMessaging = softwareSystem "SITA Messaging" {
    description "Gestiona la mensajería SITA para los diferentes países basado en eventos de Track & Trace"
    tags "SITA Messaging" "001 - Fase 1"

    sitaQueue = store "SITA Message Queue" {
        description "Cola SQS que recibe eventos de Track & Trace para procesar mensajería SITA"
        technology "AWS SQS"
        tags "Message Bus" "SQS" "001 - Fase 1"
    }

    // Integración con Track & Trace - el proceso inicia aquí
    // trackAndTrace.eventBroadcaster -> sitaQueue "Fan-out de eventos enriquecidos" "AWS SNS -> SQS" "001 - Fase 1"

    sitaDeadLetterQueue = store "SITA Dead Letter Queue" {
        description "Cola para eventos SITA que fallaron después de reintentos"
        technology "AWS SQS"
        tags "Message Bus" "SQS" "001 - Fase 1"
    }

    sitaMessagingDB = store "SITA Messaging Database" {
        description "Base de datos PostgreSQL para templates SITA, configuraciones, logs de mensajes y auditoría de eventos"
        technology "PostgreSQL"
        tags "Database" "PostgreSQL" "001 - Fase 1"
    }

    configEventQueue = store "Configuration Event Queue" {
        description "Cola SQS para eventos de cambios de configuración y feature flags"
        technology "AWS SQS"
        tags "Message Bus" "SQS" "Configuration" "001 - Fase 1"
    }

    // Nuevo worker para procesar eventos SITA
    eventProcessor = container "SITA Event Processor" {
        technology "C#, .NET Worker Service"
        description "Procesa eventos de generación de mensajes SITA"
        tags "CSharp" "001 - Fase 1"

        eventConsumer = component "Event Consumer" {
            technology "C#, RabbitMQ Client"
            description "Consume eventos de la cola de mensajes de Track & Trace"
            tags "001 - Fase 1"
        }

        eventHandler = component "Event Handler" {
            technology "C#"
            description "Procesa eventos de Track & Trace y genera mensajes SITA correspondientes"
            tags "001 - Fase 1"
        }

        service = component "SITA Generation Service" {
            technology "C#"
            description "Orquesta la validación y generación de archivos SITA desde eventos"
            tags "001 - Fase 1"
        }

        templateProvider = component "SITA Template Repository" {
            technology "C#, Entity Framework Core"
            description "Repositorio especializado para templates SITA almacenados en PostgreSQL con versionado, validación de esquemas y cache por tipo de evento y partner."
            tags "Template" "001 - Fase 1"
        }

        configProvider = component "Configuration Manager" {
            technology "C#, AWS SDK, IMemoryCache"
            description "Lee configuraciones y secretos desde repositorios y plataforma de configuración con cache inteligente (TTL: 5min). Usado por otros componentes vía inyección de dependencias."
            tags "001 - Fase 1"
        }

        configCache = component "Configuration Cache" {
            technology "IMemoryCache, Redis"
            description "Cache distribuido para configuraciones con invalidación automática y fallback a Parameter Store."
            tags "Cache" "001 - Fase 1"
        }

        tenantConfigRepository = component "Tenant Configuration Repository" {
            technology "C#, EF Core"
            description "Accede a la base de datos para recuperar configuración específica de un tenant. Usado exclusivamente por Configuration Manager."
            tags "EF Core" "001 - Fase 1"
        }

        repository = component "Repository" {
            technology "C#"
            description "Almacena los mensajes SITA generados"
            tags "001 - Fase 1"
        }

        validator = component "Validator" {
            technology "C#"
            description "Valida los mensajes SITA"
            tags "001 - Fase 1"
        }

        generator = component "File Generator" {
            technology "C#"
            description "Generador de mensajes SITA"
            tags "001 - Fase 1"
        }

        fileManager = component "File Manager" {
            technology "C#"
            description "Gestiona la carga, eliminación y consulta de archivos"
            tags "001 - Fase 1"
        }

        // Componentes de Observabilidad
        healthCheck = component "Health Check" {
            technology "ASP.NET Core Health Checks"
            description "Expone endpoints /health para monitoring del event processor."
            tags "Observability" "001 - Fase 1"
        }

        metricsCollector = component "Metrics Collector" {
            technology "Prometheus Client"
            description "Recolecta métricas: events processed/sec, SITA generation time, queue depth, config cache hit ratio, feature flag usage."
            tags "Observability" "001 - Fase 1"
        }

        logger = component "Structured Logger" {
            technology "Serilog"
            description "Logging estructurado con correlationId para trazabilidad."
            tags "Observability" "001 - Fase 1"
        }

        retryHandler = component "Retry Handler" {
            technology "C#, Polly"
            description "Maneja reintentos de eventos fallidos con backoff exponencial."
            tags "001 - Fase 1"
        }

        deadLetterProcessor = component "Dead Letter Processor" {
            technology "C#"
            description "Procesa eventos que fallaron después de todos los reintentos."
            tags "001 - Fase 1"
        }

        auditService = component "Audit Service" {
            technology "C#"
            description "Registra auditoría de eventos procesados, generaciones exitosas y fallos."
            tags "001 - Fase 1"
        }

        featureFlagService = component "Feature Flag Service" {
            technology "C#, AWS SDK"
            description "Gestiona feature flags por país y tenant para control granular de funcionalidades (ej: enable/disable SITA por país)."
            tags "Feature Flags" "001 - Fase 1"
        }

        configEventProcessor = component "Configuration Event Processor" {
            technology "C#, AWS SNS/SQS"
            description "Procesa eventos de cambios de configuración para invalidación de cache y actualizaciones dinámicas sin restart."
            tags "Configuration Events" "001 - Fase 1"
        }

        configValidator = component "Configuration Validator" {
            technology "C#, FluentValidation"
            description "Valida configuraciones y feature flags antes de aplicar cambios. Incluye rollback automático en caso de error."
            tags "Configuration Validation" "001 - Fase 1"
        }
    }

    db = store "SITA Messaging DB" {
        technology "PostgreSQL"
        description "Almacena configuración de partners (via scripts), logs de mensajes, auditoría y estado de entregas"
        tags "Database" "PostgreSQL" "001 - Fase 1"
    }

    fileStorage = store "SITA File Storage" {
        technology "AWS S3"
        description "Almacena los archivos SITA generados"
        tags "File Storage" "AWS S3" "001 - Fase 1"
    }

    sender = container "SITA Messaging Sender" {
        technology "C#"
        description "Envía archivos generados a los partners"
        tags "CSharp"

        worker = component "Worker" {
            technology "C#"
            description "Ejecuta tareas periódicas para el envío de mensajes SITA"
            tags "001 - Fase 1"
        }

        messageService = component "Message Service" {
            technology "C#"
            description "Gestiona el envío de mensajes SITA"
            tags "001 - Fase 1"
        }

        messageRepository = component "Message Repository" {
            technology "C#"
            description "Obtiene los mensajes SITA generados"
            tags "001 - Fase 1"
        }

        fileFetcher = component "File Fetcher" {
            technology "C#"
            description "Gestiona la descarga de archivos SITA generados"
            tags "001 - Fase 1"
        }

        messageSender = component "Message Sender" {
            technology "C#"
            description "Envía archivos generados a los partners"
            tags "001 - Fase 1"
        }

        deliveryTracker = component "Delivery Tracker" {
            technology "C#"
            description "Rastrea el estado de entrega y confirmaciones de partners."
            tags "001 - Fase 1"
        }

        // Componentes de Observabilidad
        healthCheck = component "Health Check" {
            technology "ASP.NET Core Health Checks"
            description "Expone endpoints /health para monitoring del message sender."
            tags "Observability" "001 - Fase 1"
        }

        metricsCollector = component "Metrics Collector" {
            technology "Prometheus Client"
            description "Recolecta métricas: delivery success rate, send times, partner response times, config cache performance."
            tags "Observability" "001 - Fase 1"
        }

        logger = component "Structured Logger" {
            technology "Serilog"
            description "Logging estructurado con correlationId para trazabilidad de envíos."
            tags "Observability" "001 - Fase 1"
        }

        configManager = component "Configuration Manager" {
            technology "C#, AWS SDK, IMemoryCache"
            description "Lee configuraciones y secretos desde repositorios y plataforma de configuración con cache inteligente y fallback automático."
            tags "001 - Fase 1"
        }

        configCache = component "Configuration Cache" {
            technology "IMemoryCache, Redis"
            description "Cache distribuido para configuraciones de delivery con TTL optimizado por tipo de configuración."
            tags "Cache" "001 - Fase 1"
        }
    }

    // ========================================
    // RELACIONES INTERNAS DEL SISTEMA
    // ========================================

    // Event Processor - Flujo principal
    eventProcessor.eventConsumer -> sitaQueue "Consume eventos de seguimiento" "RabbitMQ"
    eventProcessor.templateProvider -> sitaMessagingDB "Lee templates SITA" "Entity Framework Core" "001 - Fase 1"

    // Event Processor - Base de datos
    eventProcessor.repository -> db "Almacena mensajes generados" "" "001 - Fase 1"
    eventProcessor.tenantConfigRepository -> db "Lee configuración por tenant" "EF Core" "001 - Fase 1"
    eventProcessor.auditService -> db "Almacena auditoría" "" "001 - Fase 1"
    eventProcessor.fileManager -> fileStorage "Sube archivos generados" "" "001 - Fase 1"

    // Event Processor - Resiliencia
    eventProcessor.deadLetterProcessor -> sitaDeadLetterQueue "Envía eventos fallidos" "AWS SQS" "001 - Fase 1"

    // Event Processor - Configuración dinámica
    eventProcessor.configEventProcessor -> configEventQueue "Consume eventos de config" "AWS SQS" "001 - Fase 1"

    // Sender - Archivos y datos
    sender.fileFetcher -> fileStorage "Obtiene archivos SITA generados" "HTTPS" "001 - Fase 1"
    sender.messageRepository -> db "Lee mensajes SITA generados" "" "001 - Fase 1"
    sender.deliveryTracker -> db "Almacena estado de entregas" "" "001 - Fase 1"

    // ========================================
    // RELACIONES EXTERNAS - SISTEMAS
    // ========================================

    // Integración con plataforma de configuración
    eventProcessor.configProvider -> configPlatform.configService "Lee configuraciones y secretos" "" "001 - Fase 1"
    eventProcessor.configProvider -> configPlatform.secretsService "Lee configuraciones y secretos" "" "001 - Fase 1"
    sender.configManager -> configPlatform.configService "Lee configuraciones y secretos" "" "001 - Fase 1"
    sender.configManager -> configPlatform.secretsService "Lee configuraciones y secretos" "" "001 - Fase 1"

    // Feature flags y configuración dinámica
    eventProcessor.featureFlagService -> configPlatform.configService "Lee feature flags por país/tenant" "HTTPS" "001 - Fase 1"

    // Integración con Notification System para envío de emails
    sender.messageSender -> notification.api.notificationController "Solicita envío de emails SITA" "HTTPS via API Gateway" "001 - Fase 1"

    // Envío a partners externos
    sender.messageSender -> airlines "Envía archivos SITA" "Via Email por\nNotification System" "001 - Fase 1"
    sender.messageSender -> descartes "Envía archivos SITA" "" "001 - Fase 1"

    // ========================================
    // RELACIONES ENTRE COMPONENTES INTERNOS
    // ========================================

    // Event Processor - Flujo principal
    eventProcessor.eventConsumer -> eventProcessor.eventHandler "Envía eventos para procesar" "" "001 - Fase 1"
    eventProcessor.eventHandler -> eventProcessor.service "Solicita generación" "" "001 - Fase 1"
    eventProcessor.service -> eventProcessor.templateProvider "Obtiene template" "" "001 - Fase 1"

    // Event Processor - Configuración
    eventProcessor.service -> eventProcessor.configProvider "obtiene configuración" "" "001 - Fase 1"
    eventProcessor.configProvider -> eventProcessor.configCache "consulta cache" "" "001 - Fase 1"
    eventProcessor.configProvider -> eventProcessor.tenantConfigRepository "Lee configuración por tenant" "EF Core" "001 - Fase 1"

    // Event Processor - Servicios auxiliares
    eventProcessor.service -> eventProcessor.auditService "registra operaciones" "" "001 - Fase 1"
    eventProcessor.service -> eventProcessor.featureFlagService "consulta feature flags" "" "001 - Fase 1"
    eventProcessor.featureFlagService -> eventProcessor.configCache "usa cache para flags" "" "001 - Fase 1"

    // Event Processor - Resiliencia
    eventProcessor.eventHandler -> eventProcessor.retryHandler "usa" "" "001 - Fase 1"
    eventProcessor.retryHandler -> eventProcessor.deadLetterProcessor "usa" "" "001 - Fase 1"

    // Event Processor - Observabilidad
    eventProcessor.configProvider -> eventProcessor.metricsCollector "envía métricas de config" "" "001 - Fase 1"
    eventProcessor.featureFlagService -> eventProcessor.metricsCollector "envía métricas de feature flags" "" "001 - Fase 1"

    // Event Processor - Configuración dinámica
    eventProcessor.configEventProcessor -> eventProcessor.configCache "invalida cache" "" "001 - Fase 1"
    eventProcessor.configEventProcessor -> eventProcessor.configProvider "notifica cambios" "" "001 - Fase 1"
    eventProcessor.configProvider -> eventProcessor.configValidator "valida configuraciones" "" "001 - Fase 1"
    eventProcessor.configEventProcessor -> eventProcessor.configValidator "valida antes de aplicar" "" "001 - Fase 1"

    // Sender - Flujo principal
    sender.messageService -> sender.messageRepository "usa" "" "001 - Fase 1"
    sender.messageService -> sender.fileFetcher "usa" "" "001 - Fase 1"
    sender.messageService -> sender.messageSender "usa" "" "001 - Fase 1"
    sender.messageSender -> sender.deliveryTracker "usa" "" "001 - Fase 1"

    // Sender - Configuración
    sender.messageService -> sender.configManager "Lee configuraciones de delivery" "" "001 - Fase 1"
    sender.configManager -> sender.configCache "consulta cache" "" "001 - Fase 1"

    // Sender - Observabilidad
    sender.configManager -> sender.metricsCollector "envía métricas de config" "" "001 - Fase 1"
}
