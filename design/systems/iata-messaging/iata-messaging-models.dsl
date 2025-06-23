iataMessaging = softwareSystem "IATA Messaging System" {
    description "Gestiona la mensajería IATA para los diferentes países"

    api = application "IATA Messaging API" {
        technology "C#"
        description "API REST para consultas y configuración de mensajería IATA"
        tags "CSharp"

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

        apiGateway.yarp.authorization -> controller "Redirige solicitudes a" "HTTPS"
    }

    // Nuevo worker para procesar eventos IATA
    eventProcessor = container "IATA Event Processor" {
        technology "C#, .NET Worker Service"
        description "Procesa eventos de generación de mensajes IATA"
        tags "CSharp"

        eventConsumer = component "Event Consumer" {
            technology "C#, RabbitMQ Client"
            description "Consume eventos de la cola de mensajes de Track & Trace"

            // this -> trackAndTrace.eventsQueue "Consume eventos de seguimiento" "RabbitMQ"
        }

        eventHandler = component "Event Handler" {
            technology "C#"
            description "Procesa los eventos recibidos y genera mensajes IATA"

            eventConsumer -> this "Envía eventos para procesar"
            // this -> api.service "Solicita generación de mensajes IATA"
        }

        service = component "Service" {
            technology "C#"
            description "Gestiona la validación y generación de archivos en formato IATA"

            eventHandler -> this "usa"
        }

        repository = component "Repository" {
            technology "C#"
            description "Almacena los mensajes IATA generados"

            this -> service "usa"
            // this -> db "Almacena datos de mensajes IATA"
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
    }

    scheduler = application "IATA Scheduler" {
        technology "C#, .NET 8, Hangfire"
        description "Dispara procesos de generación IATA automáticos según configuración"
        tags "CSharp"
    }

    db = store "IATA Messaging DB" {
        technology "PostgreSQL"
        description "Almacena logs de mensajes, usuarios, aerolíneas, configuración"
        tags "Database" "PostgreSQL"

        eventProcessor.repository -> this "Almacena datos de mensajes IATA"
        api.configRepository -> this "Almacena configuraciones"
    }

    fileStorage = store "IATA File Storage" {
        technology "AWS S3"
        description "Almacena los archivos IATA generados"
        tags "File Storage" "AWS S3"

        eventProcessor.fileManager -> this "Sube archivos generados"
    }

    sender = container "IATA Messaging Sender" {
        technology "C#"
        description "Envía archivos generados a los partners"
        tags "CSharp"

        worker = component "Worker" {
            technology "C#"
            description "Ejecuta tareas periódicas para el envío de mensajes IATA"
        }

        messageService = component "Message Service" {
            technology "C#"
            description "Gestiona el envío de mensajes IATA"

            worker -> this "usa"
        }

        messageRepository = component "Message Repository" {
            technology "C#"
            description "Obtiene los mensajes IATA generados"

            messageService -> this "usa"
            this -> db "Obtiene mensajes IATA"
        }

        fileFetcher = component "File Fetcher" {
            technology "C#"
            description "Gestiona la descarga de archivos IATA generados"

            messageService -> this "usa"
            this -> fileStorage "Obtiene archivos IATA" "HTTPS"
        }

        messageSender = component "Message Sender" {
            technology "C#"
            description "Envía archivos generados a los partners"

            messageService -> this "usa"
            this -> airlines "Envía archivos IATA" "Via Email \n(Notification System)"
            this -> descartes "Envía archivos IATA"
        }
    }

    admin -> api.configController "Gestiona configuraciones" "HTTPS via API Gateway"
}
