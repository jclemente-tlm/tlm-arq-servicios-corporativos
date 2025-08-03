sitaMessaging = softwareSystem "SITA Messaging" {
    description "Gestiona la mensajería SITA para los diferentes países basado en eventos de Track & Trace"
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
        description "Base de datos PostgreSQL con esquemas separados para datos de negocio SITA y reliable messaging con garantías ACID transaccionales."
        technology "PostgreSQL"
        tags "Database" "PostgreSQL" "Multi-Schema" "001 - Fase 1"

        businessSchema = component "Business Schema" {
            technology "PostgreSQL Schema"
            description "Esquema 'business' que contiene templates SITA, configuraciones por tenant, logs de generación y auditoría de entregas."
            tags "Database Schema" "Business Data" "001 - Fase 1"
        }

        messagingSchema = component "Messaging Schema" {
            technology "PostgreSQL Schema"
            description "Esquema 'messaging' que implementa reliable messaging con outbox pattern, dead letter store y acknowledgments para garantías ACID."
            tags "Database Schema" "Reliable Messaging" "001 - Fase 1"
        }

        // Tablas específicas como componentes del messaging schema
        reliableMessagesTable = component "Reliable Messages Table" {
            technology "PostgreSQL Table"
            description "Tabla principal para mensajes confiables SITA con columnas: id, topic, payload, tenant_id, status, created_at, processed_at."
            tags "Database Table" "Message Store" "001 - Fase 1"
        }

        outboxTable = component "Outbox Table" {
            technology "PostgreSQL Table"
            description "Tabla de outbox pattern para publicación transaccional de eventos SITA con garantías ACID."
            tags "Database Table" "Outbox Pattern" "001 - Fase 1"
        }

        deadLetterTable = component "Dead Letter Table" {
            technology "PostgreSQL Table"
            description "Tabla para mensajes SITA fallidos con análisis de errores, retry automático y auditoría completa."
            tags "Database Table" "Dead Letter Queue" "001 - Fase 1"
        }

        // Tablas específicas del business schema
        templatesTable = component "Templates Table" {
            technology "PostgreSQL Table"
            description "Tabla para templates SITA con versionado, validación de esquemas y metadata por tipo de evento y partner."
            tags "Database Table" "Templates" "001 - Fase 1"
        }

        configurationTable = component "Configuration Table" {
            technology "PostgreSQL Table"
            description "Tabla para configuraciones SITA por tenant con parámetros específicos de generación y entrega."
            tags "Database Table" "Configuration" "001 - Fase 1"
        }
    }

    // Nuevo worker para procesar eventos SITA
    eventProcessor = container "SITA Event Processor" {
        technology "C#, .NET 8, Worker Service"
        description "Procesa eventos de generación de mensajes SITA"
        tags "CSharp" "001 - Fase 1"

        reliableEventConsumer = component "Reliable Event Consumer" {
            technology "C#, .NET 8, IReliableMessageConsumer"
            description "Consumer agnóstico con acknowledgments, retry patterns y procesamiento confiable para eventos SITA"
            tags "Messaging" "Reliability" "001 - Fase 1"
        }

        eventHandler = component "Event Handler" {
            technology "C#, .NET 8, Mapster"
            description "Procesa eventos de Track & Trace y genera mensajes SITA correspondientes con mapeo automático de DTOs."
            tags "001 - Fase 1"
        }

        service = component "SITA Generation Service" {
            technology "C#, .NET 8, FluentValidation"
            description "Orquesta la validación, generación de archivos SITA y persistencia desde eventos procesados."
            tags "001 - Fase 1"
        }

        templateProvider = component "SITA Template Repository" {
            technology "C#, .NET 8, EF Core"
            description "Repositorio especializado para templates SITA con versionado, validación de esquemas y cache por tipo de evento y partner."
            tags "Template" "001 - Fase 1"
        }

        configurationManager = component "Configuration Manager" {
            technology "C#, .NET 8, IMemoryCache"
            description "Gestión unificada de configuraciones con cache local, acceso a BD y configuración dinámica (TTL: 30min)."
            tags "Configuración" "Cache" "001 - Fase 1"
        }

        fileRepository = component "File & Data Repository" {
            technology "C#, .NET 8, EF Core"
            description "Repositorio unificado que gestiona almacenamiento de archivos SITA generados en S3 y metadata en PostgreSQL."
            tags "Repository" "Files" "001 - Fase 1"
        }

        generator = component "File Generator" {
            technology "C#, .NET 8, System.Text.Json"
            description "Generador especializado de mensajes SITA con formatos específicos por partner (JSON, CSV, XML)."
            tags "001 - Fase 1"
        }

        // Componentes de Observabilidad
        healthCheck = component "Health Check" {
            technology "ASP.NET Core Health Checks"
            description "Expone endpoints /health y verifica estado de dependencias críticas: PostgreSQL, S3, AWS Parameter Store."
            tags "Observability" "001 - Fase 1"
        }

        metricsCollector = component "Metrics Collector" {
            technology "Prometheus Client"
            description "Recolecta métricas de negocio y técnicas: events/sec, generation time, cache hit ratio, error rates."
            tags "Observability" "001 - Fase 1"
        }

        logger = component "Structured Logger" {
            technology "Serilog"
            description "Logging estructurado con correlationId, tenant context para trazabilidad completa de eventos SITA."
            tags "Observability" "001 - Fase 1"
        }

        // Componentes de Resiliencia
        retryHandler = component "Retry Handler" {
            technology "C#, .NET 8, Polly"
            description "Maneja reintentos de eventos fallidos con backoff exponencial y circuit breaker."
            tags "001 - Fase 1"
        }

        deadLetterProcessor = component "Dead Letter Processor" {
            technology "C#, .NET 8"
            description "Procesa eventos que fallaron después de todos los reintentos, analiza causa raíz y permite reprocessing manual."
            tags "001 - Fase 1"
        }

        auditService = component "Audit Service" {
            technology "C#, .NET 8, EF Core"
            description "Registra auditoría inmutable de eventos procesados, generaciones exitosas y fallos."
            tags "001 - Fase 1"
        }

        dynamicConfigProcessor = component "Dynamic Configuration Processor" {
            technology "C#, .NET 8, FluentValidation"
            description "Procesador unificado para cambios de configuración con polling inteligente (5min) y actualizaciones dinámicas."
            tags "Configuration Events" "Feature Flags" "001 - Fase 1"
        }
    }

    fileStorage = store "SITA File Storage" {
        technology "AWS S3"
        description "Almacena los archivos SITA generados"
        tags "File Storage" "AWS S3" "001 - Fase 1"
    }

    sender = container "SITA Messaging Sender" {
        technology "C#, .NET 8, Background Service"
        description "Envía archivos generados a partners SITA usando protocolos aeronáuticos estándar con garantías de entrega."
        tags "CSharp" "Background Service" "001 - Fase 1"

        worker = component "Worker" {
            technology "C#, .NET 8, BackgroundService"
            description "Background service que ejecuta tareas periódicas de envío con scheduling inteligente y rate limiting por partner."
            tags "Background Service" "001 - Fase 1"
        }

        messageService = component "Message Service" {
            technology "C#, .NET 8, FluentValidation"
            description "Orquesta el envío de mensajes SITA con validación de esquemas aeronáuticos y coordinación de delivery workflows."
            tags "Business Logic" "001 - Fase 1"
        }

        messageRepository = component "Message Repository" {
            technology "C#, .NET 8, EF Core"
            description "Repositorio especializado para mensajes SITA con queries optimizadas y cache de metadata."
            tags "Data Access" "001 - Fase 1"
        }

        fileFetcher = component "File Fetcher" {
            technology "C#, .NET 8, AWS SDK"
            description "Gestiona descarga optimizada de archivos SITA desde S3 con retry automático y verificación de integridad."
            tags "File Management" "001 - Fase 1"
        }

        messageSender = component "Message Sender" {
            technology "C#, .NET 8, HttpClient"
            description "Cliente especializado para envío a partners SITA con autenticación por certificados y retry policies."
            tags "External Communication" "001 - Fase 1"
        }

        deliveryTracker = component "Delivery Tracker" {
            technology "C#, .NET 8, EF Core"
            description "Rastrea estados de entrega con polling de confirmaciones y escalamiento automático de fallos."
            tags "Tracking" "001 - Fase 1"
        }

        // Componentes de Observabilidad
        healthCheck = component "Health Check" {
            technology "ASP.NET Core Health Checks"
            description "Health checks específicos para conectividad SITA: validación de endpoints de partners y verificación de certificados."
            tags "Observability" "001 - Fase 1"
        }

        metricsCollector = component "Metrics Collector" {
            technology "Prometheus.NET"
            description "Métricas específicas SITA: delivery success rate por partner, send times y response times."
            tags "Observability" "001 - Fase 1"
        }

        logger = component "Structured Logger" {
            technology "Serilog"
            description "Logging estructurado con enrichment de correlationId, partner context y message metadata."
            tags "Observability" "001 - Fase 1"
        }

        configManager = component "Configuration Manager" {
            technology "C#, .NET 8, IMemoryCache"
            description "Gestiona configuraciones de delivery con cache inteligente (TTL 30min) y fallback automático."
            tags "Configuration" "001 - Fase 1"
        }

        configCache = component "Configuration Cache" {
            technology "IMemoryCache"
            description "Cache en memoria para configuraciones de delivery con TTL optimizado por tipo."
            tags "Cache" "001 - Fase 1"
        }
    }

    // ========================================
    // RELACIONES INTERNAS DEL SISTEMA
    // ========================================

    // ========================================
    // RELACIONES INTERNAS DEL SISTEMA
    // ========================================

    // Event Processor - Flujo principal de messaging
    eventProcessor.reliableEventConsumer -> sitaMessagingDatabase "Consume eventos de seguimiento con garantías ACID desde tabla de mensajes confiables" "PostgreSQL Polling" "001 - Fase 1"
    eventProcessor.templateProvider -> sitaMessagingDatabase "Lee templates SITA con versionado desde esquema de negocio" "Entity Framework Core" "001 - Fase 1"

    // Event Processor - Acceso a datos unificado
    eventProcessor.fileRepository -> sitaMessagingDatabase "Acceso unificado: mensajes, metadata, configuraciones" "EF Core" "001 - Fase 1"
    eventProcessor.auditService -> sitaMessagingDatabase "Almacena auditoría de generación en esquema de negocio" "EF Core" "001 - Fase 1"

    // Event Processor - Manejo de errores
    eventProcessor.deadLetterProcessor -> sitaMessagingDatabase "Envía eventos fallidos a tabla DLQ con análisis de errores" "PostgreSQL" "001 - Fase 1"

    // Event Processor - Configuración dinámica
    // Configuración agnóstica eliminada - se usa cache local con polling

    // Sender - Archivos y datos
    sender.fileFetcher -> fileStorage "Obtiene archivos SITA generados" "HTTPS" "001 - Fase 1"
    sender.messageRepository -> sitaMessagingDatabase "Lee templates y configuración de mensajes SITA" "" "001 - Fase 1"
    sender.deliveryTracker -> sitaMessagingDatabase "Almacena estado de entregas en tabla de mensajes confiables" "" "001 - Fase 1"

    // ========================================
    // ========================================
    // RELACIONES EXTERNAS - SISTEMAS
    // ========================================

    // Integración con Notification System para envío de emails
    sender.messageSender -> notification.api.notificationController "Solicita envío de emails SITA" "HTTPS via API Gateway" "001 - Fase 1"

    // Envío a partners externos
    sender.messageSender -> airlines "Envía archivos SITA" "Via Email por\nNotification System" "001 - Fase 1"
    sender.messageSender -> descartes "Envía archivos SITA" "" "001 - Fase 1"

    // ========================================
    // RELACIONES ENTRE COMPONENTES INTERNOS
    // ========================================

    // Event Processor - Flujo principal de procesamiento
    eventProcessor.reliableEventConsumer -> eventProcessor.eventHandler "Envía eventos consumidos para procesamiento" "" "001 - Fase 1"
    eventProcessor.eventHandler -> eventProcessor.service "Delega generación de mensajes SITA procesados" "" "001 - Fase 1"

    // Event Processor - Flujo de generación con cache-first pattern
    eventProcessor.service -> eventProcessor.templateProvider "Solicita template SITA específico (con cache)" "" "001 - Fase 1"
    eventProcessor.service -> eventProcessor.configurationManager "Consulta configuración por tenant (cache-first)" "" "001 - Fase 1"
    eventProcessor.service -> eventProcessor.generator "Delega generación de archivo SITA validado" "" "001 - Fase 1"
    eventProcessor.service -> eventProcessor.fileRepository "Delega almacenamiento de archivo y metadata" "" "001 - Fase 1"
    eventProcessor.fileRepository -> fileStorage "Almacena archivo SITA generado" "HTTPS" "001 - Fase 1"

    // Event Processor - Persistencia y auditoría
    eventProcessor.service -> eventProcessor.auditService "Registra auditoría de generación exitosa" "" "001 - Fase 1"

    // Event Processor - Configuración con cache-first pattern
    eventProcessor.configurationManager -> configPlatform.configService "Obtiene configuraciones en cache miss (polling TTL: 30min)" "HTTPS" "001 - Fase 1"
    eventProcessor.configurationManager -> configPlatform.secretsService "Obtiene secretos en cache miss" "HTTPS" "001 - Fase 1"
    eventProcessor.configurationManager -> sitaMessagingDatabase "Lee configuraciones específicas por tenant en cache miss" "EF Core" "001 - Fase 1"

    // Event Processor - Configuración dinámica: polling inteligente para cambios
    eventProcessor.dynamicConfigProcessor -> configPlatform.configService "Consulta cambios de configuración (polling TTL: 5min)" "HTTPS" "001 - Fase 1"
    eventProcessor.dynamicConfigProcessor -> eventProcessor.configurationManager "Invalida cache específico cuando detecta cambios" "" "001 - Fase 1"

    // Event Processor - Manejo de errores y resiliencia
    eventProcessor.eventHandler -> eventProcessor.retryHandler "Delega reintentos cuando detecta fallos" "" "001 - Fase 1"
    eventProcessor.retryHandler -> eventProcessor.deadLetterProcessor "Envía a DLQ cuando agota reintentos (max: 3)" "" "001 - Fase 1"
    eventProcessor.deadLetterProcessor -> eventProcessor.auditService "Registra fallos definitivos con análisis de causa raíz" "" "001 - Fase 1"

    // Event Processor - Health checks y monitoring
    eventProcessor.healthCheck -> sitaMessagingDatabase "Verifica conectividad BD y latencia" "Health Check" "001 - Fase 1"
    eventProcessor.healthCheck -> fileStorage "Verifica conectividad S3 y permisos" "Health Check" "001 - Fase 1"
    eventProcessor.healthCheck -> configPlatform.configService "Verifica disponibilidad de configuraciones críticas" "Health Check" "001 - Fase 1"
    eventProcessor.healthCheck -> eventProcessor.metricsCollector "Métricas: estado de dependencias, latencias" "" "001 - Fase 1"

    // Event Processor - Observabilidad: Logging con acciones específicas
    eventProcessor.service -> eventProcessor.logger "Registra logs de generaciones SITA, validaciones y errores" "" "001 - Fase 1"
    eventProcessor.eventHandler -> eventProcessor.logger "Registra logs de eventos procesados, tipos y tenants" "" "001 - Fase 1"
    eventProcessor.retryHandler -> eventProcessor.logger "Registra logs de reintentos, backoff y fallos permanentes" "" "001 - Fase 1"
    eventProcessor.configurationManager -> eventProcessor.logger "Registra logs de cache hit/miss, invalidaciones y actualizaciones" "" "001 - Fase 1"
    eventProcessor.templateProvider -> eventProcessor.logger "Registra logs de cache de templates, versionado y fallos" "" "001 - Fase 1"
    eventProcessor.fileRepository -> eventProcessor.logger "Registra logs de persistencia de archivos y metadata" "" "001 - Fase 1"
    eventProcessor.generator -> eventProcessor.logger "Registra logs de generación de archivos SITA y validaciones" "" "001 - Fase 1"
    eventProcessor.deadLetterProcessor -> eventProcessor.logger "Registra logs de eventos enviados a DLQ y análisis de causa" "" "001 - Fase 1"

    // Event Processor - Observabilidad: Métricas con acciones específicas
    eventProcessor.service -> eventProcessor.metricsCollector "Envía métricas de tiempo generación, archivos/sec, éxito/fallo rate" "" "001 - Fase 1"
    eventProcessor.eventHandler -> eventProcessor.metricsCollector "Envía métricas de eventos procesados/sec, tipos de evento" "" "001 - Fase 1"
    eventProcessor.configurationManager -> eventProcessor.metricsCollector "Envía métricas de cache hit ratio, invalidaciones, feature flags usage" "" "001 - Fase 1"
    eventProcessor.reliableEventConsumer -> eventProcessor.metricsCollector "Envía métricas de eventos consumidos/sec, lag, acknowledgments" "" "001 - Fase 1"
    eventProcessor.templateProvider -> eventProcessor.metricsCollector "Envía métricas de template cache hit/miss, versionado" "" "001 - Fase 1"
    eventProcessor.generator -> eventProcessor.metricsCollector "Envía métricas de tiempo generación por partner, throughput" "" "001 - Fase 1"
    eventProcessor.fileRepository -> eventProcessor.metricsCollector "Envía métricas de operaciones I/O, tamaño archivos" "" "001 - Fase 1"
    eventProcessor.deadLetterProcessor -> eventProcessor.metricsCollector "Envía métricas de mensajes DLQ, tipos de errores" "" "001 - Fase 1"

    // Event Processor - Configuración dinámica con observabilidad y auditoría
    eventProcessor.dynamicConfigProcessor -> eventProcessor.logger "Registra logs de cambios detectados, validaciones y rollbacks" "" "001 - Fase 1"
    eventProcessor.dynamicConfigProcessor -> eventProcessor.metricsCollector "Envía métricas de configuraciones actualizadas, tiempo invalidación" "" "001 - Fase 1"
    eventProcessor.dynamicConfigProcessor -> eventProcessor.auditService "Registra auditoría de cambios de configuración aplicados" "" "001 - Fase 1"

    // Event Processor - Health Checks con acciones específicas
    eventProcessor.healthCheck -> eventProcessor.logger "Registra logs de health checks, status y latencias" "" "001 - Fase 1"
    eventProcessor.healthCheck -> eventProcessor.metricsCollector "Envía métricas de health status, latencia checks, dependencies status" "" "001 - Fase 1"
    eventProcessor.healthCheck -> sitaMessagingDatabase "Ejecuta health check con query específico (SELECT 1)" "" "001 - Fase 1"

    // Event Processor - Data Access con acciones específicas
    eventProcessor.reliableEventConsumer -> sitaMessagingDatabase "Consulta eventos pendientes con FOR UPDATE SKIP LOCKED" "" "001 - Fase 1"
    eventProcessor.reliableEventConsumer -> sitaMessagingDatabase "Actualiza status eventos a 'processing' en transacción" "" "001 - Fase 1"
    eventProcessor.fileRepository -> sitaMessagingDatabase "Persiste metadata de archivos generados (filename, size, hash)" "" "001 - Fase 1"
    eventProcessor.deadLetterProcessor -> sitaMessagingDatabase "Almacena eventos fallidos con causa y timestamp" "" "001 - Fase 1"

    // Event Processor - Integraciones externas con acciones específicas
    eventProcessor.configurationManager -> configPlatform.configService "Consulta configuraciones específicas por tenant" "" "001 - Fase 1"
    eventProcessor.configurationManager -> configPlatform.configService "Consulta feature flags habilitados por environment" "" "001 - Fase 1"

    // Sender - Flujo principal con acciones específicas
    sender.worker -> sender.messageService "Ejecuta tareas periódicas de envío SITA programadas" "" "001 - Fase 1"
    sender.messageService -> sender.messageRepository "Consulta mensajes SITA pendientes de envío" "" "001 - Fase 1"
    sender.messageService -> sender.fileFetcher "Solicita descarga de archivos SITA desde storage" "" "001 - Fase 1"
    sender.messageService -> sender.messageSender "Delega envío de archivos a partners específicos" "" "001 - Fase 1"
    sender.messageSender -> sender.deliveryTracker "Solicita rastreo de estado de entrega" "" "001 - Fase 1"

    // Sender - Configuración y cache con acciones específicas
    sender.messageService -> sender.configManager "Consulta configuraciones de delivery por partner" "" "001 - Fase 1"
    sender.configManager -> sender.configCache "Consulta cache de configuraciones (cache-first)" "" "001 - Fase 1"
    sender.configManager -> configPlatform.configService "Obtiene configuraciones en cache miss" "HTTPS" "001 - Fase 1"
    sender.configManager -> configPlatform.secretsService "Obtiene secretos de partners cuando se requiere" "HTTPS" "001 - Fase 1"

    // Sender - Observabilidad con acciones específicas
    sender.messageService -> sender.logger "Registra logs de operaciones de envío y status" "" "001 - Fase 1"
    sender.messageSender -> sender.logger "Registra logs de envíos a partners con detalles" "" "001 - Fase 1"
    sender.deliveryTracker -> sender.logger "Registra logs de confirmaciones y fallos de entrega" "" "001 - Fase 1"

    sender.messageService -> sender.metricsCollector "Envía métricas de procesamiento y throughput" "" "001 - Fase 1"
    sender.messageSender -> sender.metricsCollector "Envía métricas de delivery (éxito/fallo rate, tiempos)" "" "001 - Fase 1"
    sender.deliveryTracker -> sender.metricsCollector "Envía métricas de tracking y confirmaciones" "" "001 - Fase 1"
    sender.configManager -> sender.metricsCollector "Envía métricas de cache hit/miss ratio configuraciones" "" "001 - Fase 1"
}
