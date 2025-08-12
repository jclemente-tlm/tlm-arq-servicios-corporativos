notificationSystem = deploymentEnvironment "Notification System" {

    aws = deploymentNode "Amazon Web Services" {
        tags "Amazon Web Services"
        description "Infraestructura AWS que aloja los servicios de notificación."

        region = deploymentNode "us-east-1" {
            tags "Amazon Web Services - Region"
            description "Región AWS us-east-1 (común para DEV, QA y PROD)."

            // dns = infrastructureNode "DNS router" {
            //     technology "Route 53"
            //     description "Routes incoming requests based upon domain name."
            //     tags "Amazon Web Services - Route 53"
            // }

            lb = infrastructureNode "Load Balancer" {
                technology "Elastic Load Balancer"
                description "Distribuye tráfico a los servicios de notificación."
                tags "Amazon Web Services - Elastic Load Balancing"
            }

            // ====================
            // ECS Services
            // ====================
            ecsNotificationApi = deploymentNode "ECS - Notification API (via Fargate)" {
                tags "Amazon Web Services - Elastic Container Service"
                description "Expone endpoints REST para la gestión y envío de notificaciones multicanal."

                docker = deploymentNode "Docker" {
                    tags "Docker"
                    containerInstance notification.api
                }
            }

            ecsNotificationScheduler = deploymentNode "ECS - Notification Scheduler (via Fargate)" {
                tags "Amazon Web Services - Elastic Container Service"
                description "Servicio Worker que programa y dispara eventos de notificación en base a reglas y cron."

                docker = deploymentNode "Docker" {
                    tags "Docker"
                    containerInstance notification.scheduler
                }
            }

            // ====================
            // Lambda Functions
            // ====================
            ecsEmailProcessor = deploymentNode "Lambda Function - Email Processor" {
                tags "Amazon Web Services - AWS Lambda Lambda Function"
                description "Microservicio encargado de procesar y enviar notificaciones por correo electrónico."
                docker = deploymentNode "Docker" {
                    tags "Docker"
                    containerInstance notification.emailProcessor
                }
            }

            ecsSmsProcessor = deploymentNode "Lambda Function - SMS Processor" {
                tags "Amazon Web Services - AWS Lambda Lambda Function"
                description "Microservicio encargado de procesar y enviar notificaciones por SMS."
                docker = deploymentNode "Docker" {
                    tags "Docker"
                    containerInstance notification.smsProcessor
                }
            }

            ecsWhatsappProcessor = deploymentNode "Lambda Function - WhatsApp Processor" {
                tags "Amazon Web Services - AWS Lambda Lambda Function"
                description "Microservicio encargado de procesar y enviar notificaciones por WhatsApp."
                docker = deploymentNode "Docker" {
                    tags "Docker"
                    containerInstance notification.whatsappProcessor
                }
            }

            ecsPushProcessor = deploymentNode "Lambda Function - Push Processor" {
                tags "Amazon Web Services - AWS Lambda Lambda Function"
                description "Microservicio encargado de procesar y enviar notificaciones Push."
                docker = deploymentNode "Docker" {
                    tags "Docker"
                    containerInstance notification.pushProcessor
                }
            }

            // ====================
            // AWS Messaging
            // ====================
            sqsEmailQueue = deploymentNode "SQS - Email Queue" {
                tags "Amazon Web Services - Simple Queue Service"
                description "Cola específica para procesamiento de notificaciones por correo electrónico."
                containerInstance notification.emailQueue
            }

            sqsSmsQueue = deploymentNode "SQS - SMS Queue" {
                tags "Amazon Web Services - Simple Queue Service"
                description "Cola específica para procesamiento de notificaciones SMS con integración a proveedores."
                containerInstance notification.smsQueue
            }

            sqsWhatsappQueue = deploymentNode "SQS - WhatsApp Queue" {
                tags "Amazon Web Services - Simple Queue Service"
                description "Cola específica para procesamiento de notificaciones WhatsApp Business API."
                containerInstance notification.whatsappQueue
            }

            sqsPushQueue = deploymentNode "SQS - Push Queue" {
                tags "Amazon Web Services - Simple Queue Service"
                description "Cola específica para procesamiento de notificaciones push móviles (FCM/APNS)."
                containerInstance notification.pushQueue
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
                containerInstance notification.attachmentStorage
            }

            rdsNode = deploymentNode "AWS RDS" {
                tags "Amazon Web Services - RDS"
                description "Instancia RDS PostgreSQL para persistencia de configuraciones, logs y auditoría de notificaciones."

                deploymentNode "PostgreSQL" {
                    tags "Amazon Web Services - Aurora PostgreSQL Instance"

                    containerInstance notification.notificationDatabase
                }

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
                softwareSystemInstance emailProvider
                softwareSystemInstance smsProvider
                softwareSystemInstance whatsappProvider
                softwareSystemInstance pushProvider
            }
        }
    }

    // ====================
    // Relaciones
    // ====================
    notificationSystem.aws.region.lb -> notificationSystem.aws.region.ecsNotificationApi.docker "Redirige tráfico a API" "HTTPS" "001 - Fase 1"


    notificationSystem.aws.region.ecsNotificationApi -> notificationSystem.aws.region.snsInfraNode "Publica notificación"
    notificationSystem.aws.region.ecsNotificationScheduler -> notificationSystem.aws.region.snsInfraNode "Publica notificación"

    notificationSystem.aws.region.snsInfraNode -> notificationSystem.aws.region.sqsEmailQueue "Entrega a SQS Email"
    notificationSystem.aws.region.snsInfraNode -> notificationSystem.aws.region.sqsSmsQueue "Entrega a SQS SMS"
    notificationSystem.aws.region.snsInfraNode -> notificationSystem.aws.region.sqsWhatsappQueue "Entrega a SQS Whatsapp"
    notificationSystem.aws.region.snsInfraNode -> notificationSystem.aws.region.sqsPushQueue "Entrega a SQS Push"
}
