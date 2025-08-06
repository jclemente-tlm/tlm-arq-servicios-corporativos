# 7. Vista de implementación

Esta sección describe el mapping de la arquitectura lógica del **Sistema de Identidad** a la infraestructura física, incluyendo estrategias de deployment, configuración de entornos y consideraciones operacionales.

*[INSERTAR AQUÍ: Diagrama C4 - Deployment View del Sistema de Identidad]*

## 7.1 Estrategia de contenedorización

### Arquitectura de Contenedores

El sistema de identidad se despliega como una suite de contenedores orquestados en AWS ECS Fargate, proporcionando escalabilidad automática y gestión simplificada de infraestructura.

#### Cluster de Proveedor de Identidad Keycloak

```yaml
# Definición de Tarea ECS para Keycloak
{
  "family": "keycloak-cluster",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "1024",
  "memory": "2048",
  "containerDefinitions": [
    {
      "name": "keycloak",
      "image": "quay.io/keycloak/keycloak:23.0.4",
      "portMappings": [
        {
          "containerPort": 8080,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "KC_DB",
          "value": "postgres"
        },
        {
          "name": "KC_DB_URL",
          "value": "jdbc:postgresql://identity-db.cluster-xyz.us-east-1.rds.amazonaws.com:5432/keycloak"
        },
        {
          "name": "KC_CLUSTER",
          "value": "aws"
        },
        {
          "name": "KC_CLUSTER_AWS_REGION",
          "value": "us-east-1"
        },
        {
          "name": "KC_HEALTH_ENABLED",
          "value": "true"
        },
        {
          "name": "KC_METRICS_ENABLED",
          "value": "true"
        }
      ],
      "secrets": [
        {
          "name": "KC_DB_USERNAME",
          "valueFrom": "arn:aws:secretsmanager:us-east-1:account:secret:identity-db-username"
        },
        {
          "name": "KC_DB_PASSWORD",
          "valueFrom": "arn:aws:secretsmanager:us-east-1:account:secret:identity-db-password"
        },
        {
          "name": "KEYCLOAK_ADMIN",
          "valueFrom": "arn:aws:secretsmanager:us-east-1:account:secret:keycloak-admin-user"
        },
        {
          "name": "KEYCLOAK_ADMIN_PASSWORD",
          "valueFrom": "arn:aws:secretsmanager:us-east-1:account:secret:keycloak-admin-password"
        }
      ],
      "healthCheck": {
        "command": [
          "CMD-SHELL",
          "curl -f http://localhost:8080/health/ready || exit 1"
        ],
        "interval": 30,
        "timeout": 5,
        "retries": 3,
        "startPeriod": 60
      },
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/identity-system",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "keycloak"
        }
      }
    }
  ]
}
```

#### Servicio de API de Gestión de Identidad

```yaml
# Definición de Tarea ECS para API de Identidad
{
  "family": "identity-api",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "containerDefinitions": [
    {
      "name": "identity-api",
      "image": "corporativo/identity-api:1.2.0",
      "portMappings": [
        {
          "containerPort": 8080,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "ASPNETCORE_ENVIRONMENT",
          "value": "Production"
        },
        {
          "name": "KEYCLOAK_AUTHORITY",
          "value": "https://identity.talma.pe/auth/realms"
        },
        {
          "name": "KEYCLOAK_ADMIN_URL",
          "value": "https://identity-internal.talma.pe/admin"
        },
        {
          "name": "REDIS_CONNECTION_STRING",
          "value": "identity-cache.xyz.cache.amazonaws.com:6379"
        }
      ],
      "secrets": [
        {
          "name": "ConnectionStrings__DefaultConnection",
          "valueFrom": "arn:aws:secretsmanager:us-east-1:account:secret:identity-api-db-connection"
        },
        {
          "name": "Keycloak__ClientSecret",
          "valueFrom": "arn:aws:secretsmanager:us-east-1:account:secret:keycloak-api-client-secret"
        }
      ],
      "healthCheck": {
        "command": [
          "CMD-SHELL",
          "curl -f http://localhost:8080/health || exit 1"
        ],
        "interval": 30,
        "timeout": 5,
        "retries": 3
      }
    }
  ]
}
```

