trackAndTrace = softwareSystem "Track & Trace" {
    description "Sistema de trazabilidad para equipaje, carga y pasajeros"

    // Cola de mensajes compartida
    queue = store "Track & Trace Event Queue" {
        description "Cola de mensajes para procesamiento asíncrono de eventos"
        technology "RabbitMQ"
        tags "Message Bus" "RabbitMQ"

        iataMessaging.eventProcessor.eventConsumer -> this "Consume eventos de seguimiento"
    }

    // // Cola de eventos para servicios suscritos
    // eventsQueue = store "Track & Trace Events Queue" {
    //     description "Cola de mensajes para eventos que deben ser procesados por servicios suscritos (IATA, notificaciones, etc.)"
    //     technology "RabbitMQ"
    //     tags "Message Bus" "RabbitMQ"

    //     iataMessaging.eventProcessor.eventConsumer -> this "Consume eventos de seguimiento" "RabbitMQ"
    // }

    // API principal - Punto de entrada para consultas y operaciones
    api = container "Track & Trace API" {
        description "API REST que permite registrar eventos y consultar trazabilidad"
        technology "C#, ASP.NET Core, REST API"
        tags "CSharp"

        // Controladores para diferentes funcionalidades
        eventController = component "Event Controller" {
            technology "ASP.NET Core"
            description "Recibe y procesa eventos de seguimiento desde sistemas externos"

            appPeru -> this "Registra eventos de tracking" "HTTPS via API Gateway"
            appEcuador -> this "Registra eventos de tracking" "HTTPS via API Gateway"
            appColombia -> this "Registra eventos de tracking" "HTTPS via API Gateway"
            appMexico -> this "Registra eventos de tracking" "HTTPS via API Gateway"
        }

        trackingController = component "Tracking Controller" {
            technology "ASP.NET Core"
            description "Expone endpoints para consultas de trazabilidad y estado actual"

            appPeru -> this "Consulta estado actual e historial" "HTTPS via API Gateway"
            appEcuador -> this "Consulta estado actual e historial" "HTTPS via API Gateway"
            appColombia -> this "Consulta estado actual e historial" "HTTPS via API Gateway"
            appMexico -> this "Consulta estado actual e historial" "HTTPS via API Gateway"
        }

        tenantController = component "Tenant Controller" {
            technology "ASP.NET Core"
            description "Gestiona configuraciones específicas por país/tenant"

            admin -> this "Administra configuraciones por país" "HTTPS via API Gateway"
        }

        // Servicios de dominio
        trackingService = component "Tracking Service" {
            technology "C#"
            description "Servicio para consultas de trazabilidad e historial"

            trackingController -> this "Usa"
        }

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

            trackingService -> this "Usa"
            eventProcessorService -> this "Usa"
            tenantService -> this "Usa"
        }

        // Colas y publicación de eventos
        eventPublisher = component "Event Queue Publisher" {
            technology "C#, RabbitMQ Client"
            description "Publica eventos procesados en la cola para procesamiento asíncrono"

            eventProcessorService -> this "Publica eventos validados"
            this -> queue "Publica eventos"
        }

        apiGateway.yarp.authorization -> trackingController "Redirige solicitudes a" "HTTPS"
        apiGateway.yarp.authorization -> eventController "Redirige solicitudes a" "HTTPS"
        apiGateway.yarp.authorization -> tenantController "Redirige solicitudes a" "HTTPS"
    }

    // // Worker para procesamiento asíncrono
    // worker = container "Event Processor Worker" {
    //     description "Procesa eventos de seguimiento de forma asíncrona"
    //     technology "C#, .NET Worker Service"
    //     tags "CSharp"

    //     // Componentes del worker
    //     eventConsumer = component "Event Consumer" {
    //         technology "C#, RabbitMQ Client"
    //         description "Consume eventos de la cola de mensajes"

    //         this -> queue "Consume eventos"
    //     }

    //     eventHandler = component "Event Handler" {
    //         technology "C#"
    //         description "Procesa los eventos recibidos y actualiza el estado de seguimiento"

    //         eventConsumer -> this "Envía eventos para procesar"
    //     }

    //     notificationManager = component "Notification Manager" {
    //         technology "C#"
    //         description "Publica eventos de notificación para que sean procesados por el servicio de notificaciones"

    //         eventHandler -> this "Solicita publicación de eventos de notificación"
    //         this -> eventsQueue "Publica eventos de notificación"
    //     }

    //     iataMessageManager = component "IATA Message Manager" {
    //         technology "C#"
    //         description "Publica eventos para la generación de mensajes IATA"

    //         eventHandler -> this "Solicita publicación de eventos IATA"
    //         this -> eventsQueue "Publica eventos IATA"
    //     }

    //     // Componente de acceso a datos multitenancy para el worker
    //     workerDataAccess = component "Worker Data Access" {
    //         technology "C#, Entity Framework Core"
    //         description "Gestiona conexiones a las bases de datos según el tenant"

    //         eventHandler -> this "Usa para actualizar datos"
    //     }
    // }

    // Dashboards y visualización
    dashboard = container "Track & Trace Monitoreo" {
        description "Interfaz web para visualización de trazabilidad en tiempo real"
        technology "React, TypeScript"
        tags "Web App"

        admin -> this "Visualiza reportes y estado global" "HTTPS"
        // userPeru -> this "Visualiza trazabilidad" "HTTPS"
        // userEcuador -> this "Visualiza trazabilidad" "HTTPS"
        // userColombia -> this "Visualiza trazabilidad" "HTTPS"
        // userMexico -> this "Visualiza trazabilidad" "HTTPS"

        this -> api "Consulta datos de trazabilidad" "HTTPS"
    }

    // Bases de datos por país (multitenencia)
    peruDb = store "Peru Tracking DB" {
        description "Base de datos para datos de tracking de Perú"
        technology "PostgreSQL"
        tags "Database" "PostgreSQL" "Peru"

        api.dataAccessManager -> this "Lee y escribe datos (tenant: PE)"
        iataMessaging.eventProcessor.eventHandler -> this "Lee datos (tenant: PE)"
    }

    ecuadorDb = store "Ecuador Tracking DB" {
        description "Base de datos para datos de tracking de Ecuador"
        technology "PostgreSQL"
        tags "Database" "PostgreSQL" "Ecuador"

        api.dataAccessManager -> this "Lee y escribe datos (tenant: EC)"
        iataMessaging.eventProcessor.eventHandler -> this "Lee datos (tenant: EC)"
    }

    colombiaDb = store "Colombia Tracking DB" {
        description "Base de datos para datos de tracking de Colombia"
        technology "PostgreSQL"
        tags "Database" "PostgreSQL" "Colombia"

        api.dataAccessManager -> this "Lee y escribe datos (tenant: CO)"
        iataMessaging.eventProcessor.eventHandler -> this "Lee datos (tenant: CO)"
    }

    mexicoDb = store "Mexico Tracking DB" {
        description "Base de datos para datos de tracking de México"
        technology "PostgreSQL"
        tags "Database" "PostgreSQL" "Mexico"

        api.dataAccessManager -> this "Lee y escribe datos (tenant: MX)"
        iataMessaging.eventProcessor.eventHandler -> this "Lee datos (tenant: MX)"
    }

    // Base de datos para configuración de tenants
    tenantDb = store "Track & Trace DB" {
        description "Base de datos central para configuración de tenants/países"
        technology "PostgreSQL"
        tags "Database" "PostgreSQL"

        api.tenantService -> this "Lee configuraciones de tenants"
        // iataMessaging.eventProcessor.eventHandler -> this "Consulta configuraciones específicas por país"
    }
}