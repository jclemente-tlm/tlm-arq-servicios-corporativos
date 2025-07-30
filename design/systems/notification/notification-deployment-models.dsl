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
                tags "Amazon Web Services - Lambda"
                description "Servicio que programa y dispara eventos de notificación en base a reglas y cron."
                properties {
                    "Runtime" "Node.js 18.x"
                    "Memory" "512 MB"
                    "Triggers" "Cron jobs"
                }
                docker = deploymentNode "Docker" {
                    tags "Docker"
                    containerInstance notification.scheduler "DEV,STG,PROD"
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
            sqsNode = deploymentNode "AWS SQS" {
                tags "Amazon Web Services - Simple Queue Service"
                description "SQS principal para orquestar el flujo de eventos de notificación."
                properties {
                    "Max Message Size" "256 KB"
                    "Retention Period" "4 days"
                }
                containerInstance notification.queue "DEV,STG,PROD"
            }

            sqsEmailNode = deploymentNode "AWS SQS - Email" {
                tags "Amazon Web Services - Simple Queue Service"
                description "SQS dedicada para eventos de notificación de correo electrónico."
                properties {
                    "Max Message Size" "256 KB"
                }
                containerInstance notification.queueEmail "DEV,STG,PROD"
            }

            sqsSmsNode = deploymentNode "AWS SQS - SMS" {
                tags "Amazon Web Services - Simple Queue Service"
                description "SQS dedicada para eventos de notificación SMS."
                properties {
                    "Max Message Size" "256 KB"
                    "Retention Period" "4 days"
                }
                containerInstance notification.queueSms "DEV,STG,PROD"
            }

            sqsWhatsappNode = deploymentNode "AWS SQS - WhatsApp" {
                tags "Amazon Web Services - Simple Queue Service"
                description "SQS dedicada para eventos de notificación WhatsApp."
                properties {
                    "Max Message Size" "256 KB"
                    "Retention Period" "4 days"
                }
                containerInstance notification.queueWhatsapp "DEV,STG,PROD"
            }

            sqsPushNode = deploymentNode "AWS SQS - Push" {
                tags "Amazon Web Services - Simple Queue Service"
                description "SQS dedicada para eventos de notificación Push."
                properties {
                    "Max Message Size" "256 KB"
                    "Retention Period" "4 days"
                }
                containerInstance notification.queuePush "DEV,STG,PROD"
            }

            // ====================
            // AWS Storage & DB
            // ====================
            s3Node = deploymentNode "AWS S3" {
                tags "Amazon Web Services - Simple Storage Service"
                description "Bucket S3 para almacenar archivos adjuntos y contenido relacionado a notificaciones."
                properties {
                    "Bucket" "notification-files"
                }
                containerInstance notification.storage "DEV,STG,PROD"
            }

            rdsNode = deploymentNode "AWS RDS" {
                tags "Amazon Web Services - RDS"
                description "Instancia RDS PostgreSQL para persistencia de configuraciones, logs y auditoría de notificaciones."
                properties {
                    "Engine" "PostgreSQL 14"
                    "Instance Type" "DEV: db.t3.micro, STG: db.t3.medium, PROD: db.m5.large"
                    "Storage" "DEV: 20 GB, STG: 50 GB, PROD: 200 GB"
                }
                containerInstance notification.db "DEV,STG,PROD"
            }

            // ====================
            // AWS SNS
            // ====================
            snsInfraNode = infrastructureNode "AWS SNS" {
                tags "Amazon Web Services - Simple Notification Service"
                description "SNS Topic que distribuye eventos de notificación a las colas SQS por canal."
                properties {
                    "Tipo" "SNS Topic"
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
    notificationSystem.aws.region.ecsNotificationProcessor.docker -> notificationSystem.aws.region.snsInfraNode "Publica eventos de notificación"
    notificationSystem.aws.region.snsInfraNode -> notificationSystem.aws.region.sqsEmailNode "Entrega a SQS Email"
    notificationSystem.aws.region.snsInfraNode -> notificationSystem.aws.region.sqsSmsNode "Entrega a SQS SMS"
    notificationSystem.aws.region.snsInfraNode -> notificationSystem.aws.region.sqsWhatsappNode "Entrega a SQS Whatsapp"
    notificationSystem.aws.region.snsInfraNode -> notificationSystem.aws.region.sqsPushNode "Entrega a SQS Push"
}