#### Token Validation Service (gRPC)

```yaml
# ECS Task Definition para Token Validation
{
  "family": "token-validation-service",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "containerDefinitions": [
    {
      "name": "token-validator",
      "image": "corporativo/token-validation:1.1.0",
      "portMappings": [
        {
          "containerPort": 5000,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "ASPNETCORE_ENVIRONMENT",
          "value": "Production"
        },
        {
          "name": "GRPC_PORT",
          "value": "5000"
        },
        {
          "name": "KEYCLOAK_JWKS_URL",
          "value": "https://identity.talma.pe/auth/realms/{realm}/protocol/openid-connect/certs"
        }
      ]
    }
  ]
}
```

## 7.2 Infraestructura AWS

### Network Architecture

```yaml
VPC Configuration:
  VPC_CIDR: "10.0.0.0/16"

  Public Subnets:
    - Subnet-1A: "10.0.1.0/24" (us-east-1a)
    - Subnet-1B: "10.0.2.0/24" (us-east-1b)
    - Subnet-1C: "10.0.3.0/24" (us-east-1c)

  Private Subnets:
    - Subnet-2A: "10.0.11.0/24" (us-east-1a)
    - Subnet-2B: "10.0.12.0/24" (us-east-1b)
    - Subnet-2C: "10.0.13.0/24" (us-east-1c)

  Database Subnets:
    - DB-Subnet-A: "10.0.21.0/24" (us-east-1a)
    - DB-Subnet-B: "10.0.22.0/24" (us-east-1b)
    - DB-Subnet-C: "10.0.23.0/24" (us-east-1c)
```

### Application Load Balancer Configuration

```yaml
# ALB para Keycloak (Public)
PublicLoadBalancer:
  Type: "application"
  Scheme: "internet-facing"
  Subnets: [Subnet-1A, Subnet-1B, Subnet-1C]
  SecurityGroups: [ALB-Public-SG]

  Listeners:
    - Port: 443
      Protocol: HTTPS
      SSL:
        CertificateArn: "arn:aws:acm:us-east-1:account:certificate/identity-cert"
      DefaultAction:
        Type: "forward"
        TargetGroupArn: "arn:aws:elasticloadbalancing:us-east-1:account:targetgroup/keycloak-tg"

    - Port: 80
      Protocol: HTTP
      DefaultAction:
        Type: "redirect"
        RedirectConfig:
          Protocol: HTTPS
          Port: 443
          StatusCode: HTTP_301

# ALB para APIs Internas (Internal)
InternalLoadBalancer:
  Type: "application"
  Scheme: "internal"
  Subnets: [Subnet-2A, Subnet-2B, Subnet-2C]
  SecurityGroups: [ALB-Internal-SG]

  Listeners:
    - Port: 443
      Protocol: HTTPS
      Rules:
        - Condition:
            Path: "/api/v1/identity/*"
          Action:
            TargetGroupArn: "arn:aws:elasticloadbalancing:us-east-1:account:targetgroup/identity-api-tg"
        - Condition:
            Path: "/grpc/token/*"
          Action:
            TargetGroupArn: "arn:aws:elasticloadbalancing:us-east-1:account:targetgroup/token-validation-tg"
```

### RDS PostgreSQL Configuration

