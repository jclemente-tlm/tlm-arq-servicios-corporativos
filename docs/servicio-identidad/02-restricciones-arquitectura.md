# 2. Restricciones de la arquitectura

El **Sistema de Identidad** debe cumplir con restricciones técnicas, de seguridad, regulatorias y organizacionales críticas para la gestión de identidades corporativas. Estas restricciones definen las decisiones arquitectónicas fundamentales del sistema.

## 2.1 Restricciones técnicas

### Plataforma de Identity Provider

| Restricción | Descripción | Justificación | Impacto Arquitectónico |
|-------------|-------------|---------------|------------------------|
| **Keycloak Obligatorio** | Uso de Keycloak 23+ como IdP principal | Estándar corporativo, features empresariales | Arquitectura basada en Keycloak realms |
| **Base de Datos PostgreSQL** | Base de datos PostgreSQL para Keycloak | Robustez, escalabilidad, expertise del equipo | Esquema Keycloak nativo, optimizaciones específicas |
| **Despliegue Docker** | Despliegue en contenedores Docker | Estandardización DevOps, portabilidad | Containerized Keycloak, orchestration con Kubernetes |
| **Alta Disponibilidad** | Configuración activo-pasivo mínima | SLA 99.9%, tolerancia a fallos | Clustering, balanceo de carga, replicación de sesiones |

### Protocolos y Estándares de Seguridad

| Protocolo | Versión Requerida | Uso | Implementación |
|-----------|-------------------|-----|----------------|
| **OAuth2** | RFC 6749 compliant | Authorization framework | Authorization Code, Client Credentials flows |
| **OpenID Connect** | OIDC 1.0 Core | Authentication layer | ID tokens, UserInfo endpoint |
| **JWT** | RFC 7519, RS256 signing | Token format | RSA-256 signatures, short TTL |
| **SAML 2.0** | OASIS SAML 2.0 | Federation con sistemas legacy | SAML IdP para integración externa |
| **LDAP v3** | RFC 4511 | Directory integration | User federation, attribute mapping |

### Capacidad y Rendimiento

| Métrica | Restricción | Justificación | Arquitectura Requerida |
|---------|-------------|---------------|------------------------|
| **Usuarios Concurrentes** | 10,000 sesiones simultáneas | Operaciones pico, multi-tenant | Clustering, optimización de sesiones |
| **Authentication Latency** | p95 < 100ms | User experience crítica | In-memory caching, optimized queries |
| **Validación de Token** | p95 < 50ms | Rendimiento de API | Caché de validación de firmas JWT |
| **Base de Datos de Usuarios** | 50,000 usuarios por realm | Capacidad por país/tenant | Particionado de base de datos, indexación |

### Integración y Conectividad

| Sistema | Protocolo | Restricción | Implementación |
|---------|-----------|-------------|----------------|
| **API Gateway** | OIDC Client | Validación de token por request | Introspección JWT, validación de claims |
| **Servicios Corporativos** | OAuth2 flows | Autenticación servicio-a-servicio | Client credentials, acceso con alcance |
| **IdPs Externos** | SAML/OIDC federation | Cumplimiento de estándares | Adaptadores de protocolo, mapeo de atributos |
| **Directorios LDAP** | LDAP v3 | Integración solo lectura | Federación de usuarios, estrategias de sincronización |

## 2.2 Restricciones de seguridad

### Cumplimiento y Regulatorio

| Requisito | Estándar | Alcance | Implementación |
|-------------|----------|-------|----------------|
| **Cumplimiento GDPR** | Regulación UE 2016/679 | Datos de usuarios UE | Gestión de consentimiento, minimización de datos, derecho al olvido |
| **Cumplimiento SOX** | Sarbanes-Oxley Act | Datos financieros | Controles de acceso, segregación de deberes, audit trails |
| **ISO 27001** | Estándar internacional | Gestión de seguridad | SGSI, evaluaciones de riesgo, controles de seguridad |
| **Regulaciones Locales** | Leyes por país | Datos por jurisdicción | Residencia de datos, políticas específicas por país |
| **SOX Compliance** | Sarbanes-Oxley Act | Financial controls | Audit trails, segregation of duties, access controls |
| **ISO 27001** | Information Security | Enterprise security | Risk assessment, security policies, incident management |
| **PCI DSS** | Payment Card Industry | Credit card data | Data encryption, access restrictions, monitoring |

