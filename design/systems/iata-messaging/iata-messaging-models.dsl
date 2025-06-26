iataMessaging = softwareSystem "IATA Messaging System" {
    description "Gestiona la mensajería IATA para los diferentes países"
    tags "IATA Messaging" "001 - Fase 1"

    api = application "IATA Messaging API" {
        technology "C#"
        description "API REST para consultas y configuración de mensajería IATA"
        tags "CSharp" "001 - Fase 1"

        controller = component "Controller" {
            technology "C#"
            description "Controlador de la API REST para consultas y configuración"

            // appPeru -> this "Consulta estado de mensajes IATA" "HTTPS via API Gateway"
            // appEcuador -> this "Consulta estado de mensajes IATA" "HTTPS via API Gateway"
            // appColombia -> this "Consulta estado de mensajes IATA" "HTTPS via API Gateway"
            // appMexico -> this "Consulta estado de mensajes IATA" "HTTPS via API Gateway"
        }

        service = component "Service" {
            technology "C#"
            description "Gestiona la validación y generación de archivos en formato IATA"

            controller -> this "usa"
        }

        repository = component "Repository" {
            technology "C#"
            description "Almacena los mensajes IATA generados"

            this -> service "usa"
        }

        validator = component "Validator" {
            technology "C#"
            description "Valida los mensajes IATA"

            this -> service "usa"
        }

        generator = component "File Generator" {
            technology "C#"
            description "Generador de mensajes IATA"

            this -> service "usa"
        }

        fileManager = component "File Manager" {
            technology "C#"
            description "Gestiona la carga, eliminación y consulta de archivos"

            this -> service "usa"
        }

        configController = component "Configurations Controller" {
            technology "C#"
            description "Controlador de la API REST para la gestión de configuraciones"
        }

        configService = component "Configuration Service" {
            technology "C#"
            description "Gestiona la lógica de negocio para la gestión de configuraciones"

            configController -> this "usa"
        }

        configRepository = component "Configuration Repository" {
            technology "C#"
            description "Almacena las configuraciones de los mensajes IATA"

            configService -> this "usa"
        }

        apiGateway.yarp.authorization -> controller "Redirige solicitudes a" "HTTPS" "001 - Fase 1"
    }

    // Nuevo worker para procesar eventos IATA
    eventProcessor = container "IATA Event Processor" {
        technology "C#, .NET Worker Service"
        description "Procesa eventos de generación de mensajes IATA"
        tags "CSharp" "001 - Fase 1"

        eventConsumer = component "Event Consumer" {
            technology "C#, RabbitMQ Client"
            description "Consume eventos de la cola de mensajes de Track & Trace"
            tags "001 - Fase 1"

            // this -> trackAndTrace.eventsQueue "Consume eventos de seguimiento" "RabbitMQ"
        }

        eventHandler = component "Event Handler" {
            technology "C#"
            description "Procesa los eventos recibidos y genera mensajes IATA"
            tags "001 - Fase 1"

            eventConsumer -> this "Envía eventos para procesar" "" "001 - Fase 1"
            // this -> api.service "Solicita generación de mensajes IATA"
        }

        service = component "Service" {
            technology "C#"
            description "Gestiona la validación y generación de archivos en formato IATA"
            tags "001 - Fase 1"

            eventHandler -> this "usa" "" "001 - Fase 1"
        }

        repository = component "Repository" {
            technology "C#"
            description "Almacena los mensajes IATA generados"
            tags "001 - Fase 1"

            this -> service "usa" "" "001 - Fase 1"
            // this -> db "Almacena datos de mensajes IATA"
        }

        validator = component "Validator" {
            technology "C#"
            description "Valida los mensajes IATA"
            tags "001 - Fase 1"

            this -> service "usa" "" "001 - Fase 1"
        }

        generator = component "File Generator" {
            technology "C#"
            description "Generador de mensajes IATA"
            tags "001 - Fase 1"

            this -> service "usa" "" "001 - Fase 1"
        }

        fileManager = component "File Manager" {
            technology "C#"
            description "Gestiona la carga, eliminación y consulta de archivos"
            tags "001 - Fase 1"

            this -> service "usa" "" "001 - Fase 1"
        }
    }

    scheduler = application "IATA Scheduler" {
        technology "C#, .NET 8, Hangfire"
        description "Dispara procesos de generación IATA automáticos según configuración"
        tags "CSharp" "001 - Fase 1"
    }

    db = store "IATA Messaging DB" {
        technology "PostgreSQL"
        description "Almacena logs de mensajes, usuarios, aerolíneas, configuración"
        tags "Database" "PostgreSQL" "001 - Fase 1"

        eventProcessor.repository -> this "Almacena datos de mensajes IATA" "" "001 - Fase 1"
        api.configRepository -> this "Almacena configuraciones" "" "001 - Fase 1"
    }

    fileStorage = store "IATA File Storage" {
        technology "AWS S3"
        description "Almacena los archivos IATA generados"
        tags "File Storage" "AWS S3" "001 - Fase 1"

        eventProcessor.fileManager -> this "Sube archivos generados" "" "001 - Fase 1"
    }

    sender = container "IATA Messaging Sender" {
        technology "C#"
        description "Envía archivos generados a los partners"
        tags "CSharp"

        worker = component "Worker" {
            technology "C#"
            description "Ejecuta tareas periódicas para el envío de mensajes IATA"
            tags "001 - Fase 1"
        }

        messageService = component "Message Service" {
            technology "C#"
            description "Gestiona el envío de mensajes IATA"
            tags "001 - Fase 1"

            worker -> this "usa" "" "001 - Fase 1"
        }

        messageRepository = component "Message Repository" {
            technology "C#"
            description "Obtiene los mensajes IATA generados"
            tags "001 - Fase 1"

            messageService -> this "usa" "" "001 - Fase 1"
            this -> db "Obtiene mensajes IATA" "" "001 - Fase 1"
        }

        fileFetcher = component "File Fetcher" {
            technology "C#"
            description "Gestiona la descarga de archivos IATA generados"
            tags "001 - Fase 1"

            messageService -> this "usa" "" "001 - Fase 1"
            this -> fileStorage "Obtiene archivos IATA" "HTTPS" "001 - Fase 1"
        }

        messageSender = component "Message Sender" {
            technology "C#"
            description "Envía archivos generados a los partners"
            tags "001 - Fase 1"

            messageService -> this "usa"
            this -> airlines "Envía archivos IATA" "Via Email \n(Notification System)" "001 - Fase 1"
            this -> descartes "Envía archivos IATA" "" "001 - Fase 1"
        }
    }

    admin -> api.configController "Gestiona configuraciones" "HTTPS via API Gateway" "001 - Fase 1"
}