```yaml
# RDS Aurora PostgreSQL Cluster
AuroraCluster:
  Engine: "aurora-postgresql"
  EngineVersion: "15.4"
  DatabaseName: "identity_system"

  ClusterConfiguration:
    BackupRetentionPeriod: 7
    PreferredBackupWindow: "03:00-04:00"
    PreferredMaintenanceWindow: "sun:04:00-sun:05:00"
    DeletionProtection: true
    StorageEncrypted: true
    KmsKeyId: "arn:aws:kms:us-east-1:account:key/identity-encryption-key"

  Instances:
    Primary:
      InstanceClass: "db.r6g.large"
      AvailabilityZone: "us-east-1a"
      MonitoringInterval: 60
      PerformanceInsightsEnabled: true

    Reader1:
      InstanceClass: "db.r6g.large"
      AvailabilityZone: "us-east-1b"
      MonitoringInterval: 60
      PerformanceInsightsEnabled: true

  SubnetGroup:
    SubnetIds: [DB-Subnet-A, DB-Subnet-B, DB-Subnet-C]

  SecurityGroups:
    - DatabaseSG:
        InboundRules:
          - Port: 5432
            Protocol: TCP
            SourceSecurityGroupId: "ECS-Tasks-SG"
```

### ElastiCache Redis Configuration

```yaml
# Redis Cluster para Session Storage
RedisCluster:
  Engine: "redis"
  EngineVersion: "7.0"
  NodeType: "cache.r6g.large"
  NumCacheNodes: 3

  Configuration:
    MaxMemoryPolicy: "allkeys-lru"
    Timeout: 300
    TcpKeepAlive: 60

  SubnetGroup:
    SubnetIds: [Subnet-2A, Subnet-2B, Subnet-2C]

  SecurityGroups:
    - CacheSG:
        InboundRules:
          - Port: 6379
            Protocol: TCP
            SourceSecurityGroupId: "ECS-Tasks-SG"

  BackupConfiguration:
    SnapshotRetentionLimit: 5
    SnapshotWindow: "03:00-05:00"

  Monitoring:
    CloudWatchLogsEnabled: true
    SlowLogEnabled: true
```

## 7.3 ECS Service Configuration

### Keycloak Service

```yaml
# ECS Service para Keycloak Cluster
KeycloakService:
  ServiceName: "keycloak-cluster"
  Cluster: "identity-cluster"
  TaskDefinition: "keycloak-cluster:5"

  DesiredCount: 3
  LaunchType: "FARGATE"
  PlatformVersion: "1.4.0"

  NetworkConfiguration:
    AwsvpcConfiguration:
      Subnets: [Subnet-2A, Subnet-2B, Subnet-2C]
      SecurityGroups: [Keycloak-SG]
      AssignPublicIp: "DISABLED"

  LoadBalancers:
    - TargetGroupArn: "arn:aws:elasticloadbalancing:us-east-1:account:targetgroup/keycloak-tg"
      ContainerName: "keycloak"
      ContainerPort: 8080

  ServiceConnectConfiguration:
    Enabled: true
    Namespace: "identity-namespace"
    Services:
      - PortName: "keycloak-port"
        DiscoveryName: "keycloak"

  DeploymentConfiguration:
    MaximumPercent: 200
    MinimumHealthyPercent: 50

  HealthCheckGracePeriodSeconds: 60

  AutoScaling:
    MinCapacity: 2
    MaxCapacity: 10
    TargetTrackingScalingPolicy:
      TargetValue: 70.0
      MetricType: "ECSServiceAverageCPUUtilization"
```

### Identity API Service

```yaml
# ECS Service para Identity Management API
IdentityAPIService:
  ServiceName: "identity-api"
  Cluster: "identity-cluster"
  TaskDefinition: "identity-api:3"

  DesiredCount: 2
  LaunchType: "FARGATE"

  NetworkConfiguration:
    AwsvpcConfiguration:
      Subnets: [Subnet-2A, Subnet-2B]
      SecurityGroups: [Identity-API-SG]
      AssignPublicIp: "DISABLED"

  LoadBalancers:
    - TargetGroupArn: "arn:aws:elasticloadbalancing:us-east-1:account:targetgroup/identity-api-tg"
      ContainerName: "identity-api"
      ContainerPort: 8080

  AutoScaling:
    MinCapacity: 2
    MaxCapacity: 8
    TargetTrackingScalingPolicy:
      TargetValue: 60.0
      MetricType: "ECSServiceAverageCPUUtilization"
```

