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

        countryAdmin = person "Country Admin" {
            description "Administrador delegado que gestiona usuarios y configuraciones específicas de su país/tenant"
            tags "Admin" "Delegated" "001 - Fase 1"
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
            tags "Colombia" "001 - Fase 1"
        }

        userMexico = person "Usuario México" {
            description "Usuario que usa aplicaciones de México"
            tags "Mexico" "001 - Fase 1"
        }

        consumerGroup = group "Consumidores" {

            appPeru = externalSystem "Aplicaciones Perú" {
                description "Aplicaciones, sistemas y dispositivos de captura"
                tags "Peru" "001 - Fase 1"

                userPeru -> this "Usa"
            }

            appEcuador = externalSystem "Aplicaciones Ecuador" {
                description "Aplicaciones, sistemas y dispositivos de captura"
                tags "Ecuador" "001 - Fase 1"

                userEcuador -> this "Usa"
            }

            appColombia = externalSystem "Aplicaciones Colombia" {
                description "Aplicaciones, sistemas y dispositivos de captura"
                tags "Colombia" "001 - Fase 1"

                userColombia -> this "Usa"
            }

            appMexico = externalSystem "Aplicaciones México" {
                description "Aplicaciones, sistemas y dispositivos de captura"
                tags "Mexico" "001 - Fase 1"

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
                description "Proveedor de notificaciones SMS"
                tags "External" "SMS" "AWS SNS" "001 - Fase 1"
            }

            whatsappProvider = softwareSystem "WhatsApp Notification Provider" {
                description "Proveedor de notificaciones WhatsApp"
                tags "External" "WhatsApp" "Twilio" "001 - Fase 1"
            }

            pushProvider = softwareSystem "Push Notification Provider" {
                description "Proveedor de notificaciones push"
                tags "External" "Push" "Firebase" "001 - Fase 1"
            }
        }

        // // Proveedores de identidad externos
        // externalIdentityGroup = group "Proveedores de Identidad Externos" {

        //     peruNationalIdP = softwareSystem "Reniec - Perú" {
        //         description "Proveedor de identidad nacional de Perú - RENIEC para validación de documentos y datos de ciudadanos"
        //         tags "External, Identity, Government, Peru, 001 - Fase 1"
        //     }

        //     mexicoNationalIdP = softwareSystem "CURP/RFC - México" {
        //         description "Proveedor de identidad nacional de México - CURP/RFC para validación de documentos y datos de ciudadanos"
        //         tags "External, Identity, Government, Mexico, 001 - Fase 1"
        //     }

        //     microsoftAD = softwareSystem "Microsoft Active Directory" {
        //         description "Active Directory corporativo para federación con cuentas empresariales existentes"
        //         tags "External, Identity, Microsoft, LDAP, 001 - Fase 1"
        //     }

        //     googleWorkspace = softwareSystem "Google Workspace" {
        //         description "Google Workspace para federación con cuentas de Google empresariales"
        //         tags "External, Identity, Google, OAuth2, 001 - Fase 1"
        //     }
        // }

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
            description "Plataforma agnóstica de configuración y secretos multi-proveedor"
            tags "External, Multi-Cloud, Configuration, 001 - Fase 1"

            configService = application "Configuration Service" {
                technology "Multi-Provider: AWS SSM, Azure App Config, HashiCorp Consul, Kubernetes ConfigMaps"
                description "Servicio agnóstico de configuración dinámica por tenant y entorno. Proveedor configurable."
                tags "Configuration, Multi-Provider, 001 - Fase 1"
            }

            secretsService = application "Secrets Service" {
                technology "Multi-Provider: AWS Secrets Manager, Azure Key Vault, HashiCorp Vault, Kubernetes Secrets"
                description "Almacén agnóstico de claves, tokens y secretos por servicio. Proveedor configurable."
                tags "Secrets, Multi-Provider, 001 - Fase 1"
            }
        }

        // NOTA: Storage Platform eliminada - abstracción se maneja a nivel de código
        // !include ./systems/infrastructure/storage-platform-models.dsl

        // Microservicios Corporativos
        corporateServicesGroup = group "Servicios Corporativos" {
            !include ./systems/identity/identity-models.dsl
            !include ./systems/notification/notification-models.dsl
            !include ./systems/sita-messaging/sita-messaging-models.dsl
            !include ./systems/track-and-trace/track-and-trace-models.dsl
            !include ./systems/api-gateway/api-gateway-models.dsl

            !include ./systems/notification/notification-deployment-models.dsl

            // ========================================
            // RELACIONES CROSS-SYSTEM
            // ========================================

            // Integración API Gateway -> Identity System (Autenticación y Autorización)
            apiGateway.reverseProxyGateway.securityMiddleware -> identity.keycloakServer "Valida tokens JWT via token introspection" "HTTPS" "001 - Fase 1"

        }

        // Infraestructura de Observabilidad
        // infrastructureGroup = group "Infraestructura" {
            !include ./systems/infrastructure/observability-models.dsl
        // }
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

            exclude countryAdmin
            include "apiGateway -> *"
            include "trackAndTrace -> sitaMessaging"
            title "[Diagrama de Contexto] Servicios Corporativos"
        }

        // Vistas de los microservicios
        !include ./systems/api-gateway/api-gateway-views.dsl
        !include ./systems/identity/identity-views.dsl
        !include ./systems/notification/notification-views.dsl
        !include ./systems/sita-messaging/sita-messaging-views.dsl
        !include ./systems/track-and-trace/track-and-trace-views.dsl

        // Vistas de infraestructura
        !include ./systems/infrastructure/observability-views.dsl

        // Vistas de los sistemas externos
        !include ./systems/notification/notification-deployment-views.dsl

        // Estilos
        !include ./common/styles/branding.dsl
        !include ./common/styles/default.dsl

        // themes https://static.structurizr.com/themes/amazon-web-services-2020.04.30/theme.json
        themes https://static.structurizr.com/themes/amazon-web-services-2023.01.31/theme.json

    }
}
