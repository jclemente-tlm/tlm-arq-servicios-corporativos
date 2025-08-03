trackAndTrace = softwareSystem "Track & Trace" {
    description "Sistema corporativo de trazabilidad multitenant para equipaje, carga y pasajeros. Permite el procesamiento, almacenamiento y consulta de eventos clave y estados en los procesos logísticos y de viaje."
    tags "Track & Trace" "001 - Fase 1"

    eventIngestionQueue = store "Event Ingestion Queue" {
        description "Cola que desacopla la recepción de eventos del procesamiento asincrónico."
        technology "AWS SQS"
        tags "Message Bus" "SQS" "001 - Fase 1"
    }

    ingestApi = container "Track Ingest API" {
        description "API REST que recibe eventos de tracking (hitos y eventos relevantes) y los publica en la cola de ingesta para su procesamiento posterior."
        technology "C#, ASP.NET Core, REST API"
        tags "CSharp" "001 - Fase 1"

        eventController = component "Event Controller" {
            technology "ASP.NET Core"
            description "Expone un endpoint HTTP para recibir eventos externos de tracking."
            tags "001 - Fase 1"
        }

        eventService = component "Event Service" {
            technology "C#"
            description "Valida y encola eventos de seguimiento recibidos desde el controlador."
            tags "001 - Fase 1"
        }

        eventPublisher = component "Event Publisher" {
            technology "C#, AWS SDK (SQS)"
            description "Publica los eventos en la cola de ingesta para su procesamiento asíncrono."
            tags "001 - Fase 1"
        }

        configManager = component "Configuration Manager" {
            technology "C#, AWS SDK"
            description "Recupera parámetros y secretos desde el sistema de configuración y accede a configuración por tenant. Usado por otros componentes vía inyección de dependencias."
            tags "001 - Fase 1"
        }

        tenantConfigRepository = component "Tenant Configuration Repository" {
            technology "C#, EF Core"
            description "Accede a la base de datos para recuperar configuración específica de un tenant. Usado exclusivamente por Configuration Manager."
            tags "EF Core" "001 - Fase 1"
        }

        // Componentes de Observabilidad
        healthCheck = component "Health Check" {
            technology "ASP.NET Core Health Checks"
            description "Expone endpoints /health, /health/ready, /health/live para monitoring."
            tags "Observability" "001 - Fase 1"
        }

        metricsCollector = component "Metrics Collector" {
            technology "prometheus-net"
            description "Recolecta métricas: events/sec, processing time, error rates."
            tags "Observability" "001 - Fase 1"
        }

        logger = component "Structured Logger" {
            technology "Serilog"
            description "Logging estructurado con correlationId para trazabilidad."
            tags "Observability" "001 - Fase 1"
        }
    }

    queryApi = container "Track Query API" {
        description "API REST que permite consultar el estado actual y el historial de eventos trazados."
        technology "C#, ASP.NET Core, REST API"
        tags "CSharp" "001 - Fase 1"

        trackingController = component "Tracking Controller" {
            technology "ASP.NET Core"
            description "Expone endpoints para consultas de trazabilidad y estado actual."
        }

        trackingService = component "Tracking Service" {
            technology "C#"
            description "Orquesta las operaciones de consulta y aplica lógica de negocio o filtros."
        }

        trackingRepository = component "Tracking Repository" {
            technology "C#, EF Core"
            description "Accede a la base de datos para recuperar eventos y estados almacenados."
            tags "EF Core"
        }

        configManager = component "Configuration Manager" {
            technology "C#, AWS SDK"
            description "Recupera parámetros y secretos desde el sistema de configuración y accede a configuración por tenant. Usado por otros componentes vía inyección de dependencias."
        }

        tenantConfigRepository = component "Tenant Configuration Repository" {
            technology "C#, EF Core"
            description "Accede a la base de datos para recuperar configuración específica de un tenant. Usado exclusivamente por Configuration Manager."
            tags "EF Core"
        }

        // Componentes de Observabilidad
        healthCheck = component "Health Check" {
            technology "ASP.NET Core Health Checks"
            description "Expone endpoints /health, /health/ready, /health/live para monitoring."
            tags "Observability" "001 - Fase 1"
        }

        metricsCollector = component "Metrics Collector" {
            technology "prometheus-net"
            description "Recolecta métricas: queries/sec, response time, cache hit rate."
            tags "Observability" "001 - Fase 1"
        }

        logger = component "Structured Logger" {
            technology "Serilog"
            description "Logging estructurado con correlationId para trazabilidad."
            tags "Observability" "001 - Fase 1"
        }
    }

    eventProcessor = container "Event Processor" {
        description "Servicio que consume eventos de la cola, los valida, enriquece y almacena; publica eventos relevantes a otros sistemas a través de SNS."
        technology "C#, ASP.NET Core"
        tags "CSharp" "001 - Fase 1"

        eventConsumer = component "Event Consumer" {
            technology "C#, AWS SDK (SQS)"
            description "Consume eventos desde la cola de ingesta y los delega para su procesamiento."
            tags "001 - Fase 1"
        }

        eventHandler = component "Event Handler" {
            technology "C#"
            description "Aplica validaciones a los eventos y los delega al Event Service para procesamiento."
            tags "001 - Fase 1"
        }

        eventService = component "Event Service" {
            technology "C#"
            description "Contiene la lógica de negocio: enriquece, almacena y publica eventos procesados."
            tags "001 - Fase 1"
        }

        eventRepository = component "Event Repository" {
            technology "C#, EF Core"
            description "Persiste eventos crudos y enriquecidos en la base de datos central."
            tags "EF Core" "001 - Fase 1"
        }

        eventPublisher = component "Event Publisher" {
            technology "C#, AWS SDK (SNS)"
            description "Publica eventos enriquecidos en SNS para ser consumidos por otros sistemas."
            tags "001 - Fase 1"
        }

        configManager = component "Configuration Manager" {
            technology "C#, AWS SDK"
            description "Recupera parámetros y secretos desde el sistema de configuración y accede a configuración por tenant. Usado por otros componentes vía inyección de dependencias."
            tags "001 - Fase 1"
        }

        tenantConfigRepository = component "Tenant Configuration Repository" {
            technology "C#, EF Core"
            description "Accede a la base de datos para recuperar configuración específica de un tenant. Usado exclusivamente por Configuration Manager."
            tags "EF Core" "001 - Fase 1"
        }

        // Componentes de Observabilidad
        metricsCollector = component "Metrics Collector" {
            technology "prometheus-net"
            description "Recolecta métricas: events processed/sec, enrichment time, publish success rate."
            tags "Observability" "001 - Fase 1"
        }

        logger = component "Structured Logger" {
            technology "Serilog"
            description "Logging estructurado con correlationId para trazabilidad."
            tags "Observability" "001 - Fase 1"
        }
    }

    dashboard = container "Track & Trace Monitoreo" {
        description "Interfaz web para visualización en tiempo real del estado de tracking y eventos relevantes."
        technology "React, TypeScript"
        tags "Web App"
    }

    trackAndTraceDb = store "Track & Trace DB" {
        description "Base de datos transaccional que almacena eventos, configuraciones por tenant y el estado actual de seguimiento."
        technology "PostgreSQL"
        tags "Database" "PostgreSQL" "001 - Fase 1"
    }

    // Relaciones externas
    // ========================================
    // RELACIONES INTERNAS DEL SISTEMA
    // ========================================

    // Ingest API - Flujo principal
    ingestApi.eventPublisher -> eventIngestionQueue "Publica eventos" "" "001 - Fase 1"

    // Ingest API - Configuración
    ingestApi.tenantConfigRepository -> trackAndTraceDb "Lee configuración por tenant" "" "001 - Fase 1"

    // Query API - Flujo principal
    queryApi.trackingRepository -> trackAndTraceDb "Lee datos de trazabilidad" "EF Core" "001 - Fase 1"

    // Query API - Configuración
    queryApi.tenantConfigRepository -> trackAndTraceDb "Lee configuración por tenant" "EF Core" "001 - Fase 1"

    // Event Processor - Flujo principal
    eventProcessor.eventConsumer -> eventIngestionQueue "Consume eventos" "" "001 - Fase 1"
    eventProcessor.eventPublisher -> sitaMessaging.sitaQueue "Publica eventos" "fan-out vía SNS" "001 - Fase 1"

    // Event Processor - Configuración y datos
    eventProcessor.eventRepository -> trackAndTraceDb "Lee y escribe datos" "EF Core" "001 - Fase 1"
    eventProcessor.tenantConfigRepository -> trackAndTraceDb "Lee configuración por tenant"

    // ========================================
    // RELACIONES EXTERNAS - ACTORES
    // ========================================

    // Aplicaciones por país - Registro de eventos
    appPeru -> ingestApi.eventController "Registra eventos" "HTTPS via API Gateway" "001 - Fase 1"
    appEcuador -> ingestApi.eventController "Registra eventos" "HTTPS via API Gateway" "001 - Fase 1"
    appColombia -> ingestApi.eventController "Registra eventos" "HTTPS via API Gateway"
    appMexico -> ingestApi.eventController "Registra eventos" "HTTPS via API Gateway"

    // Aplicaciones por país - Consulta de estado
    appPeru -> queryApi.trackingController "Consulta estado e historial" "HTTPS via API Gateway" "001 - Fase 1"
    appEcuador -> queryApi.trackingController "Consulta estado e historial" "HTTPS via API Gateway" "001 - Fase 1"
    appColombia -> queryApi.trackingController "Consulta estado e historial" "HTTPS via API Gateway"
    appMexico -> queryApi.trackingController "Consulta estado e historial" "HTTPS via API Gateway"

    // Usuario operacional
    operationalUser -> dashboard "Consulta trazabilidad" "" "001 - Fase 1"
    dashboard -> queryApi "Consulta datos de trazabilidad" "HTTPS" "001 - Fase 1"

    // ========================================
    // RELACIONES EXTERNAS - SISTEMAS
    // ========================================

    // Integración con plataforma de configuración
    ingestApi.configManager -> configPlatform.configService "Lee configuraciones y secretos" "" "001 - Fase 1"
    queryApi.configManager -> configPlatform.configService "Lee configuraciones y secretos" "" "001 - Fase 1"
    eventProcessor.configManager -> configPlatform.configService "Lee configuraciones y secretos" ""  "001 - Fase 1"

    // Integración con API Gateway
    apiGateway.yarp.authorization -> ingestApi.eventController "Redirige solicitudes a" "HTTPS" "001 - Fase 1"
    apiGateway.yarp.authorization -> queryApi.trackingController "Redirige solicitudes a" "HTTPS" "001 - Fase 1"

    // ========================================
    // RELACIONES ENTRE COMPONENTES INTERNOS
    // ========================================

    // Ingest API - Flujo principal
    ingestApi.eventController -> ingestApi.eventService "Usa" "" "001 - Fase 1"
    ingestApi.eventService -> ingestApi.eventPublisher "Usa" "" "001 - Fase 1"

    // Ingest API - Configuración
    ingestApi.configManager -> ingestApi.tenantConfigRepository "Lee configuración por tenant" "EF Core" "001 - Fase 1"

    // Query API - Flujo principal
    queryApi.trackingController -> queryApi.trackingService "Usa" "" "001 - Fase 1"
    queryApi.trackingService -> queryApi.trackingRepository "Usa" "EF Core" "001 - Fase 1"

    // Query API - Configuración
    queryApi.configManager -> queryApi.tenantConfigRepository "Lee configuración por tenant" "EF Core" "001 - Fase 1"

    // Event Processor - Flujo principal
    eventProcessor.eventConsumer -> eventProcessor.eventHandler "Envía eventos para procesar" "" "001 - Fase 1"
    eventProcessor.eventHandler -> eventProcessor.eventService "Usa" "" "001 - Fase 1"
    eventProcessor.eventService -> eventProcessor.eventRepository "Usa" "EF Core" "001 - Fase 1"
    eventProcessor.eventService -> eventProcessor.eventPublisher "Usa" "" "001 - Fase 1"

    // Event Processor - Configuración
    eventProcessor.configManager -> eventProcessor.tenantConfigRepository "Lee configuración por tenant" "EF Core" "001 - Fase 1"
}