## 7.4 Security Groups y Network ACLs

### Security Group Definitions

```yaml
# Keycloak Security Group
Keycloak-SG:
  Description: "Security group for Keycloak containers"
  VpcId: "vpc-identity"

  InboundRules:
    - Port: 8080
      Protocol: TCP
      SourceSecurityGroupId: "ALB-Public-SG"
      Description: "HTTP from public ALB"
    - Port: 7800
      Protocol: TCP
      SourceSecurityGroupId: "Keycloak-SG"
      Description: "JGroups clustering"

  OutboundRules:
    - Port: 5432
      Protocol: TCP
      DestinationSecurityGroupId: "DatabaseSG"
      Description: "PostgreSQL access"
    - Port: 6379
      Protocol: TCP
      DestinationSecurityGroupId: "CacheSG"
      Description: "Redis access"
    - Port: 443
      Protocol: TCP
      CidrIp: "0.0.0.0/0"
      Description: "HTTPS outbound"

# Identity API Security Group
Identity-API-SG:
  Description: "Security group for Identity API containers"
  VpcId: "vpc-identity"

  InboundRules:
    - Port: 8080
      Protocol: TCP
      SourceSecurityGroupId: "ALB-Internal-SG"
      Description: "HTTP from internal ALB"
    - Port: 8080
      Protocol: TCP
      SourceSecurityGroupId: "API-Gateway-SG"
      Description: "Direct access from API Gateway"

  OutboundRules:
    - Port: 8080
      Protocol: TCP
      DestinationSecurityGroupId: "Keycloak-SG"
      Description: "Keycloak Admin API"
    - Port: 5432
      Protocol: TCP
      DestinationSecurityGroupId: "DatabaseSG"
      Description: "PostgreSQL access"
```

## 7.5 Deployment Environments

### Development Environment

```yaml
Environment: Development
Purpose: "Developer testing and integration"

Infrastructure:
  Compute:
    - ECS Cluster: "identity-dev"
    - Task CPU: 256
    - Task Memory: 512
    - Desired Count: 1

  Database:
    - RDS Instance: "db.t3.micro"
    - Storage: 20GB GP2
    - Backup: 1 day retention
    - Multi-AZ: false

  Cache:
    - ElastiCache: "cache.t3.micro"
    - Nodes: 1
    - Backup: disabled

Configuration:
  Keycloak:
    - Mode: development
    - Metrics: enabled
    - Admin Console: accessible
    - Sample Data: loaded

  SSL/TLS:
    - Certificate: self-signed
    - Protocol: TLS 1.2+

  Monitoring:
    - CloudWatch: basic metrics
    - Logs: 3 days retention
    - Alerts: none

Access:
  - VPN: required
  - IP Whitelist: office networks
  - Authentication: developer accounts
```

### Staging Environment

```yaml
Environment: Staging
Purpose: "Pre-production testing and QA validation"

Infrastructure:
  Compute:
    - ECS Cluster: "identity-staging"
    - Task CPU: 512
    - Task Memory: 1024
    - Desired Count: 2

  Database:
    - Aurora Cluster: "db.r6g.large"
    - Storage: 50GB
    - Backup: 7 days retention
    - Multi-AZ: true

  Cache:
    - ElastiCache: "cache.r6g.large"
    - Nodes: 2
    - Backup: daily

Configuration:
  Keycloak:
    - Mode: production
    - Clustering: enabled
    - Admin Console: restricted
    - Production Data: anonymized copy

  SSL/TLS:
    - Certificate: AWS ACM (wildcard)
    - Protocol: TLS 1.3

  Monitoring:
    - CloudWatch: detailed metrics
    - Logs: 30 days retention
    - Alerts: critical only

Access:
  - Domain: identity-staging.talma.pe
  - Authentication: staging accounts
  - Limitación de Velocidad: relaxed
```

