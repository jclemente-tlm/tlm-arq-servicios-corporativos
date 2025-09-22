sitaMessaging = softwareSystem "SITA Messaging" {
    description "Sistema de generación y entrega de mensajes SITA"
    tags "SITA Messaging" "001 - Fase 1"

    sitaMessagingDatabase = store "SITA Messaging Database" {
        description "Almacena datos de mensajeria SITA y cola de eventos"
        technology "PostgreSQL"
        tags "Database" "PostgreSQL" "001 - Fase 1"
    }

    sitaQueue = store "SITA Message Queue" {
        description "Cola que recibe eventos de Track & Trace para procesar mensajería SITA"
        technology "AWS SQS"
        tags "Message Bus" "SQS" "001 - Fase 1"
    }

    fileStorage = store "SITA File Storage" {
        technology "S3-Compatible Storage"
        description "Almacena archivos SITA generados"
        tags "File Storage" "S3-Compatible" "001 - Fase 1"
    }

    // ========================================
    // EVENT PROCESSOR - INGESTA Y GENERACIÓN
    // ========================================
    eventProcessor = container "Event Processor" {
        technology "C#, .NET 8, Worker Service"
        description "Consume eventos de Track & Trace y genera archivos SITA"
        tags "CSharp" "001 - Fase 1"

        eventConsumer = component "Event Consumer" {
            technology "C#, .NET 8"
            description "Consume y deserializa eventos de Track & Trace desde cola"
            tags "Event Processing" "001 - Fase 1"
        }

        eventOrchestrator = component "Event Orchestrator" {
            technology "C#, .NET 8"
            description "Coordina generación de archivos SITA y registro de mensajes para envío"
            tags "Event Orchestration" "001 - Fase 1"
        }

        messageRepository = component "Message Repository" {
            technology "C#, .NET 8, EF Core"
            description "Registra mensajes SITA para envío posterior"
            tags "EF Core" "001 - Fase 1"
        }

        templateEngine = component "Template Engine" {
            technology "C#, .NET 8, Scriban"
            description "Solicita plantillas y las procesa para generar el contenido SITA, retorna el contenido procesado."
            tags "Template Processing" "001 - Fase 1"
        }

        templateRepository = component "Template Repository" {
            technology "C#, .NET 8, EF Core"
            description "Accede a las plantillas SITA almacenadas en la base de datos por partner y tipo de mensaje. Abstrae el acceso a datos para el Template Engine."
            tags "Repository" "001 - Fase 1"
        }

        fileGenerator = component "File Generator" {
            technology "C#, .NET 8"
            description "Genera archivos SITA finales usando plantillas procesadas"
            tags "File Generation" "001 - Fase 1"
        }

        tenantSettingsRepository = component "TenantSettings Repository" {
            technology "C#, .NET 8, EF Core"
            description "Gestiona configuraciones por tenant del sistema"
            tags "Repository" "TenantSettings"
        }

        secretsAndConfigs = component "SecretsAndConfigs (Cross-Cutting)" {
            technology "NuGet (AWS Secrets Manager, AppConfig)"
            description "Provee acceso centralizado a configuraciones y secretos"
            tags "Configuration" "Cross-Cutting"
        }

        observability = component "Observability\n(Cross-Cutting)" {
            technology "NuGet (Serilog, Prometheus, HealthChecks)"
            description "Provee logging estructurado, métricas y health checks"
            tags "Observability" "Cross-Cutting"
        }
    }

    // ========================================
    // MESSAGE SENDER - ENVÍO A PARTNERS
    // ========================================
    sender = container "Message Sender" {
        technology "C#, .NET 8, Background Service"
        description "Envía archivos SITA generados a partners externos"
        tags "CSharp" "Background Service" "001 - Fase 1"

        sendingWorker = component "Sending Worker" {
            technology "C#, .NET 8, Quartz.NET"
            description "Monitorea mensajes SITA pendientes y orquesta envíos"
            tags "Worker Service" "Scheduling" "001 - Fase 1"
        }

        messageDispatchService = component "Message Dispatch Service" {
            technology "C#, .NET 8"
            description "Orquesta envío programado de archivos SITA a partners externos."
            tags "001 - Fase 1"
        }

        messageRepository = component "Message Repository" {
            technology "C#, .NET 8, EF Core"
            description "Consulta mensajes SITA pendientes de envío y actualiza estados"
            tags "EF Core" "001 - Fase 1"
        }

        partnerConfigRepository = component "PartnerConfig Repository" {
            technology "C#, .NET 8, EF Core"
            description "Gestiona preferencias de envío por partner/tenant (Email o API SITA)"
            tags "Repository" "PartnerConfigs"
        }

        fileFetcher = component "File Fetcher" {
            technology "C#, .NET 8, S3 SDK"
            description "Obtiene archivos SITA generados desde storage para envío a partners"
            tags "File Retrieval" "001 - Fase 1"
        }

        // Canales de envío
        emailSender = component "Email Sender" {
            technology "C#, .NET 8, Notification System API"
            description "Envía archivos SITA por email usando el sistema de notificaciones"
            tags "Email" "001 - Fase 1"
        }

        // Proveedores específicos
        sitaProviderSender = component "SITA Provider Sender" {
            technology "C#, .NET 8, HTTP Client"
            description "Envía archivos SITA a través del servicio/middleware de mensajería SITA (API)."
            tags "Partner Integration" "001 - Fase 1"
        }

        secretsAndConfigs = component "SecretsAndConfigs (Cross-Cutting)" {
            technology "NuGet (AWS Secrets Manager, AppConfig)"
            description "Provee acceso centralizado a configuraciones y secretos"
            tags "Configuration" "Cross-Cutting"
        }

        observability = component "Observability\n(Cross-Cutting)" {
            technology "NuGet (Serilog, Prometheus, HealthChecks)"
            description "Provee logging estructurado, métricas y health checks"
            tags "Observability" "Cross-Cutting"
        }
    }

    // ========================================
    // RELACIONES INTERNAS - ACCESO A DATOS
    // ========================================

    // Event Processor - Flujo principal
    eventProcessor.eventConsumer -> sitaQueue "Consume eventos de Track & Trace" "SQS" "001 - Fase 1"
    eventProcessor.eventConsumer -> eventProcessor.eventOrchestrator "Delega eventos para procesamiento" "" "001 - Fase 1"
    eventProcessor.eventOrchestrator -> eventProcessor.templateEngine "Solicita procesamiento de plantilla" "" "001 - Fase 1"
    eventProcessor.templateEngine -> eventProcessor.templateRepository "Solicita plantilla SITA por partner y tipo" "" "001 - Fase 1"
    eventProcessor.templateRepository -> sitaMessagingDatabase "Lee templates SITA por partner" "EF Core/PostgreSQL" "001 - Fase 1"
    eventProcessor.eventOrchestrator -> eventProcessor.fileGenerator "Solicita generación de archivo SITA con plantilla procesada" "" "001 - Fase 1"
    eventProcessor.fileGenerator -> fileStorage "Almacena archivos SITA generados" "S3-Compatible API" "001 - Fase 1"
    eventProcessor.eventOrchestrator -> eventProcessor.messageRepository "Registra mensaje SITA" "" "001 - Fase 1"
    eventProcessor.messageRepository -> sitaMessagingDatabase "Registra mensajes SITA" "EF Core/PostgreSQL" "001 - Fase 1"

    // Event Processor - Uso de configuración (vía DI, no acceso directo)
    // Nota: Componentes reciben IConfigurationService por constructor
    eventProcessor.eventOrchestrator -> eventProcessor.tenantSettingsRepository "Usa" "" "001 - Fase 1"
    eventProcessor.tenantSettingsRepository -> sitaMessagingDatabase "Lee desde y escribe a" "EF Core/PostgreSQL" "001 - Fase 1"


    // Sender - Flujo principal orquestado por sendingWorker
    sender.fileFetcher -> fileStorage "Obtiene archivos SITA" "S3-Compatible API" "001 - Fase 1"
    sender.sendingWorker -> sender.messageDispatchService "Consulta mensajes SITA pendientes y delega envío" "" "001 - Fase 1"
    sender.messageDispatchService -> sender.partnerConfigRepository "Consulta configuración de partner/tenant" "" "001 - Fase 1"
    sender.partnerConfigRepository -> sitaMessagingDatabase "Lee configuraciones de envío por partner/tenant" "EF Core/PostgreSQL" "001 - Fase 1"
    sender.messageRepository -> sitaMessagingDatabase "Consulta y actualiza mensajes SITA" "EF Core/PostgreSQL" "001 - Fase 1"
    sender.messageDispatchService -> sender.messageRepository "Consulta y actualiza mensajes SITA" "" "001 - Fase 1"
    sender.messageDispatchService -> sender.fileFetcher "Solicita descarga de archivos específicos" "" "001 - Fase 1"
    // sender.messageDispatchService -> sender.partnerSender "Envía mensaje SITA" "C#" "001 - Fase 1"

    // sender.partnerSender -> airlines "Envía archivos a aerolíneas" "HTTPS/Email via Notification System" "001 - Fase 1"
    // sender.partnerSender -> descartes "Envía archivos a Descartes" "HTTPS/FTP" "001 - Fase 1"
    // sender.sendingWorker -> sender.deliveryTracker "Coordina actualización de estado" "In-Memory" "001 - Fase 1"
    // sender.deliveryTracker -> sitaMessagingDatabase.deliveryLog "Actualiza estado de entregas" "PostgreSQL" "001 - Fase 1"

    // Sender - Uso de configuración (vía DI, no acceso directo)
    // Nota: Componentes reciben IConfigurationService por constructor
    # sender.partnerSender -> sitaMessagingDatabase.configuration "Lee credenciales y configuración partners" "PostgreSQL" "001 - Fase 1"
    # sender.deliveryTracker -> sitaMessagingDatabase.configuration "Lee configuración de tracking" "PostgreSQL" "001 - Fase 1"

    // ========================================
    // RELACIONES EXTERNAS - CONFIGURACIÓN
    // ========================================

    // Configuración externa - Solo config managers acceden directamente
    eventProcessor.secretsAndConfigs  -> configPlatform.configService "Lee secretos y configuraciones" "HTTPS/REST" "001 - Fase 1"
    sender.secretsAndConfigs  -> configPlatform.configService "Lee secretos y configuraciones" "HTTPS/REST" "001 - Fase 1"

    eventProcessor.observability  -> observabilitySystem "Envía logs, métricas y health checks" "HTTPS/REST" "001 - Fase 1"
    sender.observability  -> observabilitySystem "Envía logs, métricas y health checks" "HTTPS/REST" "001 - Fase 1"

    sender.messageDispatchService -> sender.emailSender "Envía vía Email" "" "001 - Fase 1"
    sender.messageDispatchService -> sender.sitaProviderSender "Envía vía API SITA" "" "001 - Fase 1"

    sender.emailSender -> airlines "Envía archivos a aerolíneas (Email)" "Notification System API" "001 - Fase 1"
    sender.sitaProviderSender -> descartes "Envía archivos al servicio SITA" "HTTPS/API" "001 - Fase 1"

}
