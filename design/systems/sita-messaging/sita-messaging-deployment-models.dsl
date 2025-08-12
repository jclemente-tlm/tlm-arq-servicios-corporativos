sitaMessagingDeployment = deploymentEnvironment "SITA Messaging" {
    aws = deploymentNode "Amazon Web Services" {
        tags "AWS"
        description "Infraestructura AWS para SITA Messaging"

        region = deploymentNode "us-east-1" {
            tags "Amazon Web Services - Region"
            description "Región principal para SITA Messaging"

            // lb = infrastructureNode "Load Balancer" {
            //     technology "Elastic Load Balancer"
            //     description "Balanceador de carga para servicios SITA Messaging"
            //     tags "Amazon Web Services - Elastic Load Balancing"
            // }

            ecsEventProcessor = deploymentNode "ECS - Event Processor (Fargate)" {
                tags "Amazon Web Services - Elastic Container Service"
                description "Contenedor Docker para Event Processor"
                docker = deploymentNode "Docker" {
                    tags "Docker"
                    containerInstance sitaMessaging.eventProcessor
                }
            }

            ecsSender = deploymentNode "ECS - Message Sender (Fargate)" {
                tags "Amazon Web Services - Elastic Container Service"
                description "Contenedor Docker para Message Sender"
                docker = deploymentNode "Docker" {
                    tags "Docker"
                    containerInstance sitaMessaging.sender
                }
            }

            rdsNode = deploymentNode "AWS RDS" {
                tags "Amazon Web Services - RDS"
                description "Instancia PostgreSQL para SITA Messaging"
                deploymentNode "PostgreSQL" {
                    tags "Amazon Web Services - Aurora PostgreSQL Instance"
                    containerInstance sitaMessaging.sitaMessagingDatabase
                }
            }

            sqsNode = deploymentNode "AWS SQS" {
                description "Cola de eventos SITA Messaging"
                tags "Amazon Web Services - Simple Queue Service"
                containerInstance sitaMessaging.sitaQueue
            }

            s3Node = deploymentNode "AWS S3" {

                description "Almacenamiento de archivos SITA"
                tags "Amazon Web Services - Simple Storage Service"
                containerInstance sitaMessaging.fileStorage
            }

        }
    }

    // Relaciones de despliegue
    // sitaMessagingDeployment.aws.region.lb -> sitaMessagingDeployment.aws.region.ecsEventProcessor.docker "Redirige tráfico a Event Processor" "HTTPS"
    // sitaMessagingDeployment.aws.region.lb -> sitaMessagingDeployment.aws.region.ecsSender.docker "Redirige tráfico a Message Sender" "HTTPS"
    // sitaMessagingDeployment.aws.region.ecsEventProcessor.docker -> sitaMessagingDeployment.aws.region.rdsNode "Accede a base de datos" "PostgreSQL"
    // sitaMessagingDeployment.aws.region.ecsSender.docker -> sitaMessagingDeployment.aws.region.rdsNode "Accede a base de datos" "PostgreSQL"
    // sitaMessagingDeployment.aws.region.ecsEventProcessor.docker -> sitaMessagingDeployment.aws.region.sqsNode "Consume eventos" "SQS"
    // sitaMessagingDeployment.aws.region.ecsSender.docker -> sitaMessagingDeployment.aws.region.s3Node "Descarga archivos SITA" "S3 API"
    // sitaMessagingDeployment.aws.region.ecsEventProcessor.docker -> sitaMessagingDeployment.aws.region.s3Node "Almacena archivos SITA" "S3 API"
    // sitaMessagingDeployment.aws.region.ecsEventProcessor.docker -> sitaMessagingDeployment.aws.region.prometheus "Expone métricas" "HTTP"
    // sitaMessagingDeployment.aws.region.ecsSender.docker -> sitaMessagingDeployment.aws.region.prometheus "Expone métricas" "HTTP"
}