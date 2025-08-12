apiGatewayDeployment = deploymentEnvironment "API Gateway Deployment" {
    aws = deploymentNode "Amazon Web Services" {
        tags "AWS"
        description "Infraestructura AWS para el API Gateway"

        region = deploymentNode "us-east-1" {
            tags "Amazon Web Services - Region"
            description "Región principal para todos los entornos"

            lb = infrastructureNode "Load Balancer" {
                technology "Elastic Load Balancer"
                description "Balanceador de carga para el API Gateway"
                tags "Amazon Web Services - Elastic Load Balancing"
            }

            ecsApiGateway = deploymentNode "ECS - API Gateway (Fargate)" {
                tags "Amazon Web Services - Elastic Container Service"
                description "Contenedor de YARP para el API Gateway"
                docker = deploymentNode "Docker" {
                    tags "Docker"
                    containerInstance apiGateway.reverseProxyGateway
                }
            }

            // Redis para rate limiting y cache (si aplica)
            redisNode = deploymentNode "AWS ElastiCache Redis" {
                tags "Amazon Web Services - ElastiCache"
                description "Redis para rate limiting y cache distribuido"
                // No containerInstance, solo infraestructura
            }
        }
    }

    // Relaciones de despliegue
    apiGatewayDeployment.aws.region.lb -> apiGatewayDeployment.aws.region.ecsApiGateway.docker "Redirige tráfico a API Gateway" "HTTPS"
    apiGatewayDeployment.aws.region.ecsApiGateway.docker -> apiGatewayDeployment.aws.region.redisNode "Accede a Redis para rate limiting y cache" "TCP"
}