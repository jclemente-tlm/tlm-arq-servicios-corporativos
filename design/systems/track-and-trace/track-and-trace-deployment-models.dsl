trackAndTraceDeployment = deploymentEnvironment "Track & Trace" {
    aws = deploymentNode "Amazon Web Services" {
        tags "AWS"
        description "Infraestructura AWS para Track & Trace"

        region = deploymentNode "us-east-1" {
            tags "AWS Region"
            description "Región principal para todos los entornos"

            lb = infrastructureNode "Load Balancer" {
                technology "Elastic Load Balancer"
                description "Distribuye tráfico a los servicios de Track & Trace"
                tags "Amazon Web Services - Elastic Load Balancing"
            }

            // ECS Services
            ecsIngestApi = deploymentNode "ECS - Tracking Ingest API (Fargate)" {
                tags "Amazon Web Services - Elastic Container Service"
                description "API REST para ingesta de eventos de tracking"
                docker = deploymentNode "Docker" {
                    tags "Docker"
                    containerInstance trackAndTrace.trackingIngestAPI
                }
            }

            ecsQueryApi = deploymentNode "ECS - Tracking Query API (Fargate)" {
                tags "Amazon Web Services - Elastic Container Service"
                description "API REST para consultas de tracking"
                docker = deploymentNode "Docker" {
                    tags "Docker"
                    containerInstance trackAndTrace.trackingQueryAPI
                }
            }

            ecsEventProcessor = deploymentNode "ECS - Tracking Event Processor (Fargate)" {
                tags "Amazon Web Services - Elastic Container Service"
                description "Procesador de eventos de tracking"
                docker = deploymentNode "Docker" {
                    tags "Docker"
                    containerInstance trackAndTrace.trackingEventProcessor
                }
            }

            ecsDashboard = deploymentNode "ECS - Tracking Dashboard (Fargate)" {
                tags "Amazon Web Services - Elastic Container Service"
                description "Dashboard web para visualización de tracking"
                docker = deploymentNode "Docker" {
                    tags "Docker"
                    containerInstance trackAndTrace.trackingDashboard
                }
            }

            // AWS Messaging
            sqsEventQueue = deploymentNode "SQS - Tracking Event Queue" {
                tags "Amazon Web Services - Simple Queue Service"
                description "Cola de eventos de tracking"
                containerInstance trackAndTrace.trackingEventQueue
            }

            // AWS Storage & DB
            rdsNode = deploymentNode "AWS RDS" {
                tags "Amazon Web Services - RDS"
                description "Instancia PostgreSQL para eventos y configuraciones"
                deploymentNode "PostgreSQL" {
                    tags "Amazon Web Services - Aurora PostgreSQL Instance"
                    containerInstance trackAndTrace.trackingDatabase
                }
            }
        }
    }

    // Relaciones de despliegue
    trackAndTraceDeployment.aws.region.lb -> trackAndTraceDeployment.aws.region.ecsIngestApi.docker "Redirige tráfico a Ingest API" "HTTPS"
    trackAndTraceDeployment.aws.region.lb -> trackAndTraceDeployment.aws.region.ecsQueryApi.docker "Redirige tráfico a Query API" "HTTPS"
    trackAndTraceDeployment.aws.region.lb -> trackAndTraceDeployment.aws.region.ecsDashboard.docker "Redirige tráfico a Dashboard" "HTTPS"
    // trackAndTraceDeployment.aws.region.ecsIngestApi.docker -> trackAndTraceDeployment.aws.region.sqsEventQueue "Publica eventos"
    // trackAndTraceDeployment.aws.region.ecsEventProcessor.docker -> trackAndTraceDeployment.aws.region.sqsEventQueue "Consume eventos"
    // trackAndTraceDeployment.aws.region.ecsEventProcessor.docker -> trackAndTraceDeployment.aws.region.rdsNode "Persiste eventos"
    // trackAndTraceDeployment.aws.region.ecsQueryApi.docker -> trackAndTraceDeployment.aws.region.rdsNode "Consulta eventos"
    // trackAndTraceDeployment.aws.region.ecsDashboard.docker -> trackAndTraceDeployment.aws.region.ecsQueryApi.docker "Consulta API"
}