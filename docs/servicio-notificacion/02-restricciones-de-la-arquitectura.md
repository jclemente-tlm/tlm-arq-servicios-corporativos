# 2. Restricciones de la arquitectura

El **Sistema de Notificación Multi-canal** debe operar bajo restricciones técnicas, operacionales y regulatorias específicas para garantizar entrega confiable de notificaciones a través de múltiples canales. Estas restricciones determinan las decisiones arquitectónicas fundamentales.

## 2.1 Restricciones técnicas

### Arquitectura de Microservicios

| Restricción | Descripción | Justificación | Implementación |
|-------------|-------------|---------------|----------------|
| **Modularidad Obligatoria** | Separación por canal y función | Escalabilidad independiente, evolución paralela | Microservicios por canal (Email, SMS, WhatsApp, Push) |
| **No Monolito** | Prohibido diseño monolítico | Flexibilidad, deployment independiente | API Gateway + servicios especializados |
| **Clean Architecture** | Separación clara de capas | Mantenibilidad, testabilidad | Dependency inversion, ports & adapters |
| **Event-Driven Design** | Comunicación asíncrona | Resiliencia, desacoplamiento | Apache Kafka para event streaming |

### Stack Tecnológico Mandatorio

| Componente | Tecnología Requerida | Versión Mínima | Justificación |
|------------|---------------------|----------------|---------------|
| **Runtime** | .NET 8 LTS | 8.0+ | Standardización corporativa, performance |
| **Message Queue** | Apache Kafka | 3.5+ | High throughput, event sourcing, durability |
| **Database** | PostgreSQL | 15+ | ACID compliance, JSON support, expertise |
| **Caching** | Redis | 7.0+ | Performance, session management |
| **Containerization** | Docker + Kubernetes | K8s 1.28+ | Orchestration, scaling, deployment |

### Canales de Notificación

| Canal | Provider Requerido | SLA Target | Restricción Técnica |
|-------|-------------------|------------|---------------------|
| **Email** | SendGrid + Amazon SES | 99.5% delivery rate | SMTP compliance, DKIM/SPF |
| **SMS** | Twilio + local providers | 98% delivery rate | GSM character encoding, length limits |
| **WhatsApp** | WhatsApp Business API | 95% delivery rate | Template approval process |
| **Push Notifications** | Firebase Cloud Messaging | 90% delivery rate | Platform-specific payloads |

### Performance y Capacidad

| Métrica | Restricción | Justificación | Arquitectura Requerida |
|---------|-------------|---------------|------------------------|
| **Throughput** | 100,000 notificaciones/hora | Peak operational loads | Horizontal scaling, queue partitioning |
| **Latency** | p95 < 5 segundos end-to-end | User experience crítica | Async processing, priority queues |
| **Delivery Rate** | > 95% across all channels | Business requirements | Retry mechanisms, fallback channels |
| **Template Processing** | < 500ms per message | Real-time personalization | Template caching, pre-compilation |

### Integración y Conectividad

| Sistema | Protocolo | Restricción | Implementación |
|---------|-----------|-------------|----------------|
| **Track & Trace Events** | Apache Kafka | Real-time event consumption | Event-driven triggers |
| **Identity System** | OAuth2/OIDC | Secure API access | JWT token validation |
| **Template Engine** | REST API | Template management | RESTful template CRUD |
| **External Providers** | Provider-specific APIs | Multiple provider support | Adapter pattern per provider |

## 2.2 Restricciones operacionales

### Disponibilidad y Confiabilidad

| Aspecto | Restricción | Justificación | Implementación |
|---------|-------------|---------------|----------------|
| **Uptime Target** | 99.9% availability | Critical business communications | Active-passive clustering |
| **Disaster Recovery** | RTO: 2 horas, RPO: 15 minutes | Business continuity | Cross-region replication |
| **Fault Tolerance** | Graceful degradation | Partial service availability | Circuit breakers, bulkhead pattern |
| **Provider Failover** | Automatic fallback | Provider outages | Multi-provider configuration |

### Escalabilidad y Elasticidad

| Aspecto | Requirement | Implementation | Monitoring |
|---------|-------------|----------------|------------|
| **Horizontal Scaling** | Auto-scaling based on queue depth | Kubernetes HPA | Queue metrics, CPU/memory |
| **Queue Management** | Dynamic partitioning | Kafka topic scaling | Partition lag monitoring |
| **Database Scaling** | Read replicas for reporting | PostgreSQL streaming replication | Connection pool monitoring |
| **Cache Scaling** | Redis cluster for session data | Redis Cluster mode | Cache hit rates, memory usage |

### Monitoreo y Observabilidad

