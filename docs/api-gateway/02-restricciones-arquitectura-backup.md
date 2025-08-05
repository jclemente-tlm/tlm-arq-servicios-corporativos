# 2. Restricciones de la Arquitectura

Esta sección define las restricciones técnicas, organizacionales y operacionales que guían el diseño del API Gateway.

## Restricciones Técnicas

### 🔧 Stack Tecnológico Obligatorio

| Componente | Tecnología | Justificación |
|------------|------------|---------------|
| **Runtime** | .NET 8 LTS | Standard corporativo |
| **Proxy** | YARP | Integración nativa .NET |
| **Contenedores** | Docker + ECS | Estándar de deployment |
| **Base de datos** | PostgreSQL | Standard corporativo |
| **Cache** | Redis | Rendimiento y escalabilidad |

### 🌐 Protocolos y Estándares

- **OAuth2 + OIDC** para autenticación
- **JWT (RS256)** para tokens
- **TLS 1.3** mínimo para transporte
- **HTTP/2** para rendimiento
- **OpenAPI 3.0** para documentación

### 📊 Requisitos de Rendimiento

| Métrica | Requisito | Justificación |
|---------|-----------|---------------|
| **Latencia P95** | < 100ms | Experiencia de usuario |
| **Throughput** | > 5,000 RPS | Carga esperada |
| **CPU utilización** | < 70% promedio | Planificación de capacidad |
| **Disponibilidad** | 99.9% | SLA empresarial |

## Restricciones Organizacionales

### 🏢 Multi-tenancy Obligatorio

- **Aislamiento por país**: Peru, Ecuador, Colombia, México
- **Configuración independiente** por tenant
- **Rate limiting** específico por tenant
- **Datos segregados** por regulaciones locales

### 🔐 Seguridad Corporativa

- **Arquitectura zero trust** - Todo request debe ser autenticado
- **Implementación RBAC** - Roles definidos por tenant
- **Audit logging** completo para compliance
- **Cifrado de datos** en tránsito y reposo

## Restricciones Operacionales

### 🚀 Deployment y DevOps

| Aspecto | Restricción | Impacto |
|---------|-------------|---------|
| **Deployment** | Blue-green solo | Cero tiempo de inactividad |
| **Configuration** | External config store | No hardcoding |
| **Secrets** | AWS Secrets Manager | Cumplimiento de seguridad |
| **Monitoring** | Prometheus + Grafana | Observabilidad estándar |

### ☁️ Cloud Provider

- **Primario**: AWS (ECS, ALB, RDS)
- **Portabilidad**: Diseño agnóstico de proveedor
- **Backup plan**: Multi-cloud ready architecture

### 🔍 Observabilidad Mandatoria

- **Structured logging** con Serilog
- **Distributed tracing** con OpenTelemetry
- **Metrics collection** con Prometheus
- **Alerting** automático en incidentes

## Restricciones de Integración

### 🔗 Servicios Downstream

El API Gateway **SOLO** puede enrutar a estos servicios:

- **Identity Service** (Keycloak)
- **Notification System**
- **Track & Trace**
- **SITA Messaging**

### 📡 External Dependencies

| Servicio | Propósito | Restricción |
|----------|-----------|-------------|
| **Keycloak** | Authentication | Única fuente de verdad |
| **Configuration Platform** | Dynamic config | Polling, no push |
| **AWS Services** | Infrastructure | Regiones específicas |

## Limitaciones Conocidas

### ⚠️ Técnicas

- **Configuration updates**: Máximo cada 30 segundos (polling)
- **Circuit breaker**: Estado compartido entre instancias
- **Rate limiting**: Eventual consistency en cluster

### 💰 Presupuestarias

- **Costo de infraestructura**: Optimización requerida
- **Scaling limits**: Auto-scaling con límites definidos
- **Data transfer**: Minimizar entre regiones

### 📅 Tiempo

- **Fase 1**: Features básicos (6 meses)
- **Fase 2**: Cache distribuido y features avanzados
- **Migration window**: Máximo 4 horas downtime
| **Cross-tenant Access** | Prohibited except admin functions | Security, compliance | Tenant context validation, access controls |
| **Tenant Configuration** | Country-specific routing rules | Requisitos operacionales | Configuration per tenant, feature flags |
| **Shared Infrastructure** | Common gateway instance | Optimización de costos | Multi-tenant aware middleware |

### Compliance y Regulatorio

| Requirement | Standard | Scope | Implementation |
|-------------|----------|-------|----------------|
| **GDPR Compliance** | EU Regulation 2016/679 | European operations | Data residency, audit logs, anonymization |
| **SOX Compliance** | Sarbanes-Oxley Act | Financial access controls | Request logging, change management |
| **Local Privacy Laws** | Per country regulations | Regional operations | Country-specific configurations |
| **PCI DSS** | Payment card security | Financial transactions | Secure data handling, encryption |

