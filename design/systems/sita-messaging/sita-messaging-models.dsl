sitaMessaging = softwareSystem "SITA Messaging" {
    description "Gestiona la mensajería SITA para los diferentes países"
    tags "SITA Messaging" "001 - Fase 1"

    api = application "SITA Messaging API" {
        technology "C#"
        description "API REST para consultas y configuración de mensajería SITA"
        tags "CSharp" "001 - Fase 1"

        controller = component "Controller" {
            technology "C#"
            description "Controlador de la API REST para consultas y configuración"

            // appPeru -> this "Consulta estado de mensajes SITA" "HTTPS via API Gateway"
            // appEcuador -> this "Consulta estado de mensajes SITA" "HTTPS via API Gateway"
            // appColombia -> this "Consulta estado de mensajes SITA" "HTTPS via API Gateway"
            // appMexico -> this "Consulta estado de mensajes SITA" "HTTPS via API Gateway"
        }

        service = component "Service" {
            technology "C#"
            description "Gestiona la validación y generación de archivos en formato SITA"

            controller -> this "usa"
        }

        repository = component "Repository" {
            technology "C#"
            description "Almacena los mensajes SITA generados"

            this -> service "usa"
        }

        validator = component "Validator" {
            technology "C#"
            description "Valida los mensajes SITA"

            this -> service "usa"
        }

        generator = component "File Generator" {
            technology "C#"
            description "Generador de mensajes SITA"

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
            description "Almacena las configuraciones de los mensajes SITA"

            configService -> this "usa"
        }

        apiGateway.yarp.authorization -> controller "Redirige solicitudes a" "HTTPS" "001 - Fase 1"
    }

    // Nuevo worker para procesar eventos SITA
    eventProcessor = container "SITA Event Processor" {
        technology "C#, .NET Worker Service"
        description "Procesa eventos de generación de mensajes SITA"
        tags "CSharp" "001 - Fase 1"

        eventConsumer = component "Event Consumer" {
            technology "C#, RabbitMQ Client"
            description "Consume eventos de la cola de mensajes de Track & Trace"
            tags "001 - Fase 1"

            // this -> trackAndTrace.eventsQueue "Consume eventos de seguimiento" "RabbitMQ"
        }

        eventHandler = component "Event Handler" {
            technology "C#"
            description "Procesa los eventos recibidos y genera mensajes SITA"
            tags "001 - Fase 1"

            eventConsumer -> this "Envía eventos para procesar" "" "001 - Fase 1"
            // this -> api.service "Solicita generación de mensajes SITA"
        }

        service = component "Service" {
            technology "C#"
            description "Gestiona la validación y generación de archivos en formato SITA"
            tags "001 - Fase 1"

            eventHandler -> this "usa" "" "001 - Fase 1"
        }

        repository = component "Repository" {
            technology "C#"
            description "Almacena los mensajes SITA generados"
            tags "001 - Fase 1"

            this -> service "usa" "" "001 - Fase 1"
            // this -> db "Almacena datos de mensajes SITA"
        }

        validator = component "Validator" {
            technology "C#"
            description "Valida los mensajes SITA"
            tags "001 - Fase 1"

            this -> service "usa" "" "001 - Fase 1"
        }

        generator = component "File Generator" {
            technology "C#"
            description "Generador de mensajes SITA"
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

    scheduler = application "SITA Scheduler" {
        technology "C#, .NET 8, Hangfire"
        description "Dispara procesos de generación SITA automáticos según configuración"
        tags "CSharp" "001 - Fase 1"
    }

    db = store "SITA Messaging DB" {
        technology "PostgreSQL"
        description "Almacena logs de mensajes, usuarios, aerolíneas, configuración"
        tags "Database" "PostgreSQL" "001 - Fase 1"

        eventProcessor.repository -> this "Almacena datos de mensajes SITA" "" "001 - Fase 1"
        api.configRepository -> this "Almacena configuraciones" "" "001 - Fase 1"
    }

    fileStorage = store "SITA File Storage" {
        technology "AWS S3"
        description "Almacena los archivos SITA generados"
        tags "File Storage" "AWS S3" "001 - Fase 1"

        eventProcessor.fileManager -> this "Sube archivos generados" "" "001 - Fase 1"
    }

    sender = container "SITA Messaging Sender" {
        technology "C#"
        description "Envía archivos generados a los partners"
        tags "CSharp"

        worker = component "Worker" {
            technology "C#"
            description "Ejecuta tareas periódicas para el envío de mensajes SITA"
            tags "001 - Fase 1"
        }

        messageService = component "Message Service" {
            technology "C#"
            description "Gestiona el envío de mensajes SITA"
            tags "001 - Fase 1"

            worker -> this "usa" "" "001 - Fase 1"
        }

        messageRepository = component "Message Repository" {
            technology "C#"
            description "Obtiene los mensajes SITA generados"
            tags "001 - Fase 1"

            messageService -> this "usa" "" "001 - Fase 1"
            this -> db "Obtiene mensajes SITA" "" "001 - Fase 1"
        }

        fileFetcher = component "File Fetcher" {
            technology "C#"
            description "Gestiona la descarga de archivos SITA generados"
            tags "001 - Fase 1"

            messageService -> this "usa" "" "001 - Fase 1"
            this -> fileStorage "Obtiene archivos SITA" "HTTPS" "001 - Fase 1"
        }

        messageSender = component "Message Sender" {
            technology "C#"
            description "Envía archivos generados a los partners"
            tags "001 - Fase 1"

            messageService -> this "usa"
            this -> airlines "Envía archivos SITA" "Via Email por\nNotification System" "001 - Fase 1"
            this -> descartes "Envía archivos SITA" "" "001 - Fase 1"
        }
    }

    admin -> api.configController "Gestiona configuraciones" "HTTPS via API Gateway" "001 - Fase 1"
}
