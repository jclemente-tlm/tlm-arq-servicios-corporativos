# 4. Estrategia de solución

## 4.1 Enfoque arquitectónico central: CQRS + Event Sourcing

**Decisión clave**: Arquitectura CQRS (Command Query Responsibility Segregation) con Event Sourcing para máxima trazabilidad y rendimiento de consultas.

### Principios de diseño

| Principio | Implementación | Beneficio |
|-----------|----------------|-----------|
| **Event-First Design** | Todos los cambios como eventos immutables | Auditabilidad completa, replay capability |
| **Command/Query Separation** | Write models vs Read models optimizados | Escalabilidad independiente por operación |
| **Procesamiento en Tiempo Real** | Event streaming agnóstico de tecnología | Latencia optimizada según volumen |
| **Polyglot Persistence** | Event store + read databases especializadas | Optimización por caso de uso |

## 4.2 Decisiones arquitectónicas clave

### Decisión 1: Event Store Agnóstico Basado en Volumen

**Alternativas tecnológicas disponibles**:

- 🟦 **PostgreSQL**: Simplicidad operacional, transacciones ACID, expertise del equipo
- 🟦 **Amazon SNS + SQS**: Escalabilidad managed, integración AWS nativa
- 🟦 **RabbitMQ / Amazon MQ**: Event streaming robusto, patrones de messaging complejos
- 🟦 **Event Bus (Kafka)**: Alto capacidad de procesamiento, ecosistema maduro (para volúmenes muy altos)

**Umbrales de decisión**:

- **< 1,000 eventos/hora**: PostgreSQL suficiente
- **1,000-10,000 eventos/hora**: Evaluación entre PostgreSQL optimizado vs SNS+SQS
- **> 10,000 eventos/hora**: SNS+SQS o RabbitMQ/Amazon MQ recomendados
- **> 100,000 eventos/hora**: Evaluación de Event Bus (Kafka)

**Abstracción de Event Store**:

- Interface `IEventStore` para desacoplar implementación de lógica de negocio
- Implementaciones concretas: PostgreSQLEventStore, SnsEventStore, RabbitMQEventStore
- Decisión de implementación basada en métricas de volumen observadas

## 4.3 Stack tecnológico agnóstico

| Capa | Tecnología | Justificación |
|------|------------|---------------|
| **Event Store** | PostgreSQL / SNS+SQS / RabbitMQ | Según volumen real de eventos |
| **Event Interface** | Abstracción IEventStore | Permite cambio de tecnología sin reescribir lógica |
| **Command API** | ASP.NET Core 8+ | Corporate standard |
| **Query API** | ASP.NET Core + GraphQL | Flexible queries |
| **Read DB** | PostgreSQL 15+ | Vistas especializadas y materialized views |
| **Time Series** | InfluxDB 2.7+ | Metrics, analytics especializadas |
| **Search** | Elasticsearch 8+ | Full-text search |
| **Cache** | Redis 7+ | Query performance |

## 4.4 Estrategia de datos

### Esquema de Eventos

```json
{
  "eventId": "uuid",
  "eventType": "FlightDelayEvent",
  "aggregateId": "flight-123",
  "timestamp": "2025-01-01T12:00:00Z",
  "tenantId": "peru-corp",
  "payload": { ... },
  "metadata": { "source": "sita-messaging" }
}
```

### Retención de Datos

| Data Type | Retention | Storage | Access Pattern |
|-----------|-----------|---------|----------------|
| **Hot Events** | 30 days | Event store primary | Real-time queries |
| **Warm Events** | 2 years | Read database optimized | Historical analysis |
| **Cold Events** | 7 years | S3 Glacier + metadata | Compliance, audit |

## 4.5 Rendimiento y escalabilidad

### Escalamiento Basado en Métricas

| Métrica Observada | Umbral de Acción | Decisión Tecnológica | Objetivo |
|-------------------|------------------|---------------------|----------|
| **Eventos/hora** | < 1,000 | PostgreSQL + índices | Simplicidad operacional |
| **Eventos/hora** | 1,000 - 10,000 | Evaluación PostgreSQL vs SNS+SQS | Según latencia requerida |
| **Eventos/hora** | > 10,000 | SNS+SQS o RabbitMQ/Amazon MQ | Escalabilidad managed |
| **Latencia Read APIs** | p95 > 200ms | Redis cache + scaling horizontal | 10k concurrent queries |
| **CPU Event Processing** | > 70% sostenido | Pod auto-scaling | Procesamiento eficiente |

### Optimización de Rendimiento

- **Cache Strategy**: Multi-level cache (Redis + aplicación)
- **Query Optimization**: Vistas materializadas + índices especializados
- **Database Sharding**: Por tenant + temporal para eventos históricos
- **CDN Integration**: Recursos estáticos y respuestas cacheables

## 4.6 Seguridad y observabilidad

### Seguridad

| Componente | Implementación | Protocolo |
|-----------|----------------|-----------|
| **API Authentication** | OAuth2 + JWT | `client_credentials` |
| **Event Encryption** | AES-256 | Payload data en reposo |
| **Network Security** | mTLS + WAF | Comunicaciones inter-servicio |
| **Audit Logging** | Event sourcing nativo | Inmutable audit trail |

### Observabilidad

- **Trazado Distribuido**: OpenTelemetry con trace correlation
- **Metrics Collection**: Prometheus + custom business metrics
- **Registro Estructurado**: Serilog con correlation IDs
- **Monitoreo de Salud**: Health checks + circuit breakers

## 4.7 Migración y compatibilidad

### Migración de Event Store

**Fase inicial**: PostgreSQL como event store primario

**Migración basada en volumen**:

1. **Trigger**: Métricas de volumen superan umbrales definidos
2. **Process**: Blue-green deployment con replay de eventos
3. **Validation**: Comparación de estado entre sistemas
4. **Cutover**: Switch gradual por tenant

### Compatibilidad hacia atrás

- **Event Schema Evolution**: Backward compatibility con versionado
- **API Versioning**: Semantic versioning + deprecation policies
- **Database Migrations**: Flyway + rollback procedures