### Requisitos Operacionales

| Aspecto | Restricción | Justificación | Implementación |
|---------|-------------|---------------|----------------|
| **24/7 Operations** | Disponibilidad continua | Operaciones aeroportuarias críticas | Despliegues blue-green, circuit breakers |
| **Budget Optimization** | Control de costos mandatorio | Restricciones financieras | Reserved instances, auto-scaling, monitoring |
| **Change Windows** | Limited maintenance windows | Minimizar impacto operacional | Rolling deployments, feature flags |
| **Disaster Recovery** | RTO: 30 minutes, RPO: 5 minutes | Continuidad empresarial | Multi-region deployment, automated failover |

## 2.3 Restricciones de seguridad

### Autenticación y Autorización

| Control | Requirement | Implementation | Validation |
|---------|-------------|----------------|------------|
| **Token Validation** | JWT signature verification | Keycloak public key validation | Token introspection, signature checks |
| **Rate Limiting** | Per-client and global limits | DDoS protection, fair usage | Redis-based counters, sliding windows |
| **IP Allowlisting** | Source IP restrictions | Additional security layer | Configurable IP ranges per tenant |
| **Request Validation** | Input sanitization | Security hardening | Schema validation, input filtering |

### Data Protection

| Aspect | Requirement | Implementation | Monitoring |
|--------|-------------|----------------|------------|
| **Data in Transit** | TLS 1.3 encryption | SSL/TLS termination | Certificate expiry monitoring |
| **Sensitive Headers** | PII header filtering | Data privacy protection | Header inspection, filtering rules |
| **Audit Logging** | Complete request logging | Compliance requirements | Structured logging, log retention |
| **Security Headers** | Standard security headers | OWASP compliance | Header injection, security scanning |

### Network Security

| Control | Purpose | Implementation | Validation |
|---------|---------|----------------|------------|
| **VPC Isolation** | Network segmentation | AWS VPC, security groups | Network topology review |
| **WAF Integration** | Web application firewall | AWS WAF rules | Attack pattern detection |
| **DDoS Protection** | Attack mitigation | AWS Shield Advanced | DDoS simulation testing |
| **Network ACLs** | Traffic filtering | Subnet-level controls | Traffic analysis |

## 2.4 Restricciones específicas YARP

### Configuration Management

| Aspect | Constraint | Implementation | Governance |
|--------|------------|----------------|------------|
| **Dynamic Configuration** | Hot reload without restart | Configuration providers | Change validation, rollback capability |
| **Route Versioning** | API versioning support | Header/path-based routing | Version compatibility testing |
| **Load Balancing** | Soporte para múltiples algoritmos | Round-robin, menos conexiones | Enrutamiento basado en salud |
| **Transforms** | Modificación de request/response | Manipulación de headers, reescritura de paths | Validación de transformaciones |

### Health Checks and Monitoring

| Component | Requirement | Implementation | Alerting |
|-----------|-------------|----------------|----------|
| **Upstream Health** | Monitoreo activo de salud | Endpoints de health HTTP | Alertas de indisponibilidad de servicio |
| **Circuit Breakers** | Tolerancia a fallos | Integración con Polly | Monitoreo de estado de circuitos |
| **Retry Policies** | Patrones de resiliencia | Backoff exponencial | Seguimiento de intentos de reintento |
| **Timeout Management** | Manejo de timeouts de request | Timeouts configurables | Monitoreo de ocurrencia de timeouts |

### Optimización de Rendimiento

| Optimization | Target | Method | Measurement |
|--------------|--------|--------|-------------|
| **Pooling de Conexiones** | Efficient resource usage | HTTP client pooling | Pool utilization metrics |
| **Response Caching** | Reduce backend load | Cache-aside pattern | Cache hit rates |
| **Compression** | Bandwidth optimization | Gzip/Brotli compression | Compression ratios |
| **Keep-Alive** | Connection reuse | HTTP keep-alive | Connection metrics |

## 2.5 Restricciones de integration

### Downstream Services

| Service | Integration Type | Constraints | Implementation |
|---------|------------------|-------------|----------------|
| **Identity Service** | OAuth2/OIDC | Token validation mandatory | JWT introspection, claims processing |
| **Notification Service** | REST API | Rate limiting, circuit breaker | Configuración de cliente HTTP |
| **Track & Trace Service** | REST API | Health monitoring requerido | Configuración de pool de conexiones |
| **SITA Messaging** | REST API | Requisito de alta disponibilidad | Políticas de reintentos, health checks |

### External Systems

| System | Protocol | Constraints | Implementation |
|--------|----------|-------------|----------------|
| **Partner APIs** | REST/SOAP | Authentication, rate limits | API key management, proxy patterns |
| **Government Systems** | Secure protocols | Encryption, certificates | mTLS, certificate validation |
| **Monitoring Tools** | Various protocols | Observability requirements | Metrics exporters, log shippers |

