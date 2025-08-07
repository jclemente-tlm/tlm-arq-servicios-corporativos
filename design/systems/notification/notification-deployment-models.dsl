notificationSystem = deploymentEnvironment "Notification System" {
    deploymentGroup "DEV"
    deploymentGroup "STG"
    deploymentGroup "PROD"

    aws = deploymentNode "Amazon Web Services" {
        tags "Amazon Web Services"
        description "Infraestructura AWS que aloja los servicios de notificación."

        region = deploymentNode "us-east-1" {
            tags "Amazon Web Services - Region"
            description "Región AWS us-east-1 (común para DEV, QA y PROD)."

            // ====================
            // ECS Services - Arquitectura Optimizada (3 Contenedores)
            // ====================
            ecsNotificationApi = deploymentNode "ECS - Notification API (via Fargate)" {
                tags "Amazon Web Services - Elastic Container Service"
                description "API REST que expone endpoints para gestión y envío de notificaciones multicanal."
                properties {
                    "Instance Type" "DEV: t3.small, STG: t3.medium, PROD: m5.large"
                    "CPU" "DEV: 1 vCPU, STG: 2 vCPUs, PROD: 4 vCPUs"
                    "Memory" "DEV: 2 GB, STG: 4 GB, PROD: 8 GB"
                    "Replicas" "DEV: 1, STG: 2, PROD: 3"
                    "Launch Type" "Fargate"
                }
                docker = deploymentNode "Docker" {
                    tags "Docker"
                    containerInstance notification.api "DEV,STG,PROD"
                }
            }

            ecsNotificationProcessor = deploymentNode "ECS - Notification Processor (via Fargate)" {
                tags "Amazon Web Services - Elastic Container Service"
                description "Procesador unificado que incluye scheduling, routing y todos los channel handlers (Email, SMS, WhatsApp, Push)."
                properties {
                    "Instance Type" "DEV: t3.medium, STG: t3.large, PROD: m5.xlarge"
                    "CPU" "DEV: 2 vCPUs, STG: 4 vCPUs, PROD: 8 vCPUs"
                    "Memory" "DEV: 4 GB, STG: 8 GB, PROD: 16 GB"
                    "Replicas" "DEV: 1, STG: 2, PROD: 4"
                    "Launch Type" "Fargate"
                }
                docker = deploymentNode "Docker" {
                    tags "Docker"
                    containerInstance notification.processor "DEV,STG,PROD"
                }
            }

            // ====================
            // Database Services
            // ====================
            rdsNode = deploymentNode "AWS RDS" {
                tags "Amazon Web Services - RDS"
                description "Instancia RDS PostgreSQL para persistencia de configuraciones, outbox pattern, logs y auditoría."
                properties {
                    "Engine" "PostgreSQL 14"
                    "Instance Type" "DEV: db.t3.micro, STG: db.t3.medium, PROD: db.m5.large"
                    "Storage" "DEV: 20 GB, STG: 50 GB, PROD: 200 GB"
                    "Multi-AZ" "STG: No, PROD: Sí"
                    "Backup Retention" "DEV: 1 día, STG: 7 días, PROD: 30 días"
                }
                containerInstance notification.notificationDatabase "DEV,STG,PROD"
            }

            // ====================
            // Storage Services
            // ====================
            s3Node = deploymentNode "S3-Compatible Storage" {
                tags "Amazon Web Services - Simple Storage Service"
                description "Storage agnóstico para adjuntos: S3, Azure Blob, MinIO, FileSystem. Proveedor configurable por tenant."
                properties {
                    "Provider" "Configurable (IStorageService)"
                    "Bucket" "notification-attachments"
                    "Encryption" "AES-256"
                }
                containerInstance notification.attachmentStorage "DEV,STG,PROD"
            }

            // ====================
            // External Providers
            // ====================
            group "Proveedores Externos" {
                emailProviderNode = deploymentNode "Email Providers" {
                    tags "EmailProvider"
                    description "Proveedores de email: SendGrid, SES, SMTP, etc."
                    softwareSystemInstance emailProvider
                }

                smsProviderNode = deploymentNode "SMS Providers" {
                    tags "SmsProvider"
                    description "Proveedores de SMS: Twilio, AWS SNS, etc."
                    softwareSystemInstance smsProvider
                }

                whatsappProviderNode = deploymentNode "WhatsApp Providers" {
                    tags "WhatsAppProvider"
                    description "WhatsApp Business API oficial."
                    softwareSystemInstance whatsappProvider
                }

                pushProviderNode = deploymentNode "Push Providers" {
                    tags "PushProvider"
                    description "Proveedores de push: Firebase, APNs, etc."
                    softwareSystemInstance pushProvider
                }
            }

            # // ====================
            # // Configuration & Monitoring
            # // ====================
            # configurationNode = infrastructureNode "Configuration Platform" {
            #     tags "Configuration"
            #     description "Plataforma agnóstica de configuración: AWS SSM, Azure App Config, Consul, Kubernetes ConfigMaps."
            #     properties {
            #         "Provider" "Configurable (IConfigurationService)"
            #         "Encryption" "KMS/KeyVault/Vault"
            #         "Multi-Tenant" "Sí"
            #     }
            # }

            # monitoringNode = infrastructureNode "Observability Platform" {
            #     tags "Monitoring"
            #     description "Plataforma de observabilidad con métricas, logs y trazas distribuidas."
            #     properties {
            #         "Metrics" "Prometheus/CloudWatch"
            #         "Logging" "ELK Stack/CloudWatch Logs"
            #         "Tracing" "Jaeger/X-Ray"
            #     }
            # }
        }
    }

    // ====================
    // Relaciones de Deployment
    // ====================

    # // API -> Processor communication
    # notificationSystem.aws.region.ecsNotificationApi.docker -> notificationSystem.aws.region.ecsNotificationProcessor.docker "Publica mensajes via outbox pattern"

    # // Processor -> Database
    # notificationSystem.aws.region.ecsNotificationProcessor.docker -> notificationSystem.aws.region.rdsNode "Consume outbox, actualiza estado"

    # // API -> Database
    # notificationSystem.aws.region.ecsNotificationApi.docker -> notificationSystem.aws.region.rdsNode "Persiste requests en outbox"

    # // Storage relationships
    # notificationSystem.aws.region.ecsNotificationApi.docker -> notificationSystem.aws.region.s3Node "Almacena adjuntos"
    # notificationSystem.aws.region.ecsNotificationProcessor.docker -> notificationSystem.aws.region.s3Node "Lee adjuntos para envío"

    # // External provider relationships
    # notificationSystem.aws.region.ecsNotificationProcessor.docker -> notificationSystem.aws.region.extProviders.emailProviderNode "Envía emails"
    # notificationSystem.aws.region.ecsNotificationProcessor.docker -> notificationSystem.aws.region.extProviders.smsProviderNode "Envía SMS"
    # notificationSystem.aws.region.ecsNotificationProcessor.docker -> notificationSystem.aws.region.extProviders.whatsappProviderNode "Envía WhatsApp"
    # notificationSystem.aws.region.ecsNotificationProcessor.docker -> notificationSystem.aws.region.extProviders.pushProviderNode "Envía Push notifications"

    # // Infrastructure relationships
    # notificationSystem.aws.region.reliablePublisherNode -> notificationSystem.aws.region.rdsNode "Implementa outbox pattern"
    # notificationSystem.aws.region.configurationNode -> notificationSystem.aws.region.ecsNotificationApi.docker "Provee configuración"
    # notificationSystem.aws.region.configurationNode -> notificationSystem.aws.region.ecsNotificationProcessor.docker "Provee configuración"
    # notificationSystem.aws.region.monitoringNode -> notificationSystem.aws.region.ecsNotificationApi.docker "Recolecta observabilidad"
    # notificationSystem.aws.region.monitoringNode -> notificationSystem.aws.region.ecsNotificationProcessor.docker "Recolecta observabilidad"
}
