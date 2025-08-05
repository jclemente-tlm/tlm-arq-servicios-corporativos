# 2. Restricciones de la arquitectura

El **Sistema de Track & Trace** debe operar bajo restricciones técnicas, operacionales y de compliance específicas para el seguimiento en tiempo real de eventos operacionales. Estas restricciones definen las decisiones arquitectónicas críticas del sistema.

## 2.1 Restricciones técnicas

### Arquitectura CQRS Obligatoria

| Restricción | Descripción | Justificación | Implementación |
|-------------|-------------|---------------|----------------|
| **CQRS Pattern** | Separación Command/Query obligatoria | Optimización lectura vs escritura, escalabilidad | Comandos para ingestión, queries para consulta |
| **Event Sourcing** | Almacenamiento basado en eventos | Auditabilidad completa, reconstrucción de estado | Event store como fuente de verdad |
| **Message Queue** | Apache Kafka para event streaming | High throughput, durabilidad, replay capability | Kafka topics por tipo de evento |
| **Read Models** | Vistas materializadas para consultas | Performance de consultas complejas | PostgreSQL para read models |

### Stack Tecnológico Mandatorio

| Componente | Tecnología Requerida | Versión Mínima | Justificación |
|------------|---------------------|----------------|---------------|
| **Runtime** | .NET 8 LTS | 8.0+ | Standardización corporativa, performance |
| **Event Store** | Apache Kafka | 3.5+ | Event streaming, high availability |
| **Read Database** | PostgreSQL | 15+ | Complex queries, JSON support, analytics |
| **Cache Layer** | Redis | 7.0+ | Query performance, real-time dashboards |
| **Time Series DB** | InfluxDB | 2.7+ | Metrics storage, time-based analytics |
| **Search Engine** | Elasticsearch | 8.0+ | Full-text search, log aggregation |

### Performance y Capacidad

| Métrica | Restricción | Justificación | Arquitectura Requerida |
|---------|-------------|---------------|------------------------|
| **Event Ingestion** | 50,000 eventos/segundo | Peak operational loads | Partitioned Kafka, async processing |
| **Query Response** | p95 < 200ms | Real-time dashboard requirements | Materialized views, caching |
| **Data Retention** | 7 años eventos, 2 años métricas | Compliance, operational analysis | Tiered storage, archival strategy |
| **Real-time Updates** | < 5 segundos latencia | Operational decision making | Event streaming, WebSocket notifications |

### Integración y Conectividad

| Sistema | Protocolo | Restricción | Implementación |
|---------|-----------|-------------|----------------|
| **SITA Messaging** | Apache Kafka | Real-time event consumption | Event-driven integration |
| **Notification System** | Apache Kafka | Event-based notifications | Publish events to notification topics |
| **Identity System** | OAuth2/OIDC | Secure API access | JWT token validation |
| **External APIs** | REST/GraphQL | Standard protocols | RESTful APIs, GraphQL for complex queries |
| **Dashboard Systems** | WebSocket + REST | Real-time updates | SignalR hubs, REST APIs |

## 2.2 Restricciones operacionales

### Disponibilidad y Confiabilidad

