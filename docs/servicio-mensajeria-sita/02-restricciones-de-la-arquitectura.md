# 2. Restricciones de la arquitectura

El **Sistema de Mensajería SITA** debe operar dentro de restricciones técnicas, organizacionales y regulatorias específicas de la industria aeronáutica. Estas restricciones determinan las decisiones arquitectónicas fundamentales del sistema.

## 2.1 Restricciones técnicas

### Protocolos y Estándares SITA

| Restricción | Descripción | Impacto Arquitectónico |
|-------------|-------------|------------------------|
| **SITA SITATEX Protocol** | Cumplimiento obligatorio con protocolos SITATEX para comunicación aeronáutica | Implementación de adaptadores específicos, validación de formatos de mensaje |
| **AFTN Addressing** | Sistema de direccionamiento AFTN (Aeronautical Fixed Telecommunication Network) | Routing engine específico, validación de direcciones aeronáuticas |
| **ICAO Message Standards** | Formatos de mensaje según Organization de Aviación Civil Internacional | Parser y validator engines para tipos de mensaje específicos |
| **Type B Message Format** | Estructura específica de mensajes Type B para operaciones aeroportuarias | Template engine especializado, validación de sintaxis Type B |

### Infraestructura y Plataforma

| Área | Restricción | Justificación | Solución Adoptada |
|------|-------------|---------------|-------------------|
| **Contenedorización** | Despliegue obligatorio en Docker containers | Estandardización DevOps, portabilidad | Docker + Kubernetes orchestration |
| **Base de Datos** | PostgreSQL como RDBMS principal | Expertise del equipo, compliance requirements | PostgreSQL 15+ con replicación |
| **Runtime** | .NET 8 LTS como plataforma principal | Standardización corporativa, soporte Enterprise | ASP.NET Core Web APIs |
| **Message Queuing** | Apache Kafka para message streaming | High throughput, event sourcing capabilities | Kafka cluster con partitioning |
| **Logging** | Serilog para logging estructurado | Observabilidad, troubleshooting | Structured JSON logging |

### Integración y Conectividad

| Sistema Externo | Protocolo Requerido | Restricción | Implementación |
|-----------------|---------------------|-------------|----------------|
| **SITA Network** | SITATEX over X.25/IP | Legacy protocol support | Protocol bridge adapter |
| **Partner Airlines** | AFTN/CIDIN | Industry standard messaging | Multi-protocol gateway |
| **Airport Systems** | Various (SOAP, REST, MQ) | Heterogeneous integration | Enterprise Service Bus pattern |
| **Track & Trace** | Internal REST APIs | Real-time event delivery | Async HTTP clients |
| **Government Systems** | Secure channels (VPN/TLS) | Security compliance | Encrypted tunnels, certificates |

### Performance y Capacidad

| Métrica | Restricción | Justificación | Arquitectura Requerida |
|---------|-------------|---------------|------------------------|
| **Message Throughput** | 10,000 mensajes/hora peak | Operaciones aeroportuarias críticas | Async processing, queue-based |
| **Latency** | < 30 segundos end-to-end | Tiempo crítico para operaciones vuelo | In-memory caching, optimized routing |
| **Availability** | 99.95% uptime | Operaciones 24/7, impacto en vuelos | Active-passive clustering |
| **Message Size** | Hasta 32KB por mensaje SITA | Limitación protocolo SITATEX | Message chunking, compression |

## 2.2 Restricciones organizacionales

### Compliance y Regulatorio

| Área | Restricción | Autoridad | Implementación Requerida |
|------|-------------|-----------|--------------------------|
| **Aviation Security** | ICAO Annex 17 compliance | International Civil Aviation Organization | Security controls, audit trails |
| **Data Privacy** | GDPR compliance en operaciones EU | European Data Protection Authorities | Data anonymization, consent management |
| **Financial Controls** | SOX compliance para data financiera | Corporate audit requirements | Access controls, change management |
| **Local Regulations** | Compliance con regulaciones por país | Aviation authorities per country | Country-specific adapters |

### Arquitectura Corporativa

| Restricción | Origen | Impacto | Solución |
|-------------|--------|---------|----------|
| **Multi-tenant Architecture** | Requisito corporativo | Aislamiento de datos por cliente | Tenant-aware data layer |
| **Multi-country Support** | Expansión regional | Localización, regulaciones locales | Country-specific configurations |
| **Identity Integration** | SSO corporativo | Autenticación centralizada vía Keycloak | OAuth2/OIDC integration |
| **Audit Requirements** | Compliance corporativo | Logging de todas las operaciones | Comprehensive audit logging |

### Operaciones y Mantenimiento

| Área | Restricción | Justificación | Implementación |
|------|-------------|---------------|----------------|
| **24/7 Operations** | Soporte continuo requerido | Operaciones aeroportuarias críticas | Monitoring, alerting, runbooks |
| **Change Windows** | Mantenimiento solo en horarios específicos | Minimizar impacto operacional | Blue-green deployments |
| **Support Model** | L1/L2/L3 support structure | Escalation procedures defined | Operational dashboards, documentation |
| **Disaster Recovery** | RTO: 4 horas, RPO: 15 minutos | Business continuity requirements | Cross-region replication |

## 2.3 Restricciones convencionales

