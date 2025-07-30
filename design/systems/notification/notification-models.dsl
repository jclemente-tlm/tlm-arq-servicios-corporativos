notification = softwareSystem "Notification System" {
    description "Gestiona envío de notificaciones por varios canales"
    tags "Notification" "001 - Fase 1"

    api = application "Notification API" {
        technology "C# .NET"
        description "Recibe solicitudes de notificaciones, gestiona adjuntos y encola eventos."
        tags "CSharp" "001 - Fase 1"

        controller = component "Controller" {
            technology "ASP.NET Core, C#"
            description "Expone endpoints para atender solicitudes de envío y consulta de notificaciones."
            tags "001 - Fase 1"
        }

        service = component "Service" {
            technology "C#"
            description "Contiene la lógica de negocio para la gestión de notificaciones."
            tags "001 - Fase 1"
        }

        // repository = component "Repository" {
        //     technology "C#, Entity Framework Core"
        //     description "Gestiona registros de notificaciones."
        //     tags "001 - Fase 1"
        // }

        validator = component "Validator" {
            technology "C#"
            description "Valida que la notificación incluya la información necesaria."
            tags "001 - Fase 1"
        }

        // messageBuilder = component "Message Builder" {
        //     technology "C#"
        //     description "Genera y formatea de forma dinámica el mensaje de la notificación para cada canal."
        //     tags "001 - Fase 1"
        // }

        queuePublisher = component "Queue Publisher" {
            technology "C#"
            description "Publica mensajes en la cola de notificaciones para su procesamiento."
            tags "001 - Fase 1"
        }

        // schedulerService = component "Scheduler Service" {
        //     technology "C#"
        //     description "Contiene la lógica de negocio para la programación de notificaciones."
        //     tags "001 - Fase 1"
        // }

        // schedulerRepository = component "Scheduler Repository" {
        //     technology "C#, Entity Framework Core"
        //     description "Gestiona registros de notificaciones programadas."
        //     tags "001 - Fase 1"
        // }

        attachmentsController = component "Attachments Controller" {
            technology "ASP.NET Core, C#"
            description "Expone endpoints para gestionar archivos adjuntos."
            tags "001 - Fase 1"
        }

        attachmentService = component "Attachment Service" {
            technology "C#"
            description "Contiene la lógica de negocio para la gestión de archivos adjuntos."
            tags "001 - Fase 1"
        }

        attachmentRepository = component "Attachment Repository" {
            technology "C#, Entity Framework Core"
            description "Gestiona metadatos de archivos adjuntos."
            tags "001 - Fase 1"
        }

        attachmentManager = component "Attachment Manager" {
            technology "C#"
            description "Gestiona la carga, eliminación y consulta de archivos adjuntos."
            tags "001 - Fase 1"
        }

        configManager = component "Configuration Manager" {
            technology "C#, AWS SDK"
            description "Obtiene configuraciones y secretos desde Configuration Platform"
        }
    }

    // configurationApi = container "Configuration API" {
    //     technology "ASP.NET Core 8 / C#"
    //     description "API para gestionar plantillas, canales, reglas y configuraciones por tenant."
    //     tags "CSharp" "001 - Fase 1"

    //     templatesController = component "Templates Controller" {
    //         technology "ASP.NET Core, C#"
    //         description "Expone endpoints para gestionar plantillas de notificación (correo, SMS, etc.)."
    //         tags "001 - Fase 1"
    //     }

    //     templateService = component "Template Service" {
    //         technology "C#"
    //         description "Contiene la lógica de negocio para la gestión de plantillas de notificación."
    //         tags "001 - Fase 1"
    //     }

    //     templateRepository = component "Template Repository" {
    //         technology "C#, Entity Framework Core"
    //         description "Gestiona registros de plantillas de notificación."
    //         tags "001 - Fase 1"
    //     }

    //     channelsController = component "Channels Controller" {
    //         technology "ASP.NET Core, C#"
    //         description "Expone endpoints para gestionar la configuración de canales de notificación (correo, SMS, etc.)."
    //         tags "001 - Fase 1"
    //     }

    //     channelService = component "Channel Service" {
    //         technology "C#"
    //         description "Contiene la lógica de negocio para la gestión de canales de notificación."
    //         tags "001 - Fase 1"
    //     }

    //     channelRepository = component "Channel Repository" {
    //         technology "C#, Entity Framework Core"
    //         description "Gestiona registros de canales."
    //         tags "001 - Fase 1"
    //     }

    //     // configController = component "Config Controller" {
    //     //     technology "ASP.NET Core, C#"
    //     //     description "Expone endpoints para gestionar configuraciones del servicio de notificaciones."
    //     //     tags "001 - Fase 1"
    //     // }

    //     // configService = component "Config Service" {
    //     //     technology "C#"
    //     //     description "Contiene la lógica de negocio para la gestión de configuraciones del servicio de notificaciones."
    //     //     tags "001 - Fase 1"
    //     // }

    //     // configRepository = component "Config Repository" {
    //     //     technology "C#, Entity Framework Core"
    //     //     description "Gestiona registros de configuraciones del servicio de notificaciones."
    //     //     tags "001 - Fase 1"
    //     // }

    //     configManager = component "Configuration Manager" {
    //         technology "C#, AWS SDK"
    //         description "Obtiene configuraciones y secretos desde Configuration Platform"
    //     }
    // }

    db = store "Notification DB" {
        technology "PostgreSQL"
        description "Almacena plantillas, canales, historial de envíos, configuraciones por tenant y notificaciones programadas."
        tags "Database" "PostgreSQL" "001 - Fase 1"
    }

    queue = store "Notification Queue" {
        technology "RabbitMQ"
        description "Cola de mensajes para gestionar el envío de notificaciones."
        tags "Message Bus" "RabbitMQ" "001 - Fase 1"
    }

    queueEmail = store "Queue Email" {
        technology "AWS SQS"
        description "Cola para notificaciones de correo electrónico."
        tags "Message Bus" "AWS SQS" "001 - Fase 1"
    }

    queueSms = store "Queue SMS" {
        technology "AWS SQS"
        description "Cola para notificaciones SMS."
        tags "Message Bus" "AWS SQS"
    }

    queueWhatsapp = store "Queue WhatsApp" {
        technology "AWS SQS"
        description "Cola para notificaciones WhatsApp."
        tags "Message Bus" "AWS SQS"
    }

    queuePush = store "Queue Push" {
        technology "AWS SQS"
        description "Cola para notificaciones Push."
        tags "Message Bus" "AWS SQS"
    }

    storage = store "Attachment Storage" {
        technology "AWS S3"
        description "Almacena los archivos adjuntos asociados a las notificaciones."
        tags "File Storage" "AWS S3" "001 - Fase 1"
    }

    notificationProcessor = application "Notification Processor" {
        technology "Worker Service (.NET 8)"
        description "Consume mensajes de SQS Inbox y publica en colas por canal usando SNS."
        tags "CSharp" "001 - Fase 1"

        configManager = component "Configuration Manager" {
            technology "C#, AWS SDK"
            description "Obtiene configuraciones y secretos desde Configuration Platform"
        }
    }

    scheduler = application "Notification Scheduler" {
        technology "C#, .NET 8"
        description "Gestiona notificaciones programadas y las envía a la cola de notificaciones."
        tags "CSharp"

        worker = component "Scheduler Worker" {
            technology "C#, Worker Service"
            description "Ejecuta tareas periódicas para mover notificaciones programadas a la cola de notificaciones."
        }

        service = component "Service" {
            technology "C#"
            description "Contiene la lógica de negocio que gestiona las notificaciones programadas."
        }

        repository = component "Repository" {
            technology "C#, Entity Framework Core"
            description "Gestiona registros de notificaciones programadas."
        }

        publisher = component "Queue Publisher" {
            technology "C#"
            description "Publica mensajes en la cola de notificaciones."
        }

        configManager = component "Configuration Manager" {
            technology "C#, AWS SDK"
            description "Obtiene configuraciones y secretos desde Configuration Platform"
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
        }

        service = component "Service" {
            technology "C#"
            description "Contiene la lógica de negocio para el envío de notificaciones de email."
            tags "001 - Fase 1"
        }

        repository = component "Repository" {
            technology "C#, Entity Framework Core"
            description "Actualiza estado de notificaciones email."
            tags "001 - Fase 1"
        }

        adapter = component "Adapter" {
            technology "C#"
            description "Adaptador para el proveedor de correo electrónico."
            tags "001 - Fase 1"
        }

        attachmentService = component "Attachment Service" {
            technology "C#"
            description "Gestiona la obtención, validación y preparación de archivos adjuntos."
            tags "001 - Fase 1"
        }

        attachmentFetcher = component "Attachment Fetcher" {
            technology "C#"
            description "Gestiona la obtención de archivos adjuntos desde el almacenamiento."
            tags "001 - Fase 1"
        }

        configManager = component "Configuration Manager" {
            technology "C#, AWS SDK"
            description "Obtiene configuraciones y secretos desde Configuration Platform"
            tags "001 - Fase 1"
        }
    }

    smsProcessor = application "SMS Processor" {
        technology "C# .NET"
        description "Gestiona el envío de notificaciones SMS."
        tags "CSharp"

        consumer = component "Consumer" {
            technology "C#"
            description "Consume mensajes de la cola de notificaciones."
        }

        service = component "Service" {
            technology "C#"
            description "Contiene la lógica de negocio para el envío de SMS."
        }

        repository = component "Repository" {
            technology "C#, Entity Framework Core"
            description "Actualiza estado de notificaciones SMS."
        }

        adapter = component "Adapter" {
            technology "C#"
            description "Adaptador para el proveedor de SMS."
        }

        configManager = component "Configuration Manager" {
            technology "C#, AWS SDK"
            description "Obtiene configuraciones y secretos desde Configuration Platform"
        }
    }

    whatsappProcessor = application "WhatsApp Processor" {
        technology "C# .NET"
        description "Gestiona el envío de notificaciones WhatsApp."
        tags "CSharp"

        consumer = component "Consumer" {
            technology "C#"
            description "Consume mensajes de la cola de notificaciones."
        }

        service = component "Service" {
            technology "C#"
            description "Contiene la lógica de negocio para el envío de notificaciones WhatsApp."
        }

        repository = component "Repository" {
            technology "C#, Entity Framework Core"
            description "Actualiza estado de notificaciones WhatsApp."
        }

        adapter = component "Adapter" {
            technology "C#"
            description "Adaptador para el proveedor de mensajería WhatsApp."
        }

        attachmentService = component "Attachment Service" {
            technology "C#"
            description "Gestiona la obtención, validación y preparación de archivos adjuntos."
        }

        attachmentFetcher = component "Attachment Fetcher" {
            technology "C#"
            description "Gestiona la obtención de archivos adjuntos desde el almacenamiento."
        }

        configManager = component "Configuration Manager" {
            technology "C#, AWS SDK"
            description "Obtiene configuraciones y secretos desde Configuration Platform"
        }
    }

    pushProcessor = application "Push Processor" {
        technology "C# .NET"
        description "Gestiona el envío de notificaciones push."
        tags "CSharp"

        consumer = component "Consumer" {
            technology "C#"
            description "Consume mensajes de la cola de notificaciones."
        }

        service = component "Service" {
            technology "C#"
            description "Contiene la lógica de negocio para el envío de notificaciones push."
        }

        repository = component "Repository" {
            technology "C#, Entity Framework Core"
            description "Actualiza estado de notificaciones push."
        }

        adapter = component "Adapter" {
            technology "C#"
            description "Adaptador para el proveedor de notificaciones push."
        }

        attachmentService = component "Attachment Service" {
            technology "C#"
            description "Gestiona la obtención, validación y preparación de archivos adjuntos."
        }

        attachmentFetcher = component "Attachment Fetcher" {
            technology "C#"
            description "Gestiona la obtención de archivos adjuntos desde el almacenamiento."
        }

        configManager = component "Configuration Manager" {
            technology "C#, AWS SDK"
            description "Obtiene configuraciones y secretos desde Configuration Platform"
        }
    }

    // -------------------
    // RELACIONES AL FINAL
    // -------------------
    api.controller -> api.service "Usa" "" "001 - Fase 1"
    api.service -> api.validator "Usa" "" "001 - Fase 1"
    api.service -> api.queuePublisher "Usa" "" "001 - Fase 1"
    api.queuePublisher -> queue "Encola notificaciones." "" "001 - Fase 1"
    api.attachmentsController -> api.attachmentService "Usa" "" "001 - Fase 1"
    api.attachmentRepository -> db "Registra metadatos de adjuntos" "" "001 - Fase 1"
    api.attachmentService -> api.attachmentRepository "Usa" "" "001 - Fase 1"
    api.attachmentService -> api.attachmentManager "Gestiona archivos adjuntos" "" "001 - Fase 1"
    api.attachmentManager -> storage "Sube archivos adjuntos" "" "001 - Fase 1"
    api.configManager -> configPlatform.configService "Lee configuraciones y secretos" "" "001 - Fase 1"

    // configurationApi.templatesController -> configurationApi.templateService "Usa" "" "001 - Fase 1"
    // configurationApi.templateService -> configurationApi.templateRepository "Usa" "" "001 - Fase 1"
    // configurationApi.templateRepository -> db "Lee y escribe datos" "" "001 - Fase 1"
    // configurationApi.channelsController -> configurationApi.channelService "Usa" "" "001 - Fase 1"
    // configurationApi.channelService -> configurationApi.channelRepository "Usa" "" "001 - Fase 1"
    // configurationApi.channelRepository -> db "Lee y escribe datos" "" "001 - Fase 1"
    // // configurationApi.configController -> configurationApi.configService "Usa" "" "001 - Fase 1"
    // // configurationApi.configService -> configurationApi.configRepository "Usa" "" "001 - Fase 1"
    // // configurationApi.configRepository -> db "Lee y escribe datos" "" "001 - Fase 1"
    // configurationApi.configManager -> configPlatform.configService "Lee configuraciones y secretos" "" "001 - Fase 1"


    queue -> notificationProcessor "Entrega mensajes al Processor."

    scheduler.worker -> scheduler.service "Usa" "" "001 - Fase 1"
    scheduler.service -> scheduler.repository "Usa" "" "001 - Fase 1"
    scheduler.repository -> db "Registra notificaciones programadas" "" "001 - Fase 1"
    scheduler.publisher -> queue "Encola notificaciones programadas" "" "001 - Fase 1"
    scheduler.configManager -> configPlatform.configService "Lee configuraciones y secretos" "" "001 - Fase 1"

    notificationProcessor -> db "Registra notificaciones" "" "001 - Fase 1"
    notificationProcessor -> queueEmail "Publica mensajes de Email" "fan-out vía SNS" "001 - Fase 1"
    notificationProcessor -> queueSms "Publica mensajes de SMS" "fan-out vía SNS"
    notificationProcessor -> queueWhatsapp "Publica mensajes de WhatsApp" "fan-out vía SNS"
    notificationProcessor -> queuePush "Publica mensajes de Push" "fan-out vía SNS"
    notificationProcessor.configManager -> configPlatform.configService "Lee configuraciones y secretos" ""

    emailProcessor.consumer -> queueEmail "Consume mensajes" "" "001 - Fase 1"
    emailProcessor.consumer -> emailProcessor.service "Usa" "" "001 - Fase 1"
    emailProcessor.service -> emailProcessor.repository "Usa" "" "001 - Fase 1"
    emailProcessor.repository -> db "Registra estado de notificación" "" "001 - Fase 1"
    emailProcessor.service -> emailProcessor.adapter "Usa" "" "001 - Fase 1"
    emailProcessor.adapter -> emailProvider "Usa" "" "001 - Fase 1"
    emailProcessor.service -> emailProcessor.attachmentService "Usa" "" "001 - Fase 1"
    emailProcessor.attachmentService -> emailProcessor.attachmentFetcher "Usa"
    emailProcessor.attachmentFetcher -> storage "Obtiene archivos adjuntos" "" "001 - Fase 1"
    emailProcessor.configManager -> configPlatform.configService "Lee configuraciones y secretos" "" "001 - Fase 1"

    smsProcessor.consumer -> queueSms "Consume mensajes"
    smsProcessor.consumer -> smsProcessor.service "Usa"
    smsProcessor.service -> smsProcessor.repository "Usa"
    smsProcessor.repository -> db "Registra estado de notificación"
    smsProcessor.service -> smsProcessor.adapter "Usa"
    smsProcessor.adapter -> smsProvider "Usa"
    smsProcessor.configManager -> configPlatform.configService "Lee configuraciones y secretos"

    whatsappProcessor.consumer -> queueWhatsapp "Consume mensajes"
    whatsappProcessor.consumer -> whatsappProcessor.service "Usa"
    whatsappProcessor.service -> whatsappProcessor.repository "Usa"
    whatsappProcessor.repository -> db "Registra estado de notificación"
    whatsappProcessor.service -> whatsappProcessor.adapter "Usa"
    whatsappProcessor.adapter -> whatsappProvider "Usa"
    whatsappProcessor.service -> whatsappProcessor.attachmentService "Usa"
    whatsappProcessor.attachmentService -> whatsappProcessor.attachmentFetcher "Usa"
    whatsappProcessor.attachmentFetcher -> storage "Obtiene archivos adjuntos"
    whatsappProcessor.configManager -> configPlatform.configService "Lee configuraciones y secretos"

    pushProcessor.consumer -> queuePush "Consume mensajes"
    pushProcessor.consumer -> pushProcessor.service "Usa"
    pushProcessor.service -> pushProcessor.repository "Usa"
    pushProcessor.repository -> db "Registra estado de notificación"
    pushProcessor.service -> pushProcessor.adapter "Usa"
    pushProcessor.adapter -> pushProvider "Usa"
    pushProcessor.service -> pushProcessor.attachmentService "Usa"
    pushProcessor.attachmentService -> pushProcessor.attachmentFetcher "Usa"
    pushProcessor.attachmentFetcher -> storage "Obtiene archivos adjuntos"
    pushProcessor.configManager -> configPlatform.configService "Lee configuraciones y secretos" "" "001 - Fase 1"

    appPeru -> api.controller "Solicita envío de notificación" "HTTPS vía API Gateway" "001 - Fase 1"
    appEcuador -> api.controller "Solicita envío de notificación" "HTTPS vía API Gateway" "001 - Fase 1"
    appColombia -> api.controller "Solicita envío de notificación" "HTTPS vía API Gateway"
    appMexico -> api.controller "Solicita envío de notificación" "HTTPS vía API Gateway"

    appPeru -> api.attachmentsController "Gestiona archivos adjuntos" "HTTPS vía API Gateway" "001 - Fase 1"
    appEcuador -> api.attachmentsController "Gestiona archivos adjuntos" "HTTPS vía API Gateway" "001 - Fase 1"
    appColombia -> api.attachmentsController "Gestiona archivos adjuntos" "HTTPS vía API Gateway"
    appMexico -> api.attachmentsController "Gestiona archivos adjuntos" "HTTPS vía API Gateway"

    // admin -> configurationApi.templatesController "Gestiona plantillas" "HTTPS vía API Gateway" "001 - Fase 1"
    // admin -> configurationApi.channelsController "Gestiona canales" "HTTPS vía API Gateway" "001 - Fase 1"
}
