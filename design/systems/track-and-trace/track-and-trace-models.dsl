trackAndTrace = softwareSystem "Track & Trace" {
    description "Sistema de trazabilidad para equipaje, carga y pasajeros"

    // Cola de mensajes compartida
    queue = store "Event Broadcast Queue" {
        description "Cola de transmisión de eventos para sistemas externos"
        technology "RabbitMQ"
        tags "Message Bus" "RabbitMQ"

        iataMessaging.eventProcessor.eventConsumer -> this "Consume eventos de seguimiento"
    }

    // Cola de eventos para servicios suscritos
    eventIngestionQueue = store "Event Ingestion Queue" {
        description "Cola que desacopla la recepción de eventos del procesamiento."
        technology "RabbitMQ"
        tags "Message Bus" "RabbitMQ"

        // iataMessaging.eventProcessor.eventConsumer -> this "Consume eventos de seguimiento" "RabbitMQ"
    }

    // API principal - Punto de entrada para consultas y operaciones
    ingestApi = container "Track Ingest API" {
        description "API REST que recibe eventos de tracking y los publica en la cola de ingesta."
        technology "C#, ASP.NET Core, REST API"
        tags "CSharp"

        // Controladores para diferentes funcionalidades
        eventController = component "Event Controller" {
            technology "ASP.NET Core"
            description "Recibe y procesa eventos de seguimiento desde sistemas externos"

            appPeru -> this "Registra eventos" "HTTPS via API Gateway"
            appEcuador -> this "Registra eventos" "HTTPS via API Gateway"
            appColombia -> this "Registra eventos" "HTTPS via API Gateway"
            appMexico -> this "Registra eventos" "HTTPS via API Gateway"
        }

        tenantController = component "Tenant Controller" {
            technology "ASP.NET Core"
            description "Gestiona configuraciones específicas por país/tenant"

            // admin -> this "Administra configuraciones por país" "HTTPS via API Gateway"
        }

        // Servicios de dominio
        eventProcessorService = component "Event Processor Service" {
            technology "C#"
            description "Valida, transforma y procesa eventos de seguimiento"

            eventController -> this "Usa"
        }

        tenantService = component "Tenant Service" {
            technology "C#"
            description "Gestiona configuraciones y metadatos por país"

            tenantController -> this "Usa"
        }

        // Componentes de acceso a datos multitenancy
        dataAccessManager = component "Data Access Manager" {
            technology "C#, Entity Framework Core"
            description "Gestiona la conexión a la base de datos correcta según el tenant"

            eventProcessorService -> this "Usa"
            tenantService -> this "Usa"
        }

        // Colas y publicación de eventos
        eventPublisher = component "Event Queue Publisher" {
            technology "C#, RabbitMQ Client"
            description "Publica eventos procesados en la cola para procesamiento asíncrono"

            // eventProcessorService -> this "Publica eventos validados"
            this -> eventIngestionQueue "Publica\n eventos"
        }

        configManager = component "Configuration Manager" {
            technology "C#, AWS SDK"
            description "Administra configuraciones dinámicas por tenant"

            this -> configPlatform.configService "Lee configuraciones"
            tenantService -> this "Usa"
        }

        apiGateway.yarp.authorization -> eventController "Redirige solicitudes a" "HTTPS"
        apiGateway.yarp.authorization -> tenantController "Redirige solicitudes a" "HTTPS"
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
            description "Servicio para consultas de trazabilidad e historial"

            trackingController -> this "Usa"
        }

        // Componentes de acceso a datos multitenancy
        dataAccessManager = component "Data Access Manager" {
            technology "C#, Entity Framework Core"
            description "Gestiona la conexión a la base de datos correcta según el tenant"

            trackingService -> this "Usa"
        }

        configManager = component "Configuration Manager" {
            technology "C#, AWS SDK"
            description "Administra configuraciones dinámicas por tenant"

            this -> configPlatform.configService "Lee configuraciones"
            trackingService -> this "Usa"
        }

        apiGateway.yarp.authorization -> trackingController "Redirige solicitudes a" "HTTPS"
    }

    // API principal - Punto de entrada para consultas y operaciones
    eventProcessor = container "Event Processor" {
        description "Servicio que valida, enriquece y almacena eventos; publica en la cola de broadcast.
        technology "C#, ASP.NET Core, REST API"
        tags "CSharp"

        // Consumidores de eventos
        eventConsumer = component "Event Consumer" {
            technology "C#, RabbitMQ Client"
            description "Consume eventos de la cola de mensajes"

            this -> eventIngestionQueue "Consume eventos"
        }

        eventHandler = component "Event Handler" {
            technology "C#"
            description "Procesa los eventos recibidos y actualiza el estado de seguimiento"

            eventConsumer -> this "Envía eventos para procesar"
        }

        // Servicios de dominio
        trackingService = component "Tracking Service" {
            technology "C#"
            description "Servicio para consultas de trazabilidad e historial"

            eventHandler -> this "Usa"
        }

        eventProcessorService = component "Event Processor Service" {
            technology "C#"
            description "Valida, transforma y procesa eventos de seguimiento"

            eventHandler -> this "Usa"
        }

        // Componentes de acceso a datos multitenancy
        dataAccessManager = component "Data Access Manager" {
            technology "C#, Entity Framework Core"
            description "Gestiona la conexión a la base de datos correcta según el tenant"

            trackingService -> this "Usa"
            eventProcessorService -> this "Usa"
        }

        // Colas y publicación de eventos
        eventPublisher = component "Event Queue Publisher" {
            technology "C#, RabbitMQ Client"
            description "Publica eventos procesados en la cola para procesamiento asíncrono"

            eventProcessorService -> this "Publica eventos validados"
            this -> queue "Publica\n eventos"
        }

        configManager = component "Configuration Manager" {
            technology "C#, AWS SDK"
            description "Administra configuraciones dinámicas por tenant"

            this -> configPlatform.configService "Lee configuraciones"
            trackingService -> this "Usa"
            eventProcessorService -> this "Usa"}
        }
    }    

    // Dashboards y visualización
    dashboard = container "Track & Trace Monitoreo" {
        description "Interfaz web para visualización de trazabilidad en tiempo real"
        technology "React, TypeScript"
        tags "Web App"

        operationalUser -> this "Consulta trazabilidad" "HTTPS via API Gateway"
        this -> queryApi "Consulta datos de trazabilidad" "HTTPS"
    }

    // // Bases de datos por país (multitenencia)
    // peruDb = store "Peru Tracking DB" {
    //     description "Base de datos para datos de tracking de Perú"
    //     technology "PostgreSQL"
    //     tags "Database" "PostgreSQL" "Peru"

    //     eventProcessor.dataAccessManager -> this "Lee y escribe datos (tenant: PE)"
    //     // iataMessaging.eventProcessor.eventHandler -> this "Lee datos (tenant: PE)"
    // }

    // ecuadorDb = store "Ecuador Tracking DB" {
    //     description "Base de datos para datos de tracking de Ecuador"
    //     technology "PostgreSQL"
    //     tags "Database" "PostgreSQL" "Ecuador"

    //     eventProcessor.dataAccessManager -> this "Lee y escribe datos (tenant: EC)"
    //     // iataMessaging.eventProcessor.eventHandler -> this "Lee datos (tenant: EC)"
    // }

    // colombiaDb = store "Colombia Tracking DB" {
    //     description "Base de datos para datos de tracking de Colombia"
    //     technology "PostgreSQL"
    //     tags "Database" "PostgreSQL" "Colombia"

    //     eventProcessor.dataAccessManager -> this "Lee y escribe datos (tenant: CO)"
    //     // iataMessaging.eventProcessor.eventHandler -> this "Lee datos (tenant: CO)"
    // }

    // mexicoDb = store "Mexico Tracking DB" {
    //     description "Base de datos para datos de tracking de México"
    //     technology "PostgreSQL"
    //     tags "Database" "PostgreSQL" "Mexico"

    //     eventProcessor.dataAccessManager -> this "Lee y escribe datos (tenant: MX)"
    //     // iataMessaging.eventProcessor.eventHandler -> this "Lee datos (tenant: MX)"
    // }

    trackAndTraceDb = store "Track & Trace DB" {
        description "Base de datos que almacena todos los eventos y el estado actual de tracking."
        technology "PostgreSQL"
        tags "Database" "PostgreSQL"

        eventProcessor.dataAccessManager -> this "Lee y escribe datos"
        queryApi.dataAccessManager -> this "Lee datos de trazabilidad"
        // trackingService.dataAccessManager -> this "Lee configuraciones"
        // tenantService.dataAccessManager -> this "Lee configuraciones"
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