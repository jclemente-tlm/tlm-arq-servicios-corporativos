# 7. Vista de implementación

## 7.1 Infraestructura y despliegue

### 7.1.1 Arquitectura de contenedores

```yaml
# docker-compose.yml para desarrollo local
version: '3.8'
services:
  api-gateway:
    build:
      context: ./src/ApiGateway
      dockerfile: Dockerfile
    ports:
      - "8080:8080"
      - "8443:8443"
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ASPNETCORE_URLS=http://+:8080;https://+:8443
      - ASPNETCORE_Kestrel__Certificates__Default__Password=password
      - ASPNETCORE_Kestrel__Certificates__Default__Path=/https/certificate.pfx
    volumes:
      - ./certs:/https:ro
      - ./config:/app/config:ro
    networks:
      - gateway-network
    depends_on:
      - redis
      - identity-service
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    command: redis-server --appendonly yes
    volumes:
      - redis-data:/data
    networks:
      - gateway-network
    restart: unless-stopped

  identity-service:
    image: identity-service:latest
    ports:
      - "8081:8080"
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
    networks:
      - gateway-network
    restart: unless-stopped

networks:
  gateway-network:
    driver: bridge

volumes:
  redis-data:
```

### 7.1.2 Dockerfile optimizado

```dockerfile
# Etapa de construcción
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy csproj and restore dependencies
COPY ["ApiGateway.csproj", "."]
RUN dotnet restore "ApiGateway.csproj"

# Copiar código fuente y construir
COPY . .
RUN dotnet build "ApiGateway.csproj" -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish "ApiGateway.csproj" -c Release -o /app/publish \
    --no-restore --no-build

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Install required packages for observability
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy published application
COPY --from=publish /app/publish .

# Set ownership and permissions
RUN chown -R appuser:appuser /app
USER appuser

# Verificación de salud
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Expose ports
EXPOSE 8080
EXPOSE 8443

ENTRYPOINT ["dotnet", "ApiGateway.dll"]
```

### 7.1.3 Despliegue en Kubernetes

```yaml
# api-gateway-deployment.yaml
apiVersion: apps/v1
kind: Despliegue
metadata:
  name: api-gateway
  namespace: corporate-services
  labels:
    app: api-gateway
    version: v1
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: api-gateway
  template:
    metadata:
      labels:
        app: api-gateway
        version: v1
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8080"
        prometheus.io/path: "/metrics"
    spec:
      serviceAccountName: api-gateway-sa
      containers:
      - name: api-gateway
        image: corporate-services/api-gateway:1.0.0
        ports:
        - containerPort: 8080
          name: http
        - containerPort: 8443
          name: https
        env:
        - name: ASPNETCORE_ENVIRONMENT
          value: "Production"
        - name: ConnectionStrings__Redis
          valueFrom:
            secretKeyRef:
              name: api-gateway-secrets
              key: redis-connection
        - name: Authentication__Authority
          value: "https://identity.corporate-services.local"
        - name: Logging__LogLevel__Default
          value: "Information"
        resources:
          solicitudes:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health/live
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 2
        volumeMounts:
        - name: config-volume
          mountPath: /app/config
          readOnly: true
        - name: certificates
          mountPath: /app/certs
          readOnly: true
      volumes:
      - name: config-volume
        configMap:
          name: api-gateway-config
      - name: certificates
        secret:
          secretName: api-gateway-certs
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - api-gateway
              topologyKey: kubernetes.io/hostname

---
apiVersion: v1
kind: Service
metadata:
  name: api-gateway-service
  namespace: corporate-services
  labels:
    app: api-gateway
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 8080
    protocol: TCP
    name: http
  - port: 443
    targetPort: 8443
    protocol: TCP
    name: https
  selector:
    app: api-gateway

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-gateway-ingress
  namespace: corporate-services
  annotations:
    kubernetes.io/ingress.class: "nginx"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/rate-limit: "1000"
    nginx.ingress.kubernetes.io/rate-limit-window: "1m"
spec:
  tls:
  - hosts:
    - api.corporate-services.com
    secretName: api-gateway-tls
  rules:
  - host: api.corporate-services.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: api-gateway-service
            port:
              number: 80
```

