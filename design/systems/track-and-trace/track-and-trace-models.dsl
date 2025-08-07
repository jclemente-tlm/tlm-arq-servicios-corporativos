trackAndTrace = softwareSystem "Track & Trace System" {
    description "Sistema de trazabilidad multitenant con eventos en tiempo real"
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
        description "PostgreSQL con esquemas separados para negocio y messaging"
        technology "PostgreSQL"
        tags "Database" "PostgreSQL" "Multi-Schema" "001 - Fase 1"

        businessSchema = component "Business Schema" {
            technology "PostgreSQL Schema"
            description "Esquema para eventos de tracking y configuraciones"
            tags "Database Schema" "Business Data" "001 - Fase 1"
        }

        messagingSchema = component "Messaging Schema" {
            technology "PostgreSQL Schema"
            description "Esquema para reliable messaging con outbox pattern"
            tags "Database Schema" "Reliable Messaging" "001 - Fase 1"
        }

        // Tablas específicas como componentes del messaging schema
        reliableMessagesTable = component "Reliable Messages Table" {
            technology "PostgreSQL Table"
            description "Tabla principal para mensajes confiables"
            tags "Database Table" "Message Store" "001 - Fase 1"
        }

        outboxTable = component "Outbox Table" {
            technology "PostgreSQL Table"
            description "Tabla de outbox pattern para publicación transaccional"
            tags "Database Table" "Outbox Pattern" "001 - Fase 1"
        }

        deadLetterTable = component "Dead Letter Table" {
            technology "PostgreSQL Table"
            description "Tabla para mensajes fallidos con retry automático"
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
        description "API REST unificada para ingesta y consulta con CQRS interno"
        technology "C#, ASP.NET Core, REST API"
        tags "CSharp" "Unified API" "001 - Fase 1"

        // ============ CONTROLADORES - SEPARACIÓN LÓGICA CQRS ============
        trackingIngestController = component "Tracking Ingest Controller" {
            technology "ASP.NET Core"
            description "Endpoints REST para operaciones de escritura"
            tags "Controller" "Command" "001 - Fase 1"
        }

        trackingQueryController = component "Tracking Query Controller" {
            technology "ASP.NET Core"
            description "Endpoints REST para operaciones de lectura"
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

        dynamicConfigProcessor = component "Dynamic Configuration Processor" {
            technology "C#, FluentValidation, HttpClient"
            description "Consulta cambios de configuración con polling inteligente, valida nuevas configuraciones contra esquemas y actualiza cache dinámicamente sin reinicio del API."
            tags "Configuration Events" "Feature Flags" "001 - Fase 1"
        }

        tenantConfigRepository = component "Tenant Config Repository" {
            technology "EF Core"
            description "Ejecuta configuraciones específicas por tenant para validación, autorización, límites de consulta y enriquecimiento de datos."
            tags "Repository" "EF Core" "Multi-Tenant" "001 - Fase 1"
        }

        // ============ OBSERVABILIDAD UNIFICADA ============
        healthCheck = component "Health Check" {
            technology "ASP.NET Core Health Checks"
            description "Valida salud del API: verifica dependencias críticas, conectividad PostgreSQL, performance y estado de colas de eventos"
            tags "Observability" "001 - Fase 1"
        }

        metricsCollector = component "Metrics Collector" {
            technology "Prometheus.NET"
            description "Recolecta métricas unificadas: registra ingest (events/sec, latencia), mide query (queries/sec, cache hits) y cuenta errores por tenant"
            tags "Observability" "001 - Fase 1"
        }

        structuredLogger = component "Structured Logger" {
            technology "Serilog"
            description "Registra logging estructurado unificado con correlationId único, captura metadatos de tenant y separa operaciones (ingest/query)"
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

        dynamicConfigProcessor = component "Dynamic Configuration Processor" {
            technology "C#, FluentValidation, HttpClient"
            description "Consulta cambios de configuración con polling inteligente, valida nuevas configuraciones contra esquemas y actualiza cache dinámicamente sin reinicio del Event Processor."
            tags "Configuration Events" "Feature Flags" "001 - Fase 1"
        }

        processorTenantConfigRepository = component "Processor Tenant Config Repository" {
            technology "EF Core"
            description "Ejecuta configuraciones específicas por tenant para reglas de procesamiento y enriquecimiento de eventos."
            tags "EF Core" "001 - Fase 1"
        }

        // Componentes de Observabilidad
        healthCheck = component "Health Check" {
            technology "ASP.NET Core Health Checks"
            description "Valida salud del procesador: verifica conectividad a colas de eventos y disponibilidad de base de datos"
            tags "Observability" "001 - Fase 1"
        }

        metricsCollector = component "Metrics Collector" {
            technology "Prometheus.NET"
            description "Recolecta métricas de procesamiento: registra events processed/sec, mide tiempo de enriquecimiento y cuenta tasa de éxito de publicación"
            tags "Observability" "001 - Fase 1"
        }

        structuredLogger = component "Structured Logger" {
            technology "Serilog"
            description "Registra logging estructurado con correlationId único, captura metadatos de tenant para trazabilidad completa de eventos"
            tags "Observability" "001 - Fase 1"
        }
    }

    trackingDashboard = container "Tracking Dashboard" {
        description "Interfaz web reactiva para visualización en tiempo real del estado de tracking y análisis de eventos."
        technology "React, TypeScript"
        tags "Web App" "001 - Fase 1"

        // Componentes de Observabilidad
        healthCheck = component "Health Check" {
            technology "React Health Check"
            description "Valida salud del dashboard: verifica conectividad a APIs, evalúa performance del frontend y estado de dependencias"
            tags "Observability" "001 - Fase 1"
        }

        metricsCollector = component "Metrics Collector" {
            technology "Browser Metrics"
            description "Recolecta métricas del frontend: registra tiempo de carga de páginas, mide interacciones de usuario y cuenta errores de UI"
            tags "Observability" "001 - Fase 1"
        }

        structuredLogger = component "Structured Logger" {
            technology "Frontend Logger"
            description "Registra logging estructurado para frontend con sessionId único, captura user context y almacena tracking de acciones"
            tags "Observability" "001 - Fase 1"
        }
    }

    // ========================================
    // RELACIONES INTERNAS DEL SISTEMA
    // ========================================

    // API Unificada - Flujo de ingesta (Command side)
    trackingAPI.reliableEventPublisher -> trackingDatabase.outboxTable "Publica eventos ACID" "PostgreSQL Outbox" "001 - Fase 1"
    trackingDatabase.outboxTable -> trackingDatabase.reliableMessagesTable "Procesa outbox a mensajes" "PostgreSQL" "001 - Fase 1"

    // API Unificada - Flujo de consulta (Query side)
    trackingAPI.trackingDataRepository -> trackingDatabase.businessSchema "Lee datos trazabilidad" "EF Core" "001 - Fase 1"

    // API Unificada - Configuración compartida
    trackingAPI.tenantConfigRepository -> trackingDatabase.businessSchema "Gestiona config por tenant" "EF Core" "001 - Fase 1"

    // Event Processor - Flujo principal (Con reliable messaging en mismo BD)
    trackingDatabase.reliableMessagesTable -> trackingEventProcessor.reliableEventConsumer "Consume eventos ACID" "PostgreSQL Polling" "001 - Fase 1"
    trackingEventProcessor.reliableDownstreamPublisher -> sitaMessaging.sitaMessagingDatabase "Publica eventos a SITA" "PostgreSQL Outbox" "001 - Fase 1"

    // Event Processor - Configuración y datos
    trackingEventProcessor.trackingEventRepository -> trackingDatabase.businessSchema "Lee y escribe eventos" "EF Core" "001 - Fase 1"
    trackingEventProcessor.processorTenantConfigRepository -> trackingDatabase.businessSchema "Lee config por tenant" "EF Core" "001 - Fase 1"

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
    appPeru -> trackingAPI.trackingQueryController "Consulta estado" "HTTPS via API Gateway" "001 - Fase 1"
    appEcuador -> trackingAPI.trackingQueryController "Consulta estado" "HTTPS via API Gateway" "001 - Fase 1"
    appColombia -> trackingAPI.trackingQueryController "Consulta estado" "HTTPS via API Gateway" "001 - Fase 1"
    appMexico -> trackingAPI.trackingQueryController "Consulta estado" "HTTPS via API Gateway" "001 - Fase 1"

    // Usuario operacional - Dashboard con datos en tiempo real
    operationalUser -> trackingDashboard "Consulta trazabilidad" "" "001 - Fase 1"
    trackingDashboard -> trackingAPI.trackingQueryController "Consulta datos tracking" "HTTPS" "001 - Fase 1"

    // ========================================
    // RELACIONES EXTERNAS - SISTEMAS
    // ========================================

    // Integración con plataforma de configuración
    trackingAPI.configurationProvider -> configPlatform.configService "Lee configuraciones" "HTTPS/REST" "001 - Fase 1"
    trackingEventProcessor.processorConfigurationProvider -> configPlatform.configService "Lee configuraciones" "HTTPS/REST" "001 - Fase 1"

    // Dynamic Configuration Relations - Patrón polling correcto
    trackingAPI.dynamicConfigProcessor -> configPlatform.configService "Consulta cambios config" "HTTPS/REST" "001 - Fase 1"
    trackingAPI.dynamicConfigProcessor -> trackingAPI.configurationProvider "Invalida cache config" "In-Memory" "001 - Fase 1"
    trackingEventProcessor.dynamicConfigProcessor -> configPlatform.configService "Consulta cambios config" "HTTPS/REST" "001 - Fase 1"
    trackingEventProcessor.dynamicConfigProcessor -> trackingEventProcessor.processorConfigurationProvider "Invalida cache processor" "In-Memory" "001 - Fase 1"

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

    // ========================================
    // OBSERVABILIDAD - TRACKING API
    // ========================================

    // Health Checks
    trackingAPI.healthCheck -> trackingDatabase "Ejecuta health check" "PostgreSQL" "001 - Fase 1"
    trackingAPI.healthCheck -> configPlatform.configService "Verifica configuraciones críticas" "HTTPS/REST" "001 - Fase 1"

    // Logging estructurado
    trackingAPI.trackingIngestController -> trackingAPI.structuredLogger "Registra operaciones de ingesta" "Serilog" "001 - Fase 1"
    trackingAPI.trackingQueryController -> trackingAPI.structuredLogger "Registra consultas" "Serilog" "001 - Fase 1"
    trackingAPI.trackingIngestService -> trackingAPI.structuredLogger "Registra procesamiento de eventos" "Serilog" "001 - Fase 1"
    trackingAPI.trackingQueryService -> trackingAPI.structuredLogger "Registra consultas complejas" "Serilog" "001 - Fase 1"
    trackingAPI.reliableEventPublisher -> trackingAPI.structuredLogger "Registra publicación de eventos" "Serilog" "001 - Fase 1"
    trackingAPI.trackingDataRepository -> trackingAPI.structuredLogger "Registra operaciones de datos" "Serilog" "001 - Fase 1"
    trackingAPI.configurationProvider -> trackingAPI.structuredLogger "Registra cache hit/miss config" "Serilog" "001 - Fase 1"
    trackingAPI.tenantConfigRepository -> trackingAPI.structuredLogger "Registra configuraciones por tenant" "Serilog" "001 - Fase 1"
    trackingAPI.dynamicConfigProcessor -> trackingAPI.structuredLogger "Registra cambios de configuración" "Serilog" "001 - Fase 1"
    trackingAPI.healthCheck -> trackingAPI.structuredLogger "Registra health checks" "Serilog" "001 - Fase 1"

    // Métricas de negocio y técnicas
    trackingAPI.trackingIngestController -> trackingAPI.metricsCollector "Publica métricas de ingesta" "Prometheus" "001 - Fase 1"
    trackingAPI.trackingQueryController -> trackingAPI.metricsCollector "Publica métricas de consultas" "Prometheus" "001 - Fase 1"
    trackingAPI.trackingIngestService -> trackingAPI.metricsCollector "Publica métricas de eventos procesados" "Prometheus" "001 - Fase 1"
    trackingAPI.trackingQueryService -> trackingAPI.metricsCollector "Publica métricas de performance de consultas" "Prometheus" "001 - Fase 1"
    trackingAPI.reliableEventPublisher -> trackingAPI.metricsCollector "Publica métricas de throughput" "Prometheus" "001 - Fase 1"
    trackingAPI.trackingDataRepository -> trackingAPI.metricsCollector "Publica métricas de query performance" "Prometheus" "001 - Fase 1"
    trackingAPI.configurationProvider -> trackingAPI.metricsCollector "Publica métricas de cache" "Prometheus" "001 - Fase 1"
    trackingAPI.tenantConfigRepository -> trackingAPI.metricsCollector "Publica métricas de configuración por tenant" "Prometheus" "001 - Fase 1"
    trackingAPI.dynamicConfigProcessor -> trackingAPI.metricsCollector "Publica métricas de configuración dinámica" "Prometheus" "001 - Fase 1"
    trackingAPI.healthCheck -> trackingAPI.metricsCollector "Publica métricas de health status" "Prometheus" "001 - Fase 1"

    // Observabilidad cross-cutting
    trackingAPI.structuredLogger -> trackingAPI.metricsCollector "Correlaciona logs y métricas" "In-Memory" "001 - Fase 1"

    // ========================================
    // OBSERVABILIDAD - TRACKING EVENT PROCESSOR
    // ========================================

    // Health Checks
    trackingEventProcessor.healthCheck -> trackingDatabase "Ejecuta health check" "PostgreSQL" "001 - Fase 1"
    trackingEventProcessor.healthCheck -> configPlatform.configService "Verifica configuraciones críticas" "HTTPS/REST" "001 - Fase 1"

    // Logging estructurado
    trackingEventProcessor.reliableEventConsumer -> trackingEventProcessor.structuredLogger "Registra consumo de eventos" "Serilog" "001 - Fase 1"
    trackingEventProcessor.trackingEventHandler -> trackingEventProcessor.structuredLogger "Registra procesamiento de eventos" "Serilog" "001 - Fase 1"
    trackingEventProcessor.trackingProcessingService -> trackingEventProcessor.structuredLogger "Registra lógica de procesamiento" "Serilog" "001 - Fase 1"
    trackingEventProcessor.trackingEventRepository -> trackingEventProcessor.structuredLogger "Registra operaciones de persistencia" "Serilog" "001 - Fase 1"
    trackingEventProcessor.reliableDownstreamPublisher -> trackingEventProcessor.structuredLogger "Registra publicación downstream" "Serilog" "001 - Fase 1"
    trackingEventProcessor.processorConfigurationProvider -> trackingEventProcessor.structuredLogger "Registra cache hit/miss config" "Serilog" "001 - Fase 1"
    trackingEventProcessor.processorTenantConfigRepository -> trackingEventProcessor.structuredLogger "Registra configuraciones por tenant" "Serilog" "001 - Fase 1"
    trackingEventProcessor.dynamicConfigProcessor -> trackingEventProcessor.structuredLogger "Registra cambios de configuración" "Serilog" "001 - Fase 1"
    trackingEventProcessor.healthCheck -> trackingEventProcessor.structuredLogger "Registra health checks" "Serilog" "001 - Fase 1"

    // Métricas de negocio y técnicas
    trackingEventProcessor.reliableEventConsumer -> trackingEventProcessor.metricsCollector "Publica métricas de consumo" "Prometheus" "001 - Fase 1"
    trackingEventProcessor.trackingEventHandler -> trackingEventProcessor.metricsCollector "Publica métricas de procesamiento" "Prometheus" "001 - Fase 1"
    trackingEventProcessor.trackingProcessingService -> trackingEventProcessor.metricsCollector "Publica métricas de lógica de negocio" "Prometheus" "001 - Fase 1"
    trackingEventProcessor.trackingEventRepository -> trackingEventProcessor.metricsCollector "Publica métricas de persistencia" "Prometheus" "001 - Fase 1"
    trackingEventProcessor.reliableDownstreamPublisher -> trackingEventProcessor.metricsCollector "Publica métricas de throughput downstream" "Prometheus" "001 - Fase 1"
    trackingEventProcessor.processorConfigurationProvider -> trackingEventProcessor.metricsCollector "Publica métricas de cache" "Prometheus" "001 - Fase 1"
    trackingEventProcessor.processorTenantConfigRepository -> trackingEventProcessor.metricsCollector "Publica métricas de configuración por tenant" "Prometheus" "001 - Fase 1"
    trackingEventProcessor.dynamicConfigProcessor -> trackingEventProcessor.metricsCollector "Publica métricas de configuración dinámica" "Prometheus" "001 - Fase 1"
    trackingEventProcessor.healthCheck -> trackingEventProcessor.metricsCollector "Publica métricas de health status" "Prometheus" "001 - Fase 1"

    // Observabilidad cross-cutting
    trackingEventProcessor.structuredLogger -> trackingEventProcessor.metricsCollector "Correlaciona logs y métricas" "In-Memory" "001 - Fase 1"

    // ========================================
    // RELACIONES EXTERNAS - OBSERVABILIDAD
    // ========================================

    // Métricas
    trackAndTrace.trackingAPI.metricsCollector -> observabilitySystem.metricsCollector "Expone métricas de performance API" "HTTP" "001 - Fase 1"
    trackAndTrace.trackingEventProcessor.metricsCollector -> observabilitySystem.metricsCollector "Expone métricas de procesamiento" "HTTP" "001 - Fase 1"

    // Health Checks
    trackAndTrace.trackingAPI.healthCheck -> observabilitySystem.metricsCollector "Expone health checks API" "HTTP" "001 - Fase 1"
    trackAndTrace.trackingEventProcessor.healthCheck -> observabilitySystem.metricsCollector "Expone health checks Processor" "HTTP" "001 - Fase 1"

    // Logs estructurados
    trackAndTrace.trackingAPI.structuredLogger -> observabilitySystem.logAggregator "Envía logs estructurados API" "HTTP" "001 - Fase 1"
    trackAndTrace.trackingEventProcessor.structuredLogger -> observabilitySystem.logAggregator "Envía logs estructurados Processor" "HTTP" "001 - Fase 1"

    // Tracing distribuido (Fase 2)
    trackAndTrace.trackingAPI.structuredLogger -> observabilitySystem.tracingPlatform "Envía trazas distribuidas API" "OpenTelemetry" "002 - Fase 2"
    trackAndTrace.trackingEventProcessor.structuredLogger -> observabilitySystem.tracingPlatform "Envía trazas distribuidas Processor" "OpenTelemetry" "002 - Fase 2"
}
