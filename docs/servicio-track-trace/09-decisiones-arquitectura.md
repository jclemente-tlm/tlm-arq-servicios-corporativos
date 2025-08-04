# 9. Decisiones de arquitectura

## 9.1 ADR-001: Event Sourcing como patrón principal

**Estado**: Aceptado
**Fecha**: 2024-01-15
**Decidido por**: Equipo de Arquitectura

### Contexto
El servicio Track & Trace requiere trazabilidad completa de eventos operacionales con capacidades de auditoría robustas y análisis temporal de patrones.

### Alternativas consideradas
1. **CRUD tradicional con audit log**: Base de datos relacional con tabla de auditoría
2. **Event Sourcing**: Almacenamiento de eventos como única fuente de verdad
3. **Hybrid approach**: CRUD principal + Event log secundario

### Decisión
Adoptamos **Event Sourcing** como patrón arquitectónico principal.

### Justificación
- **Auditoría completa**: Cumplimiento con regulaciones que requieren trazabilidad total
- **Análisis temporal**: Capacidad de reconstruir estado en cualquier momento
- **Escalabilidad de lectura**: Read models especializados para diferentes vistas
- **Debugging avanzado**: Replay de eventos para reproducir problemas
- **Analytics nativo**: Stream de eventos ideal para análisis en tiempo real

### Consecuencias
- **Positivas**: Auditabilidad, escalabilidad, flexibilidad analítica
- **Negativas**: Complejidad inicial, curva de aprendizaje, eventual consistency
- **Mitigación**: Training del equipo, herramientas de debugging robustas

---

## 9.2 ADR-002: PostgreSQL como Event Store

**Estado**: Aceptado
**Fecha**: 2024-01-20
**Decidido por**: Equipo de Arquitectura

### Contexto
Necesidad de un almacén confiable y performante para eventos con soporte ACID y capacidades de consulta avanzadas.

### Alternativas consideradas
1. **EventStore DB**: Base especializada en event sourcing
2. **PostgreSQL**: Base relacional con soporte JSONB
3. **Apache Kafka**: Stream processing platform
4. **DynamoDB**: Base NoSQL managed

### Decisión
Adoptamos **PostgreSQL** con JSONB para almacenamiento de eventos.

### Justificación
- **Familiaridad del equipo**: Conocimiento existente en PostgreSQL
- **ACID compliance**: Transacciones robustas para consistency
- **JSONB support**: Flexibilidad para evolución de esquemas
- **Performance**: Índices especializados para queries temporales
- **Ecosystem**: Amplio soporte de herramientas y librerías
- **Multi-tenancy**: Schema-per-tenant para aislamiento

### Consecuencias
- **Positivas**: Confiabilidad, performance, ecosystem maduro
- **Negativas**: No especializado para event sourcing, setup más complejo
- **Mitigación**: Optimizaciones específicas, monitoring especializado

---

## 9.3 ADR-003: CQRS con read models separados

**Estado**: Aceptado
**Fecha**: 2024-01-25
**Decidido por**: Tech Lead

### Contexto
Optimización de queries para diferentes casos de uso (timeline, analytics, search) con patrones de acceso muy distintos.

### Alternativas consideradas
1. **Query directo desde Event Store**: Una sola fuente de datos
2. **CQRS con read models**: Separación de lectura y escritura
3. **Materialized views**: Vistas materializadas en misma DB

### Decisión
Implementamos **CQRS** con read models especializados.

### Justificación
- **Performance**: Queries optimizadas por caso de uso
- **Escalabilidad**: Read models independientes escalables
- **Flexibilidad**: Diferentes estructuras de datos por necesidad
- **Disponibilidad**: Tolerancia a fallos independiente

### Implementación
```csharp
// Command side - Event Store
public class EventStoreRepository : IEventRepository
{
    public async Task SaveEventsAsync(string streamId, IEnumerable<DomainEvent> events)
    {
        // Append events to PostgreSQL event store
    }
}

// Query side - Read Models
public class TimelineReadModel : ITimelineQueries
{
    public async Task<TimelineView> GetTimelineAsync(string entityId)
    {
        // Query from optimized timeline projection
    }
}
```

### Consecuencias
- **Positivas**: Performance, escalabilidad, mantenibilidad
- **Negativas**: Eventual consistency, complejidad de sincronización
- **Mitigación**: Monitoreo de lag, circuit breakers, fallback queries

---

## 9.4 ADR-004: Apache Kafka para event streaming

**Estado**: Aceptado
**Fecha**: 2024-02-01
**Decidido por**: Equipo de Arquitectura

### Contexto
Necesidad de streaming de eventos hacia read models y sistemas externos con alta throughput y durabilidad.

### Alternativas consideradas
1. **RabbitMQ**: Message broker tradicional
2. **Apache Kafka**: Distributed streaming platform
3. **Azure Service Bus**: Managed message service
4. **Direct database polling**: Polling de event store

### Decisión
Adoptamos **Apache Kafka** para event streaming.

