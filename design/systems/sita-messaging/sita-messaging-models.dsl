sitaMessaging = softwareSystem "SITA Messaging" {
    description "Sistema corporativo que gestiona la generación y entrega automatizada de mensajes SITA a partners aeronáuticos, procesando eventos de Track & Trace con garantías de confiabilidad y observabilidad completa."
    tags "SITA Messaging" "001 - Fase 1"

    // ========================================
    // DATA STORES - ARQUITECTURA DE ESQUEMAS SEPARADOS
    // ========================================
    // DECISIÓN ARQUITECTÓNICA: Fase 1 usa esquemas separados en misma PostgreSQL
    // - Schema 'business': Templates SITA, configuraciones, logs y auditoría
    // - Schema 'messaging': Reliable messaging (outbox, dead letter, acknowledgments)
    // INTEGRACIÓN: Consume eventos cross-system desde trackAndTrace reliable messaging
    // DELIVERY: Genera y envía archivos SITA a partners externos

    sitaMessagingDatabase = store "SITA Messaging Database" {
        description "Base de datos PostgreSQL con arquitectura de esquemas separados: 'business' para datos de dominio SITA y 'messaging' para reliable messaging con garantías ACID transaccionales."
        technology "PostgreSQL"
        tags "Database" "PostgreSQL" "Multi-Schema" "001 - Fase 1"

        businessSchema = component "Business Schema" {
            technology "PostgreSQL Schema"
            description "Esquema 'business' optimizado para datos de dominio SITA: templates versionados, configuraciones por tenant/partner, logs de generación y auditoría completa."
            tags "Database Schema" "Business Data" "001 - Fase 1"
        }

        messagingSchema = component "Messaging Schema" {
            technology "PostgreSQL Schema"
            description "Esquema 'messaging' que implementa reliable messaging pattern: outbox transaccional, dead letter queue y acknowledgments con garantías ACID."
            tags "Database Schema" "Reliable Messaging" "001 - Fase 1"
        }

        // Tablas específicas como componentes del messaging schema
        reliableMessagesTable = component "Reliable Messages Table" {
            technology "PostgreSQL Table"
            description "Tabla principal para eventos confiables con columnas optimizadas: id, topic, payload, tenant_id, status, created_at, processed_at, retry_count."
            tags "Database Table" "Message Store" "001 - Fase 1"
        }

        outboxTable = component "Outbox Table" {
            technology "PostgreSQL Table"
            description "Implementa outbox pattern para publicación transaccional de eventos SITA con garantías ACID y procesamiento idempotente."
            tags "Database Table" "Outbox Pattern" "001 - Fase 1"
        }

        deadLetterTable = component "Dead Letter Table" {
            technology "PostgreSQL Table"
            description "Almacena eventos SITA fallidos con metadata enriquecida: análisis de errores, stack traces, retry history y flags de reprocessing manual."
            tags "Database Table" "Dead Letter Queue" "001 - Fase 1"
        }

        // Tablas específicas del business schema
        templatesTable = component "Templates Table" {
            technology "PostgreSQL Table"
            description "Catálogo de templates SITA con versionado semántico, validación de esquemas JSON y metadata de compatibilidad por partner aeronáutico."
            tags "Database Table" "Templates" "001 - Fase 1"
        }

        configurationTable = component "Configuration Table" {
            technology "PostgreSQL Table"
            description "Configuraciones específicas por tenant y partner con parámetros de generación, reglas de negocio y settings de delivery personalizados."
            tags "Database Table" "Configuration" "001 - Fase 1"
        }
    }

    // Nuevo worker para procesar eventos SITA
    eventProcessor = container "SITA Event Processor" {
        technology "C#, .NET 8, Worker Service"
        description "Worker service que consume eventos de Track & Trace y genera archivos SITA correspondientes con garantías de procesamiento confiable y observabilidad completa."
        tags "CSharp" "001 - Fase 1"

        reliableEventConsumer = component "Reliable Event Consumer" {
            technology "C#, .NET 8, IReliableMessageConsumer"
            description "Consume eventos de Track & Trace desde messaging schema con acknowledgments, polling optimizado y garantías de entrega única."
            tags "Messaging" "Reliability" "001 - Fase 1"
        }

        eventHandler = component "Event Handler" {
            technology "C#, .NET 8, Mapster"
            description "Procesa y transforma eventos de Track & Trace aplicando reglas de negocio específicas para generación SITA, con mapeo automático de DTOs."
            tags "001 - Fase 1"
        }

        service = component "SITA Generation Service" {
            technology "C#, .NET 8, FluentValidation"
            description "Servicio principal que orquesta la generación completa de archivos SITA: validación de datos, aplicación de templates, generación de archivos y persistencia."
            tags "001 - Fase 1"
        }

        templateProvider = component "SITA Template Repository" {
            technology "C#, .NET 8, EF Core"
            description "Repositorio especializado para templates SITA con cache inteligente, versionado automático y validación de esquemas por tipo de evento y partner."
            tags "Template" "001 - Fase 1"
        }

        configurationManager = component "Configuration Manager" {
            technology "C#, .NET 8, IMemoryCache"
            description "Gestiona configuraciones por tenant con cache local (TTL: 30min), polling inteligente a Configuration Platform y fallback automático."
            tags "Configuración" "Cache" "001 - Fase 1"
        }

        fileRepository = component "File & Data Repository" {
            technology "C#, .NET 8, EF Core"
            description "Repositorio híbrido que gestiona almacenamiento de archivos SITA via IStorageService interface y persiste metadata asociada en PostgreSQL business schema."
            tags "Repository" "Files" "001 - Fase 1"
        }

        generator = component "File Generator" {
            technology "C#, .NET 8, System.Text.Json"
            description "Motor de generación de archivos SITA que aplica templates específicos por partner y produce formatos aeronáuticos estándar (JSON, CSV, XML)."
            tags "001 - Fase 1"
        }

        // Componentes de Observabilidad
        healthCheck = component "Health Check" {
            technology "ASP.NET Core Health Checks"
            description "Valida salud del Event Processor: verifica conectividad PostgreSQL, disponibilidad storage, estado Configuration Platform y latencias de dependencias."
            tags "Observability" "001 - Fase 1"
        }

        metricsCollector = component "Metrics Collector" {
            technology "Prometheus.NET"
            description "Recolecta métricas de procesamiento SITA: registra eventos/sec procesados, mide tiempo generación de archivos, cuenta cache hit ratio y monitorea rates de éxito/fallo."
            tags "Observability" "001 - Fase 1"
        }

        structuredLogger = component "Structured Logger" {
            technology "Serilog"
            description "Registra logging estructurado con correlationId único para trazabilidad, captura tenant context y almacena metadata de eventos para debugging y auditoría."
            tags "Observability" "001 - Fase 1"
        }

        // Componentes de Resiliencia
        retryHandler = component "Retry Handler" {
            technology "Polly"
            description "Gestiona políticas de reintentos para fallos transitorios con backoff exponencial, circuit breaker y límites configurables por tipo de error."
            tags "001 - Fase 1"
        }

        deadLetterProcessor = component "Dead Letter Processor" {
            technology "C#, .NET 8"
            description "Procesa eventos que fallaron definitivamente después de agotar reintentos, realiza análisis de causa raíz y permite reprocessing manual administrativo."
            tags "001 - Fase 1"
        }

        auditService = component "Audit Service" {
            technology "EF Core"
            description "Registra auditoría inmutable de todo el ciclo de vida: eventos recibidos, archivos generados, fallos ocurridos y acciones administrativas."
            tags "001 - Fase 1"
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

    sender = container "SITA Messaging Sender" {
        technology "C#, .NET 8, Background Service"
        description "Background service que gestiona el envío programado de archivos SITA a partners aeronáuticos con garantías de entrega, rate limiting y monitoreo completo."
        tags "CSharp" "Background Service" "001 - Fase 1"

        worker = component "Worker" {
            technology "C#, .NET 8, BackgroundService"
            description "Scheduler inteligente que ejecuta tareas de envío programadas con rate limiting por partner, horarios específicos y manejo de prioridades."
            tags "Background Service" "001 - Fase 1"
        }

        messageService = component "Message Service" {
            technology "C#, .NET 8, FluentValidation"
            description "Servicio principal que orquesta el proceso completo de envío: selección de archivos, validación aeronáutica, coordinación con partners y tracking de entrega."
            tags "Business Logic" "001 - Fase 1"
        }

        messageRepository = component "Message Repository" {
            technology "C#, .NET 8, EF Core"
            description "Repositorio especializado que consulta archivos SITA pendientes de envío, configuraciones de partners y metadata de entregas desde business schema."
            tags "Data Access" "001 - Fase 1"
        }

        fileFetcher = component "File Fetcher" {
            technology "C#, .NET 8, AWS SDK"
            description "Cliente optimizado para descarga de archivos SITA desde Storage Platform con streaming, verificación de integridad (hash) y retry automático por fallos de red."
            tags "File Management" "001 - Fase 1"
        }

        messageSender = component "Message Sender" {
            technology "C#, .NET 8, HttpClient"
            description "Cliente especializado para entrega a partners SITA que maneja múltiples protocolos (HTTPS, FTP), autenticación por certificados y confirmaciones de recepción."
            tags "External Communication" "001 - Fase 1"
        }

        partnerManager = component "Partner Manager" {
            technology "C#, .NET 8, Polly"
            description "Gestiona configuraciones específicas por partner: rate limiting dinámico, circuit breaker, ventanas de envío y estado de conectividad en tiempo real."
            tags "Partner Management" "001 - Fase 1"
        }

        deliveryTracker = component "Delivery Tracker" {
            technology "C#, .NET 8, EF Core"
            description "Rastrea estados de entrega en tiempo real con polling de confirmaciones, escalamiento automático de fallos y SLA tracking por partner."
            tags "Tracking" "001 - Fase 1"
        }

        // Componentes de Observabilidad
        healthCheck = component "Health Check" {
            technology "ASP.NET Core Health Checks"
            description "Valida salud del Sender: verifica conectividad con partners SITA, valida certificados digitales, confirma disponibilidad storage y mide latencias de Configuration Platform."
            tags "Observability" "001 - Fase 1"
        }

        metricsCollector = component "Metrics Collector" {
            technology "Prometheus.NET"
            description "Recolecta métricas de delivery específicas: registra success rate por partner, mide tiempos de envío, cuenta throughput de archivos y evalúa SLA compliance."
            tags "Observability" "001 - Fase 1"
        }

        structuredLogger = component "Structured Logger" {
            technology "Serilog"
            description "Registra logging estructurado para operaciones de envío con enrichment de partner context, correlationId único y metadata de archivos para trazabilidad completa."
            tags "Observability" "001 - Fase 1"
        }

        configManager = component "Configuration Manager" {
            technology "IMemoryCache"
            description "Gestiona configuraciones de delivery por partner con cache inteligente (TTL 30min), polling a Configuration Platform y fallback automático."
            tags "Configuration" "001 - Fase 1"
        }

        // Componentes de Resiliencia
        retryHandler = component "Retry Handler" {
            technology "Polly"
            description "Gestiona políticas de reintentos para fallos de envío con backoff exponencial específico por partner y circuit breaker adaptativo."
            tags "Resilience" "001 - Fase 1"
        }

        auditService = component "Audit Service" {
            technology "C#, .NET 8, EF Core"
            description "Registra auditoría inmutable de todo el proceso de delivery: intentos de envío, confirmaciones de partners, fallos y acciones correctivas."
            tags "Audit" "001 - Fase 1"
        }
    }

    // ========================================
    // RELACIONES CROSS-SYSTEM (CONSUMO DE EVENTOS)
    // ========================================
    // NOTA: Esta relación se define después de que ambos sistemas estén disponibles
    // trackAndTrace.trackingAPI.reliableEventPublisher -> eventProcessor.reliableEventConsumer "Publica eventos Track & Trace para procesamiento SITA" "PostgreSQL Cross-Schema" "001 - Fase 1"

    // ========================================
    // RELACIONES INTERNAS - ACCESO A DATOS
    // ========================================

    // Event Processor - Acceso a esquemas de base de datos
    eventProcessor.templateProvider -> sitaMessagingDatabase.businessSchema "Lee templates SITA con versionado y cache" "EF Core" "001 - Fase 1"
    eventProcessor.fileRepository -> sitaMessagingDatabase.businessSchema "Almacena metadata de archivos generados" "EF Core" "001 - Fase 1"
    eventProcessor.auditService -> sitaMessagingDatabase.businessSchema "Registra auditoría inmutable de procesamiento" "EF Core" "001 - Fase 1"
    eventProcessor.reliableEventConsumer -> sitaMessagingDatabase.messagingSchema "Consume y actualiza eventos desde reliable messages table" "EF Core" "001 - Fase 1"
    eventProcessor.deadLetterProcessor -> sitaMessagingDatabase.messagingSchema "Almacena eventos fallidos en dead letter table" "EF Core" "001 - Fase 1"
    eventProcessor.configurationManager -> sitaMessagingDatabase.businessSchema "Lee configuraciones por tenant desde configuration table" "EF Core" "001 - Fase 1"

    // Sender - Acceso a esquemas de base de datos
    sender.messageRepository -> sitaMessagingDatabase.businessSchema "Consulta templates y configuraciones SITA" "EF Core" "001 - Fase 1"
    sender.deliveryTracker -> sitaMessagingDatabase.messagingSchema "Actualiza estado de entregas en reliable messages table" "EF Core" "001 - Fase 1"
    sender.auditService -> sitaMessagingDatabase.businessSchema "Almacena auditoría de entregas y confirmaciones" "EF Core" "001 - Fase 1"

    // Sender - Acceso a archivos
    sender.fileFetcher -> fileStorage "Descarga archivos SITA generados con verificación de integridad" "S3-Compatible API" "001 - Fase 1"

    // ========================================
    // RELACIONES EXTERNAS - INTEGRACIONES
    // ========================================

    // Integración con Notification System para envío
    sender.messageSender -> notification.api.notificationController "Solicita envío de emails SITA con archivos adjuntos" "HTTPS/REST" "001 - Fase 1"

    // Envío a partners aeronáuticos externos
    sender.messageSender -> airlines "Entrega archivos SITA por email" "SMTP via Notification System" "001 - Fase 1"
    sender.messageSender -> descartes "Entrega archivos SITA por protocolo específico" "HTTPS/FTP" "001 - Fase 1"

    // Integración con Configuration Platform
    eventProcessor.configurationManager -> configPlatform.configService "Obtiene configuraciones por tenant en cache miss" "HTTPS/REST" "001 - Fase 1"
    eventProcessor.configurationManager -> configPlatform.secretsService "Obtiene secretos de partners en cache miss" "HTTPS/REST" "001 - Fase 1"
    eventProcessor.dynamicConfigProcessor -> configPlatform.configService "Consulta cambios de configuración con polling inteligente" "HTTPS/REST" "001 - Fase 1"
    sender.configManager -> configPlatform.configService "Obtiene configuraciones de delivery en cache miss" "HTTPS/REST" "001 - Fase 1"
    sender.configManager -> configPlatform.secretsService "Obtiene credenciales de partners cuando se requiere" "HTTPS/REST" "001 - Fase 1"

    // ========================================
    // FLUJO DE PROCESAMIENTO DE EVENTOS
    // ========================================

    // Event Processor - Pipeline principal
    eventProcessor.reliableEventConsumer -> eventProcessor.eventHandler "Delega eventos consumidos para procesamiento de negocio" "In-Memory" "001 - Fase 1"
    eventProcessor.eventHandler -> eventProcessor.service "Solicita generación de mensajes SITA validados" "In-Memory" "001 - Fase 1"
    eventProcessor.service -> eventProcessor.templateProvider "Consulta template específico por tipo de evento" "In-Memory" "001 - Fase 1"
    eventProcessor.service -> eventProcessor.configurationManager "Consulta configuración por tenant con cache-first" "In-Memory" "001 - Fase 1"
    eventProcessor.service -> eventProcessor.generator "Delega generación de archivo SITA con template" "In-Memory" "001 - Fase 1"
    eventProcessor.service -> eventProcessor.fileRepository "Solicita almacenamiento de archivo y metadata" "In-Memory" "001 - Fase 1"
    eventProcessor.fileRepository -> fileStorage "Almacena archivo SITA generado en bucket específico" "S3-Compatible API" "001 - Fase 1"
    eventProcessor.service -> eventProcessor.auditService "Registra evento de generación exitosa" "In-Memory" "001 - Fase 1"

    // Event Processor - Manejo de errores
    eventProcessor.eventHandler -> eventProcessor.retryHandler "Delega manejo de fallos con políticas específicas" "In-Memory" "001 - Fase 1"
    eventProcessor.retryHandler -> eventProcessor.deadLetterProcessor "Envía a DLQ tras agotar reintentos configurados" "In-Memory" "001 - Fase 1"
    eventProcessor.deadLetterProcessor -> eventProcessor.auditService "Registra fallo definitivo con análisis de causa" "In-Memory" "001 - Fase 1"

    // Event Processor - Configuración dinámica
    eventProcessor.dynamicConfigProcessor -> eventProcessor.configurationManager "Invalida cache específico de configuraciones al detectar cambios" "In-Memory" "001 - Fase 1"

    // ========================================
    // OBSERVABILIDAD - EVENT PROCESSOR
    // ========================================

    // Health Checks
    eventProcessor.healthCheck -> sitaMessagingDatabase "Ejecuta health check con query de conectividad" "PostgreSQL" "001 - Fase 1"
    eventProcessor.healthCheck -> fileStorage "Verifica conectividad storage y permisos de escritura" "S3-Compatible API" "001 - Fase 1"
    eventProcessor.healthCheck -> configPlatform.configService "Verifica disponibilidad de configuraciones críticas" "HTTPS/REST" "001 - Fase 1"

    // Logging estructurado
    eventProcessor.service -> eventProcessor.structuredLogger "Registra eventos de generación y validaciones" "Serilog" "001 - Fase 1"
    eventProcessor.eventHandler -> eventProcessor.structuredLogger "Registra eventos procesados con contexto" "Serilog" "001 - Fase 1"
    eventProcessor.retryHandler -> eventProcessor.structuredLogger "Registra reintentos y políticas aplicadas" "Serilog" "001 - Fase 1"
    eventProcessor.configurationManager -> eventProcessor.structuredLogger "Registra cache hit/miss y actualizaciones" "Serilog" "001 - Fase 1"
    eventProcessor.templateProvider -> eventProcessor.structuredLogger "Registra cache de templates y versionado" "Serilog" "001 - Fase 1"
    eventProcessor.fileRepository -> eventProcessor.structuredLogger "Registra persistencia de archivos y metadata" "Serilog" "001 - Fase 1"
    eventProcessor.generator -> eventProcessor.structuredLogger "Registra generación de archivos SITA" "Serilog" "001 - Fase 1"
    eventProcessor.deadLetterProcessor -> eventProcessor.structuredLogger "Registra eventos DLQ y análisis de causa" "Serilog" "001 - Fase 1"
    eventProcessor.dynamicConfigProcessor -> eventProcessor.structuredLogger "Registra cambios de configuración detectados" "Serilog" "001 - Fase 1"
    eventProcessor.healthCheck -> eventProcessor.structuredLogger "Registra resultados de health checks" "Serilog" "001 - Fase 1"

    // Métricas de negocio y técnicas
    eventProcessor.service -> eventProcessor.metricsCollector "Publica métricas de tiempo generación y throughput" "Prometheus" "001 - Fase 1"
    eventProcessor.eventHandler -> eventProcessor.metricsCollector "Publica métricas de eventos procesados por tipo" "Prometheus" "001 - Fase 1"
    eventProcessor.configurationManager -> eventProcessor.metricsCollector "Publica métricas de cache hit ratio" "Prometheus" "001 - Fase 1"
    eventProcessor.reliableEventConsumer -> eventProcessor.metricsCollector "Publica métricas de consumo y lag" "Prometheus" "001 - Fase 1"
    eventProcessor.templateProvider -> eventProcessor.metricsCollector "Publica métricas de cache de templates" "Prometheus" "001 - Fase 1"
    eventProcessor.generator -> eventProcessor.metricsCollector "Publica métricas de generación por partner" "Prometheus" "001 - Fase 1"
    eventProcessor.fileRepository -> eventProcessor.metricsCollector "Publica métricas de I/O y tamaño archivos" "Prometheus" "001 - Fase 1"
    eventProcessor.deadLetterProcessor -> eventProcessor.metricsCollector "Publica métricas de mensajes DLQ" "Prometheus" "001 - Fase 1"
    eventProcessor.dynamicConfigProcessor -> eventProcessor.metricsCollector "Publica métricas de configuración dinámica" "Prometheus" "001 - Fase 1"
    eventProcessor.healthCheck -> eventProcessor.metricsCollector "Publica métricas de health status" "Prometheus" "001 - Fase 1"

    // Auditoría
    eventProcessor.dynamicConfigProcessor -> eventProcessor.auditService "Registra cambios de configuración aplicados" "EF Core" "001 - Fase 1"

    // ========================================
    // FLUJO DE ENVÍO DE MENSAJES
    // ========================================

    // Sender - Pipeline principal de envío
    sender.worker -> sender.messageService "Ejecuta tareas de envío programadas con scheduling" "In-Memory" "001 - Fase 1"
    sender.messageService -> sender.messageRepository "Consulta mensajes SITA pendientes de envío" "In-Memory" "001 - Fase 1"
    sender.messageService -> sender.fileFetcher "Solicita descarga de archivos desde storage" "In-Memory" "001 - Fase 1"
    sender.messageService -> sender.partnerManager "Consulta estado y configuración de partners" "In-Memory" "001 - Fase 1"
    sender.partnerManager -> sender.messageSender "Autoriza envío según rate limits y circuit breaker" "In-Memory" "001 - Fase 1"
    sender.messageSender -> sender.deliveryTracker "Solicita rastreo de estado de entrega" "In-Memory" "001 - Fase 1"

    // Sender - Manejo de errores y resiliencia
    sender.messageSender -> sender.retryHandler "Delega reintentos en fallos de envío" "In-Memory" "001 - Fase 1"
    sender.partnerManager -> sender.retryHandler "Notifica fallos para actualizar circuit breaker" "In-Memory" "001 - Fase 1"
    sender.retryHandler -> sender.auditService "Registra reintentos y fallos permanentes" "In-Memory" "001 - Fase 1"
    sender.deliveryTracker -> sender.auditService "Registra auditoría de entregas y confirmaciones" "In-Memory" "001 - Fase 1"

    // Sender - Configuración
    sender.messageService -> sender.configManager "Consulta configuraciones de delivery por partner" "In-Memory" "001 - Fase 1"

    // ========================================
    // OBSERVABILIDAD - SENDER
    // ========================================

    // Health Checks
    sender.healthCheck -> sitaMessagingDatabase "Ejecuta health check con query de conectividad" "PostgreSQL" "001 - Fase 1"
    sender.healthCheck -> fileStorage "Verifica conectividad storage y permisos de lectura" "S3-Compatible API" "001 - Fase 1"
    sender.healthCheck -> configPlatform.configService "Verifica disponibilidad de configuraciones de delivery" "HTTPS/REST" "001 - Fase 1"

    // Logging estructurado
    sender.messageService -> sender.structuredLogger "Registra operaciones de envío y estado" "Serilog" "001 - Fase 1"
    sender.messageSender -> sender.structuredLogger "Registra envíos a partners con detalles" "Serilog" "001 - Fase 1"
    sender.deliveryTracker -> sender.structuredLogger "Registra confirmaciones y fallos de entrega" "Serilog" "001 - Fase 1"
    sender.worker -> sender.structuredLogger "Registra ejecución de tareas programadas" "Serilog" "001 - Fase 1"
    sender.messageRepository -> sender.structuredLogger "Registra queries y acceso a datos" "Serilog" "001 - Fase 1"
    sender.fileFetcher -> sender.structuredLogger "Registra descarga de archivos Storage Platform" "Serilog" "001 - Fase 1"
    sender.configManager -> sender.structuredLogger "Registra cache hit/miss de configuraciones" "Serilog" "001 - Fase 1"
    sender.partnerManager -> sender.structuredLogger "Registra rate limiting y circuit breaker" "Serilog" "001 - Fase 1"
    sender.retryHandler -> sender.structuredLogger "Registra reintentos y políticas aplicadas" "Serilog" "001 - Fase 1"
    sender.auditService -> sender.structuredLogger "Registra eventos de auditoría" "Serilog" "001 - Fase 1"
    sender.healthCheck -> sender.structuredLogger "Registra resultados de health checks" "Serilog" "001 - Fase 1"

    // Métricas de negocio y técnicas
    sender.messageService -> sender.metricsCollector "Publica métricas de procesamiento y throughput" "Prometheus" "001 - Fase 1"
    sender.messageSender -> sender.metricsCollector "Publica métricas de delivery success rate" "Prometheus" "001 - Fase 1"
    sender.deliveryTracker -> sender.metricsCollector "Publica métricas de tracking y confirmaciones" "Prometheus" "001 - Fase 1"
    sender.configManager -> sender.metricsCollector "Publica métricas de cache hit/miss ratio" "Prometheus" "001 - Fase 1"
    sender.worker -> sender.metricsCollector "Publica métricas de scheduling y latencia" "Prometheus" "001 - Fase 1"
    sender.messageRepository -> sender.metricsCollector "Publica métricas de query performance" "Prometheus" "001 - Fase 1"
    sender.fileFetcher -> sender.metricsCollector "Publica métricas de descarga y throughput" "Prometheus" "001 - Fase 1"
    sender.partnerManager -> sender.metricsCollector "Publica métricas de rate limiting por partner" "Prometheus" "001 - Fase 1"
    sender.retryHandler -> sender.metricsCollector "Publica métricas de reintentos y circuit breaker" "Prometheus" "001 - Fase 1"
    sender.auditService -> sender.metricsCollector "Publica métricas de auditoría y compliance" "Prometheus" "001 - Fase 1"
    sender.healthCheck -> sender.metricsCollector "Publica métricas de health status" "Prometheus" "001 - Fase 1"
}
