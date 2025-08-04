# 2. Restricciones de la arquitectura

El **API Gateway corporativo** debe operar bajo restricciones técnicas, organizacionales y operacionales específicas que garantizan seguridad, performance y compliance en el ecosistema de servicios corporativos multi-tenant.

## 2.1 Restricciones técnicas

### Plataforma y Runtime

| Restricción | Descripción | Justificación | Impacto Arquitectónico |
|-------------|-------------|---------------|------------------------|
| **YARP como Gateway** | Uso obligatorio de Microsoft YARP | Integración nativa .NET, extensibilidad, performance | Arquitectura middleware pipeline, configuración declarativa |
| **.NET 8 LTS** | Runtime .NET 8 como standard | Estabilidad empresarial, soporte hasta 2026 | Stack unificado, bibliotecas compartidas |
| **AWS ECS Fargate** | Contenedores serverless obligatorios | Escalabilidad automática, no gestión de servidores | Stateless design, health checks requeridos |
| **Application Load Balancer** | AWS ALB para distribución de tráfico | Health checks, SSL termination, path routing | Multi-AZ deployment, certificate management |

### Protocolos y Seguridad

| Protocolo | Versión Requerida | Uso | Implementación |
|-----------|-------------------|-----|----------------|
| **OAuth2** | RFC 6749 compliant | Authorization framework | Client credentials, authorization code flows |
| **JWT** | RFC 7519, RS256 signing | Token format validation | Claims extraction, signature verification |
| **OpenID Connect** | OIDC 1.0 Core | Authentication integration | Keycloak integration, token introspection |
| **TLS** | 1.3 minimum | Transport security | Certificate management, cipher suites |
| **HTTP/2** | HTTP/2 support | Performance optimization | Multiplexing, server push capabilities |

### Performance y Capacidad

| Métrica | Restricción | Justificación | Arquitectura Requerida |
|---------|-------------|---------------|------------------------|
| **Request Throughput** | 50,000 requests/minute | Peak operational loads | Horizontal scaling, connection pooling |
| **Response Latency** | p95 < 200ms | User experience crítica | Optimized routing, caching strategies |
| **Concurrent Connections** | 10,000 simultaneous | Multi-tenant operations | Efficient connection handling |
| **CPU Utilization** | < 70% average | Cost optimization, burst capacity | Resource allocation, auto-scaling |

### Base de Datos y Persistencia

| Componente | Tecnología | Restricción | Propósito |
|------------|------------|-------------|-----------|
| **Configuration Store** | PostgreSQL 15+ | ACID compliance | Route configuration, tenant settings |
| **Caching Layer** | Redis 7.0+ | In-memory performance | Route cache, rate limiting data |
| **Metrics Storage** | CloudWatch + Prometheus | Observability requirement | Performance metrics, alerting |
| **Audit Logs** | CloudWatch Logs | Compliance mandatorio | Request logging, security events |

## 2.2 Restricciones organizacionales

### Multi-tenant Architecture

| Aspecto | Restricción | Justificación | Implementación |
|---------|-------------|---------------|----------------|
| **Tenant Isolation** | Complete separation by country | Regulatory compliance, data sovereignty | Tenant-aware routing, separate downstream services |
| **Cross-tenant Access** | Prohibited except admin functions | Security, compliance | Tenant context validation, access controls |
| **Tenant Configuration** | Country-specific routing rules | Operational requirements | Configuration per tenant, feature flags |
| **Shared Infrastructure** | Common gateway instance | Cost optimization | Multi-tenant aware middleware |

### Compliance y Regulatorio

| Requirement | Standard | Scope | Implementation |
|-------------|----------|-------|----------------|
| **GDPR Compliance** | EU Regulation 2016/679 | European operations | Data residency, audit logs, anonymization |
| **SOX Compliance** | Sarbanes-Oxley Act | Financial access controls | Request logging, change management |
| **Local Privacy Laws** | Per country regulations | Regional operations | Country-specific configurations |
| **PCI DSS** | Payment card security | Financial transactions | Secure data handling, encryption |

### Operational Requirements

| Aspecto | Restricción | Justificación | Implementación |
|---------|-------------|---------------|----------------|
| **24/7 Operations** | Continuous availability | Airport operations critical | Blue-green deployments, circuit breakers |
| **Budget Optimization** | Cost control mandatorio | Financial constraints | Reserved instances, auto-scaling, monitoring |
| **Change Windows** | Limited maintenance windows | Minimize operational impact | Rolling deployments, feature flags |
| **Disaster Recovery** | RTO: 30 minutes, RPO: 5 minutes | Business continuity | Multi-region deployment, automated failover |

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
| **Load Balancing** | Multiple algorithms support | Round-robin, least connections | Health-based routing |
| **Transforms** | Request/response modification | Header manipulation, path rewriting | Transform validation |

### Health Checks and Monitoring

| Component | Requirement | Implementation | Alerting |
|-----------|-------------|----------------|----------|
| **Upstream Health** | Active health monitoring | HTTP health endpoints | Service unavailability alerts |
| **Circuit Breakers** | Fault tolerance | Polly integration | Circuit state monitoring |
| **Retry Policies** | Resilience patterns | Exponential backoff | Retry attempt tracking |
| **Timeout Management** | Request timeout handling | Configurable timeouts | Timeout occurrence monitoring |