### Service Mesh Integration

| Aspect | Requirement | Implementation | Beneficios |
|--------|-------------|----------------|----------|
| **Service Discovery** | Dynamic service location | Consul/Eureka integration | Automatic failover |
| **Traffic Management** | Advanced routing | Istio/Linkerd compatibility | Canary deployments |
| **Security Policies** | mTLS enforcement | Service mesh security | Zero-trust networking |
| **Observability** | Distributed tracing | OpenTelemetry integration | End-to-end visibility |

## 2.6 Restricciones de deployment

### Containerization

| Aspect | Requirement | Implementation | Validation |
|--------|-------------|----------------|------------|
| **Container Image** | Distroless base images | Security hardening | Vulnerability scanning |
| **Resource Limits** | CPU/memory constraints | Kubernetes limits | Resource monitoring |
| **Health Endpoints** | Liveness/readiness probes | HTTP health checks | Probe configuration |
| **Graceful Shutdown** | Clean termination | SIGTERM handling | Shutdown testing |

### Orchestration

| Component | Technology | Constraint | Configuration |
|-----------|------------|------------|---------------|
| **Container Platform** | AWS ECS Fargate | Serverless requirement | Task definitions, service configuration |
| **Load Balancer** | AWS Application Load Balancer | Alta disponibilidad | Despliegue multi-AZ |
| **Auto Scaling** | ECS Service Auto Scaling | Dynamic scaling | CloudWatch metrics based |
| **Service Discovery** | AWS Cloud Map | Service registration | DNS-based discovery |

### CI/CD Pipeline

| Stage | Requirement | Implementation | Quality Gates |
|-------|-------------|----------------|---------------|
| **Build** | Automated compilation | GitHub Actions | Code quality checks |
| **Test** | Comprehensive testing | Unit, integration, load tests | Coverage thresholds |
| **Security** | Security scanning | SAST, DAST, dependency checks | Vulnerability assessments |
| **Deploy** | Blue-green deployment | ECS rolling updates | Health check validation |

## 2.7 Restricciones de monitoreo

### Observabilidad Mandatoria

| Component | Tool | Purpose | Configuration |
|-----------|------|---------|---------------|
| **Metrics** | CloudWatch + Prometheus | Monitoreo de rendimiento | Custom metrics, dashboards |
| **Logging** | CloudWatch Logs | Centralized logging | Structured JSON logs |
| **Tracing** | AWS X-Ray + OpenTelemetry | Request tracing | Trace correlation |
| **APM** | Application monitoring | Perspectivas de rendimiento | Error tracking, profiling |

### Métricas Empresariales

| Metric | Purpose | Implementation | Alerting |
|--------|---------|----------------|----------|
| **Request Rate** | Traffic monitoring | Counter metrics | Traffic spike detection |
| **Error Rate** | System health | Error ratio calculation | SLA breach alerts |
| **Response Time** | Seguimiento de rendimiento | Histogram metrics | Latency degradation |
| **Tenant Metrics** | Multi-tenant monitoring | Tenant-specific metrics | Per-tenant alerting |

### SLA Monitoring

| SLA Metric | Target | Measurement | Action |
|------------|--------|-------------|--------|
| **Availability** | 99.9% uptime | Health check aggregation | Incident response |
| **Response Time** | p95 < 200ms | Latency percentiles | Optimización de rendimiento |
| **Error Rate** | < 0.1% | Error ratio monitoring | Root cause analysis |
| **Throughput** | 50k req/min | Seguimiento de tasa de requests | Planificación de capacidad |

## 2.8 Impacto en el diseño

### Decisiones Arquitectónicas Derivadas

| Constraint | Design Decision | Trade-off | Mitigation |
|------------|----------------|-----------|------------|
| **Multi-tenant Support** | Tenant-aware middleware | Request processing overhead | Efficient tenant resolution |
| **Alta Disponibilidad** | Diseño sin estado | Complejidad de gestión de sesiones | Almacenamiento externo de sesiones |
| **Security Requirements** | Comprehensive validation | Processing latency | Optimized validation pipelines |
| **Objetivos de Rendimiento** | Caching strategies | Data consistency challenges | Cache invalidation strategies |

### Technology Stack Implications

| Layer | Technology Choice | Constraint Driver | Alternative Considered |
|-------|-------------------|-------------------|----------------------|
| **Gateway Platform** | Microsoft YARP | .NET ecosystem alignment | Envoy Proxy (complexity), NGINX (features) |
| **Runtime** | .NET 8 | Corporate standard | Node.js (expertise), Java (licensing) |
| **Database** | PostgreSQL | ACID compliance | DynamoDB (consistency), Redis (durability) |
| **Caching** | Redis | Requisitos de rendimiento | Memcached (features), Hazelcast (complexity) |