## 7.2 Configuración y secretos

### 7.2.1 ConfigMap para configuración

```yaml
# api-gateway-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: api-gateway-config
  namespace: corporate-services
data:
  appsettings.Production.json: |
    {
      "Logging": {
        "LogLevel": {
          "Default": "Information",
          "Microsoft": "Warning",
          "Microsoft.Hosting.Lifetime": "Information"
        }
      },
      "ReverseProxy": {
        "Routes": {
          "identity-route": {
            "ClusterId": "identity-cluster",
            "Match": {
              "Path": "/api/identity/{**catch-all}"
            },
            "Transforms": [
              { "PathPattern": "/api/{**catch-all}" },
              { "RequestHeader": "X-Forwarded-Proto", "Set": "https" }
            ]
          },
          "notification-route": {
            "ClusterId": "notification-cluster",
            "Match": {
              "Path": "/api/notifications/{**catch-all}"
            },
            "Transforms": [
              { "PathPattern": "/api/{**catch-all}" }
            ]
          },
          "track-trace-route": {
            "ClusterId": "track-trace-cluster",
            "Match": {
              "Path": "/api/tracking/{**catch-all}"
            }
          },
          "sita-messaging-route": {
            "ClusterId": "sita-messaging-cluster",
            "Match": {
              "Path": "/api/sita/{**catch-all}"
            }
          }
        },
        "Clusters": {
          "identity-cluster": {
            "LoadBalancingPolicy": "RoundRobin",
            "HealthCheck": {
              "Active": {
                "Enabled": true,
                "Interval": "00:00:30",
                "Timeout": "00:00:05",
                "Policy": "ConsecutiveFailures",
                "Path": "/health"
              }
            },
            "Destinations": {
              "identity-1": {
                "Address": "http://identity-service:8080"
              }
            }
          },
          "notification-cluster": {
            "LoadBalancingPolicy": "LeastRequests",
            "Destinations": {
              "notification-1": {
                "Address": "http://notification-service:8080"
              }
            }
          },
          "track-trace-cluster": {
            "LoadBalancingPolicy": "RoundRobin",
            "Destinations": {
              "track-trace-1": {
                "Address": "http://track-trace-service:8080"
              }
            }
          },
          "sita-messaging-cluster": {
            "LoadBalancingPolicy": "RoundRobin",
            "Destinations": {
              "sita-messaging-1": {
                "Address": "http://sita-messaging-service:8080"
              }
            }
          }
        }
      },
      "Authentication": {
        "Authority": "https://identity.corporate-services.local",
        "RequireHttpsMetadata": true,
        "ValidateAudience": true,
        "ValidateIssuer": true,
        "ClockSkew": "00:05:00"
      },
      "RateLimiting": {
        "DefaultPolicy": {
          "PermitLimit": 1000,
          "Window": "00:01:00",
          "ReplenishmentPeriod": "00:00:01",
          "SegmentsPerWindow": 8,
          "QueueLimit": 100
        },
        "PremiumPolicy": {
          "PermitLimit": 10000,
          "Window": "00:01:00"
        }
      },
      "Observability": {
        "ServiceName": "api-gateway",
        "Version": "1.0.0",
        "Jaeger": {
          "AgentHost": "jaeger-agent",
          "AgentPort": 6831
        },
        "Prometheus": {
          "Enabled": true,
          "Path": "/metrics"
        }
      }
    }
```

### 7.2.2 Secrets management

```yaml
# api-gateway-secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: api-gateway-secrets
  namespace: corporate-services
type: Opaque
data:
  redis-connection: cmVkaXM6Ly9yZWRpcy1jbHVzdGVyOjYzNzk=  # base64 encoded
  jwt-signing-key: <base64-encoded-key>
  certificate-password: <base64-encoded-password>

---
apiVersion: v1
kind: Secret
metadata:
  name: api-gateway-certs
  namespace: corporate-services
type: kubernetes.io/tls
data:
  tls.crt: <base64-encoded-certificate>
  tls.key: <base64-encoded-private-key>
```