### Justificación
- **Throughput**: Manejo de alto volumen de eventos
- **Durabilidad**: Persistencia configurable de mensajes
- **Ordering**: Garantías de orden por partición
- **Ecosystem**: Integración con herramientas de analytics
- **Scalability**: Escalamiento horizontal natural

### Configuración
```yaml
topics:
  domain-events:
    partitions: 12
    replication-factor: 3
    retention: 7d
  integration-events:
    partitions: 6
    replication-factor: 3
    retention: 30d
```

### Consecuencias
- **Positivas**: Alta performance, durabilidad, ecosystem rico
- **Negativas**: Complejidad operacional, learning curve
- **Mitigación**: Managed Kafka service, monitoring robusto, documentación

---

## 9.5 ADR-005: Redis para caching distribuido

**Estado**: Aceptado
**Fecha**: 2024-02-05
**Decidido por**: Tech Lead

### Contexto
Optimización de queries frecuentes de timeline y reducción de latencia en consultas de read models.

### Alternativas consideradas
1. **In-memory caching**: Cache local por instancia
2. **Redis**: Cache distribuido
3. **Memcached**: Simple distributed cache
4. **Database query cache**: Cache a nivel de DB

### Decisión
Implementamos **Redis** como cache distribuido.

### Justificación
- **Performance**: Sub-millisecond latency para hot data
- **Consistency**: Cache compartido entre instancias
- **Durability**: Opcional persistence para warm-up
- **Features**: Estructuras de datos avanzadas (TTL, pipelines)
- **Monitoring**: Métricas detalladas de hit/miss ratios

### Estrategia de cache
```csharp
public class CacheStrategy
{
    // L1: In-memory (5 min TTL)
    // L2: Redis distributed (15 min TTL)
    // L3: Database fallback

    public async Task<T> GetOrSetAsync<T>(string key, Func<Task<T>> factory)
    {
        return await _memoryCache.GetOrCreateAsync(key, async entry =>
        {
            entry.SlidingExpiration = TimeSpan.FromMinutes(5);
            return await _distributedCache.GetOrSetAsync(key, factory, TimeSpan.FromMinutes(15));
        });
    }
}
```

### Consecuencias
- **Positivas**: Latencia ultra-baja, consistency, monitoring
- **Negativas**: Complejidad adicional, gestión de invalidación
- **Mitigación**: TTL automático, cache warming, fallback strategies

---

## 9.6 ADR-006: Multi-tenant schema separation

**Estado**: Aceptado
**Fecha**: 2024-02-10
**Decidido por**: Equipo de Arquitectura

### Contexto
Aislamiento completo de datos entre tenants para compliance y security, con diferentes niveles de servicio por cliente.

### Alternativas consideradas
1. **Single schema con tenant_id**: Row-level security
2. **Schema per tenant**: Separación a nivel de schema
3. **Database per tenant**: Base de datos dedicada
4. **Service per tenant**: Instancia dedicada

### Decisión
Implementamos **Schema per tenant** en PostgreSQL.

### Justificación
- **Aislamiento**: Separación física de datos
- **Performance**: Índices y optimizaciones por tenant
- **Compliance**: Requisitos regulatorios de aislamiento
- **Backup**: Estrategias diferenciadas por cliente
- **Scaling**: Posibilidad de sharding por tenant

### Implementación
```sql
-- Dynamic schema creation
CREATE SCHEMA tenant_${tenantId};

-- Tenant-specific event table
CREATE TABLE tenant_${tenantId}.events (
    stream_id VARCHAR(255) NOT NULL,
    version BIGINT NOT NULL,
    event_type VARCHAR(255) NOT NULL,
    event_data JSONB NOT NULL,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (stream_id, version)
);

-- Tenant-specific indexes
CREATE INDEX idx_events_timestamp ON tenant_${tenantId}.events(timestamp);
CREATE INDEX idx_events_type ON tenant_${tenantId}.events(event_type);
```

### Consecuencias
- **Positivas**: Aislamiento total, performance, compliance
- **Negativas**: Gestión compleja de schemas, migraciones
- **Mitigación**: Automatización de setup, scripts de migración

---

## 9.7 Resumen de decisiones

| ADR | Decisión | Impacto | Estado |
|-----|----------|---------|---------|
| 001 | Event Sourcing | Alto - Arquitectura fundamental | ✅ Implementado |
| 002 | PostgreSQL Event Store | Alto - Storage principal | ✅ Implementado |
| 003 | CQRS Read Models | Medio - Performance | ✅ Implementado |
| 004 | Kafka Streaming | Medio - Integration | ✅ Implementado |
| 005 | Redis Caching | Bajo - Optimization | ✅ Implementado |
| 006 | Multi-tenant Schema | Alto - Security/Compliance | ✅ Implementado |

## 9.8 Decisiones pendientes

### PND-001: Sharding strategy para escalamiento
**Contexto**: Crecimiento esperado requiere distribución horizontal
**Opciones**: Shard por tenant, por tiempo, por hash de entity
**Target**: Q2 2024

### PND-002: Archiving policy para event store
**Contexto**: Retención a largo plazo vs performance
**Opciones**: Cold storage, compression, summarization
**Target**: Q3 2024
