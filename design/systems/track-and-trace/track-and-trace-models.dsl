trackAndTrace = softwareSystem "Track & Trace System" {
    description "Sistema de trazabilidad multitenant con eventos en tiempo real"
    tags "Track & Trace" "001 - Fase 1"

    // ========================================
    // DATA STORES - ARQUITECTURA SIMPLE
    // ========================================

    trackingDatabase = store "Tracking Database" {
        description "PostgreSQL con esquemas separados para negocio y messaging"
        technology "PostgreSQL"
        tags "Database" "PostgreSQL" "001 - Fase 1"

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

        outboxTable = component "Outbox Table" {
            technology "PostgreSQL Table"
            description "Tabla de outbox pattern para publicación transaccional"
            tags "Database Table" "Outbox Pattern" "001 - Fase 1"
        }
    }

    // ========================================
    // API UNIFICADA CON CQRS LÓGICO
    // ========================================

    trackingAPI = container "Tracking API" {
        description "API REST unificada para ingesta y consulta con CQRS interno"
        technology "C#, ASP.NET Core, REST API"
        tags "CSharp" "Unified API" "001 - Fase 1"

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

        trackingIngestService = component "Tracking Ingest Service" {
            technology "C#, .NET 8, EF Core"
            description "Valida, enriquece y persiste eventos de tracking por tenant"
            tags "Service" "Command" "001 - Fase 1"
        }

        trackingQueryService = component "Tracking Query Service" {
            technology "C#, .NET 8, EF Core"
            description "Ejecuta consultas de estado y historial con filtros por tenant"
            tags "Service" "Query" "001 - Fase 1"
        }

        reliableEventPublisher = component "Reliable Event Publisher" {
            technology "C#, .NET 8, PostgreSQL"
            description "Publica eventos a downstream con garantía transaccional"
            tags "Messaging" "001 - Fase 1"
        }

        trackingRepository = component "Tracking Repository" {
            technology "C#, .NET 8, EF Core"
            description "Gestiona persistencia de eventos y consultas de estado"
            tags "EF Core" "001 - Fase 1"
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
            description "Recolecta métricas unificadas"
            tags "Observability" "001 - Fase 1"
        }

        structuredLogger = component "Structured Logger" {
            technology "Serilog"
            description "Logging estructurado unificado"
            tags "Observability" "001 - Fase 1"
        }
    }

    // ========================================
    // EVENT PROCESSOR - PROCESAMIENTO ASÍNCRONO
    // ========================================

    trackingEventProcessor = container "Tracking Event Processor" {
        description "Procesador de eventos que consume, valida, enriquece y almacena eventos"
        technology "C#, ASP.NET Core"
        tags "CSharp" "001 - Fase 1"

        reliableEventConsumer = component "Reliable Event Consumer" {
            technology "C#, .NET 8, PostgreSQL"
            description "Consume eventos con retry automático y manejo de errores"
            tags "Messaging" "001 - Fase 1"
        }

        trackingEventHandler = component "Tracking Event Handler" {
            technology "C#, .NET 8"
            description "Deserializa y valida formato de eventos recibidos"
            tags "Event Handler" "001 - Fase 1"
        }

        trackingProcessingService = component "Tracking Processing Service" {
            technology "C#, .NET 8"
            description "Enriquece eventos con datos de contexto y reglas de negocio"
            tags "Business Logic" "001 - Fase 1"
        }

        trackingEventRepository = component "Tracking Event Repository" {
            technology "C#, .NET 8, EF Core"
            description "Persiste eventos procesados y mantiene historial de cambios"
            tags "EF Core" "001 - Fase 1"
        }

        reliableDownstreamPublisher = component "Reliable Downstream Publisher" {
            technology "C#, .NET 8, PostgreSQL"
            description "Publica eventos procesados a sistemas downstream con garantía de entrega"
            tags "Messaging" "001 - Fase 1"
        }

        configManager = component "Configuration Manager" {
            technology "C#, .NET 8, EF Core"
            description "Gestiona configuraciones del servicio y por tenant"
            tags "Configuration" "Multi-Tenant" "001 - Fase 1"
        }

        // Observabilidad esencial
        healthCheck = component "Health Check" {
            technology "ASP.NET Core Health Checks"
            description "Monitoreo de salud del Processor"
            tags "Observability" "001 - Fase 1"
        }

        metricsCollector = component "Metrics Collector" {
            technology "Prometheus.NET"
            description "Recolecta métricas de procesamiento"
            tags "Observability" "001 - Fase 1"
        }

        structuredLogger = component "Structured Logger" {
            technology "Serilog"
            description "Logging estructurado con correlación"
            tags "Observability" "001 - Fase 1"
        }
    }

    trackingDashboard = container "Tracking Dashboard" {
        description "Dashboard web para consulta de estado y análisis de eventos en tiempo real"
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
    // RELACIONES INTERNAS DEL SISTEMA
    // ========================================

    // API Unificada - Flujo de ingesta (Command side)
    trackingAPI.trackingIngestController -> trackingAPI.trackingIngestService "Delega ingesta de eventos" "C#" "001 - Fase 1"
    trackingAPI.trackingIngestService -> trackingAPI.trackingRepository "Persiste eventos" "EF Core" "001 - Fase 1"
    trackingAPI.trackingIngestService -> trackingAPI.reliableEventPublisher "Publica eventos confiables" "C#" "001 - Fase 1"
    trackingAPI.reliableEventPublisher -> trackingDatabase.outboxTable "Publica eventos ACID" "PostgreSQL Outbox" "001 - Fase 1"
    trackingAPI.trackingRepository -> trackingDatabase.businessSchema "Persiste en esquema de negocio" "EF Core" "001 - Fase 1"

    // API Unificada - Flujo de consulta (Query side)
    trackingAPI.trackingQueryController -> trackingAPI.trackingQueryService "Delega consultas" "C#" "001 - Fase 1"
    trackingAPI.trackingQueryService -> trackingAPI.trackingRepository "Consulta datos optimizados" "EF Core" "001 - Fase 1"

    // API - Uso de configuración (vía DI, no acceso directo)
    // Nota: Servicios reciben IConfigurationService por constructor
    trackingAPI.trackingIngestService -> trackingDatabase.businessSchema "Lee configuración de validación por tenant" "PostgreSQL" "001 - Fase 1"
    trackingAPI.trackingQueryService -> trackingDatabase.businessSchema "Lee configuración de consultas por tenant" "PostgreSQL" "001 - Fase 1"
    trackingAPI.reliableEventPublisher -> trackingDatabase.businessSchema "Lee configuración de publicación" "PostgreSQL" "001 - Fase 1"

    // API - Configuración externa (solo configManager accede directamente)
    trackingAPI.configManager -> configPlatform.configService "Obtiene configuración externa" "HTTPS/REST" "001 - Fase 1"
    trackingAPI.configManager -> trackingDatabase.businessSchema "Lee metadatos estáticos tenant" "PostgreSQL" "001 - Fase 1"

    // Event Processor - Flujo principal
    trackingEventProcessor.reliableEventConsumer -> trackingDatabase.messagingSchema "Consume eventos confiables" "PostgreSQL" "001 - Fase 1"
    trackingEventProcessor.reliableEventConsumer -> trackingEventProcessor.trackingEventHandler "Delega manejo de eventos" "C#" "001 - Fase 1"
    trackingEventProcessor.trackingEventHandler -> trackingEventProcessor.trackingProcessingService "Procesa lógica de negocio" "C#" "001 - Fase 1"
    trackingEventProcessor.trackingProcessingService -> trackingEventProcessor.trackingEventRepository "Persiste eventos procesados" "EF Core" "001 - Fase 1"
    trackingEventProcessor.trackingProcessingService -> trackingEventProcessor.reliableDownstreamPublisher "Publica a downstream" "C#" "001 - Fase 1"
    trackingEventProcessor.trackingEventRepository -> trackingDatabase.businessSchema "Persiste en esquema de negocio" "EF Core" "001 - Fase 1"
    # trackingEventProcessor.reliableDownstreamPublisher -> trackingDatabase.outboxTable "Publica eventos downstream" "PostgreSQL Outbox" "001 - Fase 1"

    // Event Processor - Uso de configuración (vía DI, no acceso directo)
    // Nota: Servicios reciben IConfigurationService por constructor
    # trackingEventProcessor.trackingProcessingService -> trackingDatabase.businessSchema "Lee reglas de procesamiento por tenant" "PostgreSQL" "001 - Fase 1"
    # trackingEventProcessor.reliableDownstreamPublisher -> trackingDatabase.businessSchema "Lee configuración de destinos downstream" "PostgreSQL" "001 - Fase 1"

    // Event Processor - Configuración externa (solo configManager accede directamente)
    trackingEventProcessor.configManager -> configPlatform.configService "Obtiene configuración externa" "HTTPS/REST" "001 - Fase 1"
    trackingEventProcessor.configManager -> trackingDatabase.businessSchema "Lee metadatos estáticos tenant" "PostgreSQL" "001 - Fase 1"

    trackingEventProcessor.reliableDownstreamPublisher -> sitaMessaging.sitaMessagingDatabase.eventsQueue "Publica eventos SITA" "PostgreSQL Outbox" "001 - Fase 1"

    // ========================================
    // OBSERVABILIDAD - API
    // ========================================

    // Health Checks
    trackingAPI.healthCheck -> trackingDatabase "Ejecuta health check" "PostgreSQL" "001 - Fase 1"

    // Logging estructurado
    trackingAPI.trackingIngestController -> trackingAPI.structuredLogger "Registra operaciones de ingesta" "Serilog" "001 - Fase 1"
    trackingAPI.trackingQueryController -> trackingAPI.structuredLogger "Registra operaciones de consulta" "Serilog" "001 - Fase 1"
    trackingAPI.trackingIngestService -> trackingAPI.structuredLogger "Registra lógica de ingesta" "Serilog" "001 - Fase 1"
    trackingAPI.trackingQueryService -> trackingAPI.structuredLogger "Registra lógica de consulta" "Serilog" "001 - Fase 1"
    trackingAPI.reliableEventPublisher -> trackingAPI.structuredLogger "Registra publicación de eventos" "Serilog" "001 - Fase 1"
    trackingAPI.trackingRepository -> trackingAPI.structuredLogger "Registra operaciones de datos" "Serilog" "001 - Fase 1"
    trackingAPI.healthCheck -> trackingAPI.structuredLogger "Registra health checks" "Serilog" "001 - Fase 1"

    // Métricas
    trackingAPI.trackingIngestController -> trackingAPI.metricsCollector "Publica métricas de ingesta" "Prometheus" "001 - Fase 1"
    trackingAPI.trackingQueryController -> trackingAPI.metricsCollector "Publica métricas de consulta" "Prometheus" "001 - Fase 1"
    trackingAPI.trackingIngestService -> trackingAPI.metricsCollector "Publica métricas de lógica ingesta" "Prometheus" "001 - Fase 1"
    trackingAPI.trackingQueryService -> trackingAPI.metricsCollector "Publica métricas de lógica consulta" "Prometheus" "001 - Fase 1"
    trackingAPI.reliableEventPublisher -> trackingAPI.metricsCollector "Publica métricas de publicación" "Prometheus" "001 - Fase 1"
    trackingAPI.trackingRepository -> trackingAPI.metricsCollector "Publica métricas de datos" "Prometheus" "001 - Fase 1"
    trackingAPI.healthCheck -> trackingAPI.metricsCollector "Publica métricas de health status" "Prometheus" "001 - Fase 1"

    // ========================================
    // OBSERVABILIDAD - EVENT PROCESSOR
    // ========================================

    // Health Checks
    trackingEventProcessor.healthCheck -> trackingDatabase "Ejecuta health check" "PostgreSQL" "001 - Fase 1"

    // Logging estructurado
    trackingEventProcessor.reliableEventConsumer -> trackingEventProcessor.structuredLogger "Registra consumo de eventos" "Serilog" "001 - Fase 1"
    trackingEventProcessor.trackingEventHandler -> trackingEventProcessor.structuredLogger "Registra manejo de eventos" "Serilog" "001 - Fase 1"
    trackingEventProcessor.trackingProcessingService -> trackingEventProcessor.structuredLogger "Registra procesamiento" "Serilog" "001 - Fase 1"
    trackingEventProcessor.trackingEventRepository -> trackingEventProcessor.structuredLogger "Registra persistencia" "Serilog" "001 - Fase 1"
    trackingEventProcessor.reliableDownstreamPublisher -> trackingEventProcessor.structuredLogger "Registra publicación downstream" "Serilog" "001 - Fase 1"
    trackingEventProcessor.healthCheck -> trackingEventProcessor.structuredLogger "Registra health checks" "Serilog" "001 - Fase 1"

    // Métricas
    trackingEventProcessor.reliableEventConsumer -> trackingEventProcessor.metricsCollector "Publica métricas de consumo" "Prometheus" "001 - Fase 1"
    trackingEventProcessor.trackingEventHandler -> trackingEventProcessor.metricsCollector "Publica métricas de manejo" "Prometheus" "001 - Fase 1"
    trackingEventProcessor.trackingProcessingService -> trackingEventProcessor.metricsCollector "Publica métricas de procesamiento" "Prometheus" "001 - Fase 1"
    trackingEventProcessor.trackingEventRepository -> trackingEventProcessor.metricsCollector "Publica métricas de persistencia" "Prometheus" "001 - Fase 1"
    trackingEventProcessor.reliableDownstreamPublisher -> trackingEventProcessor.metricsCollector "Publica métricas downstream" "Prometheus" "001 - Fase 1"
    trackingEventProcessor.healthCheck -> trackingEventProcessor.metricsCollector "Publica métricas de health status" "Prometheus" "001 - Fase 1"

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