## 7.3 Infraestructura como código

### 7.3.1 Terraform para AWS EKS

```hcl
# infrastructure/terraform/api-gateway.tf
resource "aws_eks_cluster" "corporate_services" {
  name     = "corporate-services-cluster"
  role_arn = aws_iam_role.cluster_role.arn
  version  = "1.28"

  vpc_config {
    subnet_ids              = module.vpc.private_subnets
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks.arn
    }
    resources = ["secrets"]
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy,
    aws_iam_role_policy_attachment.vpc_resource_controller,
  ]

  tags = {
    Environment = "production"
    Service     = "api-gateway"
  }
}

resource "aws_eks_node_group" "gateway_nodes" {
  cluster_name    = aws_eks_cluster.corporate_services.name
  node_group_name = "api-gateway-nodes"
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = module.vpc.private_subnets

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.medium"]

  scaling_config {
    desired_size = 3
    max_size     = 10
    min_size     = 2
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    "node-type" = "api-gateway"
  }

  tags = {
    Environment = "production"
    Service     = "api-gateway"
  }
}

# Balanceador de Carga de Aplicación
resource "aws_lb" "api_gateway" {
  name               = "api-gateway-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = true

  tags = {
    Environment = "production"
    Service     = "api-gateway"
  }
}

resource "aws_lb_target_group" "api_gateway" {
  name     = "api-gateway-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Environment = "production"
    Service     = "api-gateway"
  }
}

# ElastiCache Redis Cluster
resource "aws_elasticache_replication_group" "redis_cluster" {
  replication_group_id       = "api-gateway-redis"
  description                = "Redis cluster for API Gateway"

  node_type                  = "cache.t3.micro"
  port                       = 6379
  parameter_group_name       = "default.redis7"

  num_cache_clusters         = 2
  automatic_failover_enabled = true
  multi_az_enabled          = true

  subnet_group_name = aws_elasticache_subnet_group.redis.name
  security_group_ids = [aws_security_group.redis.id]

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  tags = {
    Environment = "production"
    Service     = "api-gateway"
  }
}
```

### 7.3.2 Helm Chart para deployment

```yaml
# helm/api-gateway/Chart.yaml
apiVersion: v2
name: api-gateway
description: Corporate Services API Gateway
type: application
version: 1.0.0
appVersion: "1.0.0"

dependencies:
- name: redis
  version: "17.3.7"
  repository: "https://charts.bitnami.com/bitnami"
  condition: redis.enabled

---
# helm/api-gateway/values.yaml
replicaCount: 3

image:
  repository: corporate-services/api-gateway
  tag: "1.0.0"
  pullPolicy: IfNotPresent

service:
  type: LoadBalancer
  port: 80
  targetPort: 8080

ingress:
  enabled: true
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
  hosts:
    - host: api.corporate-services.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: api-gateway-tls
      hosts:
        - api.corporate-services.com

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
  targetMemoryUtilizationPercentage: 80

redis:
  enabled: true
  auth:
    enabled: true
  master:
    persistence:
      enabled: true
      size: 8Gi

monitoring:
  prometheus:
    enabled: true
    port: 8080
    path: /metrics
  jaeger:
    enabled: true
    agent:
      host: jaeger-agent
      port: 6831

configuration:
  logLevel: "Information"
  environment: "Production"
  authentication:
    authority: "https://identity.corporate-services.local"
    requireHttps: true
  rateLimiting:
    defaultLimit: 1000
    premiumLimit: 10000
    windowMinutes: 1
```

## 7.4 CI/CD Pipeline

### 7.4.1 GitHub Actions workflow