### Autenticación y Autorización

| Control | Requisito | Justificación | Implementación |
|---------|-------------|---------------|----------------|
| **Autenticación Multi-Factor** | MFA obligatorio para roles admin | Seguridad Zero Trust | TOTP, WebAuthn, SMS de respaldo |
| **Política de Contraseñas** | Complejidad: 12+ caracteres, mayúsculas/minúsculas | Mejores prácticas de seguridad | Políticas de contraseña Keycloak |
| **Gestión de Sesiones** | Sesión máx: 8h, timeout inactivo: 1h | Seguridad vs usabilidad | Configurable por realm |
| **TTL de Access Token** | 15 minutos máximo | Minimizar ventana de ataque | Tokens de corta duración, estrategia de refresh |
| **Rotación de Refresh Token** | Rotación en cada uso | Mitigación de robo de tokens | Rotación de refresh token Keycloak |

### Cifrado y Protección de Datos

| Aspecto | Requisito | Estándar | Implementación |
|---------|-------------|----------|----------------|
| **Datos en Reposo** | Cifrado AES-256 | Estándar de la industria | Cifrado de base de datos, cifrado de sistema de archivos |
| **Datos en Tránsito** | TLS 1.3 obligatorio | Seguridad moderna | HTTPS en todas partes, gestión de certificados |
| **Firma de Tokens** | RSA-2048 mínimo | Fortaleza criptográfica | Firmas JWT RS256 |
| **Gestión de Claves** | Módulos de Seguridad de Hardware | Seguridad empresarial | AWS KMS, rotación de claves |

## 2.3 Restricciones organizacionales

### Governance y Operaciones

| Área | Restricción | Justificación | Impacto |
|------|-------------|---------------|---------|
| **Team Structure** | DevOps model, 24/7 support | Business continuity | On-call rotations, automation |
| **Change Management** | ITIL v4 processes | Risk mitigation | Change approval board, rollback procedures |
| **Documentation** | Arc42 + ADRs mandatory | Knowledge management | Structured documentation, decision tracking |
| **Code Review** | 2-person approval minimum | Quality assurance | Peer review process, security review |

### Multi-Tenant Requirements

| Tenant | Isolation Level | Compliance | Special Requirements |
|---------|----------------|------------|---------------------|
| **Peru** | Realm-level isolation | Local data residency | Spanish language, PEN currency |
| **Ecuador** | Realm-level isolation | Local data residency | Spanish language, USD currency |
| **Colombia** | Realm-level isolation | Local data residency | Spanish language, COP currency |
| **Mexico** | Realm-level isolation | Local data residency | Spanish language, MXN currency |

### Integration Constraints

| System | Integration Type | Constraint | Rationale |
|--------|-----------------|------------|-----------|
| **HRIS Systems** | Read-only federation | No write-back capability | Single source of truth for employee data |
| **Google Workspace** | SAML/OIDC federation | Limited to @talma.pe domain | Corporate email integration |
| **Legacy Systems** | SAML 2.0 only | Protocol limitation | Existing enterprise applications |
| **External Partners** | OAuth2 client credentials | Service-to-service only | API access, no user delegation |

## 2.4 Restricciones regulatorias específicas

### Data Residency por País

| País | Regulación | Requirement | Implementation |
|------|------------|-------------|----------------|
| **Perú** | Ley de Protección de Datos Personales | Data must remain in Peru | AWS Lima region deployment |
| **Ecuador** | Ley Orgánica de Protección de Datos | Data sovereignty | Regional data isolation |
| **Colombia** | Ley Estatutaria 1581 | Habeas data compliance | Consent management, data rights |
| **México** | Ley Federal de Protección de Datos | INAI compliance | Privacy notice, data subject rights |

### Cross-Border Data Transfer

