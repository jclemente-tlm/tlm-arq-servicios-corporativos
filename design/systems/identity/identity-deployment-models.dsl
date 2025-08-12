identityDeployment = deploymentEnvironment "Identity & Access Management System" {
    aws = deploymentNode "Amazon Web Services" {
        tags "AWS"
        description "Infraestructura AWS para el sistema de identidad"

        region = deploymentNode "us-east-1" {
            tags "Amazon Web Services - Region"
            description "Región principal para todos los entornos"

            lb = infrastructureNode "Load Balancer" {
                technology "Elastic Load Balancer"
                description "Balanceador de carga para Keycloak"
                tags "Amazon Web Services - Elastic Load Balancing"
            }

            ecsKeycloak = deploymentNode "ECS - Keycloak Server (Fargate)" {
                tags "Amazon Web Services - Elastic Container Service"
                description "Contenedor Docker oficial de Keycloak"
                docker = deploymentNode "Docker" {
                    tags "Docker"
                    containerInstance identity.keycloakServer
                }
            }

            rdsNode = deploymentNode "AWS RDS" {
                tags "Amazon Web Services - RDS"
                description "Instancia PostgreSQL para Keycloak"
                deploymentNode "PostgreSQL" {
                    tags "Amazon Web Services - Aurora PostgreSQL Instance"
                    containerInstance identity.keycloakDatabase
                }
            }
        }
    }

    // Relaciones de despliegue
    identityDeployment.aws.region.lb -> identityDeployment.aws.region.ecsKeycloak.docker "Redirige tráfico a Keycloak" "HTTPS"
    // identityDeployment.aws.region.ecsKeycloak.docker -> identityDeployment.aws.region.rdsNode "Accede a base de datos" "PostgreSQL JDBC"
}