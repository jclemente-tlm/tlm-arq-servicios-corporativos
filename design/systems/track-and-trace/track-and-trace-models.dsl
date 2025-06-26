trackAndTrace = softwareSystem "Track & Trace" {
    description "Sistema de trazabilidad para equipaje, carga y pasajeros"
    tags "Track & Trace" "001 - Fase 1"

    // Cola de mensajes compartida
    queue = store "Event Broadcast Queue" {
        description "Cola de transmisión de eventos para sistemas externos"
        technology "RabbitMQ"
        tags "Message Bus" "RabbitMQ" "001 - Fase 1"

        iataMessaging.eventProcessor.eventConsumer -> this "Consume eventos de seguimiento" "" "001 - Fase 1"
    }

    // Cola de eventos para servicios suscritos
    eventIngestionQueue = store "Event Ingestion Queue" {
        description "Cola que desacopla la recepción de eventos del procesamiento."
        technology "RabbitMQ"
        tags "Message Bus" "RabbitMQ" "001 - Fase 1"

        // iataMessaging.eventProcessor.eventConsumer -> this "Consume eventos de seguimiento" "RabbitMQ"
    }

    // API principal - Punto de entrada para consultas y operaciones
    ingestApi = container "Track Ingest API" {
        description "API REST que recibe eventos de tracking y los publica en la cola de ingesta."
        technology "C#, ASP.NET Core, REST API"
        tags "CSharp" "001 - Fase 1"

        // Controladores para diferentes funcionalidades
        eventController = component "Event Controller" {
            technology "ASP.NET Core"
            description "Expone un endpoint HTTP para recibir eventos externos de tracking"
            tags "001 - Fase 1"

            appPeru -> this "Registra eventos" "HTTPS via API Gateway" "001 - Fase 1"
            appEcuador -> this "Registra eventos" "HTTPS via API Gateway" "001 - Fase 1"
            appColombia -> this "Registra eventos" "HTTPS via API Gateway"
            appMexico -> this "Registra eventos" "HTTPS via API Gateway"
        }

        // tenantController = component "Tenant Controller" {
        //     technology "ASP.NET Core"
        //     description "Gestiona configuraciones específicas por país/tenant"

        //     // admin -> this "Administra configuraciones por país" "HTTPS via API Gateway"
        // }

        // Servicios de dominio
        eventService = component "Event Service" {
            technology "C#"
            description "Valida y encola eventos de seguimiento"
            tags "001 - Fase 1"

            eventController -> this "Usa" "" "001 - Fase 1"
        }

        // tenantService = component "Tenant Service" {
        //     technology "C#"
        //     description "Gestiona configuraciones y metadatos por país"

        //     tenantController -> this "Usa"
        // }

        // // Componentes de acceso a datos multitenancy
        // trackingRepository = component "Data Access Manager" {
        //     technology "C#, Entity Framework Core"
        //     description "Gestiona la conexión a la base de datos correcta según el tenant"

        //     eventService -> this "Usa"
        //     tenantService -> this "Usa"
        // }

        // Colas y publicación de eventos
        eventPublisher = component "Event Publisher" {
            technology "C#, RabbitMQ Client"
            description "Publica los eventos recibidos en una cola de ingesta para ser procesados asincrónicamente"
            tags "001 - Fase 1"

            eventService -> this "Usa" "" "001 - Fase 1"
            this -> eventIngestionQueue "Publica\n eventos" "" "001 - Fase 1"
        }

        configManager = component "Configuration Manager" {
            technology "C#, AWS SDK"
            description "Obtiene configuraciones y secretos desde Configuration Platform"
            tags "001 - Fase 1"

            this -> configPlatform.configService "Lee configuraciones y secretos" "" "001 - Fase 1"
            // eventService -> this "Usa"
            // eventPublisher -> this "Usa"
            // tenantService -> this "Usa"
        }

        apiGateway.yarp.authorization -> eventController "Redirige solicitudes a" "HTTPS" "001 - Fase 1"
        // apiGateway.yarp.authorization -> tenantController "Redirige solicitudes a" "HTTPS"
    }

    // API principal - Punto de entrada para consultas y operaciones
    queryApi = container "Track Query API" {
        description "API REST que permite consultar el estado actual y el historial de eventos"
        technology "C#, ASP.NET Core, REST API"
        tags "CSharp"

        // Controladores para diferentes funcionalidades
        trackingController = component "Tracking Controller" {
            technology "ASP.NET Core"
            description "Expone endpoints para consultas de trazabilidad y estado actual"

            appPeru -> this "Consulta estado e historial" "HTTPS via API Gateway"
            appEcuador -> this "Consulta estado e historial" "HTTPS via API Gateway"
            appColombia -> this "Consulta estado e historial" "HTTPS via API Gateway"
            appMexico -> this "Consulta estado e historial" "HTTPS via API Gateway"
        }

        // Servicios de dominio
        trackingService = component "Tracking Service" {
            technology "C#"
            description "Orquesta las operaciones de consulta y aplica lógica de negocio o filtros"

            trackingController -> this "Usa"
        }

        // Componentes de acceso a datos multitenancy
        trackingRepository = component "Tracking Repository" {
            technology "C#, Entity Framework Core"
            description "Accede a la base de datos para recuperar eventos almacenados"

            trackingService -> this "Usa"
        }

        configManager = component "Configuration Manager" {
            technology "C#, AWS SDK"
            description "Obtiene configuraciones y secretos desde Configuration Platform"

            this -> configPlatform.configService "Lee configuraciones y secretos"
            // trackingService -> this "Usa"
        }

        apiGateway.yarp.authorization -> trackingController "Redirige solicitudes a" "HTTPS"
    }

    // API principal - Punto de entrada para consultas y operaciones
    eventProcessor = container "Event Processor" {
        description "Servicio que valida, enriquece y almacena eventos; publica en la cola de broadcast"
        technology "C#, ASP.NET Core, REST API"
        tags "CSharp" "001 - Fase 1"

        // Consumidores de eventos
        eventConsumer = component "Event Consumer" {
            technology "C#, RabbitMQ Client"
            description "Consume eventos desde la cola de ingesta y los delega para su procesamiento"
            tags "001 - Fase 1"

            this -> eventIngestionQueue "Consume eventos" "" "001 - Fase 1"
        }

        eventHandler = component "Event Handler" {
            technology "C#"
            description "Recibe eventos, aplica validaciones y delega la lógica al servicio correspondiente"
            tags "001 - Fase 1"

            eventConsumer -> this "Envía eventos para procesar" "" "001 - Fase 1"
        }

        // // Servicios de dominio
        // trackingService = component "Tracking Service" {
        //     technology "C#"
        //     description "Servicio para consultas de trazabilidad e historial"

        //     eventHandler -> this "Usa"
        // }

        eventService = component "Event Service" {
            technology "C#"
            description "Contiene la lógica de negocio: enriquece el evento, coordina la persistencia y la publicación"
            tags "001 - Fase 1"

            eventHandler -> this "Usa" "" "001 - Fase 1"
        }

        // Componentes de acceso a datos multitenancy
        eventRepository = component "Event Repository" {
            technology "C#, Entity Framework Core"
            description "Persiste eventos crudos o enriquecidos en la base de datos para trazabilidad y análisis"
            tags "001 - Fase 1"

            // trackingService -> this "Usa"
            eventService -> this "Usa" "" "001 - Fase 1"
        }

        // Colas y publicación de eventos
        eventPublisher = component "Event Publisher" {
            technology "C#, RabbitMQ Client"
            description "Publica eventos enriquecidos a una cola de salida para que otros sistemas los consuman"
            tags "001 - Fase 1"

            // eventProcessorService -> this "Publica eventos validados"
            this -> queue "Publica\n eventos" "" "001 - Fase 1"
            eventService -> this "Usa" "" "001 - Fase 1"
        }

        configManager = component "Configuration Manager" {
            technology "C#, AWS SDK"
            description "Obtiene configuraciones y secretos desde Configuration Platform"
            tags "001 - Fase 1"

            this -> configPlatform.configService "Lee configuraciones y secretos" "" "001 - Fase 1"
            // eventHandler -> this "Usa"
        }
    }

    // Dashboards y visualización
    dashboard = container "Track & Trace Monitoreo" {
        description "Interfaz web para visualización de trazabilidad en tiempo real"
        technology "React, TypeScript"
        tags "Web App"

        operationalUser -> this "Consulta trazabilidad"
        this -> queryApi "Consulta datos de trazabilidad" "HTTPS"
    }

    // // Bases de datos por país (multitenencia)
    // peruDb = store "Peru Tracking DB" {
    //     description "Base de datos para datos de tracking de Perú"
    //     technology "PostgreSQL"
    //     tags "Database" "PostgreSQL" "Peru"

    //     eventProcessor.trackingRepository -> this "Lee y escribe datos (tenant: PE)"
    //     // iataMessaging.eventProcessor.eventHandler -> this "Lee datos (tenant: PE)"
    // }

    // ecuadorDb = store "Ecuador Tracking DB" {
    //     description "Base de datos para datos de tracking de Ecuador"
    //     technology "PostgreSQL"
    //     tags "Database" "PostgreSQL" "Ecuador"

    //     eventProcessor.trackingRepository -> this "Lee y escribe datos (tenant: EC)"
    //     // iataMessaging.eventProcessor.eventHandler -> this "Lee datos (tenant: EC)"
    // }

    // colombiaDb = store "Colombia Tracking DB" {
    //     description "Base de datos para datos de tracking de Colombia"
    //     technology "PostgreSQL"
    //     tags "Database" "PostgreSQL" "Colombia"

    //     eventProcessor.trackingRepository -> this "Lee y escribe datos (tenant: CO)"
    //     // iataMessaging.eventProcessor.eventHandler -> this "Lee datos (tenant: CO)"
    // }

    // mexicoDb = store "Mexico Tracking DB" {
    //     description "Base de datos para datos de tracking de México"
    //     technology "PostgreSQL"
    //     tags "Database" "PostgreSQL" "Mexico"

    //     eventProcessor.trackingRepository -> this "Lee y escribe datos (tenant: MX)"
    //     // iataMessaging.eventProcessor.eventHandler -> this "Lee datos (tenant: MX)"
    // }

    trackAndTraceDb = store "Track & Trace DB" {
        description "Base de datos que almacena todos los eventos y el estado actual de tracking."
        technology "PostgreSQL"
        tags "Database" "PostgreSQL" "001 - Fase 1"

        eventProcessor.eventRepository -> this "Lee y escribe datos" "" "001 - Fase 1"
        queryApi.trackingRepository -> this "Lee datos de trazabilidad"
        // trackingService.trackingRepository -> this "Lee configuraciones"
        // tenantService.trackingRepository -> this "Lee configuraciones"
    }

    // // Base de datos para configuración de tenants
    // configurationService = container "Configuration Service" {
    //     description "Servicio externo que provee configuraciones dinámicas (por tenant/país)"
    //     technology "AWS Parameter Store"
    //     tags "AWS Parameter Store"

    //     ingestApi.tenantService -> this "Lee configuraciones de tenants"
    //     queryApi.trackingService -> this "Lee configuraciones de tenants"
    //     eventProcessor.eventHandler -> this "Lee configuraciones de tenants"

    //     admin -> this "Administra configuraciones por país" "HTTPS via API Gateway"
    //     // iataMessaging.eventProcessor.eventHandler -> this "Consulta configuraciones específicas por país"
    // }
}