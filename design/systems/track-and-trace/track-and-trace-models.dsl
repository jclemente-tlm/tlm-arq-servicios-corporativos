trackAndTrace = softwareSystem "Track & Trace System" {
    description "Sistema corporativo de trazabilidad multitenant para equipaje, carga y pasajeros con procesamiento de eventos en tiempo real."
    tags "Track & Trace" "001 - Fase 1"

    // ========================================
    // DATA STORES - ARQUITECTURA DE ESQUEMAS SEPARADOS
    // ========================================
    // DECISIÓN ARQUITECTÓNICA: Fase 1 usa esquemas separados en misma PostgreSQL
    // - Schema 'business': Datos de negocio (eventos, configuraciones, queries)
    // - Schema 'messaging': Reliable messaging (outbox, dead letter, acknowledgments)
    // VENTAJAS: Simplicidad operacional, transaccionalidad ACID, cero configuración adicional
    // MIGRACIÓN FUTURA: Fase 2 puede separar BD messaging para escalamiento independiente

    trackingDatabase = store "Tracking Database" {
        description "Base de datos PostgreSQL con esquemas separados para datos de negocio y reliable messaging con garantías ACID transaccionales."
        technology "PostgreSQL"
        tags "Database" "PostgreSQL" "Multi-Schema" "001 - Fase 1"

        businessSchema = component "Business Schema" {
            technology "PostgreSQL Schema"
            description "Esquema 'business' que contiene eventos de tracking, configuraciones por tenant, estados de trazabilidad e índices optimizados para consultas."
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
            description "Tabla principal para mensajes confiables con columnas: id, topic, payload, tenant_id, status, created_at, processed_at."
            tags "Database Table" "Message Store" "001 - Fase 1"
        }

        outboxTable = component "Outbox Table" {
            technology "PostgreSQL Table"
            description "Tabla de outbox pattern para publicación transaccional de eventos con garantías ACID."
            tags "Database Table" "Outbox Pattern" "001 - Fase 1"
        }

        deadLetterTable = component "Dead Letter Table" {
            technology "PostgreSQL Table"
            description "Tabla para mensajes fallidos con análisis de errores, retry automático y auditoría completa."
            tags "Database Table" "Dead Letter Queue" "001 - Fase 1"
        }
    }

    // ========================================
    // API UNIFICADA CON CQRS LÓGICO
    // ========================================
    // DECISIÓN ARQUITECTÓNICA: API unificada con separación lógica CQRS
    // - Commands: Controlador/Servicio de ingesta especializados
    // - Queries: Controlador/Servicio de consulta especializados
    // - Infraestructura compartida: Repository, Configuration, Observability
    // VENTAJAS: Simplicidad operacional, menos duplicación, deployment único
    // PATTERN: CQRS lógico sin separación física innecesaria

    trackingAPI = container "Tracking API" {
        description "API REST unificada para ingesta y consulta de eventos de tracking con arquitectura CQRS interna, alta concurrencia y procesamiento optimizado."
        technology "C#, ASP.NET Core, REST API"
        tags "CSharp" "Unified API" "001 - Fase 1"

        // ============ CONTROLADORES - SEPARACIÓN LÓGICA CQRS ============
        trackingIngestController = component "Tracking Ingest Controller" {
            technology "ASP.NET Core"
            description "Expone endpoints REST para operaciones de escritura: POST /events para recepción masiva de eventos con validación de esquemas."
            tags "Controller" "Command" "001 - Fase 1"
        }

        trackingQueryController = component "Tracking Query Controller" {
            technology "ASP.NET Core"
            description "Expone endpoints REST para operaciones de lectura: GET /events, /status con filtrado avanzado, paginación y agregaciones."
            tags "Controller" "Query" "001 - Fase 1"
        }

        // ============ SERVICIOS - LÓGICA DE NEGOCIO ESPECIALIZADA ============
        trackingIngestService = component "Tracking Ingest Service" {
            technology "C#"
            description "Procesa y valida eventos de tracking aplicando reglas de negocio, enriquecimiento de datos y publicación confiable."
            tags "Service" "Command" "001 - Fase 1"
        }

        trackingQueryService = component "Tracking Query Service" {
            technology "C#"
            description "Orquesta operaciones de consulta complejas con optimizaciones de rendimiento, cache inteligente y agregaciones."
            tags "Service" "Query" "001 - Fase 1"
        }

        // ============ INFRAESTRUCTURA COMPARTIDA ============
        reliableEventPublisher = component "Reliable Event Publisher" {
            technology "C#, IReliableMessagePublisher"
            description "Publisher agnóstico con outbox pattern, garantías de entrega y support para múltiples message brokers (PostgreSQL/RabbitMQ/Kafka)."
            tags "Messaging" "Reliability" "001 - Fase 1"
        }

        trackingDataRepository = component "Tracking Data Repository" {
            technology "C#, EF Core"
            description "Repositorio unificado con patrones optimizados para escritura (bulk inserts) y lectura (índices, cache, agregaciones)."
            tags "Repository" "EF Core" "001 - Fase 1"
        }

        configurationProvider = component "Configuration Provider" {
            technology "C#, IConfigurationProvider"
            description "Proveedor unificado de configuraciones dinámicas con cache local, polling inteligente y configuración por tenant."
            tags "Configuration" "001 - Fase 1"
        }

        tenantConfigRepository = component "Tenant Config Repository" {
            technology "C#, EF Core"
            description "Gestiona configuraciones específicas por tenant para validación, autorización, límites de consulta y enriquecimiento."
            tags "Repository" "EF Core" "Multi-Tenant" "001 - Fase 1"
        }

        // ============ OBSERVABILIDAD UNIFICADA ============
        healthCheck = component "Health Check" {
            technology "ASP.NET Core Health Checks"
            description "Endpoints de salud unificados con verificación de dependencias, conectividad a BD, performance y estado de colas."
            tags "Observability" "001 - Fase 1"
        }

        metricsCollector = component "Metrics Collector" {
            technology "Prometheus Client"
            description "Métricas unificadas: ingest (events/sec, latencia), query (queries/sec, cache hits), errores por tenant y performance general."
            tags "Observability" "001 - Fase 1"
        }

        logger = component "Structured Logger" {
            technology "Serilog"
            description "Logging estructurado unificado con correlationId, metadatos de tenant y separación lógica por operación (ingest/query)."
            tags "Observability" "001 - Fase 1"
        }
    }

    trackingEventProcessor = container "Tracking Event Processor" {
        description "Procesador de eventos que consume, valida, enriquece y almacena eventos de tracking, publicando eventos relevantes a sistemas downstream."
        technology "C#, ASP.NET Core"
        tags "CSharp" "001 - Fase 1"

        reliableEventConsumer = component "Reliable Event Consumer" {
            technology "C#, IReliableMessageConsumer"
            description "Consumer agnóstico con acknowledgments, retry patterns y procesamiento paralelo para máximo throughput sin pérdida de eventos."
            tags "Messaging" "Reliability" "001 - Fase 1"
        }

        trackingEventHandler = component "Tracking Event Handler" {
            technology "C#"
            description "Aplica validaciones de esquema y reglas de negocio a eventos de tracking antes del procesamiento."
            tags "001 - Fase 1"
        }

        trackingProcessingService = component "Tracking Processing Service" {
            technology "C#"
            description "Contiene la lógica de negocio para enriquecimiento, correlación y almacenamiento de eventos de tracking."
            tags "001 - Fase 1"
        }

        trackingEventRepository = component "Tracking Event Repository" {
            technology "C#, EF Core"
            description "Persiste eventos crudos y enriquecidos con optimizaciones para consultas de alta frecuencia."
            tags "EF Core" "001 - Fase 1"
        }

        reliableDownstreamPublisher = component "Reliable Downstream Publisher" {
            technology "C#, IReliableMessagePublisher"
            description "Publisher agnóstico para eventos downstream con outbox pattern y garantías de entrega a múltiples sistemas."
            tags "Messaging" "Reliability" "001 - Fase 1"
        }

        processorConfigurationProvider = component "Processor Configuration Provider" {
            technology "C#, IConfigurationProvider"
            description "Proporciona configuraciones dinámicas de procesamiento y parámetros de enriquecimiento con interfaz agnóstica y cache local."
            tags "001 - Fase 1"
        }

        processorTenantConfigRepository = component "Processor Tenant Config Repository" {
            technology "C#, EF Core"
            description "Gestiona configuraciones específicas por tenant para reglas de procesamiento y enriquecimiento."
            tags "EF Core" "001 - Fase 1"
        }

        // Componentes de Observabilidad
        healthCheck = component "Health Check" {
            technology "ASP.NET Core Health Checks"
            description "Expone endpoints de salud con verificación de conectividad a colas y base de datos."
            tags "Observability" "001 - Fase 1"
        }

        metricsCollector = component "Metrics Collector" {
            technology "Prometheus Client"
            description "Recolecta métricas de procesamiento: events processed/sec, tiempo de enriquecimiento, tasa de éxito de publicación."
            tags "Observability" "001 - Fase 1"
        }

        logger = component "Structured Logger" {
            technology "Serilog"
            description "Logging estructurado con correlationId y metadatos de tenant para trazabilidad completa."
            tags "Observability" "001 - Fase 1"
        }
    }

    trackingDashboard = container "Tracking Dashboard" {
        description "Interfaz web reactiva para visualización en tiempo real del estado de tracking y análisis de eventos."
        technology "React, TypeScript"
        tags "Web App" "001 - Fase 1"
    }

    // ========================================
    // RELACIONES INTERNAS DEL SISTEMA
    // ========================================

    // API Unificada - Flujo de ingesta (Command side)
    trackingAPI.reliableEventPublisher -> trackingDatabase.outboxTable "Publica eventos con garantías ACID (outbox pattern)" "PostgreSQL Outbox" "001 - Fase 1"
    trackingDatabase.outboxTable -> trackingDatabase.reliableMessagesTable "Background service procesa outbox → message store" "PostgreSQL" "001 - Fase 1"

    // API Unificada - Flujo de consulta (Query side)
    trackingAPI.trackingDataRepository -> trackingDatabase.businessSchema "Lee datos de trazabilidad con patrones optimizados" "EF Core" "001 - Fase 1"

    // API Unificada - Configuración compartida
    trackingAPI.tenantConfigRepository -> trackingDatabase.businessSchema "Gestiona configuración por tenant (ingest + query)" "EF Core" "001 - Fase 1"

    // Event Processor - Flujo principal (Con reliable messaging en mismo BD)
    trackingDatabase.reliableMessagesTable -> trackingEventProcessor.reliableEventConsumer "Consume eventos con garantías ACID (polling)" "PostgreSQL Polling" "001 - Fase 1"
    trackingEventProcessor.reliableDownstreamPublisher -> sitaMessaging.sitaMessagingDatabase "Publica eventos downstream confiablemente al sistema SITA (cross-system messaging)" "PostgreSQL Outbox" "001 - Fase 1"

    // Event Processor - Configuración y datos
    trackingEventProcessor.trackingEventRepository -> trackingDatabase.businessSchema "Lee y escribe datos de eventos" "EF Core" "001 - Fase 1"
    trackingEventProcessor.processorTenantConfigRepository -> trackingDatabase.businessSchema "Lee configuración por tenant" "EF Core" "001 - Fase 1"

    // Relaciones internas de la base de datos
    trackingDatabase.messagingSchema -> trackingDatabase.reliableMessagesTable "Contiene tabla de mensajes" "" "001 - Fase 1"
    trackingDatabase.messagingSchema -> trackingDatabase.outboxTable "Contiene tabla de outbox" "" "001 - Fase 1"
    trackingDatabase.messagingSchema -> trackingDatabase.deadLetterTable "Contiene tabla de dead letters" "" "001 - Fase 1"

    // ========================================
    // RELACIONES EXTERNAS - ACTORES
    // ========================================

    // Aplicaciones por país - Operaciones de escritura (Commands)
    appPeru -> trackingAPI.trackingIngestController "Registra eventos de tracking" "HTTPS via API Gateway" "001 - Fase 1"
    appEcuador -> trackingAPI.trackingIngestController "Registra eventos de tracking" "HTTPS via API Gateway" "001 - Fase 1"
    appColombia -> trackingAPI.trackingIngestController "Registra eventos de tracking" "HTTPS via API Gateway" "001 - Fase 1"
    appMexico -> trackingAPI.trackingIngestController "Registra eventos de tracking" "HTTPS via API Gateway" "001 - Fase 1"

    // Aplicaciones por país - Operaciones de consulta (Queries)
    appPeru -> trackingAPI.trackingQueryController "Consulta estado e historial" "HTTPS via API Gateway" "001 - Fase 1"
    appEcuador -> trackingAPI.trackingQueryController "Consulta estado e historial" "HTTPS via API Gateway" "001 - Fase 1"
    appColombia -> trackingAPI.trackingQueryController "Consulta estado e historial" "HTTPS via API Gateway" "001 - Fase 1"
    appMexico -> trackingAPI.trackingQueryController "Consulta estado e historial" "HTTPS via API Gateway" "001 - Fase 1"

    // Usuario operacional - Dashboard con datos en tiempo real
    operationalUser -> trackingDashboard "Consulta trazabilidad y métricas" "" "001 - Fase 1"
    trackingDashboard -> trackingAPI.trackingQueryController "Consulta datos de trazabilidad" "HTTPS" "001 - Fase 1"

    // ========================================
    // RELACIONES EXTERNAS - SISTEMAS
    // ========================================

    // Integración con plataforma de configuración
    trackingAPI.configurationProvider -> configPlatform.configService "Lee configuraciones unificadas y secretos" "" "001 - Fase 1"
    trackingEventProcessor.processorConfigurationProvider -> configPlatform.configService "Lee configuraciones y secretos" "" "001 - Fase 1"

    // ========================================
    // RELACIONES ENTRE COMPONENTES INTERNOS
    // ========================================

    // API Unificada - Flujo de ingesta (Command side)
    trackingAPI.trackingIngestController -> trackingAPI.trackingIngestService "Procesa comandos de ingesta" "" "001 - Fase 1"
    trackingAPI.trackingIngestService -> trackingAPI.reliableEventPublisher "Usa publisher confiable" "" "001 - Fase 1"
    trackingAPI.trackingIngestService -> trackingAPI.trackingDataRepository "Persiste eventos inmediatamente" "EF Core" "001 - Fase 1"

    // API Unificada - Flujo de consulta (Query side)
    trackingAPI.trackingQueryController -> trackingAPI.trackingQueryService "Procesa consultas complejas" "" "001 - Fase 1"
    trackingAPI.trackingQueryService -> trackingAPI.trackingDataRepository "Optimiza acceso de lectura" "EF Core" "001 - Fase 1"

    // API Unificada - Infraestructura compartida
    trackingAPI.configurationProvider -> trackingAPI.tenantConfigRepository "Gestiona configuración por tenant" "EF Core" "001 - Fase 1"

    // Event Processor - Flujo principal (Sin cambios)
    trackingEventProcessor.reliableEventConsumer -> trackingEventProcessor.trackingEventHandler "Envía eventos para procesar" "" "001 - Fase 1"
    trackingEventProcessor.trackingEventHandler -> trackingEventProcessor.trackingProcessingService "Usa" "" "001 - Fase 1"
    trackingEventProcessor.trackingProcessingService -> trackingEventProcessor.trackingEventRepository "Usa" "EF Core" "001 - Fase 1"
    trackingEventProcessor.trackingProcessingService -> trackingEventProcessor.reliableDownstreamPublisher "Usa publisher confiable" "" "001 - Fase 1"

    // Event Processor - Configuración
    trackingEventProcessor.processorConfigurationProvider -> trackingEventProcessor.processorTenantConfigRepository "Lee configuración por tenant" "EF Core" "001 - Fase 1"
}
