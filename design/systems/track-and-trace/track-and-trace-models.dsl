trackAndTrace = softwareSystem "Track & Trace System" {
    description "Sistema corporativo de trazabilidad multitenant para equipaje, carga y pasajeros con procesamiento de eventos en tiempo real."
    tags "Track & Trace" "001 - Fase 1"

    trackingEventQueue = store "Tracking Event Queue" {
        description "Cola que desacopla la recepción de eventos de tracking del procesamiento asíncrono."
        technology "AWS SQS"
        tags "Message Bus" "SQS" "001 - Fase 1"
    }

    trackingIngestAPI = container "Tracking Ingest API" {
        description "API REST para recepción de eventos de tracking desde sistemas externos y publicación en cola de procesamiento."
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

        tenantSettingsRepository = component "TenantSettings Repository" {
            technology "C#, .NET 8, EF Core"
            description "Gestiona configuraciones por tenant del sistema"
            tags "Repository" "TenantSettings"
        }

        secretsAndConfigs = component "SecretsAndConfigs (Cross-Cutting)" {
            technology "NuGet (AWS Secrets Manager, AppConfig)"
            description "Provee acceso centralizado a configuraciones y secretos"
            tags "Configuration" "Cross-Cutting"
        }

        observability = component "Observability\n(Cross-Cutting)" {
            technology "NuGet (Serilog, Prometheus, HealthChecks)"
            description "Provee logging estructurado, métricas y health checks"
            tags "Observability" "Cross-Cutting"
        }
    }

    trackingQueryAPI = container "Tracking Query API" {
        description "API REST de consulta de estado actual e historial de eventos de tracking."
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

        tenantSettingsRepository = component "TenantSettings Repository" {
            technology "C#, .NET 8, EF Core"
            description "Gestiona configuraciones por tenant del sistema"
            tags "Repository" "TenantSettings"
        }

        secretsAndConfigs = component "SecretsAndConfigs (Cross-Cutting)" {
            technology "NuGet (AWS Secrets Manager, AppConfig)"
            description "Provee acceso centralizado a configuraciones y secretos"
            tags "Configuration" "Cross-Cutting"
        }

        observability = component "Observability\n(Cross-Cutting)" {
            technology "NuGet (Serilog, Prometheus, HealthChecks)"
            description "Provee logging estructurado, métricas y health checks"
            tags "Observability" "Cross-Cutting"
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

        tenantSettingsRepository = component "TenantSettings Repository" {
            technology "C#, .NET 8, EF Core"
            description "Gestiona configuraciones por tenant del sistema"
            tags "Repository" "TenantSettings"
        }

        secretsAndConfigs = component "SecretsAndConfigs (Cross-Cutting)" {
            technology "NuGet (AWS Secrets Manager, AppConfig)"
            description "Provee acceso centralizado a configuraciones y secretos"
            tags "Configuration" "Cross-Cutting"
        }

        observability = component "Observability\n(Cross-Cutting)" {
            technology "NuGet (Serilog, Prometheus, HealthChecks)"
            description "Provee logging estructurado, métricas y health checks"
            tags "Observability" "Cross-Cutting"
        }
    }

    trackingDashboard = container "Tracking Web" {
        description "Interfaz web reactiva para visualización en tiempo real del estado de tracking y análisis de eventos."
        technology "React, TypeScript"
        tags "Web App" "001 - Fase 1"
    }

    trackingDatabase = store "Tracking Database" {
        description "Almacena eventos, estados de tracking y configuraciones por tenant."
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
    trackingQueryAPI.trackingDataRepository -> trackingDatabase "Lee datos de trazabilidad" "EF Core/PostgreSQL" "001 - Fase 1"

    // // Query API - Configuración
    // trackingQueryAPI.queryTenantConfigRepository -> trackingDatabase "Lee configuración por tenant" "EF Core" "001 - Fase 1"

    // Event Processor - Flujo principal
    trackingEventProcessor.trackingEventConsumer -> trackingEventQueue "Consume eventos" "" "001 - Fase 1"
    trackingEventProcessor.downstreamEventPublisher -> sitaMessaging.sitaQueue "Publica eventos" "fan-out vía SNS" "001 - Fase 1"

    // Event Processor - Configuración y datos
    trackingEventProcessor.trackingEventRepository -> trackingDatabase "Lee y escribe datos" "EF Core/PostgreSQL" "001 - Fase 1"
    // trackingEventProcessor.processorTenantConfigRepository -> trackingDatabase "Lee configuración por tenant" "EF Core" "001 - Fase 1"

    // ========================================
    // RELACIONES EXTERNAS - ACTORES
    // ========================================

    // Aplicaciones por país - Registro de eventos
    appPeru -> trackingIngestAPI.trackingEventController "Registra eventos" "HTTPS via API Gateway" "001 - Fase 1"
    appEcuador -> trackingIngestAPI.trackingEventController "Registra eventos" "HTTPS via API Gateway" "001 - Fase 1"
    appColombia -> trackingIngestAPI.trackingEventController "Registra eventos" "HTTPS via API Gateway" "001 - Fase 1"
    appMexico -> trackingIngestAPI.trackingEventController "Registra eventos" "HTTPS via API Gateway" "001 - Fase 1"

    // // Aplicaciones por país - Consulta de estado
    // appPeru -> trackingQueryAPI.trackingQueryController "Consulta estado e historial" "HTTPS via API Gateway" "001 - Fase 1"
    // appEcuador -> trackingQueryAPI.trackingQueryController "Consulta estado e historial" "HTTPS via API Gateway" "001 - Fase 1"
    // appColombia -> trackingQueryAPI.trackingQueryController "Consulta estado e historial" "HTTPS via API Gateway" "001 - Fase 1"
    // appMexico -> trackingQueryAPI.trackingQueryController "Consulta estado e historial" "HTTPS via API Gateway" "001 - Fase 1"

    // Usuario operacional
    operationalUser -> trackingDashboard "Consulta trazabilidad" "" "001 - Fase 1"
    trackingDashboard -> trackingQueryAPI.trackingQueryController "Consulta datos de trazabilidad" "HTTPS" "001 - Fase 1"

    // ========================================
    // RELACIONES EXTERNAS - SISTEMAS
    // ========================================

    // Integración con plataforma de configuración
    trackingIngestAPI.secretsAndConfigs -> configPlatform.configService "Lee configuraciones y secretos" "" "001 - Fase 1"
    trackingQueryAPI.secretsAndConfigs -> configPlatform.configService "Lee configuraciones y secretos" "" "001 - Fase 1"
    trackingEventProcessor.secretsAndConfigs -> configPlatform.configService "Lee configuraciones y secretos" "" "001 - Fase 1"

    // Integración con API Gateway
    apiGateway.reverseProxyGateway.resilienceMiddleware -> trackingIngestAPI.trackingEventController "Redirige solicitudes a" "HTTPS" "001 - Fase 1"
    apiGateway.reverseProxyGateway.resilienceMiddleware -> trackingQueryAPI.trackingQueryController "Redirige solicitudes a" "HTTPS" "001 - Fase 1"

    // ========================================
    // RELACIONES ENTRE COMPONENTES INTERNOS
    // ========================================

    // Ingest API - Flujo principal
    trackingIngestAPI.trackingEventController -> trackingIngestAPI.trackingEventService "Valida y procesa evento recibido" "" "001 - Fase 1"
    trackingIngestAPI.trackingEventService -> trackingIngestAPI.trackingEventPublisher "Publica evento en cola" "SQS" "001 - Fase 1"
    trackingIngestAPI.trackingEventService -> trackingIngestAPI.tenantSettingsRepository "Consulta configuración por tenant" "" "001 - Fase 1"
    trackingIngestAPI.tenantSettingsRepository -> trackingDatabase "Lee configuraciones de tenant" "EF Core/PostgreSQL" "001 - Fase 1"

    // // Ingest API - Configuración
    // trackingIngestAPI.ingestConfigurationManager -> trackingIngestAPI.ingestTenantConfigRepository "Lee configuración por tenant" "EF Core" "001 - Fase 1"

    // Query API - Flujo principal
    trackingQueryAPI.trackingQueryController -> trackingQueryAPI.trackingQueryService "Orquesta consulta de tracking" "" "001 - Fase 1"
    trackingQueryAPI.trackingQueryService -> trackingQueryAPI.trackingDataRepository "Accede a datos de tracking" "" "001 - Fase 1"
    trackingQueryAPI.trackingQueryService -> trackingQueryAPI.tenantSettingsRepository "Consulta configuración por tenant" "" "001 - Fase 1"
    trackingQueryAPI.tenantSettingsRepository -> trackingDatabase "Lee configuraciones de tenant" "EF Core/PostgreSQL" "001 - Fase 1"

    // // Query API - Relaciones internas
    // trackingQueryAPI.queryConfigurationManager -> trackingQueryAPI.queryTenantConfigRepository "Lee configuración por tenant" "EF Core" "001 - Fase 1"

    // Event Processor - Flujo principal
    trackingEventProcessor.trackingEventConsumer -> trackingEventProcessor.trackingEventHandler "Entrega evento para validación" "" "001 - Fase 1"
    trackingEventProcessor.trackingEventHandler -> trackingEventProcessor.trackingProcessingService "Aplica reglas de negocio" "" "001 - Fase 1"
    trackingEventProcessor.trackingProcessingService -> trackingEventProcessor.trackingEventRepository "Persiste evento procesado" "" "001 - Fase 1"
    trackingEventProcessor.trackingProcessingService -> trackingEventProcessor.downstreamEventPublisher "Publica evento downstream" "SNS" "001 - Fase 1"
    trackingEventProcessor.trackingProcessingService -> trackingEventProcessor.tenantSettingsRepository "Consulta configuración por tenant" "" "001 - Fase 1"
    trackingEventProcessor.tenantSettingsRepository -> trackingDatabase "Lee configuraciones de tenant" "EF Core/PostgreSQL" "001 - Fase 1"

    // // Event Processor - Configuración
    // trackingEventProcessor.processorConfigurationManager -> trackingEventProcessor.processorTenantConfigRepository "Lee configuración por tenant" "EF Core" "001 - Fase 1"
    trackingIngestAPI.observability  -> observabilitySystem "Envía logs, métricas y health checks" "HTTPS/REST" "001 - Fase 1"
    trackingQueryAPI.observability  -> observabilitySystem "Envía logs, métricas y health checks" "HTTPS/REST" "001 - Fase 1"
    trackingEventProcessor.observability  -> observabilitySystem "Envía logs, métricas y health checks" "HTTPS/REST" "001 - Fase 1"
}
