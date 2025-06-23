notification = softwareSystem "Notification System" {
    description "Gestiona envío de notificaciones por varios canales"

    api = application "Notification API" {
        technology "C# .NET"
        description "Registra solicitudes de notificaciones y gestiona configuraciones asociadas."
        tags "CSharp"

        controller = component "Controller" {
            technology "ASP.NET Core, C#"
            description "Expone endpoints para atender solicitudes de envío y consulta de notificaciones."

            appPeru -> this "Solicita envío de notificación" "HTTPS vía API Gateway"
            appEcuador -> this "Solicita envío de notificación" "HTTPS vía API Gateway"
            appColombia -> this "Solicita envío de notificación" "HTTPS vía API Gateway"
            appMexico -> this "Solicita envío de notificación" "HTTPS vía API Gateway"
        }

        service = component "Service" {
            technology "C#"
            description "Contiene la lógica de negocio para la gestión de notificaciones."

            controller -> this "Usa"
        }

        repository = component "Repository" {
            technology "C#, Entity Framework Core"
            description "Gestiona registros de notificaciones."

            service -> this "usa"
        }

        validator = component "Validator" {
            technology "C#"
            description "Valida que la notificación incluya la información necesaria."

            service -> this "Usa"
        }

        messageBuilder = component "Message Builder" {
            technology "C#"
            description "Genera y formatea de forma dinámica el mensaje de la notificación para cada canal."

            service -> this "Usa"
        }

        queuePublisher = component "Queue Publisher" {
            technology "C#"
            description "Publica mensajes en la cola de notificaciones para su procesamiento."

            service -> this "Usa"
        }

        schedulerService = component "Scheduler Service" {
            technology "C#"
            description "Contiene la lógica de negocio para la programación de notificaciones."

            service -> this "Usa"
        }

        schedulerRepository = component "Scheduler Repository" {
            technology "C#, Entity Framework Core"
            description "Gestiona registros de notificaciones programadas."

            schedulerService -> this "Usa"
        }

        templatesController = component "Templates Controller" {
            technology "ASP.NET Core, C#"
            description "Expone endpoints para gestionar plantillas de notificación (correo, SMS, etc.)."
        }

        templateService = component "Template Service" {
            technology "C#"
            description "Contiene la lógica de negocio para la gestión de plantillas de notificación."

            templatesController -> this "Usa"
        }

        templateRepository = component "Template Repository" {
            technology "C#, Entity Framework Core"
            description "Gestiona registros de plantillas de notificación."

            templateService -> this "Usa"
        }

        channelsController = component "Channels Controller" {
            technology "ASP.NET Core, C#"
            description "Expone endpoints para gestionar la configuración de canales de notificación (correo, SMS, etc.)."
        }

        channelService = component "Channel Service" {
            technology "C#"
            description "Contiene la lógica de negocio para la gestión de canales de notificación."

            channelsController -> this "Usa"
        }

        channelRepository = component "Channel Repository" {
            technology "C#, Entity Framework Core"
            description "Gestiona registros de canales."

            channelService -> this "Usa"
        }

        configController = component "Config Controller" {
            technology "ASP.NET Core, C#"
            description "Expone endpoints para gestionar configuraciones del servicio de notificaciones."
        }

        configService = component "Config Service" {
            technology "C#"
            description "Contiene la lógica de negocio para la gestión de configuraciones del servicio de notificaciones."

            configController -> this "Usa"
        }

        configRepository = component "Config Repository" {
            technology "C#, Entity Framework Core"
            description "Gestiona registros de configuraciones del servicio de notificaciones."

            configService -> this "Usa"
        }

        attachmentsController = component "Attachments Controller" {
            technology "ASP.NET Core, C#"
            description "Expone endpoints para gestionar archivos adjuntos."

            appPeru -> this "Solicita archivos adjuntos" "HTTPS vía API Gateway"
            appEcuador -> this "Solicita archivos adjuntos" "HTTPS vía API Gateway"
            appColombia -> this "Solicita archivos adjuntos" "HTTPS vía API Gateway"
            appMexico -> this "Solicita archivos adjuntos" "HTTPS vía API Gateway"
        }

        attachmentService = component "Attachment Service" {
            technology "C#"
            description "Contiene la lógica de negocio para la gestión de archivos adjuntos."

            attachmentsController -> this "Usa"
        }

        attachmentRepository = component "Attachment Repository" {
            technology "C#, Entity Framework Core"
            description "Gestiona metadatos de archivos adjuntos."

            attachmentService -> this "Usa"
        }

        attachmentManager = component "Attachment Manager" {
            technology "C#"
            description "Gestiona la carga, eliminación y consulta de archivos adjuntos."

            attachmentService -> this "Gestiona archivos adjuntos"
        }

        apiGateway.yarp.authorization -> controller "Redirige solicitudes a" "HTTPS"
    }

    db = store "Notification DB" {
        technology "PostgreSQL"
        description "Almacena registros de notificaciones, plantillas, canales y configuraciones."
        tags "Database" "PostgreSQL"

        api.repository -> this "Registra notificaciones"
        api.schedulerRepository -> this "Registra notificaciones programadas"
        api.templateRepository -> this "Lee y escribe datos"
        api.channelRepository -> this "Lee y escribe datos"
        api.configRepository -> this "Lee y escribe datos"
        api.attachmentRepository -> this "Lee y escribe datos"
    }

    queue = store "Notification Queue" {
        technology "RabbitMQ"
        description "Cola de mensajes para gestionar el envío de notificaciones."
        tags "Message Bus" "RabbitMQ"

        api.queuePublisher -> this "Encola notificaciones."
    }

    storage = store "Attachment Storage" {
        technology "AWS S3"
        description "Almacena los archivos adjuntos asociados a las notificaciones."
        tags "File Storage" "AWS S3"

        api.attachmentManager -> this "Sube archivos adjuntos"
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
        tags "CSharp"

        consumer = component "Consumer" {
            technology "C#"
            description "Consume mensajes de la cola de notificaciones."

            this  -> queue "Consume mensajes"
        }

        service = component "Service" {
            technology "C#"
            description "Contiene la lógica de negocio para el envío de notificaciones de email."

            consumer -> this "Usa"
        }

        repository = component "Repository" {
            technology "C#, Entity Framework Core"
            description "Actualiza estado de notificaciones email."

            service -> this "Usa"
            this -> db "Lee y escribe datos"
        }

        adapter = component "Adapter" {
            technology "C#"
            description "Adaptador para el proveedor de correo electrónico."

            service -> this "Usa"
            this -> emailProvider "Usa"
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

    admin -> api.templatesController "Gestiona plantillas" "HTTPS vía API Gateway"
    admin -> api.channelsController "Gestiona canales" "HTTPS vía API Gateway"
    admin -> api.configController "Gestiona configuraciones" "HTTPS vía API Gateway"
}