### Production Environment

```yaml
Environment: Production
Purpose: "Live production workloads"

Infrastructure:
  Compute:
    - ECS Cluster: "identity-production"
    - Task CPU: 1024
    - Task Memory: 2048
    - Desired Count: 3 (minimum)
    - Auto Scaling: 2-10 instances

  Database:
    - Aurora Cluster: "db.r6g.xlarge"
    - Storage: 100GB (auto-scaling)
    - Backup: 30 days retention
    - Multi-AZ: true
    - Read Replicas: 2

  Cache:
    - ElastiCache: "cache.r6g.xlarge"
    - Nodes: 3 (cluster mode)
    - Backup: daily with point-in-time recovery

Configuration:
  Keycloak:
    - Mode: production
    - Clustering: full HA
    - Admin Console: super-restricted
    - Security: hardened

  SSL/TLS:
    - Certificate: AWS ACM (EV certificate)
    - Protocol: TLS 1.3 only
    - HSTS: enabled

  Monitoring:
    - CloudWatch: comprehensive metrics
    - Logs: 1 year retention
    - Alerts: full coverage
    - APM: AWS X-Ray enabled

Access:
  - Domain: identity.talma.pe
  - CDN: CloudFront with WAF
  - Limitación de Velocidad: strict
  - DDoS Protection: AWS Shield Advanced
```

## 7.6 Disaster Recovery y Backup Strategy

### Backup Configuration

```yaml
Database Backups:
  Automated:
    - Frequency: Daily at 03:00 UTC
    - Retention: 30 days production, 7 days staging
    - Cross-Region: us-west-2 (secondary)
    - Encryption: AES-256

  Manual Snapshots:
    - Before major deployments
    - Monthly archival snapshots
    - Retention: 1 year

Configuration Backups:
  Keycloak Realms:
    - Export: Daily automated export
    - Storage: S3 with versioning
    - Format: JSON realm exports
    - Encryption: server-side (SSE-S3)

  Infrastructure:
    - Terraform State: S3 backend with versioning
    - CloudFormation: template versioning
    - ECS Task Definitions: automated backup
```

### Disaster Recovery Plan

```yaml
RTO/RPO Targets:
  Database:
    - RTO: 15 minutes
    - RPO: 5 minutes
    - Method: Aurora cross-region read replicas

  Application Services:
    - RTO: 10 minutes
    - RPO: 0 (stateless)
    - Method: Multi-AZ deployment + auto-scaling

Recovery Procedures:
  Database Failure:
    1. Aurora automatic failover (30 seconds)
    2. DNS update if needed (2 minutes)
    3. Application connection re-establishment

  Regional Failure:
    1. Route 53 health check detects failure
    2. DNS failover to secondary region
    3. Manual promotion of read replica
    4. ECS service restart in backup region

  Complete Recovery Test:
    - Frequency: Quarterly
    - Environment: Dedicated DR environment
    - Validation: Full functionality test
```

*[INSERTAR AQUÍ: Diagrama C4 - Deployment Architecture AWS]*

## 7.7 Monitoring y Observability

### CloudWatch Configuration

```yaml
Metrics:
  ECS Metrics:
    - CPUUtilization
    - MemoryUtilization
    - NetworkRxBytes/NetworkTxBytes
    - TaskCount

  Custom Application Metrics:
    - AuthenticationRate
    - TokenValidationLatency
    - FailedLoginAttempts
    - ActiveSessions
    - DatabaseConnectionPool

  Database Metrics:
    - DatabaseConnections
    - ReadLatency/WriteLatency
    - ReadIOPS/WriteIOPS
    - FreeStorageSpace

Alarms:
  Critical:
    - ECS Service Unhealthy (>50% tasks failing)
    - Database CPU >80% for 5 minutes
    - High error rate (>5% for 2 minutes)
    - Memory utilization >90%

  Warning:
    - CPU utilization >70% for 10 minutes
    - Failed login rate >100/minute
    - Slow query detection (>1 second)
    - Disk space <20%
```

