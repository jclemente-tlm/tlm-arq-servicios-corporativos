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
            // ECS Services
            // ====================
            ecsNotificationApi = deploymentNode "ECS - Notification API (via Fargate)" {
                tags "Amazon Web Services - Elastic Container Service"
                description "Expone endpoints REST para la gestión y envío de notificaciones multicanal."
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
                description "Servicio backend que consume eventos y distribuye mensajes a los canales configurados."
                properties {
                    "Instance Type" "DEV: t3.small, STG: t3.medium, PROD: m5.large"
                    "CPU" "DEV: 1 vCPU, STG: 2 vCPUs, PROD: 4 vCPUs"
                    "Memory" "DEV: 2 GB, STG: 4 GB, PROD: 8 GB"
                    "Replicas" "DEV: 1, STG: 2, PROD: 4"
                    "Launch Type" "Fargate"
                }
                docker = deploymentNode "Docker" {
                    tags "Docker"
                    containerInstance notification.notificationProcessor "DEV,STG,PROD"
                }
            }

            ecsNotificationScheduler = deploymentNode "ECS - Notification Scheduler (via Fargate)" {
                tags "Amazon Web Services - Elastic Container Service"
                description "Servicio Worker que programa y dispara eventos de notificación en base a reglas y cron."
                properties {
                    "Runtime" ".NET 8"
                    "Instance Type" "DEV: t3.nano, STG: t3.small, PROD: t3.medium"
                    "CPU" "DEV: 0.5 vCPU, STG: 1 vCPU, PROD: 2 vCPUs"
                    "Memory" "DEV: 1 GB, STG: 2 GB, PROD: 4 GB"
                    "Replicas" "DEV: 1, STG: 1, PROD: 2"
                    "Launch Type" "Fargate"
                }
                docker = deploymentNode "Docker" {
                    tags "Docker"
                    containerInstance notification.notificationScheduler "DEV,STG,PROD"
                }
            }

            ecsEmailProcessor = deploymentNode "ECS - Email Processor (via Fargate)" {
                tags "Amazon Web Services - Elastic Container Service"
                description "Microservicio encargado de procesar y enviar notificaciones por correo electrónico."
                properties {
                    "Instance Type" "DEV: t3.nano, STG: t3.small, PROD: m5.large"
                    "Replicas" "DEV: 1, STG: 1, PROD: 3"
                    "Launch Type" "Fargate"
                }
                docker = deploymentNode "Docker" {
                    tags "Docker"
                    containerInstance notification.emailProcessor "DEV,STG,PROD"
                }
            }

            ecsSmsProcessor = deploymentNode "ECS - SMS Processor (via Fargate)" {
                tags "Amazon Web Services - Elastic Container Service"
                description "Microservicio encargado de procesar y enviar notificaciones por SMS."
                properties {
                    "Instance Type" "DEV: t3.nano, STG: t3.small, PROD: m5.large"
                    "Replicas" "DEV: 1, STG: 1, PROD: 3"
                    "Launch Type" "Fargate"
                }
                docker = deploymentNode "Docker" {
                    tags "Docker"
                    containerInstance notification.smsProcessor "DEV,STG,PROD"
                }
            }

            ecsWhatsappProcessor = deploymentNode "ECS - WhatsApp Processor (via Fargate)" {
                tags "Amazon Web Services - Elastic Container Service"
                description "Microservicio encargado de procesar y enviar notificaciones por WhatsApp."
                properties {
                    "Instance Type" "DEV: t3.nano, STG: t3.small, PROD: m5.large"
                    "Replicas" "DEV: 1, STG: 1, PROD: 2"
                    "Launch Type" "Fargate"
                }
                docker = deploymentNode "Docker" {
                    tags "Docker"
                    containerInstance notification.whatsappProcessor "DEV,STG,PROD"
                }
            }

            ecsPushProcessor = deploymentNode "ECS - Push Processor (via Fargate)" {
                tags "Amazon Web Services - Elastic Container Service"
                description "Microservicio encargado de procesar y enviar notificaciones Push."
                properties {
                    "Instance Type" "DEV: t3.nano, STG: t3.small, PROD: m5.large"
                    "Replicas" "DEV: 1, STG: 1, PROD: 2"
                    "Launch Type" "Fargate"
                }
                docker = deploymentNode "Docker" {
                    tags "Docker"
                    containerInstance notification.pushProcessor "DEV,STG,PROD"
                }
            }

            // ====================
            // AWS Messaging
            // ====================
            // ====================
            // Reliable Messaging Infrastructure
            // ====================
            reliableMessageStoreNode = deploymentNode "Reliable Message Store" {
                tags "PostgreSQL"
                description "Store de mensajes fiables implementado en PostgreSQL para garantizar cero pérdida de mensajes."
                // Reliable messaging components están contenidos en notificationDatabase
            }

            // Nota: Los componentes de messaging (reliableMessagesTable, deadLetterTable)
            // están implementados como tablas dentro de notificationDatabase con schema messaging

            // ====================
            // AWS Storage & DB
            // ====================
            s3Node = deploymentNode "S3-Compatible Storage" {
                tags "Amazon Web Services - Simple Storage Service"
                description "Storage agnóstico: S3, Azure Blob, MinIO, etc. Proveedor configurable por tenant."
                properties {
                    "Provider" "configurable"
                    "Bucket" "notification-files"
                }
                containerInstance notification.attachmentStorage "DEV,STG,PROD"
            }

            rdsNode = deploymentNode "AWS RDS" {
                tags "Amazon Web Services - RDS"
                description "Instancia RDS PostgreSQL para persistencia de configuraciones, logs y auditoría de notificaciones."
                properties {
                    "Engine" "PostgreSQL 14"
                    "Instance Type" "DEV: db.t3.micro, STG: db.t3.medium, PROD: db.m5.large"
                    "Storage" "DEV: 20 GB, STG: 50 GB, PROD: 200 GB"
                }
                containerInstance notification.notificationDatabase "DEV,STG,PROD"
            }

            // ====================
            // Reliable Message Publisher Node
            // ====================
            reliablePublisherNode = infrastructureNode "Reliable Message Publisher" {
                tags "PostgreSQL"
                description "Infraestructura de publicación de mensajes fiables con garantías ACID."
                properties {
                    "Pattern" "Outbox Pattern"
                    "Garantías" "Exactly-Once Delivery"
                }
            }

            // ====================
            // External Providers
            // ====================
            group "Proveedores Externos" {
                extNode = deploymentNode "Proveedores Externos" {
                    tags "ExternalSystem"
                    description "Nodos que representan proveedores externos para el envío de notificaciones."
                    softwareSystemInstance emailProvider
                    softwareSystemInstance smsProvider
                    softwareSystemInstance whatsappProvider
                    softwareSystemInstance pushProvider
                }
            }
        }
    }

    // ====================
    // Relaciones
    // ====================
    notificationSystem.aws.region.ecsNotificationProcessor.docker -> notificationSystem.aws.region.rdsNode "Accede a base de datos unificada"
    notificationSystem.aws.region.reliablePublisherNode -> notificationSystem.aws.region.rdsNode "Implementa outbox pattern en PostgreSQL"
}