### Performance Optimization

| Optimization | Target | Method | Measurement |
|--------------|--------|--------|-------------|
| **Connection Pooling** | Efficient resource usage | HTTP client pooling | Pool utilization metrics |
| **Response Caching** | Reduce backend load | Cache-aside pattern | Cache hit rates |
| **Compression** | Bandwidth optimization | Gzip/Brotli compression | Compression ratios |
| **Keep-Alive** | Connection reuse | HTTP keep-alive | Connection metrics |

## 2.5 Restricciones de integration

### Downstream Services

| Service | Integration Type | Constraints | Implementation |
|---------|------------------|-------------|----------------|
| **Identity Service** | OAuth2/OIDC | Token validation mandatory | JWT introspection, claims processing |
| **Notification Service** | REST API | Rate limiting, circuit breaker | HTTP client configuration |
| **Track & Trace** | REST API | Real-time requirements | WebSocket proxy, connection management |
| **SITA Messaging** | REST API | High availability requirement | Retry policies, health checks |

### External Systems

| System | Protocol | Constraints | Implementation |
|--------|----------|-------------|----------------|
| **Partner APIs** | REST/SOAP | Authentication, rate limits | API key management, proxy patterns |
| **Government Systems** | Secure protocols | Encryption, certificates | mTLS, certificate validation |
| **Monitoring Tools** | Various protocols | Observability requirements | Metrics exporters, log shippers |

### Service Mesh Integration

| Aspect | Requirement | Implementation | Benefits |
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
| **Load Balancer** | AWS Application Load Balancer | High availability | Multi-AZ deployment |
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
| **Metrics** | CloudWatch + Prometheus | Performance monitoring | Custom metrics, dashboards |
| **Logging** | CloudWatch Logs | Centralized logging | Structured JSON logs |
| **Tracing** | AWS X-Ray + OpenTelemetry | Request tracing | Trace correlation |
| **APM** | Application monitoring | Performance insights | Error tracking, profiling |

### Business Metrics

| Metric | Purpose | Implementation | Alerting |
|--------|---------|----------------|----------|
| **Request Rate** | Traffic monitoring | Counter metrics | Traffic spike detection |
| **Error Rate** | System health | Error ratio calculation | SLA breach alerts |
| **Response Time** | Performance tracking | Histogram metrics | Latency degradation |
| **Tenant Metrics** | Multi-tenant monitoring | Tenant-specific metrics | Per-tenant alerting |

### SLA Monitoring

| SLA Metric | Target | Measurement | Action |
|------------|--------|-------------|--------|
| **Availability** | 99.9% uptime | Health check aggregation | Incident response |
| **Response Time** | p95 < 200ms | Latency percentiles | Performance optimization |
| **Error Rate** | < 0.1% | Error ratio monitoring | Root cause analysis |
| **Throughput** | 50k req/min | Request rate tracking | Capacity planning |

## 2.8 Impacto en el diseño

### Decisiones Arquitectónicas Derivadas

| Constraint | Design Decision | Trade-off | Mitigation |
|------------|----------------|-----------|------------|
| **Multi-tenant Support** | Tenant-aware middleware | Request processing overhead | Efficient tenant resolution |
| **High Availability** | Stateless design | Session management complexity | External session storage |
| **Security Requirements** | Comprehensive validation | Processing latency | Optimized validation pipelines |
| **Performance Targets** | Caching strategies | Data consistency challenges | Cache invalidation strategies |

### Technology Stack Implications

| Layer | Technology Choice | Constraint Driver | Alternative Considered |
|-------|-------------------|-------------------|----------------------|
| **Gateway Platform** | Microsoft YARP | .NET ecosystem alignment | Envoy Proxy (complexity), NGINX (features) |
| **Runtime** | .NET 8 | Corporate standard | Node.js (expertise), Java (licensing) |
| **Database** | PostgreSQL | ACID compliance | DynamoDB (consistency), Redis (durability) |
| **Caching** | Redis | Performance requirements | Memcached (features), Hazelcast (complexity) |

### Operational Considerations

| Aspect | Implication | Mitigation Strategy |
|--------|-------------|-------------------|
| **Configuration Complexity** | Multi-tenant routing rules | Automation, templating, validation |
| **Security Surface** | Single point of entry | Defense in depth, monitoring, hardening |
| **Performance Bottleneck** | Gateway saturation | Horizontal scaling, caching, optimization |
| **Operational Overhead** | Complex deployment | Automation, monitoring, documentation |

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
| **Code Quality** | SonarQube quality gates | PR blocks si quality gate falla | Technical debt con plan de resolución |
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

## 2.6 Restricciones de Performance

| Métrica | Target | Measurement | Enforcement |
|---------|--------|-------------|-------------|
| **Latency Overhead** | < 10ms p95 | APM monitoring | SLA monitoring, alertas |
| **Throughput** | 10K req/s mínimo | Load testing continuo | Performance budgets |
| **Availability** | 99.9% uptime | Health checks, circuit breakers | Incident response SLA |
| **Resource Usage** | CPU < 70%, Memory < 80% | Container metrics | Auto-scaling triggers |
| **Error Rate** | < 0.1% errors | Error tracking, dashboards | Error budgets, postmortems |