### Logging Strategy

```yaml
Log Aggregation:
  Platform: AWS CloudWatch Logs

  Log Groups:
    - /ecs/identity-system/keycloak
    - /ecs/identity-system/identity-api
    - /ecs/identity-system/token-validation
    - /rds/aurora/postgresql

  Log Structure:
    Format: JSON registro estructurado
    Fields:
      - timestamp
      - level (ERROR, WARN, INFO, DEBUG)
      - component
      - user_id (when applicable)
      - tenant_id
      - trace_id
      - message
      - metadata

  Retention:
    - Production: 1 year
    - Staging: 30 days
    - Development: 7 days

  Analysis:
    - CloudWatch Insights for querying
    - Custom dashboards for trends
    - Automated anomaly detection
```

## Referencias

### AWS Documentation

- [ECS Fargate User Guide](https://docs.aws.amazon.com/AmazonECS/latest/userguide/)
- [Aurora PostgreSQL User Guide](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/)
- [Application Load Balancer Guide](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/)

### Keycloak Deployment

- [Keycloak on Kubernetes](https://www.keycloak.org/getting-started/getting-started-kube)
- [Keycloak Clustering](https://www.keycloak.org/docs/latest/server_installation/#_clustering)
- [Keycloak Production Deployment](https://www.keycloak.org/docs/latest/server_installation/#_production-deployment)

### Architecture References

- [Arc42 Deployment View Template](https://docs.arc42.org/section-7/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
  - Storage: AWS EBS volumes

Configuration:
  - Keycloak: Production mode
  - SSL: Let's Encrypt certificates
  - Monitoring: Prometheus + Grafana
  - Logs: CloudWatch + ELK stack
```

### Production Environment
```yaml
Environment: Production
Infrastructure:
  - Kubernetes: AWS EKS (6 nodes, 3 AZs)
  - Database: AWS RDS PostgreSQL (Multi-AZ + Read Replicas)
  - Cache: AWS ElastiCache Redis (Cluster mode)
  - Storage: AWS EFS for shared volumes

Configuration:
  - Keycloak: Production mode + clustering
  - SSL: Enterprise CA certificates
  - Monitoring: Full observability stack
  - Logs: Centralized + long-term retention
```

## 7.3 Security Implementation

### Network Security
```yaml
Network Policies:
  - Ingress: Only through ALB/Nginx Ingress
  - Internal: Service mesh (Istio)
  - Database: Private subnets only
  - External: VPN/Private Link connections

Security Groups:
  - Web Tier: Ports 80/443 from ALB
  - App Tier: Port 8080 from web tier
  - DB Tier: Port 5432 from app tier
```

### Secrets Management
```yaml
AWS Secrets Manager:
  - Database credentials
  - Keycloak admin passwords
  - JWT signing keys
  - External IdP certificates

Kubernetes Secrets:
  - Service account tokens
  - TLS certificates
  - Configuration values
```

## 7.4 Monitoring & Observability

### Metrics Collection
```yaml
Prometheus Metrics:
  - Keycloak: Custom SPI metrics
  - Identity API: ASP.NET Core metrics
  - Database: PostgreSQL exporter
  - Infrastructure: Node exporter, kube-state-metrics

Key Performance Indicators:
  - Authentication requests/sec
  - Token validation latency
  - Database connection pool usage
  - Cache hit ratios
```

### Logging Strategy
```yaml
Application Logs:
  - Format: Structured JSON (Serilog)
  - Level: INFO in production
  - Rotation: Daily with 30-day retention
  - Correlation: Request ID tracking

Audit Logs:
  - Events: All authentication/authorization
  - Storage: Immutable audit store
  - Retention: 7 years (compliance)
  - Access: Read-only with approval workflow
```

### Trazado Distribuido
```yaml
Jaeger Implementation:
  - Sampling: 1% of requests
  - Span creation: Automatic via OpenTelemetry
  - Storage: Elasticsearch backend
  - UI: Jaeger Query interface
```

## 7.5 Backup & Disaster Recovery

### Database Backup Strategy
```yaml
Automated Backups:
  - Frequency: Every 6 hours
  - Retention: 30 days point-in-time recovery
  - Cross-region: Daily snapshots to DR region
  - Testing: Monthly restore validation

Backup Components:
  - Database: Full + incremental
  - Keycloak config: Realm exports
  - Secrets: Encrypted vault snapshots
  - Application config: Git repository
```

### Disaster Recovery Plan
```yaml
Recovery Time Objectives (RTO):
  - Database failover: < 5 minutes
  - Application restart: < 10 minutes
  - Full region recovery: < 2 hours

Recovery Point Objectives (RPO):
  - Database: < 15 minutes data loss
  - Configuration: < 1 hour data loss
  - Audit logs: Zero data loss (replicated)
```

## 7.6 CI/CD Pipeline

### Build Pipeline
```yaml
GitHub Actions Workflow:

  Build Stage:
    - Code checkout
    - .NET 8 SDK setup
    - Unit test execution
    - Code coverage analysis
    - SonarQube quality gate
    - Docker image build
    - Security scan (Trivy)
    - Image push to registry

  Deploy Stage:
    - Helm chart linting
    - Kubernetes manifest validation
    - Deployment to staging
    - Integration tests
    - Performance tests
    - Security tests (OWASP ZAP)
    - Production deployment (manual approval)
```

### Gestión de Configuración
```yaml
GitOps Approach:
  - Infrastructure: Terraform in separate repo
  - Applications: Helm charts + ArgoCD
  - Configuration: ConfigMaps + Secrets
  - Environment promotion: Git branches (dev->staging->prod)

Keycloak Configuration:
  - Realm definitions: JSON exports in Git
  - Theme customization: Docker image layers
  - Extensions: JAR files in shared volume
  - Auto-deployment: Custom operator
```

## 7.7 Scaling Strategy

### Horizontal Scaling
```yaml
Auto-scaling Configuration:

  Keycloak Pods:
    - Min replicas: 2
    - Max replicas: 10
    - CPU threshold: 70%
    - Memory threshold: 80%
    - Scale-up: 2 pods at a time
    - Scale-down: 1 pod every 5 minutes

  Identity API Pods:
    - Min replicas: 2
    - Max replicas: 8
    - Custom metrics: Active sessions
    - Target: 1000 sessions per pod
```

### Vertical Scaling
```yaml
Resource Scaling:

  Database:
    - Instance types: t3.medium -> r5.xlarge
    - Read replicas: Auto-scaling based on load
    - Connection pooling: PgBouncer

  Cache:
    - Redis cluster: Auto-scaling based on memory
    - Eviction policy: allkeys-lru
    - Max memory: 80% of available
```

## 7.8 Compliance & Governance

### Regulatory Compliance
```yaml
GDPR Compliance:
  - Data encryption: At rest + in transit
  - Data retention: Automated cleanup
  - Right to be forgotten: Automated anonymization
  - Consent management: Audit trail

SOX Compliance:
  - Change management: All changes tracked
  - Access controls: Role-based permissions
  - Financial data: Separate encryption keys
  - Audit trails: Immutable logs
```

### Security Governance
```yaml
Security Controls:
  - Vulnerability scanning: Daily automated scans
  - Penetration testing: Quarterly external audits
  - Security policies: Enforced via OPA/Gatekeeper
  - Incident response: 24/7 SOC monitoring
```

## Referencias
- [Keycloak Production Guide](https://www.keycloak.org/server/configuration-production)
- [Kubernetes Security Mejores Prácticas](https://kubernetes.io/docs/concepts/security/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Arc42 Deployment View](https://docs.arc42.org/section-7/)