### Estándares de Desarrollo

| Categoría | Estándar | Herramienta/Framework | Enforcement |
|-----------|----------|----------------------|-------------|
| **Coding Standards** | Microsoft C# Guidelines | StyleCop, EditorConfig | CI/CD pipeline checks |
| **API Design** | OpenAPI 3.0 specification | Swashbuckle, NSwag | Automated documentation |
| **Testing** | Unit tests > 80% coverage | xUnit, NSubstitute | SonarQube quality gates |
| **Documentation** | Arc42 methodology | Markdown, Structurizr | Documentation reviews |

### Seguridad

| Aspecto | Restricción | Implementación | Validación |
|---------|-------------|----------------|------------|
| **Authentication** | OAuth2/OIDC mandatory | Keycloak integration | Security testing |
| **Authorization** | RBAC with fine-grained permissions | Claims-based authorization | Penetration testing |
| **Data Encryption** | TLS 1.3 for transport, AES-256 at rest | .NET encryption libraries | Security audits |
| **Secret Management** | Azure Key Vault / HashiCorp Vault | Centralized secret storage | Secret rotation policies |

### Monitoreo y Observabilidad

| Componente | Herramienta Requerida | Propósito | Configuración |
|------------|----------------------|-----------|---------------|
| **Application Metrics** | Prometheus + Grafana | Performance monitoring | Custom metrics, dashboards |
| **Logging** | ELK Stack (Elasticsearch, Logstash, Kibana) | Centralized logging | Structured logs, retention |
| **Tracing** | OpenTelemetry + Jaeger | Distributed tracing | Request correlation |
| **Health Checks** | ASP.NET Core Health Checks | Service availability | /health endpoints |

## 2.4 Restricciones específicas SITA

### Conectividad SITA Network

| Aspecto | Restricción | Detalle Técnico |
|---------|-------------|-----------------|
| **Network Access** | Conexión dedicada SITA requerida | Línea dedicada, no internet público |
| **Addressing Scheme** | AFTN addresses format | 8-character ICAO location codes |
| **Message Priority** | Priority levels (SS, DD, FF, GG) | Routing based on message urgency |
| **Error Handling** | SITA-specific error codes | Standard SITA error reporting |

### Message Format Compliance

| Tipo Mensaje | Standard | Validación Requerida | Ejemplo |
|--------------|---------|---------------------|---------|
| **Flight Plans** | ICAO 4444 format | Syntax, route validation | FPL messages |
| **Flight Updates** | Type B messages | Field validation, timing | CHG, CNL, DLA messages |
| **Airport Operations** | SITA specifications | Operational constraints | Gate assignments, baggage |
| **Weather Data** | ICAO Annex 3 | Meteorological format | METAR, TAF messages |

### Certification Requirements

| Certificación | Organismo | Frecuencia | Scope |
|---------------|-----------|------------|-------|
| **SITA Network Certification** | SITA IT Services | Annual | Message format compliance |
| **ICAO Compliance** | Local aviation authority | Bi-annual | Operational procedures |
| **Security Certification** | Corporate security | Quarterly | Security controls audit |

## 2.5 Impacto en el diseño

### Decisiones Arquitectónicas Derivadas

| Restricción | Decisión de Diseño | Rationale |
|-------------|-------------------|-----------|
| **Legacy Protocol Support** | Adapter Pattern implementation | Isolation of legacy complexity |
| **High Availability** | Active-Passive clustering | Meet 99.95% uptime requirement |
| **Multi-tenant** | Database per tenant strategy | Data isolation and compliance |
| **Message Validation** | Pipeline pattern with validators | Extensible validation chain |
| **Error Handling** | Circuit breaker pattern | Resilience for external dependencies |

### Trade-offs Aceptados

| Trade-off | Decisión | Justificación |
|-----------|----------|---------------|
| **Performance vs Compliance** | Priorizar compliance | Regulatory requirements non-negotiable |
| **Flexibility vs Standards** | Adherir a standards SITA | Industry interoperability critical |
| **Cost vs Reliability** | Invertir en redundancia | Operational impact of downtime |
| **Simplicity vs Features** | Feature completeness | Support diverse airline requirements |

## Referencias

### Estándares y Especificaciones

- [SITA SITATEX Protocol Specification](https://www.sita.aero/solutions/airline-operations/sitatex/)
- [ICAO Doc 4444 - PANS-ATM](https://www.icao.int/publications/documents/4444_cons_en.pdf)
- [AFTN Manual (ICAO Doc 7030)](https://www.icao.int/publications/pages/publication.aspx?docnum=7030)
- [Type B Message Format Standard](https://www.sita.aero/resources/type-b-message-standard/)

### Regulaciones

- [ICAO Annex 17 - Aviation Security](https://www.icao.int/Security/Pages/Annex-17---Aviation-Security.aspx)
- [GDPR Regulation (EU) 2016/679](https://gdpr-info.eu/)
- [Sarbanes-Oxley Act](https://www.congress.gov/bill/107th-congress/house-bill/3763)

### Documentación Corporativa

- [Keycloak Documentation](https://www.keycloak.org/documentation)
- [.NET 8 Documentation](https://docs.microsoft.com/en-us/dotnet/)
- [Arc42 Architecture Template](https://arc42.org/)
