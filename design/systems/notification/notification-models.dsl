notification = softwareSystem "Notification System" {
    description "Gestiona envío de notificaciones por varios canales"
    tags "Notification" "001 - Fase 1"

    api = application "Notification API" {
        technology "C# .NET"
        description "Registra solicitudes de notificaciones y gestiona configuraciones asociadas."
        tags "CSharp" "001 - Fase 1"

        controller = component "Controller" {
            technology "ASP.NET Core, C#"
            description "Expone endpoints para atender solicitudes de envío y consulta de notificaciones."
            tags "001 - Fase 1"

            appPeru -> this "Solicita envío de notificación" "HTTPS vía API Gateway" "001 - Fase 1"
            appEcuador -> this "Solicita envío de notificación" "HTTPS vía API Gateway" "001 - Fase 1"
            appColombia -> this "Solicita envío de notificación" "HTTPS vía API Gateway"
            appMexico -> this "Solicita envío de notificación" "HTTPS vía API Gateway"
        }

        service = component "Service" {
            technology "C#"
            description "Contiene la lógica de negocio para la gestión de notificaciones."
            tags "001 - Fase 1"

            controller -> this "Usa" "" "001 - Fase 1"
        }

        repository = component "Repository" {
            technology "C#, Entity Framework Core"
            description "Gestiona registros de notificaciones."
            tags "001 - Fase 1"

            service -> this "usa" "" "001 - Fase 1"
        }

        validator = component "Validator" {
            technology "C#"
            description "Valida que la notificación incluya la información necesaria."
            tags "001 - Fase 1"

            service -> this "Usa" "" "001 - Fase 1"
        }

        messageBuilder = component "Message Builder" {
            technology "C#"
            description "Genera y formatea de forma dinámica el mensaje de la notificación para cada canal."
            tags "001 - Fase 1"

            service -> this "Usa" "" "001 - Fase 1"
        }

        queuePublisher = component "Queue Publisher" {
            technology "C#"
            description "Publica mensajes en la cola de notificaciones para su procesamiento."
            tags "001 - Fase 1"

            service -> this "Usa" "" "001 - Fase 1"
        }

        schedulerService = component "Scheduler Service" {
            technology "C#"
            description "Contiene la lógica de negocio para la programación de notificaciones."
            tags "001 - Fase 1"

            service -> this "Usa" "" "001 - Fase 1"
        }

        schedulerRepository = component "Scheduler Repository" {
            technology "C#, Entity Framework Core"
            description "Gestiona registros de notificaciones programadas."
            tags "001 - Fase 1"

            schedulerService -> this "Usa" "" "001 - Fase 1"
        }

        templatesController = component "Templates Controller" {
            technology "ASP.NET Core, C#"
            description "Expone endpoints para gestionar plantillas de notificación (correo, SMS, etc.)."
            tags "001 - Fase 1"
        }

        templateService = component "Template Service" {
            technology "C#"
            description "Contiene la lógica de negocio para la gestión de plantillas de notificación."
            tags "001 - Fase 1"

            templatesController -> this "Usa" "" "001 - Fase 1"
        }

        templateRepository = component "Template Repository" {
            technology "C#, Entity Framework Core"
            description "Gestiona registros de plantillas de notificación."
            tags "001 - Fase 1"

            templateService -> this "Usa" "" "001 - Fase 1"
        }

        channelsController = component "Channels Controller" {
            technology "ASP.NET Core, C#"
            description "Expone endpoints para gestionar la configuración de canales de notificación (correo, SMS, etc.)."
            tags "001 - Fase 1"
        }

        channelService = component "Channel Service" {
            technology "C#"
            description "Contiene la lógica de negocio para la gestión de canales de notificación."
            tags "001 - Fase 1"

            channelsController -> this "Usa" "" "001 - Fase 1"
        }

        channelRepository = component "Channel Repository" {
            technology "C#, Entity Framework Core"
            description "Gestiona registros de canales."
            tags "001 - Fase 1"

            channelService -> this "Usa" "" "001 - Fase 1"
        }

        configController = component "Config Controller" {
            technology "ASP.NET Core, C#"
            description "Expone endpoints para gestionar configuraciones del servicio de notificaciones."
            tags "001 - Fase 1"
        }

        configService = component "Config Service" {
            technology "C#"
            description "Contiene la lógica de negocio para la gestión de configuraciones del servicio de notificaciones."
            tags "001 - Fase 1"

            configController -> this "Usa" "" "001 - Fase 1"
        }

        configRepository = component "Config Repository" {
            technology "C#, Entity Framework Core"
            description "Gestiona registros de configuraciones del servicio de notificaciones."
            tags "001 - Fase 1"

            configService -> this "Usa" "" "001 - Fase 1"
        }

        attachmentsController = component "Attachments Controller" {
            technology "ASP.NET Core, C#"
            description "Expone endpoints para gestionar archivos adjuntos."
            tags "001 - Fase 1"

            appPeru -> this "Solicita archivos adjuntos" "HTTPS vía API Gateway" "001 - Fase 1"
            appEcuador -> this "Solicita archivos adjuntos" "HTTPS vía API Gateway" "001 - Fase 1"
            appColombia -> this "Solicita archivos adjuntos" "HTTPS vía API Gateway"
            appMexico -> this "Solicita archivos adjuntos" "HTTPS vía API Gateway"
        }

        attachmentService = component "Attachment Service" {
            technology "C#"
            description "Contiene la lógica de negocio para la gestión de archivos adjuntos."
            tags "001 - Fase 1"

            attachmentsController -> this "Usa" "" "001 - Fase 1"
        }

        attachmentRepository = component "Attachment Repository" {
            technology "C#, Entity Framework Core"
            description "Gestiona metadatos de archivos adjuntos."
            tags "001 - Fase 1"

            attachmentService -> this "Usa" "" "001 - Fase 1"
        }

        attachmentManager = component "Attachment Manager" {
            technology "C#"
            description "Gestiona la carga, eliminación y consulta de archivos adjuntos."
            tags "001 - Fase 1"

            attachmentService -> this "Gestiona archivos adjuntos" "" "001 - Fase 1"
        }

        apiGateway.yarp.authorization -> controller "Redirige solicitudes a" "HTTPS" "001 - Fase 1"
    }

    db = store "Notification DB" {
        technology "PostgreSQL"
        description "Almacena registros de notificaciones, plantillas, canales y configuraciones."
        tags "Database" "PostgreSQL" "001 - Fase 1"

        api.repository -> this "Registra notificaciones" "" "001 - Fase 1"
        api.schedulerRepository -> this "Registra notificaciones programadas" "" "001 - Fase 1"
        api.templateRepository -> this "Lee y escribe datos" "" "001 - Fase 1"
        api.channelRepository -> this "Lee y escribe datos" "" "001 - Fase 1"
        api.configRepository -> this "Lee y escribe datos" "" "001 - Fase 1"
        api.attachmentRepository -> this "Lee y escribe datos" "" "001 - Fase 1"
    }

    queue = store "Notification Queue" {
        technology "RabbitMQ"
        description "Cola de mensajes para gestionar el envío de notificaciones."
        tags "Message Bus" "RabbitMQ" "001 - Fase 1"

        api.queuePublisher -> this "Encola notificaciones." "" "001 - Fase 1"
    }

    storage = store "Attachment Storage" {
        technology "AWS S3"
        description "Almacena los archivos adjuntos asociados a las notificaciones."
        tags "File Storage" "AWS S3" "001 - Fase 1"

        api.attachmentManager -> this "Sube archivos adjuntos" "" "001 - Fase 1"
    }

    scheduler = application "Notification Scheduler" {
        technology "C#, .NET"
        description "Gestiona notificaciones programadas y las envía a la cola de notificaciones."
        tags "CSharp"

        worker = component "Scheduler Worker" {
            technology "C#, Worker Service"
            description "Ejecuta tareas periódicas para mover notificaciones programadas a la cola de notificaciones."
        }

        service = component "Service" {
            technology "C#"
            description "Contiene la lógica de negocio que gestiona las notificaciones programadas."

            worker -> this "Usa"
        }

        repository = component "Repository" {
            technology "C#, Entity Framework Core"
            description "Gestiona registros de notificaciones programadas."

            service -> this "Usa"
            this -> db "Lee y escribe datos"
        }

        publisher = component "Queue Publisher" {
            technology "C#"
            description "Publica mensajes en la cola de notificaciones."

            service -> this "Usa"
            this -> queue "Encola notificaciones"
        }
    }

    // Procesadores de Canal
    emailProcessor = application "Email Processor" {
        technology "C# .NET"
        description "Gestiona el envío de notificaciones email."
        tags "CSharp" "001 - Fase 1"

        consumer = component "Consumer" {
            technology "C#"
            description "Consume mensajes de la cola de notificaciones."
            tags "001 - Fase 1"

            this  -> queue "Consume mensajes" "" "001 - Fase 1"
        }

        service = component "Service" {
            technology "C#"
            description "Contiene la lógica de negocio para el envío de notificaciones de email."
            tags "001 - Fase 1"

            consumer -> this "Usa" "" "001 - Fase 1"
        }

        repository = component "Repository" {
            technology "C#, Entity Framework Core"
            description "Actualiza estado de notificaciones email."
            tags "001 - Fase 1"

            service -> this "Usa" "" "001 - Fase 1"
            this -> db "Lee y escribe datos" "" "001 - Fase 1"
        }

        adapter = component "Adapter" {
            technology "C#"
            description "Adaptador para el proveedor de correo electrónico."
            tags "001 - Fase 1"

            service -> this "Usa" "" "001 - Fase 1"
            this -> emailProvider "Usa" "" "001 - Fase 1"
        }

        attachmentService = component "Attachment Service" {
            technology "C#"
            description "Gestiona la obtención, validación y preparación de archivos adjuntos."
            tags "001 - Fase 1"

            service -> this "Usa" "" "001 - Fase 1"
        }

        attachmentFetcher = component "Attachment Fetcher" {
            technology "C#"
            description "Gestiona la obtención de archivos adjuntos desde el almacenamiento."
            tags "001 - Fase 1"

            attachmentService -> this "Usa"
            this -> storage "Obtiene archivos adjuntos" "" "001 - Fase 1"
        }
    }

    smsProcessor = application "SMS Processor" {
        technology "C# .NET"
        description "Gestiona el envío de notificaciones SMS."
        tags "CSharp"

        consumer = component "Consumer" {
            technology "C#"
            description "Consume mensajes de la cola de notificaciones."

            this  -> queue "Consume mensajes"
        }

        service = component "Service" {
            technology "C#"
            description "Contiene la lógica de negocio para el envío de SMS."

            consumer -> this "Usa"
        }

        repository = component "Repository" {
            technology "C#, Entity Framework Core"
            description "Actualiza estado de notificaciones SMS."

            service -> this "Usa"
            this -> db "Lee y escribe datos"
        }

        adapter = component "Adapter" {
            technology "C#"
            description "Adaptador para el proveedor de SMS."

            service -> this "Usa"
            this -> smsProvider "Usa"
        }
    }

    whatsappProcessor = application "WhatsApp Processor" {
        technology "C# .NET"
        description "Gestiona el envío de notificaciones WhatsApp."
        tags "CSharp"

        consumer = component "Consumer" {
            technology "C#"
            description "Consume mensajes de la cola de notificaciones."

            this  -> queue "Consume mensajes"
        }

        service = component "Service" {
            technology "C#"
            description "Contiene la lógica de negocio para el envío de notificaciones WhatsApp."

            consumer -> this "Usa"
        }

        repository = component "Repository" {
            technology "C#, Entity Framework Core"
            description "Actualiza estado de notificaciones WhatsApp."

            service -> this "Usa"
            this -> db "Lee y escribe datos"
        }

        adapter = component "Adapter" {
            technology "C#"
            description "Adaptador para el proveedor de mensajería WhatsApp."

            service -> this "Usa"
            this -> whatsappProvider "Usa"
        }

        attachmentService = component "Attachment Service" {
            technology "C#"
            description "Gestiona la obtención, validación y preparación de archivos adjuntos."

            service -> this "Usa"
        }

        attachmentFetcher = component "Attachment Fetcher" {
            technology "C#"
            description "Gestiona la obtención de archivos adjuntos desde el almacenamiento."

            attachmentService -> this "Usa"
            this -> storage "Obtiene archivos adjuntos"
        }
    }

    pushProcessor = application "Push Processor" {
        technology "C# .NET"
        description "Gestiona el envío de notificaciones push."
        tags "CSharp"

        consumer = component "Consumer" {
            technology "C#"
            description "Consume mensajes de la cola de notificaciones."

            this  -> queue "Consume mensajes"
        }

        service = component "Service" {
            technology "C#"
            description "Contiene la lógica de negocio para el envío de notificaciones push."

            consumer -> this "Usa"
        }

        repository = component "Repository" {
            technology "C#, Entity Framework Core"
            description "Actualiza estado de notificaciones push."

            service -> this "Usa"
            this -> db "Lee y escribe datos"
        }

        adapter = component "Adapter" {
            technology "C#"
            description "Adaptador para el proveedor de notificaciones push."

            service -> this "Usa"
            this -> pushProvider "Usa"
        }

        attachmentService = component "Attachment Service" {
            technology "C#"
            description "Gestiona la obtención, validación y preparación de archivos adjuntos."

            service -> this "Usa"
        }

        attachmentFetcher = component "Attachment Fetcher" {
            technology "C#"
            description "Gestiona la obtención de archivos adjuntos desde el almacenamiento."

            attachmentService -> this "Usa"
            this -> storage "Obtiene archivos adjuntos"
        }
    }

    admin -> api.templatesController "Gestiona plantillas" "HTTPS vía API Gateway" "001 - Fase 1"
    admin -> api.channelsController "Gestiona canales" "HTTPS vía API Gateway" "001 - Fase 1"
    admin -> api.configController "Gestiona configuraciones" "HTTPS vía API Gateway" "001 - Fase 1"
}