| Scenario | Restriction | Compliance Mechanism | Technical Implementation |
|----------|-------------|---------------------|-------------------------|
| **Admin Access** | EU personnel access to LATAM data | Standard Contractual Clauses | VPN + audit logging |
| **Support Operations** | 24/7 global support team | Data Processing Agreements | Role-based access, data minimization |
| **Disaster Recovery** | Cross-region backup | Adequate data protection | Encrypted backups, limited retention |
| **Analytics** | Anonymized data only | GDPR compliance | Data anonymization, consent tracking |

## 2.5 Restricciones de infraestructura

### AWS Cloud Environment

| Component | Restriction | Rationale | Implementation |
|-----------|-------------|-----------|----------------|
| **Compute** | ECS Fargate only | Serverless management | Container orchestration |
| **Database** | RDS PostgreSQL | Managed service | Multi-AZ deployment |
| **Load Balancer** | Application Load Balancer | SSL termination, health checks | Target group management |
| **Networking** | VPC with private subnets | Security isolation | NAT gateways, security groups |

### Monitoring y Observability

| Tool | Purpose | Requirement | Integration |
|------|---------|-------------|-------------|
| **CloudWatch** | Infrastructure monitoring | AWS native | ECS, RDS, ALB metrics |
| **Prometheus** | Application metrics | Custom metrics | Keycloak metrics export |
| **Grafana** | Visualization | Centralized dashboards | Multi-tenant dashboards |
| **OpenTelemetry** | Distributed tracing | Request tracing | OTLP export to Jaeger |

### Backup y Disaster Recovery

| Aspect | Requirement | RTO | RPO | Implementation |
|--------|-------------|-----|-----|----------------|
| **Database Backup** | Automated daily | 4 hours | 15 minutes | RDS automated backups |
| **Configuration Backup** | Keycloak realm export | 2 hours | 1 hour | Automated realm export |
| **Cross-Region DR** | Standby environment | 8 hours | 1 hour | RDS cross-region replicas |
| **Point-in-Time Recovery** | 7 days retention | 1 hour | 5 minutes | RDS PITR capability |

*[INSERTAR AQUÍ: Diagrama C4 - Constraints and Dependencies]*

## 2.6 Constrains tecnológicos adicionales

### Versioning y Lifecycle

| Component | Version Strategy | Upgrade Policy | Backward Compatibility |
|-----------|-----------------|----------------|----------------------|
| **Keycloak** | LTS versions only | Quarterly assessment | N-1 version support |
| **.NET Runtime** | LTS versions | Annual upgrades | API compatibility |
| **PostgreSQL** | Major.minor tracking | Annual major upgrades | Migration testing |
| **Docker Images** | Semantic versioning | Security patches weekly | Container compatibility |

### Performance Baselines

| Metric | Baseline | Target | Monitoring |
|--------|----------|--------|------------|
| **Login Response Time** | 500ms | 200ms | Synthetic monitoring |
| **Token Validation** | 100ms | 50ms | Application metrics |
| **Database Connections** | 50 | 200 max | Connection pooling |
| **Memory Usage** | 2GB | 4GB max | Container limits |

### Security Constraints

| Control | Implementation | Validation | Automation |
|---------|----------------|------------|------------|
| **Vulnerability Scanning** | Weekly scans | CVSS 7+ remediation | Automated patching |
| **Penetration Testing** | Quarterly | External assessment | Remediation tracking |
| **Security Audits** | Annual | SOC 2 Type II | Compliance reporting |
| **Code Security** | Static analysis | SonarQube gates | CI/CD integration |
| **SOX Compliance** | Sarbanes-Oxley Act | Financial access controls | Segregation of duties, audit trails, access reviews |
| **ISO 27001** | Information Security | Security management | Risk assessment, security controls, continuous monitoring |
| **Local Privacy Laws** | Per country regulations | Regional compliance | Country-specific privacy configurations |

### Security Controls Mandatorias

| Control | Requirement | Implementation | Validation |
|---------|-------------|----------------|------------|
| **Multi-Factor Authentication** | MFA para roles críticos | TOTP, SMS, Email | Policy enforcement, bypass monitoring |
| **Password Policies** | Complexity, rotation, history | Keycloak password policies | Policy compliance reporting |
| **Session Management** | Timeout, concurrent session limits | Keycloak session configuration | Session monitoring, force logout |
| **Account Lockout** | Brute force protection | Failed attempt thresholds | Automated lockout, manual unlock |
| **Privileged Access** | Enhanced security for admin roles | Additional MFA, approval workflows | PAM integration, activity monitoring |