| Componente | Herramienta | Propósito | Configuración |
|------------|-------------|-----------|---------------|
| **Application Metrics** | Prometheus + Grafana | Performance, delivery rates | Custom metrics, dashboards |
| **Logging** | ELK Stack | Centralized logging, troubleshooting | Structured JSON logs |
| **Tracing** | OpenTelemetry + Jaeger | Request tracing, performance | Distributed tracing |
| **Health Monitoring** | ASP.NET Core Health Checks | Service health status | /health endpoints |

## 2.3 Restricciones regulatorias y compliance

### Protección de Datos

| Regulation | Scope | Requirement | Implementation |
|------------|-------|-------------|----------------|
| **GDPR** | EU user data | Consent, data minimization, deletion | Consent management, data retention policies |
| **LGPD** | Brazil operations | Similar to GDPR | Localized compliance framework |
| **CCPA** | California residents | Consumer privacy rights | Privacy controls, opt-out mechanisms |
| **Local Privacy Laws** | Per country operations | Regional compliance | Country-specific configurations |

### Comunicaciones Comerciales

| Jurisdiction | Regulation | Requirement | Implementation |
|-------------|------------|-------------|----------------|
| **CAN-SPAM Act** | United States | Email marketing compliance | Unsubscribe mechanisms, sender identification |
| **CASL** | Canada | Anti-spam legislation | Explicit consent, record keeping |
| **EU ePrivacy** | European Union | Electronic communications | Cookie consent, marketing preferences |
| **Local Telecom Laws** | Per country | SMS/voice regulations | Provider compliance, opt-in requirements |

### Retención y Auditoría

| Data Type | Retention Period | Justification | Implementation |
|-----------|------------------|---------------|----------------|
| **Delivery Logs** | 7 years | Audit, dispute resolution | Archived storage, searchable |
| **User Consent** | Until withdrawn + 3 years | Legal protection | Immutable consent records |
| **Templates** | 5 years | Version history, compliance | Version-controlled storage |
| **Performance Metrics** | 2 years | Operational analysis | Time-series database |

## 2.4 Restricciones de seguridad

### Autenticación y Autorización

| Aspecto | Requirement | Implementation | Validation |
|---------|-------------|----------------|------------|
| **API Authentication** | OAuth2/OIDC mandatory | Keycloak integration | JWT token validation |
| **Service-to-Service** | mTLS for internal communication | Certificate-based auth | Certificate validation |
| **Data Encryption** | AES-256 at rest, TLS 1.3 in transit | Industry standard encryption | Encryption compliance audits |
| **Secret Management** | External secret management | Azure Key Vault / HashiCorp Vault | Secret rotation policies |

### Content Security

| Control | Purpose | Implementation | Monitoring |
|---------|---------|----------------|------------|
| **Content Filtering** | Prevent malicious content | Content scanning, virus checking | Threat detection alerts |
| **Template Validation** | Secure template processing | Input sanitization, XSS prevention | Security scanning |
| **Rate Limiting** | DDoS protection, abuse prevention | API rate limiting, throttling | Rate limit metrics |
| **Audit Logging** | Security event tracking | Comprehensive security logs | SIEM integration |

## 2.5 Restricciones específicas por canal

### Email Channel

| Constraint | Requirement | Implementation | Compliance |
|------------|-------------|----------------|------------|
| **SMTP Compliance** | RFC 5321/5322 standards | Standard SMTP implementation | Protocol compliance testing |
| **Authentication** | DKIM, SPF, DMARC | Email authentication setup | Deliverability monitoring |
| **Content Standards** | CAN-SPAM, GDPR compliance | Unsubscribe links, sender identification | Legal compliance audits |
| **Size Limits** | 25MB including attachments | Content size validation | Size limit enforcement |

### SMS Channel

| Constraint | Requirement | Implementation | Compliance |
|------------|-------------|----------------|------------|
| **Character Encoding** | GSM 7-bit, Unicode support | Proper encoding handling | Message display validation |
| **Length Limits** | 160 chars (GSM), 70 chars (Unicode) | Message segmentation | Length validation |
| **Opt-out Compliance** | STOP keyword support | Automatic unsubscribe | Telecom regulation compliance |
| **Delivery Reports** | Real-time delivery status | Provider webhook integration | Delivery rate monitoring |

### WhatsApp Channel

| Constraint | Requirement | Implementation | Compliance |
|------------|-------------|----------------|------------|
| **Template Approval** | WhatsApp pre-approved templates | Template management system | Template compliance tracking |
| **Business API** | WhatsApp Business API only | Official API integration | API compliance monitoring |
| **Rate Limits** | Provider-imposed limits | Intelligent rate limiting | Quota management |
| **Content Policy** | WhatsApp content guidelines | Content validation | Policy compliance checks |

### Push Notifications

| Constraint | Requirement | Implementation | Compliance |
|------------|-------------|----------------|------------|
| **Platform Compliance** | iOS/Android guidelines | Platform-specific implementations | App store compliance |
| **Token Management** | Device token lifecycle | Token refresh mechanisms | Token validity tracking |
| **Payload Limits** | 4KB (iOS), 256KB (Android) | Payload size validation | Size limit enforcement |
| **Privacy Controls** | User consent, opt-out | Permission management | Privacy compliance |

