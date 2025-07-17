workspace {

    properties {
        "structurizr.dslEditor" "false"
    }

    !identifiers hierarchical

    model {

        archetypes {
            externalSystem = softwareSystem {
                description "Sistema externo"
            }
            application = container {
                tag "Application"
            }
            store = container {
                tag "Store"
            }
        }

        admin = person "Admin" {
            description "Usuario administrador que gestiona configuraciones de los sistemas"
            tags "Admin" "001 - Fase 1"
        }

        operationalUser = person "Usuario Operativo" {
            description "Usuario que opera los sistemas corporativos"
            tags "User"
        }

        // Usuarios de las aplicaciones de cada país (Peru, Ecuador, Colombia y México)
        userPeru = person "Usuario\nPerú" {
            description "Usuario que usa aplicaciones de Perú"
            tags "Peru" "001 - Fase 1"
        }

        userEcuador = person "Usuario Ecuador" {
            description "Usuario que usa aplicaciones de Ecuador"
            tags "Ecuador" "001 - Fase 1"
        }

        userColombia = person "Usuario Colombia" {
            description "Usuario que usa aplicaciones de Colombia"
            tags "Colombia"
        }

        userMexico = person "Usuario México" {
            description "Usuario que usa aplicaciones de México"
            tags "Mexico"
        }

        consumerGroup = group "Consumidores" {

            appPeru = externalSystem "Aplicaciones Perú" {
                description "Aplicaciones, sistemas y dispositivos de captura"
                tags "Peru" "001 - Fase 1"

                userPeru -> this "Usa"
            }

            appEcuador = externalSystem "Aplicaciones Ecuador" {
                description "Aplicaciones, sistemas y dispositivos de captura"
                tags "Ecuador"  "001 - Fase 1"

                userEcuador -> this "Usa"
            }

            appColombia = externalSystem "Aplicaciones Colombia" {
                description "Aplicaciones, sistemas y dispositivos de captura"
                tags "Colombia"

                userColombia -> this "Usa"
            }

            appMexico = externalSystem "Aplicaciones México" {
                description "Aplicaciones, sistemas y dispositivos de captura"
                tags "Mexico"

                userMexico -> this "Usa"
            }
        }

        // Proveedores de servicios de notificaciones
        notificationProviderGroup = group "Proveedores de Notificaciones" {

            emailProvider = softwareSystem "Email Notification Provider" {
                description "Proveedor de notificaciones email"
                tags "External, Email, AWS SES, 001 - Fase 1"
            }

            smsProvider = softwareSystem "SMS Notification Provider" {
                description "proveedor de notificaciones SMS"
                tags "External, SMS, AWS SNS"
            }

            whatsappProvider = softwareSystem "WhatsApp Notification Provider" {
                description "Prov. de notificaciones WhatsApp"
                tags "External, WhatsApp, Twilio"
            }

            pushProvider = softwareSystem "Push Notification Provider" {
                description "Proveedor de notificaciones push."
                tags "External, Push, Firebase"
            }
        }

        // Aerolíneas asociadas
        sitaClientsGroup = group "Receptores de mensajería SITA" {
            airlines = softwareSystem "Airlines" {
                description "Sistema de mensajería SITA para aerolíneas"
                tags "External, Airlines, 001 - Fase 1"
            }

            descartes = softwareSystem "Descartes / SITATEX" {
                description "Proveedor de servicios de mensajería SITA"
                tags "External, Descartes, 001 - Fase 1"
            }
        }

        configPlatform = externalSystem  "Configuration Platform" {
            description "Plataforma centralizada de configuración y secretos"
            tags "External, AWS, 001 - Fase 1"

            configService = application "Parameter Store" {
                // technology = "AWS SSM"
                description "Servicio de configuración dinámica por tenant y entorno."
                tags "AWS SSM, Configuration, 001 - Fase 1"
            }

            secretsService = application "Secrets Manager" {
                // technology = "AWS Secrets Manager"
                description "Almacén seguro de claves, tokens y secretos por servicio."
                tags "AWS Secrets Manager, Secrets, 001 - Fase 1"
            }
        }

        // Microservicios Corporativos
        corporateServicesGroup = group "Servicios Corporativos" {
            !include ./systems/api-gateway/api-gateway-models.dsl
            !include ./systems/identity/identity-models.dsl
            !include ./systems/notification/notification-models.dsl
            !include ./systems/sita-messaging/sita-messaging-models.dsl
            !include ./systems/track-and-trace/track-and-trace-models.dsl

            // sitaMessaging.eventProcessor.eventConsumer -> trackAndTrace "Consume eventos de tracking" "RabbitMQ"
        }
    }

    views {
        terminology {
        }

        systemLandscape "corporate_services" {
            include *
            exclude configPlatform
            exclude "* -> identity"
            exclude "* -> notification"
            exclude "* -> sitaMessaging"
            exclude "* -> trackAndTrace"
            include "apiGateway -> *"
            include "sitaMessaging -> trackAndTrace"
            title "[Diagrama de Contexto] Servicios Corporativos"
        }

        // Vistas de los microservicios
        !include ./systems/api-gateway/api-gateway-views.dsl
        !include ./systems/identity/identity-views.dsl
        !include ./systems/notification/notification-views.dsl
        !include ./systems/sita-messaging/sita-messaging-views.dsl
        !include ./systems/track-and-trace/track-and-trace-views.dsl

        // Estilos
        !include ./common/styles/branding.dsl
        !include ./common/styles/default.dsl
    }
}