### Consideraciones Operacionales

| Aspect | Implication | Mitigation Strategy |
|--------|-------------|-------------------|
| **Configuration Complexity** | Multi-tenant routing rules | Automation, templating, validation |
| **Security Surface** | Single point of entry | Defense in depth, monitoring, hardening |
| **Cuello de Botella de Rendimiento** | Gateway saturation | Horizontal scaling, caching, optimization |
| **Sobrecarga Operacional** | Complex deployment | Automation, monitoring, documentation |

## Referencias

### Microsoft YARP

- [YARP Documentation](https://microsoft.github.io/reverse-proxy/)
- [YARP Configuration](https://microsoft.github.io/reverse-proxy/articles/config-files.html)
- [YARP Load Balancing](https://microsoft.github.io/reverse-proxy/articles/load-balancing.html)

### AWS Services

- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [AWS Application Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/)
- [AWS CloudWatch](https://docs.aws.amazon.com/cloudwatch/)

### Security Standards

- [OAuth 2.0 (RFC 6749)](https://tools.ietf.org/html/rfc6749)
- [OpenID Connect Core](https://openid.net/specs/openid-connect-core-1_0.html)
- [JWT (RFC 7519)](https://tools.ietf.org/html/rfc7519)

### Compliance

- [GDPR Regulation](https://gdpr-info.eu/)
- [PCI DSS Standards](https://www.pcisecuritystandards.org/)
- [OWASP API Security](https://owasp.org/www-project-api-security/)
| **Equipos Distribuidos** | Desarrollo en múltiples países | Organización existente | Documentación exhaustiva, APIs well-defined |

## 2.3 Restricciones de Desarrollo

| Restricción | Herramienta/Proceso | Enforcement | Excepciones |
|-------------|---------------------|-------------|-------------|
| **Control de Versiones** | Git + GitHub Enterprise | GitHub branch protection | Hotfixes críticos con aprobación |
| **CI/CD Pipeline** | GitHub Actions mandatorio | Quality gates, automated testing | Manual deploys solo en emergencias |
| **Code Quality** | SonarQube quality gates | PR blocks si quality gate falla | Deuda técnica con plan de resolución |
| **Security Scanning** | Checkov + Dependency scanning | Automated en pipeline | False positives con justificación |
| **Testing Coverage** | Mínimo 80% cobertura | PR blocks si coverage < 80% | Legacy code con plan de mejora |

## 2.4 Restricciones de Infraestructura

| Categoría | Restricción | Detalle | Impacto Arquitectónico |
|-----------|-------------|---------|------------------------|
| **Networking** | VPC privada obligatoria | Solo ALB en subnet pública | Security by design, bastion hosts |
| **TLS/SSL** | TLS 1.3 mínimo | Certificados gestionados por ACM | Encryption in transit, performance overhead |
| **Monitoring** | Prometheus + Grafana standard | Custom metrics obligatorias | Observability built-in, dashboards |
| **Logging** | CloudWatch Logs centralizados | Structured logging con Serilog | JSON format, correlation IDs |
| **Backup** | RTO < 5 min, RPO < 1 min | Multi-AZ deployment | Database design, stateless services |

## 2.5 Restricciones de Seguridad

### Autenticación y Autorización

- **JWT Validation:** Validación obligatoria de tokens en cada request
- **Claims Processing:** Extracción de tenant context y roles
- **Token Refresh:** Implementación de refresh token flow
- **Rate Limiting:** Por tenant, usuario y endpoint

### Cifrado y Secretos

- **Secrets Management:** AWS Secrets Manager para API keys
- **Encryption at Rest:** AES-256 para datos sensibles
- **Encryption in Transit:** TLS 1.3 end-to-end
- **Certificate Management:** Rotación automática via ACM

### Auditoría y Compliance

- **Access Logs:** 100% requests loggeados con correlation ID
- **Audit Trail:** Cambios de configuración trackeados
- **Data Residency:** Datos por país en región AWS correspondiente
- **Privacy by Design:** GDPR compliance built-in

## 2.6 Restricciones de Rendimiento

| Métrica | Target | Measurement | Enforcement |
|---------|--------|-------------|-------------|
| **Latency Overhead** | < 10ms p95 | APM monitoring | SLA monitoring, alertas |
| **Throughput** | 10K req/s mínimo | Testing de carga continuo | Presupuestos de rendimiento |
| **Disponibilidad** | 99.9% tiempo de actividad | Health checks, circuit breakers | SLA de respuesta a incidentes |
| **Resource Usage** | CPU < 70%, Memory < 80% | Container metrics | Auto-scaling triggers |
| **Error Rate** | < 0.1% errors | Error tracking, dashboards | Error budgets, postmortems |
