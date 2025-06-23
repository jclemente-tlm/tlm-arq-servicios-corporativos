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
            tags "Admin"
        }

        // Usuarios de las aplicaciones de cada país (Peru, Ecuador, Colombia y México)
        userPeru = person "Usuario\nPerú" {
            description "Usuario que usa aplicaciones de Perú"
        }

        userEcuador = person "Usuario Ecuador" {
            description "Usuario que usa aplicaciones de Ecuador"
        }

        userColombia = person "Usuario Colombia" {
            description "Usuario que usa aplicaciones de Colombia"
        }

        userMexico = person "Usuario México" {
            description "Usuario que usa aplicaciones de México"
        }

        consumerGroup = group "Consumidores" {

            appPeru = externalSystem "Aplicaciones Perú" {
                description "Aplicaciones, sistemas y dispositivos de captura"
                tags "Peru"

                userPeru -> this "Usa"
            }

            appEcuador = externalSystem "Aplicaciones Ecuador" {
                description "Aplicaciones, sistemas y dispositivos de captura"
                tags "Ecuador"

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
                tags "External, Email, AWS SES"
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
        iataClientsGroup = group "Receptores de mensajería IATA" {
            airlines = softwareSystem "Airlines" {
                description "Sistema de mensajería IATA para aerolíneas"
                tags "External, Airlines"
            }

            descartes = softwareSystem "Descartes" {
                description "Proveedor de servicios de mensajería IATA"
                tags "External, Descartes"
            }
        }

        // Microservicios Corporativos
        corporateServicesGroup = group "Servicios Corporativos" {
            !include ./systems/api-gateway/api-gateway-models.dsl
            !include ./systems/identity/identity-models.dsl
            !include ./systems/notification/notification-models.dsl
            !include ./systems/iata-messaging/iata-messaging-models.dsl
            !include ./systems/track-and-trace/track-and-trace-models.dsl

            // iataMessaging.eventProcessor.eventConsumer -> trackAndTrace "Consume eventos de tracking" "RabbitMQ"
        }
    }

    views {
        terminology {
        }

        systemLandscape "corporate_services" {
            include *
            exclude "* -> identity"
            exclude "* -> notification"
            exclude "* -> iataMessaging"
            exclude "* -> trackAndTrace"
            include "apiGateway -> *"
            include "iataMessaging -> trackAndTrace"
            title "[Diagrama de Contexto] Servicios Corporativos"
        }

        // Vistas de los microservicios
        !include ./systems/api-gateway/api-gateway-views.dsl
        !include ./systems/identity/identity-views.dsl
        !include ./systems/notification/notification-views.dsl
        !include ./systems/iata-messaging/iata-messaging-views.dsl
        !include ./systems/track-and-trace/track-and-trace-views.dsl

        // Estilos
        !include ./common/styles/branding.dsl
        !include ./common/styles/default.dsl
    }
}