## 2.6 Restricciones de integration

### Event-Driven Architecture

| Aspect | Constraint | Implementation | Monitoring |
|--------|------------|----------------|------------|
| **Event Schema** | Avro schema evolution | Schema registry, versioning | Schema compatibility checks |
| **Event Ordering** | Per-entity ordering guarantee | Kafka partitioning strategy | Ordering validation |
| **Event Replay** | Support for event replay | Offset management, retention | Replay monitoring |
| **Dead Letter Handling** | Failed message handling | Dead letter queues, retry policies | Error rate monitoring |

### Template Management

| Aspect | Constraint | Implementation | Governance |
|--------|------------|----------------|------------|
| **Version Control** | Template versioning | Git-based template storage | Change approval process |
| **Multi-language** | Localization support | Language-specific templates | Translation quality assurance |
| **Personalization** | Dynamic content injection | Template engine with variables | Variable validation |
| **A/B Testing** | Template variant testing | Experiment framework | Performance comparison |

## 2.7 Impacto en el diseño

### Decisiones Arquitectónicas Derivadas

| Constraint | Design Decision | Trade-off | Mitigation |
|------------|----------------|-----------|------------|
| **Multi-channel Support** | Microservices per channel | Operational complexity | Service mesh, centralized config |
| **High Throughput** | Event-driven architecture | Eventual consistency | Event sourcing, CQRS |
| **Provider Reliability** | Multi-provider strategy | Cost increase | Smart routing, cost optimization |
| **Compliance Requirements** | Comprehensive audit logging | Storage overhead | Log aggregation, retention policies |

### Technology Stack Implications

| Layer | Technology Choice | Constraint Driver | Alternative Considered |
|-------|-------------------|-------------------|----------------------|
| **Message Queue** | Apache Kafka | High throughput, durability | RabbitMQ (complexity), Azure Service Bus (vendor lock) |
| **Database** | PostgreSQL | ACID, JSON support | MongoDB (consistency), MySQL (features) |
| **Cache** | Redis | Performance, clustering | Memcached (features), Hazelcast (complexity) |
| **Templates** | Liquid Templates | Security, flexibility | Razor (security), Handlebars (features) |

### Operational Considerations

| Aspect | Implication | Mitigation Strategy |
|--------|-------------|-------------------|
| **Complexity** | Multiple moving parts | Automation, monitoring, documentation |
| **Provider Management** | Multiple external dependencies | SLA monitoring, failover automation |
| **Compliance** | Regulatory complexity | Automated compliance checks, regular audits |
| **Performance** | Multi-hop processing | Optimization, caching, async processing |

## Referencias

### Estándares y Protocolos

- [SMTP Protocol (RFC 5321)](https://tools.ietf.org/html/rfc5321)
- [Email Message Format (RFC 5322)](https://tools.ietf.org/html/rfc5322)
- [DKIM Signatures (RFC 6376)](https://tools.ietf.org/html/rfc6376)
- [WhatsApp Business API Documentation](https://developers.facebook.com/docs/whatsapp)

### Regulaciones

- [CAN-SPAM Act](https://www.ftc.gov/enforcement/rules/rulemaking-regulatory-reform-proceedings/can-spam-rule)
- [GDPR Regulation (EU) 2016/679](https://gdpr-info.eu/)
- [CASL (Canada's Anti-Spam Legislation)](https://crtc.gc.ca/eng/casl-lcap/)

### Tecnologías y Frameworks

- [Apache Kafka Documentation](https://kafka.apache.org/documentation/)
- [.NET 8 Documentation](https://docs.microsoft.com/en-us/dotnet/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Redis Documentation](https://redis.io/documentation)

- Todas las modificaciones en canales y funciones deben ser trazables y versionadas.


### Resumen de restricciones técnicas clave

| Restricción           | Descripción                                 |
|----------------------|---------------------------------------------|
| .NET 8 y C#          | Tecnología principal                        |
| AWS SQS/SNS/S3       | Colas y almacenamiento                      |
| PostgreSQL           | Base de datos principal                     |
| YARP                 | API Gateway                                 |
| Políticas de seguridad| Cumplimiento corporativo                    |
| Serverless preferido | Servicios gestionados                       |
| Multi-tenant         | Separación lógica de datos y recursos       |
| Multipaís            | Configuración regional y soporte de localización |

---

## Referencias

- [ADR-006: Modularidad por canal y función](docs/servicio-notificacion/adr/adr-006-modularidad.md)
- [Microservicios y modularidad](https://martinfowler.com/articles/microservices.html)
- [Arc42: Restricciones de arquitectura](https://arc42.org/section-2/)