| Aspecto | Restricción | Justificación | Implementación |
|---------|-------------|---------------|----------------|
| **Uptime Target** | 99.95% availability | Critical operational visibility | Active-active clustering |
| **Data Durability** | 99.999999999% (11 9's) | Event data cannot be lost | Kafka replication, backup strategies |
| **Disaster Recovery** | RTO: 1 hour, RPO: 5 minutes | Business continuity | Cross-region replication |
| **Event Replay** | Support for historical replay | Data recovery, debugging | Kafka retention, offset management |

### Escalabilidad y Performance

| Aspecto | Requirement | Implementation | Monitoring |
|---------|-------------|----------------|------------|
| **Horizontal Scaling** | Linear scaling with load | Stateless services, partitioned data | Performance metrics, auto-scaling |
| **Data Partitioning** | Partition by tenant/time | Optimal query performance | Partition monitoring |
| **Query Optimization** | Sub-second response times | Indexed read models, caching | Query performance tracking |
| **Storage Scaling** | Automatic storage expansion | Elastic storage, data lifecycle | Storage utilization monitoring |

### Data Management

| Aspecto | Restricción | Justificación | Implementación |
|---------|-------------|---------------|----------------|
| **Data Consistency** | Eventual consistency acceptable | CQRS trade-off, performance | Event-driven consistency |
| **Schema Evolution** | Backward-compatible changes | System evolution, integration | Avro schema registry |
| **Data Lineage** | Complete event traceability | Audit, debugging, compliance | Event correlation IDs |
| **Archive Strategy** | Automated data archiving | Cost optimization, compliance | Tiered storage, compression |

## 2.3 Restricciones regulatorias y compliance

### Retención de Datos

| Tipo de Dato | Período Retención | Justificación | Implementación |
|--------------|-------------------|---------------|----------------|
| **Eventos Operacionales** | 7 años | Auditoría, investigaciones | Archive storage, retrieval capability |
| **Eventos de Seguridad** | 10 años | Compliance, forense | Immutable storage, encryption |
| **Métricas de Performance** | 2 años | Análisis operacional | Time-series compression |
| **Logs de Sistema** | 1 año | Troubleshooting, debugging | Log rotation, archival |

### Auditoría y Compliance

| Requirement | Standard | Implementation | Validation |
|-------------|----------|----------------|------------|
| **Audit Trail** | Complete event history | Immutable event log | Audit compliance checks |
| **Data Privacy** | GDPR, LGPD compliance | Data anonymization, deletion | Privacy impact assessments |
| **Access Control** | RBAC with fine-grained permissions | Identity integration | Access reviews, monitoring |
| **Change Tracking** | All modifications logged | Event sourcing pattern | Change audit reports |

### Jurisdictional Requirements

| Jurisdiction | Requirement | Implementation | Compliance Check |
|-------------|-------------|----------------|------------------|
| **European Union** | GDPR data protection | Data residency, encryption | Privacy compliance audits |
| **United States** | SOX financial controls | Access controls, audit trails | Financial audit compliance |
| **Latin America** | Local data protection laws | Country-specific configurations | Regional compliance reviews |
| **Aviation Authorities** | Operational data retention | Industry-specific requirements | Aviation compliance audits |

## 2.4 Restricciones de seguridad

### Autenticación y Autorización

| Aspecto | Requirement | Implementation | Validation |
|---------|-------------|----------------|------------|
| **API Authentication** | OAuth2/OIDC mandatory | Keycloak integration | Token validation testing |
| **Service-to-Service** | mTLS for internal communication | Certificate-based authentication | Certificate validation |
| **Data Access** | Role-based permissions | Fine-grained authorization | Permission testing |
| **Sensitive Data** | Field-level encryption | Column encryption, key management | Encryption compliance |

### Data Security

| Control | Purpose | Implementation | Monitoring |
|---------|---------|----------------|------------|
| **Encryption at Rest** | Data protection | AES-256 database encryption | Encryption status monitoring |
| **Encryption in Transit** | Communication security | TLS 1.3 for all communications | Certificate monitoring |
| **Event Integrity** | Tamper detection | Digital signatures, checksums | Integrity validation |
| **Access Logging** | Security auditing | Comprehensive access logs | Security event monitoring |

### Network Security

| Aspect | Requirement | Implementation | Validation |
|--------|-------------|----------------|------------|
| **Network Segmentation** | Isolated network zones | VPC, subnets, security groups | Network topology review |
| **Firewall Rules** | Least privilege access | Minimal port exposure | Security rule audits |
| **DDoS Protection** | Attack mitigation | Rate limiting, traffic analysis | DDoS testing |
| **Intrusion Detection** | Security monitoring | IDS/IPS deployment | Security alert validation |

## 2.5 Restricciones específicas CQRS

### Command Side (Write)

| Aspect | Constraint | Implementation | Validation |
|--------|------------|----------------|------------|
| **Event Schema** | Immutable event structure | Avro schema evolution | Schema compatibility testing |
| **Command Validation** | Business rule enforcement | Domain validation | Business rule testing |
| **Event Ordering** | Chronological ordering | Kafka partitioning strategy | Ordering verification |
| **Idempotency** | Duplicate event handling | Idempotency keys | Duplicate detection testing |

### Query Side (Read)

| Aspect | Constraint | Implementation | Validation |
|--------|------------|----------------|------------|
| **View Materialization** | Optimized for read patterns | Denormalized read models | Query performance testing |
| **Cache Strategy** | Multi-level caching | Redis + application cache | Cache hit rate monitoring |
| **Search Capabilities** | Full-text and faceted search | Elasticsearch integration | Search relevance testing |
| **Real-time Updates** | Live dashboard updates | Event-driven view updates | Update latency monitoring |

### Event Store

| Aspect | Constraint | Implementation | Validation |
|--------|------------|----------------|------------|
| **Event Versioning** | Schema evolution support | Version fields, migration scripts | Compatibility testing |
| **Snapshot Strategy** | Performance optimization | Periodic snapshots | Snapshot validation |
| **Replay Capability** | Historical event processing | Offset management | Replay testing |
| **Storage Optimization** | Cost-effective storage | Compression, tiered storage | Storage efficiency monitoring |

## 2.6 Restricciones de integration

### Event-Driven Integration

| System | Event Types | Constraints | Implementation |
|--------|-------------|-------------|----------------|
| **SITA Messaging** | Flight events, message status | Real-time consumption | Kafka consumer groups |
| **Notification System** | Alert triggers, status updates | Low latency publishing | Async event publishing |
| **Dashboard Systems** | Real-time metrics, alerts | Sub-second updates | WebSocket streaming |
| **External Analytics** | Data export, reporting | Batch and streaming | Data pipeline integration |

### API Integration

| Integration Type | Protocol | Constraints | Implementation |
|------------------|----------|-------------|----------------|
| **Internal APIs** | REST + GraphQL | Standard patterns | OpenAPI specs, GraphQL schema |
| **External Partners** | REST APIs | Rate limiting, security | API gateway, authentication |
| **Real-time Feeds** | WebSocket + Server-Sent Events | Connection management | SignalR, connection pooling |
| **Batch Exports** | File-based (CSV, JSON, Parquet) | Large dataset handling | Streaming exports, compression |

## 2.7 Restricciones de monitoreo

### Observabilidad Mandatoria

| Component | Tool | Purpose | Configuration |
|-----------|------|---------|---------------|
| **Metrics** | Prometheus + Grafana | Performance monitoring | Custom metrics, dashboards |
| **Logging** | ELK Stack | Centralized logging | Structured JSON logs |
| **Tracing** | OpenTelemetry + Jaeger | Distributed tracing | Request correlation |
| **Health Checks** | ASP.NET Core Health Checks | Service availability | Health endpoints |

### Business Metrics

| Metric | Purpose | Implementation | Alerting |
|--------|---------|----------------|----------|
| **Event Ingestion Rate** | Operational monitoring | Counter metrics | Rate anomaly detection |
| **Query Response Time** | Performance tracking | Histogram metrics | SLA breach alerts |
| **Data Freshness** | Real-time capability | Timestamp tracking | Stale data alerts |
| **Error Rates** | System health | Error counters | Error spike detection |

## 2.8 Impacto en el diseño

### Decisiones Arquitectónicas Derivadas

| Constraint | Design Decision | Trade-off | Mitigation |
|------------|----------------|-----------|------------|
| **CQRS Requirement** | Separate read/write models | Eventual consistency | Event-driven synchronization |
| **High Throughput** | Event streaming architecture | Complexity increase | Managed Kafka service |
| **Real-time Requirements** | In-memory caching | Memory overhead | Cache optimization |
| **Long-term Retention** | Tiered storage strategy | Storage costs | Automated lifecycle policies |

### Technology Stack Implications

| Layer | Technology Choice | Constraint Driver | Alternative Considered |
|-------|-------------------|-------------------|----------------------|
| **Event Store** | Apache Kafka | Throughput, durability | EventStore (complexity), AWS Kinesis (vendor lock) |
| **Read Database** | PostgreSQL | Query complexity, JSON support | MongoDB (consistency), ClickHouse (operational complexity) |
| **Time Series** | InfluxDB | Time-based analytics | Prometheus (query language), TimescaleDB (licensing) |
| **Search** | Elasticsearch | Full-text search, analytics | Solr (maintenance), Amazon OpenSearch (vendor dependency) |

### Operational Considerations

| Aspect | Implication | Mitigation Strategy |
|--------|-------------|-------------------|
| **Data Volume** | Large storage requirements | Compression, archival, tiered storage |
| **Query Complexity** | Performance optimization needed | Materialized views, indexing, caching |
| **Real-time Processing** | Resource intensive | Horizontal scaling, efficient algorithms |
| **Data Consistency** | Eventual consistency challenges | Monitoring, conflict resolution strategies |

## Referencias

### Architectural Patterns

- [CQRS Pattern](https://docs.microsoft.com/en-us/azure/architecture/patterns/cqrs)
- [Event Sourcing Pattern](https://docs.microsoft.com/en-us/azure/architecture/patterns/event-sourcing)
- [Saga Pattern](https://microservices.io/patterns/data/saga.html)

### Technologies

- [Apache Kafka Documentation](https://kafka.apache.org/documentation/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [InfluxDB Documentation](https://docs.influxdata.com/)
- [Elasticsearch Documentation](https://www.elastic.co/guide/)

### Compliance and Standards

- [GDPR Regulation](https://gdpr-info.eu/)
- [SOX Compliance](https://www.sox-online.com/)
- [ISO 27001](https://www.iso.org/isoiec-27001-information-security.html)
