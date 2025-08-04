trackAndTrace = softwareSystem "Track & Trace System" {
    description "Sistema optimizado de trazabilidad multitenant siguiendo mejores prácticas de la industria."
    tags "Track & Trace" "001 - Fase 1"

    // ========================================
    // DATA STORE - SIMPLIFICADO
    // ========================================

    trackingDatabase = store "Tracking Database" {
        description "PostgreSQL con esquemas optimizados para trazabilidad y reliable messaging."
        technology "PostgreSQL"
        tags "Database" "PostgreSQL" "001 - Fase 1"

        // Componentes esenciales del esquema
        eventsTable = component "Events Table" {
            technology "PostgreSQL Table"
            description "Tabla principal para eventos de tracking con índices optimizados."
            tags "Database Table" "Events" "001 - Fase 1"
        }

        configurationsTable = component "Configurations Table" {
            technology "PostgreSQL Table"
            description "Configuraciones por tenant unificadas."
            tags "Database Table" "Configuration" "001 - Fase 1"
        }

        outboxTable = component "Outbox Table" {
            technology "PostgreSQL Table"
            description "Outbox pattern para reliable messaging."
            tags "Database Table" "Outbox" "001 - Fase 1"
        }
    }

    // ========================================
    // TRACKING API - UNIFICADO Y OPTIMIZADO
    // ========================================

    api = application "Tracking API" {
        technology "ASP.NET Core"
        description "API unificada para ingesta y consulta de eventos de tracking."
        tags "API" "001 - Fase 1"

        // Controladores unificados
        trackingController = component "Tracking Controller" {
            technology "ASP.NET Core"
            description "Endpoints REST para ingesta y consulta: POST /events, GET /events/{id}, GET /status"
            tags "Controller" "001 - Fase 1"
        }

        // Servicios de negocio
        trackingService = component "Tracking Service" {
            technology "C#"
            description "Lógica de negocio unificada para validación, procesamiento y consultas."
            tags "Service" "001 - Fase 1"
        }

        // Background services integrados
        eventProcessor = component "Event Processor" {
            technology "Background Service"
            description "Procesador en background que consume outbox y procesa eventos asincrónicamente."
            tags "Background Service" "001 - Fase 1"
        }

        // Infraestructura unificada
        messagePublisher = component "Message Publisher" {
            technology "Reliable Messaging"
            description "Publisher unificado con outbox pattern."
            tags "Messaging" "001 - Fase 1"
        }

        trackingRepository = component "Tracking Repository" {
            technology "Entity Framework Core"
            description "Repositorio unificado para todas las operaciones de datos."
            tags "Repository" "001 - Fase 1"
        }

        configurationService = component "Configuration Service" {
            technology "IConfigurationProvider"
            description "Servicio unificado de configuración con cache local."
            tags "Configuration" "001 - Fase 1"
        }

        // Observabilidad esencial
        healthCheck = component "Health Check" {
            technology "ASP.NET Core Health Checks"
            description "Health checks unificados: /health, /health/ready"
            tags "Health" "001 - Fase 1"
        }
    }

    // Dashboard opcional (mantenido por simplicidad)
    dashboard = application "Tracking Dashboard" {
        technology "React, TypeScript"
        description "Interfaz web para visualización de tracking."
        tags "Web App" "001 - Fase 1"
    }

    // ========================================
    // RELACIONES INTERNAS - OPTIMIZADAS
    // ========================================

    // Controller flow
    api.trackingController -> api.trackingService "Procesa requests" "C#" "001 - Fase 1"
    api.trackingService -> api.messagePublisher "Publica eventos" "Reliable Messaging" "001 - Fase 1"
    api.trackingService -> api.trackingRepository "Persiste datos" "EF Core" "001 - Fase 1"

    // Background processing
    api.eventProcessor -> trackingDatabase.outboxTable "Consume eventos" "PostgreSQL" "001 - Fase 1"
    api.eventProcessor -> api.trackingRepository "Actualiza estados" "EF Core" "001 - Fase 1"

    // Data access
    api.messagePublisher -> trackingDatabase.outboxTable "Persiste mensajes" "PostgreSQL" "001 - Fase 1"
    api.trackingRepository -> trackingDatabase "Operaciones CRUD" "PostgreSQL" "001 - Fase 1"
    api.configurationService -> configPlatform.configService "Lee configuración" "HTTPS" "001 - Fase 1"

    // Dashboard
    dashboard -> api.trackingController "Consulta datos" "HTTPS" "001 - Fase 1"

    // ========================================
    // RELACIONES EXTERNAS
    // ========================================

    // Aplicaciones por país
    appPeru -> api.trackingController "Registra y consulta eventos" "HTTPS via API Gateway" "001 - Fase 1"
    appEcuador -> api.trackingController "Registra y consulta eventos" "HTTPS via API Gateway" "001 - Fase 1"
    appColombia -> api.trackingController "Registra y consulta eventos" "HTTPS via API Gateway" "001 - Fase 1"
    appMexico -> api.trackingController "Registra y consulta eventos" "HTTPS via API Gateway" "001 - Fase 1"

    // Usuarios
    operationalUser -> dashboard "Consulta trazabilidad" "HTTPS" "001 - Fase 1"

    // Integración con sistemas downstream
    api.eventProcessor -> sitaMessaging.api "Publica eventos downstream" "HTTPS" "001 - Fase 1"
}
