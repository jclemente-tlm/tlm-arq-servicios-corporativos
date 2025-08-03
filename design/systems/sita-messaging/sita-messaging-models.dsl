sitaMessaging = softwareSystem "SITA Messaging" {
    description "Gestiona la mensajería SITA para los diferentes países basado en eventos de Track & Trace"
    tags "SITA Messaging" "001 - Fase 1"

    // ========================================
    // DATA STORES - ARQUITECTURA DE ESQUEMAS SEPARADOS
    // ========================================
    // DECISIÓN ARQUITECTÓNICA: Fase 1 usa esquemas separados en misma PostgreSQL
    // - Schema 'business': Templates SITA, configuraciones, logs y auditoría
    // - Schema 'messaging': Reliable messaging para eventos de Track & Trace
    // INTEGRACIÓN: Consume eventos cross-system desde trackAndTrace.reliableMessageStore
    // DELIVERY: Genera y envía archivos SITA a partners externos

    reliableMessageStore = store "SITA Reliable Message Store" {
        description "Almacén confiable para eventos SITA implementado como esquema 'messaging' en la misma PostgreSQL con outbox pattern, garantías ACID y soporte agnóstico para múltiples proveedores"
        technology "PostgreSQL (Schema: messaging) + Messaging Abstraction"
        tags "Message Store" "PostgreSQL" "Reliability" "Shared Database" "001 - Fase 1"
    }

    sitaDeadLetterStore = store "SITA Dead Letter Store" {
        description "Almacén durável para eventos SITA fallidos implementado en esquema 'messaging' con análisis de fallos y retry automático"
        technology "PostgreSQL (Schema: messaging)"
        tags "Message Store" "PostgreSQL" "DLQ" "Shared Database" "001 - Fase 1"
    }

    sitaMessagingDB = store "SITA Messaging Database" {
        description "Base de datos PostgreSQL con esquemas separados: 'business' para templates SITA/configuraciones/logs/auditoría, 'messaging' para reliable messaging"
        technology "PostgreSQL (Schemas: business, messaging)"
        tags "Database" "PostgreSQL" "Multi-Schema" "001 - Fase 1"
    }

    // Nuevo worker para procesar eventos SITA
    eventProcessor = container "SITA Event Processor" {
        technology "C#, .NET Worker Service"
        description "Procesa eventos de generación de mensajes SITA"
        tags "CSharp" "001 - Fase 1"

        reliableEventConsumer = component "Reliable Event Consumer" {
            technology "C#, IReliableMessageConsumer"
            description "Consumer agnóstico con acknowledgments, retry patterns y procesamiento confiable para eventos SITA"
            tags "Messaging" "Reliability" "001 - Fase 1"
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

        configProvider = component "Configuration Provider" {
            technology "C# .NET 8, IConfigurationProvider"
            description "Proveedor agnóstico de configuraciones SITA con implementaciones intercambiables para diferentes backends de configuración."
            tags "Configuración" "001 - Fase 1"
        }

        configCache = component "Local Configuration Cache" {
            technology "IMemoryCache"
            description "Cache local para configuraciones SITA con polling inteligente (TTL: 30min, jitter: ±25%) y fallback al proveedor."
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
    reliableMessageStore -> eventProcessor.reliableEventConsumer "Consume eventos de seguimiento confiablemente" "PostgreSQL/AMQP"
    eventProcessor.templateProvider -> sitaMessagingDB "Lee templates SITA" "Entity Framework Core" "001 - Fase 1"

    // Event Processor - Base de datos
    eventProcessor.repository -> db "Almacena mensajes generados" "" "001 - Fase 1"
    eventProcessor.tenantConfigRepository -> db "Lee configuración por tenant" "EF Core" "001 - Fase 1"
    eventProcessor.auditService -> db "Almacena auditoría" "" "001 - Fase 1"
    eventProcessor.fileManager -> fileStorage "Sube archivos generados" "" "001 - Fase 1"

    // Event Processor - Resiliencia
    eventProcessor.deadLetterProcessor -> sitaDeadLetterStore "Envía eventos fallidos a DLQ durável" "PostgreSQL" "001 - Fase 1"

    // Event Processor - Configuración dinámica
    // Configuración agnóstica eliminada - se usa cache local con polling

    // Sender - Archivos y datos
    sender.fileFetcher -> fileStorage "Obtiene archivos SITA generados" "HTTPS" "001 - Fase 1"
    sender.messageRepository -> db "Lee mensajes SITA generados" "" "001 - Fase 1"
    sender.deliveryTracker -> db "Almacena estado de entregas" "" "001 - Fase 1"

    // ========================================
    // ========================================
    // RELACIONES EXTERNAS - SISTEMAS
    // ========================================

    // Configuración agnóstica con cache local (Cache-first pattern)
    eventProcessor.configProvider -> eventProcessor.configCache "Cache-first: busca configuración" "" "001 - Fase 1"
    eventProcessor.configCache -> configPlatform.configService "Cache miss: polling inteligente (TTL: 30min)" "HTTPS" "001 - Fase 1"
    eventProcessor.configCache -> configPlatform.secretsService "Cache miss: obtiene secretos" "HTTPS" "001 - Fase 1"

    // Feature flags desde cache local
    eventProcessor.featureFlagService -> eventProcessor.configCache "Evalúa feature flags desde cache" "" "001 - Fase 1"

    // Integración con Notification System para envío de emails
    sender.messageSender -> notification.api.notificationController "Solicita envío de emails SITA" "HTTPS via API Gateway" "001 - Fase 1"

    // Envío a partners externos
    sender.messageSender -> airlines "Envía archivos SITA" "Via Email por\nNotification System" "001 - Fase 1"
    sender.messageSender -> descartes "Envía archivos SITA" "" "001 - Fase 1"

    // ========================================
    // RELACIONES ENTRE COMPONENTES INTERNOS
    // ========================================

    // Event Processor - Flujo principal
    eventProcessor.reliableEventConsumer -> eventProcessor.eventHandler "Envía eventos para procesar" "" "001 - Fase 1"
    eventProcessor.eventHandler -> eventProcessor.service "Solicita generación" "" "001 - Fase 1"
    eventProcessor.service -> eventProcessor.templateProvider "Obtiene template" "" "001 - Fase 1"

    // Event Processor - Configuración (Cache-first pattern)
    eventProcessor.service -> eventProcessor.configProvider "Obtiene configuración" "" "001 - Fase 1"
    eventProcessor.configProvider -> eventProcessor.tenantConfigRepository "Configuraciones específicas por tenant" "EF Core" "001 - Fase 1"

    // Event Processor - Servicios auxiliares
    eventProcessor.service -> eventProcessor.auditService "registra operaciones" "" "001 - Fase 1"
    eventProcessor.service -> eventProcessor.featureFlagService "consulta feature flags" "" "001 - Fase 1"

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