### Encryption Requirements

| Aspect | Requirement | Implementation | Key Management |
|--------|-------------|----------------|----------------|
| **Data at Rest** | AES-256 encryption | Database encryption, encrypted volumes | Azure Key Vault / HashiCorp Vault |
| **Data in Transit** | TLS 1.3 minimum | HTTPS only, secure protocols | Certificate management, rotation |
| **Token Signing** | RSA-256 minimum | JWT signing keys | Key rotation, secure storage |
| **SAML Assertions** | XML signature/encryption | SAML security | Certificate-based signing |

## 2.3 Restricciones organizacionales

### Multi-tenant Architecture

| Aspecto | Restricción | Implementación | Impacto |
|---------|-------------|----------------|---------|
| **Tenant Isolation** | Complete data isolation | Separate Keycloak realms | Realm-specific configurations |
| **Cross-tenant Access** | Prohibited by default | Realm boundaries enforcement | Federation for specific use cases |
| **Tenant Customization** | Branding, policies per tenant | Realm themes, custom flows | Tenant-specific admin interfaces |
| **Shared Resources** | Common admin realm | Master realm for administration | Global admin access controls |

### Operational Requirements

| Area | Constraint | Justification | Implementation |
|------|------------|---------------|----------------|
| **24/7 Availability** | Continuous operation required | Global operations, multiple timezones | Monitoring, alerting, on-call procedures |
| **Backup and Recovery** | RPO: 15 min, RTO: 4 hours | Business continuity | Automated backups, disaster recovery testing |
| **Change Management** | Controlled deployment process | Security, stability | Blue-green deployments, rollback procedures |
| **Audit Requirements** | Complete audit trail | Compliance, security investigations | Comprehensive event logging |

### Integration Standards

| Integration Type | Standard | Requirement | Implementation |
|------------------|----------|-------------|----------------|
| **Service-to-Service** | OAuth2 Client Credentials | Automated authentication | Service accounts, scoped permissions |
| **User Authentication** | OIDC Authorization Code | Browser-based flows | PKCE for mobile/SPA |
| **External Federations** | SAML 2.0 / OIDC | Identity provider integration | Federated identity mapping |
| **Legacy Systems** | LDAP integration | Gradual migration support | User federation, attribute sync |

## 2.4 Restricciones convencionales

### Desarrollo y Deployment

| Categoría | Standard | Tool/Framework | Enforcement |
|-----------|----------|----------------|-------------|
| **Container Orchestration** | Kubernetes | Helm charts | GitOps deployment |
| **Configuration Management** | GitOps approach | ArgoCD, Flux | Version controlled configs |
| **Secret Management** | External secret stores | External Secrets Operator | No secrets in configs |
| **Monitoring** | Prometheus/Grafana stack | Keycloak metrics | SLA monitoring |

### High Availability Design

| Component | HA Requirement | Implementation | Testing |
|-----------|----------------|----------------|---------|
| **Keycloak Instances** | Active-Active clustering | Load balanced instances | Failover testing |
| **Database** | PostgreSQL HA | Primary-replica setup | Disaster recovery drills |
| **Load Balancer** | No single point of failure | Multiple LB instances | Health check validation |
| **Storage** | Persistent, replicated | Distributed storage | Backup/restore testing |

### Performance Optimization

| Optimization | Target | Method | Measurement |
|--------------|--------|--------|-------------|
| **Database Tuning** | < 100ms queries | Indexing, connection pooling | Query performance monitoring |
| **Caching Strategy** | High cache hit ratio | Redis for sessions, local cache | Cache metrics, hit rates |
| **Connection Management** | Efficient resource usage | Connection pooling, timeouts | Resource utilization monitoring |
| **JVM Tuning** | Optimal garbage collection | Heap sizing, GC algorithms | JVM metrics, response times |

## 2.5 Restricciones específicas Keycloak

### Realm Architecture