```yaml
# .github/workflows/api-gateway-deploy.yml
name: API Gateway CI/CD

on:
  push:
    branches: [ main, develop ]
    paths: [ 'src/ApiGateway/**' ]
  pull_request:
    branches: [ main ]
    paths: [ 'src/ApiGateway/**' ]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: corporate-services/api-gateway

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4

    - name: Setup .NET
      uses: actions/setup-dotnet@v3
      with:
        dotnet-version: '8.0.x'

    - name: Restore dependencies
      run: dotnet restore src/ApiGateway/ApiGateway.csproj

    - name: Build
      run: dotnet build src/ApiGateway/ApiGateway.csproj --no-restore

    - name: Test
      run: dotnet test src/ApiGateway.Tests/ApiGateway.Tests.csproj --no-build --verbosity normal --collect:"XPlat Code Coverage"

    - name: SonarCloud Scan
      uses: SonarSource/sonarcloud-github-action@master
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}

  security-scan:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4

    - name: Run Trivy vulnerability scanner
      uses: aquasecurity/trivy-action@master
      with:
        scan-type: 'fs'
        scan-ref: 'src/ApiGateway'
        format: 'sarif'
        output: 'trivy-results.sarif'

    - name: Upload Trivy scan results
      uses: github/codeql-action/upload-sarif@v2
      with:
        sarif_file: 'trivy-results.sarif'

  build-and-push:
    needs: [test, security-scan]
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'

    steps:
    - uses: actions/checkout@v4

    - name: Log in to Container Registry
      uses: docker/login-action@v2
      with:
        registry: ${{ env.REGISTRY }}
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}

    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v4
      with:
        images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
        tags: |
          type=ref,event=branch
          type=ref,event=pr
          type=sha
          type=raw,value=latest,enable={{is_default_branch}}

    - name: Build and push Docker image
      uses: docker/build-push-action@v4
      with:
        context: src/ApiGateway
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}

  deploy:
    needs: build-and-push
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'

    steps:
    - uses: actions/checkout@v4

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1

    - name: Update kubeconfig
      run: aws eks update-kubeconfig --name corporate-services-cluster

    - name: Deploy to EKS
      run: |
        helm upgrade --install api-gateway ./helm/api-gateway \
          --namespace corporate-services \
          --create-namespace \
          --set image.tag=${{ github.sha }} \
          --set environment=production \
          --wait

    - name: Verify deployment
      run: |
        kubectl rollout status deployment/api-gateway -n corporate-services
        kubectl get pods -n corporate-services -l app=api-gateway
```

## 7.5 Monitoring y observabilidad

### 7.5.1 Prometheus configuration

```yaml
# monitoring/prometheus/prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "api-gateway-alerts.yml"

scrape_configs:
  - job_name: 'api-gateway'
    kubernetes_sd_configs:
      - role: endpoints
        namespaces:
          names:
            - corporate-services
    relabel_configs:
      - source_labels: [__meta_kubernetes_service_name]
        action: keep
        regex: api-gateway-service
      - source_labels: [__meta_kubernetes_endpoint_port_name]
        action: keep
        regex: http
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093
```

### 7.5.2 Alerting rules

```yaml
# monitoring/prometheus/api-gateway-alerts.yml
groups:
- name: api-gateway
  rules:
  - alert: APIGatewayHighErrorRate
    expr: (rate(http_requests_total{job="api-gateway",code=~"5.."}[5m]) / rate(http_requests_total{job="api-gateway"}[5m])) > 0.05
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: "API Gateway error rate is above 5%"
      description: "API Gateway error rate is {{ $value | humanizePercentage }} for the last 5 minutes"

  - alert: APIGatewayHighLatency
    expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket{job="api-gateway"}[5m])) > 1
    for: 10m
    labels:
      severity: warning
    annotations:
      summary: "API Gateway 95th percentile latency is high"
      description: "API Gateway 95th percentile latency is {{ $value }}s"

  - alert: APIGatewayDown
    expr: up{job="api-gateway"} == 0
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "API Gateway is down"
      description: "API Gateway has been down for more than 1 minute"
```
