trackAndTrace = softwareSystem "Track & Trace System" {
    description "Sistema corporativo de trazabilidad multitenant para equipaje, carga y pasajeros con procesamiento de eventos en tiempo real."
    tags "Track & Trace" "001 - Fase 1"

    trackingEventQueue = store "Tracking Event Queue" {
        description "Cola de alta disponibilidad que desacopla la recepción de eventos de tracking del procesamiento asíncrono."
        technology "AWS SQS"
        tags "Message Bus" "SQS" "001 - Fase 1"
    }

    trackingIngestAPI = container "Tracking Ingest API" {
        description "API REST de alta concurrencia para recepción de eventos de tracking desde sistemas externos y publicación en cola de procesamiento."
        technology "C#, ASP.NET Core, REST API"
        tags "CSharp" "001 - Fase 1"

        trackingEventController = component "Tracking Event Controller" {
            technology "ASP.NET Core"
            description "Expone endpoints REST optimizados para recepción masiva de eventos de tracking con validación de esquemas."
            tags "001 - Fase 1"
        }

        trackingEventService = component "Tracking Event Service" {
            technology "C#"
            description "Procesa y valida eventos de seguimiento aplicando reglas de negocio y enriquecimiento de datos."
            tags "001 - Fase 1"
        }

        trackingEventPublisher = component "Tracking Event Publisher" {
            technology "C#, AWS SDK (SQS)"
            description "Publica eventos validados en la cola de procesamiento con garantías de entrega y control de duplicados."
            tags "001 - Fase 1"
        }

        // ingestConfigurationManager = component "Ingest Configuration Manager" {
        //     technology "C#, AWS SDK"
        //     description "Gestiona configuraciones dinámicas de ingesta y recupera secretos desde sistemas de configuración externos."
        //     tags "001 - Fase 1"
        // }

        // ingestTenantConfigRepository = component "Ingest Tenant Config Repository" {
        //     technology "C#, EF Core"
        //     description "Gestiona configuraciones específicas por tenant para validación y enriquecimiento de eventos."
        //     tags "EF Core" "001 - Fase 1"
        // }

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

    trackingQueryAPI = container "Tracking Query API" {
        description "API REST de consulta con alta performance para búsqueda de estado actual e historial de eventos de tracking."
        technology "C#, ASP.NET Core, REST API"
        tags "CSharp" "001 - Fase 1"

        trackingQueryController = component "Tracking Query Controller" {
            technology "ASP.NET Core"
            description "Expone endpoints REST optimizados para consultas de trazabilidad con filtrado avanzado y paginación."
            tags "001 - Fase 1"
        }

        trackingQueryService = component "Tracking Query Service" {
            technology "C#"
            description "Orquesta operaciones de consulta complejas y aplica lógica de negocio para filtrado y agregación de datos."
            tags "001 - Fase 1"
        }

        trackingDataRepository = component "Tracking Data Repository" {
            technology "C#, EF Core"
            description "Gestiona acceso optimizado a datos de tracking con índices para consultas rápidas y agregaciones complejas."
            tags "EF Core" "001 - Fase 1"
        }

        // queryConfigurationManager = component "Query Configuration Manager" {
        //     technology "C#, AWS SDK"
        //     description "Gestiona configuraciones dinámicas de consulta y parámetros de rendimiento específicos por tenant."
        //     tags "001 - Fase 1"
        // }

        // queryTenantConfigRepository = component "Query Tenant Config Repository" {
        //     technology "C#, EF Core"
        //     description "Gestiona configuraciones específicas por tenant para autorización y límites de consulta."
        //     tags "EF Core" "001 - Fase 1"
        // }

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

    trackingEventProcessor = container "Tracking Event Processor" {
        description "Procesador de eventos que consume, valida, enriquece y almacena eventos de tracking, publicando eventos relevantes a sistemas downstream."
        technology "C#, ASP.NET Core"
        tags "CSharp" "001 - Fase 1"

        trackingEventConsumer = component "Tracking Event Consumer" {
            technology "C#, AWS SDK (SQS)"
            description "Consume eventos de tracking desde la cola con manejo de errores y reintentos automáticos."
            tags "001 - Fase 1"
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

        downstreamEventPublisher = component "Downstream Event Publisher" {
            technology "C#, AWS SDK (SNS)"
            description "Publica eventos procesados a sistemas downstream con garantías de entrega y control de duplicados."
            tags "001 - Fase 1"
        }

        // processorConfigurationManager = component "Processor Configuration Manager" {
        //     technology "C#, AWS SDK"
        //     description "Gestiona configuraciones dinámicas de procesamiento y parámetros de enriquecimiento por tenant."
        //     tags "001 - Fase 1"
        // }

        // processorTenantConfigRepository = component "Processor Tenant Config Repository" {
        //     technology "C#, EF Core"
        //     description "Gestiona configuraciones específicas por tenant para reglas de procesamiento y enriquecimiento."
        //     tags "EF Core" "001 - Fase 1"
        // }

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

    trackingDashboard = container "Tracking Dashboard" {
        description "Interfaz web reactiva para visualización en tiempo real del estado de tracking y análisis de eventos."
        technology "React, TypeScript"
        tags "Web App" "001 - Fase 1"
    }

    trackingDatabase = store "Tracking Database" {
        description "Base de datos transaccional optimizada para almacenamiento de eventos, estados de tracking y configuraciones por tenant."
        technology "PostgreSQL"
        tags "Database" "PostgreSQL" "001 - Fase 1"
    }

    // ========================================
    // RELACIONES INTERNAS DEL SISTEMA
    // ========================================

    // Ingest API - Flujo principal
    trackingIngestAPI.trackingEventPublisher -> trackingEventQueue "Publica eventos" "" "001 - Fase 1"

    // // Ingest API - Configuración
    // trackingIngestAPI.ingestTenantConfigRepository -> trackingDatabase "Lee configuración por tenant" "" "001 - Fase 1"

    // Query API - Flujo principal
    trackingQueryAPI.trackingDataRepository -> trackingDatabase "Lee datos de trazabilidad" "EF Core" "001 - Fase 1"

    // // Query API - Configuración
    // trackingQueryAPI.queryTenantConfigRepository -> trackingDatabase "Lee configuración por tenant" "EF Core" "001 - Fase 1"

    // Event Processor - Flujo principal
    trackingEventProcessor.trackingEventConsumer -> trackingEventQueue "Consume eventos" "" "001 - Fase 1"
    trackingEventProcessor.downstreamEventPublisher -> sitaMessaging.sitaQueue "Publica eventos" "fan-out vía SNS" "001 - Fase 1"

    // Event Processor - Configuración y datos
    trackingEventProcessor.trackingEventRepository -> trackingDatabase "Lee y escribe datos" "EF Core" "001 - Fase 1"
    // trackingEventProcessor.processorTenantConfigRepository -> trackingDatabase "Lee configuración por tenant" "EF Core" "001 - Fase 1"

    // ========================================
    // RELACIONES EXTERNAS - ACTORES
    // ========================================

    // Aplicaciones por país - Registro de eventos
    appPeru -> trackingIngestAPI.trackingEventController "Registra eventos" "HTTPS via API Gateway" "001 - Fase 1"
    appEcuador -> trackingIngestAPI.trackingEventController "Registra eventos" "HTTPS via API Gateway" "001 - Fase 1"
    appColombia -> trackingIngestAPI.trackingEventController "Registra eventos" "HTTPS via API Gateway" "001 - Fase 1"
    appMexico -> trackingIngestAPI.trackingEventController "Registra eventos" "HTTPS via API Gateway" "001 - Fase 1"

    // Aplicaciones por país - Consulta de estado
    appPeru -> trackingQueryAPI.trackingQueryController "Consulta estado e historial" "HTTPS via API Gateway" "001 - Fase 1"
    appEcuador -> trackingQueryAPI.trackingQueryController "Consulta estado e historial" "HTTPS via API Gateway" "001 - Fase 1"
    appColombia -> trackingQueryAPI.trackingQueryController "Consulta estado e historial" "HTTPS via API Gateway" "001 - Fase 1"
    appMexico -> trackingQueryAPI.trackingQueryController "Consulta estado e historial" "HTTPS via API Gateway" "001 - Fase 1"

    // Usuario operacional
    operationalUser -> trackingDashboard "Consulta trazabilidad" "" "001 - Fase 1"
    trackingDashboard -> trackingQueryAPI "Consulta datos de trazabilidad" "HTTPS" "001 - Fase 1"

    // ========================================
    // RELACIONES EXTERNAS - SISTEMAS
    // ========================================

    // Integración con plataforma de configuración
    trackingIngestAPI.configManager -> configPlatform.configService "Lee configuraciones y secretos" "" "001 - Fase 1"
    trackingIngestAPI.configManager -> trackingDatabase "Lee configuración por tenant" "EF Core" "001 - Fase 1"
    trackingQueryAPI.configManager -> configPlatform.configService "Lee configuraciones y secretos" "" "001 - Fase 1"
    trackingQueryAPI.configManager -> trackingDatabase "Lee configuración por tenant" "EF Core" "001 - Fase 1"
    trackingEventProcessor.configManager -> configPlatform.configService "Lee configuraciones y secretos" "" "001 - Fase 1"
    trackingEventProcessor.configManager -> trackingDatabase "Lee configuración por tenant" "EF Core" "001 - Fase 1"
    // trackingEventProcessor.processorConfigurationManager -> configPlatform.configService "Lee configuraciones y secretos" "" "001 - Fase 1"

    // Integración con API Gateway
    apiGateway.reverseProxyGateway.resilienceHandler -> trackingIngestAPI.trackingEventController "Redirige solicitudes a" "HTTPS" "001 - Fase 1"
    apiGateway.reverseProxyGateway.resilienceHandler -> trackingQueryAPI.trackingQueryController "Redirige solicitudes a" "HTTPS" "001 - Fase 1"

    // ========================================
    // RELACIONES ENTRE COMPONENTES INTERNOS
    // ========================================

    // Ingest API - Flujo principal
    trackingIngestAPI.trackingEventController -> trackingIngestAPI.trackingEventService "Valida y procesa evento recibido" "C#" "001 - Fase 1"
    trackingIngestAPI.trackingEventService -> trackingIngestAPI.trackingEventPublisher "Publica evento en cola" "AWS SQS" "001 - Fase 1"

    // // Ingest API - Configuración
    // trackingIngestAPI.ingestConfigurationManager -> trackingIngestAPI.ingestTenantConfigRepository "Lee configuración por tenant" "EF Core" "001 - Fase 1"

    // Query API - Flujo principal
    trackingQueryAPI.trackingQueryController -> trackingQueryAPI.trackingQueryService "Orquesta consulta de tracking" "C#" "001 - Fase 1"
    trackingQueryAPI.trackingQueryService -> trackingQueryAPI.trackingDataRepository "Accede a datos de tracking" "EF Core" "001 - Fase 1"

    // // Query API - Relaciones internas
    // trackingQueryAPI.queryConfigurationManager -> trackingQueryAPI.queryTenantConfigRepository "Lee configuración por tenant" "EF Core" "001 - Fase 1"

    // Event Processor - Flujo principal
    trackingEventProcessor.trackingEventConsumer -> trackingEventProcessor.trackingEventHandler "Entrega evento para validación" "C#" "001 - Fase 1"
    trackingEventProcessor.trackingEventHandler -> trackingEventProcessor.trackingProcessingService "Aplica reglas de negocio" "C#" "001 - Fase 1"
    trackingEventProcessor.trackingProcessingService -> trackingEventProcessor.trackingEventRepository "Persiste evento procesado" "EF Core" "001 - Fase 1"
    trackingEventProcessor.trackingProcessingService -> trackingEventProcessor.downstreamEventPublisher "Publica evento downstream" "AWS SNS" "001 - Fase 1"

    // // Event Processor - Configuración
    // trackingEventProcessor.processorConfigurationManager -> trackingEventProcessor.processorTenantConfigRepository "Lee configuración por tenant" "EF Core" "001 - Fase 1"

    // Enrutamiento a servicios corporativos
    apiGateway.reverseProxyGateway.resilienceHandler -> trackAndTrace.trackingIngestAPI "Enruta a tracking" "HTTPS" "001 - Fase 1"

    // Health checks de servicios downstream
    apiGateway.reverseProxyGateway.healthCheck -> trackAndTrace.trackingIngestAPI "Verifica disponibilidad" "HTTPS" "001 - Fase 1"
}