| Aspect | Constraint | Rationale | Implementation |
|--------|------------|-----------|----------------|
| **Realm per Tenant** | One realm per country/tenant | Data isolation, compliance | Peru-corp, Ecuador-corp, etc. |
| **Master Realm** | Administrative realm only | Security separation | Global admin access only |
| **Realm Themes** | Custom branding per tenant | User experience consistency | Tenant-specific themes |
| **Cross-realm Trust** | Limited federation only | Security, data isolation | Specific trust relationships |

### User Federation

| Provider | Constraint | Configuration | Sync Strategy |
|----------|------------|---------------|---------------|
| **LDAP Directories** | Read-only access | User federation providers | Periodic sync, on-demand import |
| **External SAML IdPs** | Standard SAML 2.0 | Identity provider mappers | Just-in-time provisioning |
| **Social Providers** | Limited to approved providers | Google, Microsoft only | Consent flows, data mapping |

### Custom Extensions

| Extension Type | Restriction | Approval Process | Testing Requirements |
|----------------|-------------|------------------|---------------------|
| **Custom SPIs** | Security review required | Architecture review board | Security testing, performance impact |
| **Custom Themes** | Brand guidelines compliance | Brand team approval | Cross-browser testing |
| **Custom Authenticators** | Security assessment mandatory | CISO approval | Penetration testing |

## 2.6 Impacto en el diseño

### Decisiones Arquitectónicas Derivadas

| Constraint | Design Decision | Trade-off | Mitigation |
|------------|----------------|-----------|------------|
| **Multi-tenant Isolation** | Separate Keycloak realms | Management complexity | Automation tools |
| **High Availability** | Clustered deployment | Infrastructure cost | Managed services |
| **Security Compliance** | Enhanced authentication flows | User experience friction | UX optimization |
| **Integration Standards** | Standard protocols only | Limited flexibility | Protocol adapters |

### Technology Stack Implications

| Layer | Technology Choice | Constraint Driver | Alternative Considered |
|-------|-------------------|-------------------|----------------------|
| **Identity Provider** | Keycloak | Corporate standard | Auth0 (cost), Okta (vendor lock-in) |
| **Database** | PostgreSQL | Keycloak compatibility | MySQL (features), Oracle (cost) |
| **Caching** | Redis | Performance requirements | Hazelcast (complexity) |
| **Load Balancer** | NGINX/HAProxy | HA requirements | Cloud LB (vendor dependency) |

### Operational Considerations

| Aspect | Implication | Mitigation Strategy |
|--------|-------------|-------------------|
| **Complexity** | Multi-realm management | Automation, standardization |
| **Performance** | Token validation overhead | Caching, optimization |
| **Security** | Attack surface expansion | Defense in depth, monitoring |
| **Compliance** | Audit trail requirements | Comprehensive logging |

## Referencias

### Keycloak Documentation
- [Keycloak Server Installation Guide](https://www.keycloak.org/docs/latest/server_installation/)
- [Keycloak High Availability Guide](https://www.keycloak.org/docs/latest/server_installation/#_clustering)
- [Keycloak Security Hardening](https://www.keycloak.org/docs/latest/server_installation/#_hardening)

### Security Standards
- [OAuth 2.0 Authorization Framework (RFC 6749)](https://tools.ietf.org/html/rfc6749)
- [OpenID Connect Core 1.0](https://openid.net/specs/openid-connect-core-1_0.html)
- [JSON Web Token (JWT) (RFC 7519)](https://tools.ietf.org/html/rfc7519)
- [SAML 2.0 Core Specification](https://docs.oasis-open.org/security/saml/v2.0/saml-core-2.0-os.pdf)

### Compliance and Regulations
- [GDPR Regulation (EU) 2016/679](https://gdpr-info.eu/)
- [Sarbanes-Oxley Act](https://www.congress.gov/bill/107th-congress/house-bill/3763)
- [ISO/IEC 27001:2013](https://www.iso.org/standard/54534.html)

### Infrastructure and Deployment
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [PostgreSQL High Availability](https://www.postgresql.org/docs/current/high-availability.html)
- [Redis Clustering](https://redis.io/docs/manual/scaling/)
