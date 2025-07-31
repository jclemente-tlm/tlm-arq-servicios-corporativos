notification = softwareSystem "Notification System" {
    description "Gestiona envío de notificaciones por varios canales"
    tags "Notification" "001 - Fase 1"

    api = application "Notification API" {
        technology "ASP.NET Core, C# .NET 8"
        description "Recibe solicitudes de notificaciones, gestiona adjuntos y encola eventos."
        tags "CSharp" "001 - Fase 1"

        controller = component "Controller" {
            technology "ASP.NET Core, C# .NET 8"
            description "Expone endpoints para atender solicitudes de envío y consulta de notificaciones."
            tags "001 - Fase 1"
        }

        service = component "Service" {
            technology "C# .NET 8"
            description "Contiene la lógica de negocio para la gestión de notificaciones."
            tags "001 - Fase 1"
        }

        validator = component "Validator" {
            technology "C# .NET 8, FluentValidation"
            description "Valida que la notificación incluya la información necesaria."
            tags "001 - Fase 1"
        }

        queuePublisher = component "Queue Publisher" {
            technology "C# .NET 8, AWS SDK"
            description "Publica mensajes en la cola de notificaciones para su procesamiento."
            tags "001 - Fase 1"
        }

        attachmentsController = component "Attachments Controller" {
            technology "ASP.NET Core, C# .NET 8"
            description "Expone endpoints para gestionar archivos adjuntos."
            tags "001 - Fase 1"
        }

        attachmentService = component "Attachment Service" {
            technology "C# .NET 8"
            description "Contiene la lógica de negocio para la gestión de archivos adjuntos."
            tags "001 - Fase 1"
        }

        attachmentRepository = component "Attachment Repository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Gestiona metadatos de archivos adjuntos."
            tags "001 - Fase 1"
        }

        attachmentManager = component "Attachment Manager" {
            technology "C# .NET 8, AWS SDK"
            description "Gestiona la carga, eliminación y consulta de archivos adjuntos."
            tags "001 - Fase 1"
        }

        tenantConfigRepository = component "TenantConfigRepository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Gestiona y provee configuraciones, reglas y parámetros por tenant para el servicio."
            tags "001 - Fase 1"
        }

        configManager = component "Configuration Manager" {
            technology "C# .NET 8, AWS SDK"
            description "Obtiene configuraciones y secretos desde TenantConfigRepository y Configuration Platform"
            tags "Configuración" "001 - Fase 1"
        }
    }

    db = store "Notification DB" {
        technology "PostgreSQL"
        description "Almacena plantillas, canales, historial de envíos, configuraciones por tenant y notificaciones programadas."
        tags "Database" "PostgreSQL" "001 - Fase 1"
    }

    queue = store "Notification Queue" {
        technology "AWS SQS"
        description "Cola de mensajes para gestionar el envío de notificaciones."
        tags "Message Bus" "AWS SQS" "001 - Fase 1"
    }

    dlq = store "Dead Letter Queue" {
        technology "AWS SQS"
        description "Cola para mensajes no entregados o fallidos."
        tags "Message Bus" "AWS SQS" "DLQ" "001 - Fase 1"
    }

    queueEmail = store "Queue Email" {
        technology "AWS SQS"
        description "Cola para notificaciones de correo electrónico."
        tags "Message Bus" "AWS SQS" "001 - Fase 1"
    }

    queueSms = store "Queue SMS" {
        technology "AWS SQS"
        description "Cola para notificaciones SMS."
        tags "Message Bus" "AWS SQS" "001 - Fase 1"
    }

    queueWhatsapp = store "Queue WhatsApp" {
        technology "AWS SQS"
        description "Cola para notificaciones WhatsApp."
        tags "Message Bus" "AWS SQS" "001 - Fase 1"
    }

    queuePush = store "Queue Push" {
        technology "AWS SQS"
        description "Cola para notificaciones Push."
        tags "Message Bus" "AWS SQS" "001 - Fase 1"
    }

    storage = store "Attachment Storage" {
        technology "AWS S3"
        description "Almacena los archivos adjuntos asociados a las notificaciones."
        tags "File Storage" "AWS S3" "001 - Fase 1"
    }

    notificationProcessor = application "Notification Processor" {
        technology "Worker Service, C# .NET 8"
        description "Consume mensajes de SQS Inbox, valida, construye mensajes por canal y publica en colas de canal. Registra en BD."
        tags "CSharp" "001 - Fase 1"

        consumer = component "Consumer" {
            technology "C# .NET 8, AWS SDK"
            description "Consume mensajes de la cola de notificaciones."
            tags "001 - Fase 1"
        }

        service = component "Service" {
            technology "C# .NET 8"
            description "Lógica de negocio: valida, construye y distribuye notificaciones por canal."
            tags "001 - Fase 1"
        }

        messageBuilder = component "Message Builder" {
            technology "C# .NET 8"
            description "Construye y formatea el mensaje final para cada canal usando templates y datos."
            tags "Builder" "001 - Fase 1"
        }

        adapter = component "Adapter" {
            technology "C# .NET 8, AWS SDK"
            description "Publica mensajes en las colas de canal (Email, SMS, WhatsApp, Push)."
            tags "001 - Fase 1"
        }

        repository = component "Repository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Registra estado y eventos de notificaciones procesadas en BD."
            tags "001 - Fase 1"
        }

        configManager = component "Configuration Manager" {
            technology "C# .NET 8, AWS SDK"
            description "Obtiene configuraciones, plantillas y configuración de canales desde los repositorios."
            tags "Configuración" "001 - Fase 1"
        }

        templateRepository = component "Template Repository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Gestiona registros y versiones de plantillas de notificación."
            tags "Template" "001 - Fase 1"
        }

        tenantConfigRepository = component "TenantConfigRepository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Gestiona y provee configuraciones, reglas y parámetros por tenant para el servicio."
            tags "001 - Fase 1"
        }

        channelConfigRepository = component "ChannelConfigRepository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Gestiona y provee configuraciones específicas de cada canal (Email, SMS, WhatsApp, Push)."
            tags "Configuración" "001 - Fase 1"
        }
    }

    scheduler = application "Notification Scheduler" {
        technology "Worker Service, C# .NET 8"
        description "Gestiona notificaciones programadas y las envía a la cola de notificaciones."
        tags "CSharp" "001 - Fase 1"

        worker = component "Scheduler Worker" {
            technology "Worker Service, C# .NET 8"
            description "Ejecuta tareas periódicas para mover notificaciones programadas a la cola de notificaciones."
            tags "001 - Fase 1"
        }

        service = component "Service" {
            technology "C# .NET 8"
            description "Contiene la lógica de negocio que gestiona las notificaciones programadas."
            tags "001 - Fase 1"
        }

        repository = component "Repository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Gestiona registros de notificaciones programadas."
            tags "001 - Fase 1"
        }

        publisher = component "Queue Publisher" {
            technology "C# .NET 8, AWS SDK"
            description "Publica mensajes en la cola de notificaciones."
            tags "001 - Fase 1"
        }

        tenantConfigRepository = component "TenantConfigRepository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Gestiona y provee configuraciones, reglas y parámetros por tenant para el servicio."
            tags "001 - Fase 1"
        }
        configManager = component "Configuration Manager" {
            technology "C# .NET 8, AWS SDK"
            description "Obtiene configuraciones y secretos desde TenantConfigRepository y Configuration Platform"
            tags "Configuración" "001 - Fase 1"
        }
    }

    // Procesadores de Canal
    emailProcessor = application "Email Processor" {
        technology "Worker Service, C# .NET 8"
        description "Gestiona el envío de notificaciones email."
        tags "CSharp" "001 - Fase 1"

        consumer = component "Consumer" {
            technology "C# .NET 8, AWS SDK"
            description "Consume mensajes de la cola de notificaciones."
            tags "001 - Fase 1"
        }

        service = component "Service" {
            technology "C# .NET 8"
            description "Contiene la lógica de negocio para el envío de notificaciones de email."
            tags "001 - Fase 1"
        }

        repository = component "Repository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Actualiza estado de notificaciones email."
            tags "001 - Fase 1"
        }

        adapter = component "Adapter" {
            technology "C# .NET 8, AWS SDK"
            description "Adaptador para el proveedor de correo electrónico."
            tags "Integración" "001 - Fase 1"
        }

        attachmentFetcher = component "Attachment Fetcher" {
            technology "C# .NET 8, AWS SDK"
            description "Gestiona la obtención de archivos adjuntos desde el almacenamiento."
            tags "001 - Fase 1"
        }

        tenantConfigRepository = component "TenantConfigRepository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Gestiona y provee configuraciones, reglas y parámetros por tenant para el servicio."
            tags "001 - Fase 1"
        }
        configManager = component "Configuration Manager" {
            technology "C# .NET 8, AWS SDK"
            description "Obtiene configuraciones y secretos desde TenantConfigRepository y Configuration Platform"
            tags "Configuración" "001 - Fase 1"
        }

        channelConfigRepository = component "ChannelConfigRepository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Gestiona y provee configuraciones específicas del canal de email (endpoint, credenciales, proveedor, protocolo, etc.)."
            tags "Configuración" "001 - Fase 1"
        }
    }

    smsProcessor = application "SMS Processor" {
        technology "Worker Service, C# .NET 8"
        description "Gestiona el envío de notificaciones SMS."
        tags "CSharp" "001 - Fase 1"

        consumer = component "Consumer" {
            technology "C# .NET 8, AWS SDK"
            description "Consume mensajes de la cola de notificaciones."
            tags "001 - Fase 1"
        }

        service = component "Service" {
            technology "C# .NET 8"
            description "Contiene la lógica de negocio para el envío de SMS."
            tags "001 - Fase 1"
        }

        repository = component "Repository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Actualiza estado de notificaciones SMS."
            tags "001 - Fase 1"
        }

        adapter = component "Adapter" {
            technology "C# .NET 8, AWS SDK"
            description "Adaptador para el proveedor de SMS."
            tags "Integración" "001 - Fase 1"
        }

        // attachmentFetcher = component "Attachment Fetcher" {
        //     technology "C# .NET 8, AWS SDK"
        //     description "Gestiona la obtención de archivos adjuntos desde el almacenamiento."
        //     tags "001 - Fase 1"
        // }

        tenantConfigRepository = component "TenantConfigRepository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Gestiona y provee configuraciones, reglas y parámetros por tenant para el servicio."
            tags "001 - Fase 1"
        }
        configManager = component "Configuration Manager" {
            technology "C# .NET 8, AWS SDK"
            description "Obtiene configuraciones y secretos desde TenantConfigRepository y Configuration Platform"
            tags "Configuración" "001 - Fase 1"
        }

        channelConfigRepository = component "ChannelConfigRepository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Gestiona y provee configuraciones específicas del canal SMS (endpoint, credenciales, proveedor, protocolo, etc.)."
            tags "Configuración" "001 - Fase 1"
        }
    }

    whatsappProcessor = application "WhatsApp Processor" {
        technology "Worker Service, C# .NET 8"
        description "Gestiona el envío de notificaciones WhatsApp."
        tags "CSharp" "001 - Fase 1"

        consumer = component "Consumer" {
            technology "C# .NET 8, AWS SDK"
            description "Consume mensajes de la cola de notificaciones."
            tags "001 - Fase 1"
        }

        service = component "Service" {
            technology "C# .NET 8"
            description "Contiene la lógica de negocio para el envío de notificaciones WhatsApp."
            tags "001 - Fase 1"
        }

        repository = component "Repository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Actualiza estado de notificaciones WhatsApp."
            tags "001 - Fase 1"
        }

        adapter = component "Adapter" {
            technology "C# .NET 8, AWS SDK"
            description "Adaptador para el proveedor de mensajería WhatsApp."
            tags "Integración" "001 - Fase 1"
        }

        attachmentFetcher = component "Attachment Fetcher" {
            technology "C# .NET 8, AWS SDK"
            description "Gestiona la obtención de archivos adjuntos desde el almacenamiento."
            tags "001 - Fase 1"
        }

        tenantConfigRepository = component "TenantConfigRepository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Gestiona y provee configuraciones, reglas y parámetros por tenant para el servicio."
            tags "001 - Fase 1"
        }
        configManager = component "Configuration Manager" {
            technology "C# .NET 8, AWS SDK"
            description "Obtiene configuraciones y secretos desde TenantConfigRepository y Configuration Platform"
            tags "Configuración" "001 - Fase 1"
        }

        channelConfigRepository = component "ChannelConfigRepository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Gestiona y provee configuraciones específicas del canal WhatsApp (endpoint, credenciales, proveedor, protocolo, etc.)."
            tags "Configuración" "001 - Fase 1"
        }
    }

    pushProcessor = application "Push Processor" {
        technology "Worker Service, C# .NET 8"
        description "Gestiona el envío de notificaciones push."
        tags "CSharp" "001 - Fase 1"

        consumer = component "Consumer" {
            technology "C# .NET 8, AWS SDK"
            description "Consume mensajes de la cola de notificaciones."
            tags "001 - Fase 1"
        }

        service = component "Service" {
            technology "C# .NET 8"
            description "Contiene la lógica de negocio para el envío de notificaciones push."
            tags "001 - Fase 1"
        }

        repository = component "Repository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Actualiza estado de notificaciones push."
            tags "001 - Fase 1"
        }

        adapter = component "Adapter" {
            technology "C# .NET 8, AWS SDK"
            description "Adaptador para el proveedor de notificaciones push."
            tags "Integración" "001 - Fase 1"
        }

        attachmentFetcher = component "Attachment Fetcher" {
            technology "C# .NET 8, AWS SDK"
            description "Gestiona la obtención de archivos adjuntos desde el almacenamiento."
            tags "001 - Fase 1"
        }

        tenantConfigRepository = component "TenantConfigRepository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Gestiona y provee configuraciones, reglas y parámetros por tenant para el servicio."
            tags "001 - Fase 1"
        }
        configManager = component "Configuration Manager" {
            technology "C# .NET 8, AWS SDK"
            description "Obtiene configuraciones y secretos desde TenantConfigRepository y Configuration Platform"
            tags "Configuración" "001 - Fase 1"
        }

        channelConfigRepository = component "ChannelConfigRepository" {
            technology "C# .NET 8, Entity Framework Core"
            description "Gestiona y provee configuraciones específicas del canal Push (endpoint, credenciales, proveedor, protocolo, etc.)."
            tags "Configuración" "001 - Fase 1"
        }
    }

    // Relaciones principales
    api.controller -> api.service "Usa" "" "001 - Fase 1"
    api.service -> api.validator "Usa" "" "001 - Fase 1"
    api.service -> api.queuePublisher "Usa" "" "001 - Fase 1"
    api.queuePublisher -> queue "Encola notificaciones." "AWS SQS" "001 - Fase 1"
    api.attachmentsController -> api.attachmentService "Usa" "" "001 - Fase 1"
    api.attachmentRepository -> db "Registra metadatos de adjuntos" "Entity Framework Core" "001 - Fase 1"
    api.attachmentService -> api.attachmentRepository "Usa" "" "001 - Fase 1"
    api.attachmentService -> api.attachmentManager "Gestiona archivos adjuntos" "" "001 - Fase 1"
    api.attachmentManager -> storage "Sube archivos adjuntos" "AWS S3" "001 - Fase 1"
    api.configManager -> configPlatform.configService "Lee configuraciones y secretos" "" "001 - Fase 1"
    api.configManager -> api.tenantConfigRepository "Lee configuraciones por tenant" "Entity Framework Core" "001 - Fase 1"
    api.tenantConfigRepository -> db "Lee y actualiza configuraciones por tenant" "Entity Framework Core" "001 - Fase 1"

    queue -> notificationProcessor.consumer "Entrega mensajes al Processor." "AWS SQS" "001 - Fase 1"
    notificationProcessor.consumer -> notificationProcessor.service "Usa" "" "001 - Fase 1"
    notificationProcessor.service -> notificationProcessor.messageBuilder "Construye mensaje por canal" "" "001 - Fase 1"
    notificationProcessor.service -> notificationProcessor.adapter "Distribuye por canal" "" "001 - Fase 1"
    notificationProcessor.service -> notificationProcessor.repository "Registra en BD" "Entity Framework Core" "001 - Fase 1"
    notificationProcessor.service -> notificationProcessor.configManager "Obtiene configuración, plantillas y canales" "" "001 - Fase 1"
    notificationProcessor.configManager -> notificationProcessor.templateRepository "Lee plantillas" "Entity Framework Core" "001 - Fase 1"
    notificationProcessor.configManager -> notificationProcessor.tenantConfigRepository "Lee configuración por tenant" "Entity Framework Core" "001 - Fase 1"
    notificationProcessor.configManager -> notificationProcessor.channelConfigRepository "Lee configuración de canales" "Entity Framework Core" "001 - Fase 1"
    notificationProcessor.adapter -> queueEmail "Publica mensajes de Email" "fan-out vía SNS" "SNS, 001 - Fase 1"
    notificationProcessor.adapter -> queueSms "Publica mensajes de SMS" "fan-out vía SNS" "SNS, 001 - Fase 1"
    notificationProcessor.adapter -> queueWhatsapp "Publica mensajes de WhatsApp" "fan-out vía SNS" "SNS, 001 - Fase 1"
    notificationProcessor.adapter -> queuePush "Publica mensajes de Push" "fan-out vía SNS" "SNS, 001 - Fase 1"
    notificationProcessor.repository -> db "Registra mensaje construido" "Entity Framework Core" "001 - Fase 1"
    notificationProcessor.templateRepository -> db "Lee plantillas" "Entity Framework Core" "001 - Fase 1"
    notificationProcessor.tenantConfigRepository -> db "Lee configuración por tenant" "Entity Framework Core" "001 - Fase 1"
    notificationProcessor.channelConfigRepository -> db "Lee configuración de canales" "Entity Framework Core" "001 - Fase 1"
    emailProcessor.repository -> db "Actualiza estado de notificación email" "Entity Framework Core" "001 - Fase 1"
    smsProcessor.repository -> db "Actualiza estado de notificación SMS" "Entity Framework Core" "001 - Fase 1"
    whatsappProcessor.repository -> db "Actualiza estado de notificación WhatsApp" "Entity Framework Core" "001 - Fase 1"
    pushProcessor.repository -> db "Actualiza estado de notificación push" "Entity Framework Core" "001 - Fase 1"
    // notificationProcessor.tenantConfigRepository -> db "Lee y actualiza configuraciones por tenant" "Entity Framework Core" "001 - Fase 1"

    emailProcessor.consumer -> queueEmail "Consume mensajes" "AWS SQS" "001 - Fase 1"
    emailProcessor.consumer -> emailProcessor.service "Usa" "" "001 - Fase 1"
    emailProcessor.service -> emailProcessor.repository "Usa" "" "001 - Fase 1"
    // emailProcessor.repository -> db "Registra estado de notificación" "Entity Framework Core" "001 - Fase 1"
    emailProcessor.service -> emailProcessor.attachmentFetcher "Obtiene adjuntos para envío" "" "001 - Fase 1"
    emailProcessor.attachmentFetcher -> storage "Obtiene archivos adjuntos" "AWS S3" "001 - Fase 1"
    emailProcessor.configManager -> configPlatform.configService "Lee configuraciones y secretos" "" "001 - Fase 1"
    emailProcessor.configManager -> emailProcessor.tenantConfigRepository "Lee configuraciones por tenant" "Entity Framework Core" "001 - Fase 1"
    // emailProcessor.tenantConfigRepository -> db "Lee y actualiza configuraciones por tenant" "Entity Framework Core" "001 - Fase 1"
    emailProcessor.configManager -> emailProcessor.channelConfigRepository "Lee configuraciones de canal" "Entity Framework Core" "001 - Fase 1"
    emailProcessor.channelConfigRepository -> db "Lee configuraciones de canal" "Entity Framework Core" "001 - Fase 1"
    // emailProcessor.service -> emailProcessor.configManager "Obtiene configuraciones de canal" "" "001 - Fase 1"

    smsProcessor.consumer -> queueSms "Consume mensajes" "AWS SQS" "001 - Fase 1"
    smsProcessor.consumer -> smsProcessor.service "Usa" "" "001 - Fase 1"
    smsProcessor.service -> smsProcessor.repository "Usa" "" "001 - Fase 1"
    // smsProcessor.repository -> db "Registra estado de notificación" "Entity Framework Core" "001 - Fase 1"
    // smsProcessor.service -> smsProcessor.attachmentFetcher "Obtiene adjuntos para envío" "" "001 - Fase 1"
    // smsProcessor.attachmentFetcher -> storage "Obtiene archivos adjuntos" "AWS S3" "001 - Fase 1"
    smsProcessor.configManager -> configPlatform.configService "Lee configuraciones y secretos" "" "001 - Fase 1"
    smsProcessor.configManager -> smsProcessor.tenantConfigRepository "Lee configuraciones por tenant" "Entity Framework Core" "001 - Fase 1"
    smsProcessor.tenantConfigRepository -> db "Lee y actualiza configuraciones por tenant" "Entity Framework Core" "001 - Fase 1"
    smsProcessor.configManager -> smsProcessor.channelConfigRepository "Lee configuraciones de canal" "Entity Framework Core" "001 - Fase 1"
    smsProcessor.channelConfigRepository -> db "Lee configuraciones de canal" "Entity Framework Core" "001 - Fase 1"
    // smsProcessor.service -> smsProcessor.configManager "Obtiene configuraciones de canal" "" "001 - Fase 1"

    whatsappProcessor.consumer -> queueWhatsapp "Consume mensajes" "AWS SQS" "001 - Fase 1"
    whatsappProcessor.consumer -> whatsappProcessor.service "Usa" "" "001 - Fase 1"
    whatsappProcessor.service -> whatsappProcessor.repository "Usa" "" "001 - Fase 1"
    // whatsappProcessor.repository -> db "Registra estado de notificación" "Entity Framework Core" "001 - Fase 1"
    whatsappProcessor.service -> whatsappProcessor.attachmentFetcher "Obtiene adjuntos para envío" "" "001 - Fase 1"
    whatsappProcessor.attachmentFetcher -> storage "Obtiene archivos adjuntos" "AWS S3" "001 - Fase 1"
    whatsappProcessor.configManager -> configPlatform.configService "Lee configuraciones y secretos" "" "001 - Fase 1"
    whatsappProcessor.configManager -> whatsappProcessor.tenantConfigRepository "Lee configuraciones por tenant" "Entity Framework Core" "001 - Fase 1"
    whatsappProcessor.tenantConfigRepository -> db "Lee y actualiza configuraciones por tenant" "Entity Framework Core" "001 - Fase 1"
    whatsappProcessor.configManager -> whatsappProcessor.channelConfigRepository "Lee configuraciones de canal" "Entity Framework Core" "001 - Fase 1"
    whatsappProcessor.channelConfigRepository -> db "Lee configuraciones de canal" "Entity Framework Core" "001 - Fase 1"
    // whatsappProcessor.service -> whatsappProcessor.configManager "Obtiene configuraciones de canal" "" "001 - Fase 1"

    pushProcessor.consumer -> queuePush "Consume mensajes" "AWS SQS" "001 - Fase 1"
    pushProcessor.consumer -> pushProcessor.service "Usa" "" "001 - Fase 1"
    pushProcessor.service -> pushProcessor.repository "Usa" "" "001 - Fase 1"
    // pushProcessor.repository -> db "Registra estado de notificación" "Entity Framework Core" "001 - Fase 1"
    pushProcessor.service -> pushProcessor.attachmentFetcher "Obtiene adjuntos para envío" "" "001 - Fase 1"
    pushProcessor.attachmentFetcher -> storage "Obtiene archivos adjuntos" "AWS S3" "001 - Fase 1"
    pushProcessor.configManager -> configPlatform.configService "Lee configuraciones y secretos" "" "001 - Fase 1"
    pushProcessor.configManager -> pushProcessor.tenantConfigRepository "Lee configuraciones por tenant" "Entity Framework Core" "001 - Fase 1"
    pushProcessor.tenantConfigRepository -> db "Lee y actualiza configuraciones por tenant" "Entity Framework Core" "001 - Fase 1"
    pushProcessor.configManager -> pushProcessor.channelConfigRepository "Lee configuraciones de canal" "Entity Framework Core" "001 - Fase 1"
    pushProcessor.channelConfigRepository -> db "Lee configuraciones de canal" "Entity Framework Core" "001 - Fase 1"

    appPeru -> api.controller "Solicita envío de notificación" "HTTPS vía API Gateway" "001 - Fase 1"
    appEcuador -> api.controller "Solicita envío de notificación" "HTTPS vía API Gateway" "001 - Fase 1"
    appColombia -> api.controller "Solicita envío de notificación" "HTTPS vía API Gateway" "001 - Fase 1"
    appMexico -> api.controller "Solicita envío de notificación" "HTTPS vía API Gateway" "001 - Fase 1"

    appPeru -> api.attachmentsController "Gestiona archivos adjuntos" "HTTPS vía API Gateway" "001 - Fase 1"
    appEcuador -> api.attachmentsController "Gestiona archivos adjuntos" "HTTPS vía API Gateway" "001 - Fase 1"
    appColombia -> api.attachmentsController "Gestiona archivos adjuntos" "HTTPS vía API Gateway" "001 - Fase 1"
    appMexico -> api.attachmentsController "Gestiona archivos adjuntos" "HTTPS vía API Gateway" "001 - Fase 1"

    // admin -> configurationApi.templatesController "Gestiona plantillas" "HTTPS vía API Gateway" "001 - Fase 1"
    // admin -> configurationApi.channelsController "Gestiona canales" "HTTPS vía API Gateway" "001 - Fase 1"

    scheduler.worker -> scheduler.service "Usa" "" "001 - Fase 1"
    scheduler.service -> scheduler.repository "Usa" "" "001 - Fase 1"
    scheduler.repository -> db "Lee notificaciones programadas pendientes" "Entity Framework Core" "001 - Fase 1"
    scheduler.publisher -> queue "Encola notificaciones programadas" "AWS SQS" "001 - Fase 1"
    scheduler.service -> scheduler.publisher "Publica notificaciones programadas" "" "001 - Fase 1"
    scheduler.configManager -> configPlatform.configService "Lee configuraciones y secretos" "" "001 - Fase 1"
    scheduler.configManager -> scheduler.tenantConfigRepository "Lee configuraciones por tenant" "Entity Framework Core" "001 - Fase 1"
    scheduler.tenantConfigRepository -> db "Lee y actualiza configuraciones por tenant" "Entity Framework Core" "001 - Fase 1"

    emailProcessor.adapter -> dlq "Encola mensajes fallidos" "AWS SQS" "DLQ 001 - Fase 1"
    smsProcessor.adapter -> dlq "Encola mensajes fallidos" "AWS SQS" "DLQ 001 - Fase 1"
    whatsappProcessor.adapter -> dlq "Encola mensajes fallidos" "AWS SQS" "DLQ 001 - Fase 1"
    pushProcessor.adapter -> dlq "Encola mensajes fallidos" "AWS SQS" "DLQ 001 - Fase 1"

    // Relaciones entre service y adapter de cada canal
    emailProcessor.service -> emailProcessor.adapter "Usa" "" "001 - Fase 1"
    smsProcessor.service -> smsProcessor.adapter "Usa" "" "001 - Fase 1"
    whatsappProcessor.service -> whatsappProcessor.adapter "Usa" "" "001 - Fase 1"
    pushProcessor.service -> pushProcessor.adapter "Usa" "" "001 - Fase 1"

    emailProcessor.adapter -> emailProvider "Envía notificaciones email" "HTTPS" "Integración 001 - Fase 1"
    smsProcessor.adapter -> smsProvider "Envía notificaciones SMS" "HTTPS" "Integración 001 - Fase 1"
    whatsappProcessor.adapter -> whatsappProvider "Envía notificaciones WhatsApp" "HTTPS" "Integración 001 - Fase 1"
    pushProcessor.adapter -> pushProvider "Envía notificaciones push" "HTTPS" "Integración 001 - Fase 1"
}
