# ADR-001: Reliable Messaging con Esquemas Separados en Base de Datos Compartida

## Estado
Aceptado

## Contexto

Los servicios corporativos requieren un sistema de mensajería confiable que garantice:
- Cero pérdida de mensajes
- Procesamiento exactly-once
- Vendor-agnostic implementation
- Simplicidad operacional para Fase 1
- Path de migración para escalamiento futuro

## Decisión

**Fase 1**: Implementar reliable messaging usando **esquemas separados en la misma base de datos PostgreSQL**

### Estructura de Esquemas:
```sql
-- Esquema para datos de negocio
CREATE SCHEMA business;
CREATE TABLE business.tracking_events (...);
CREATE TABLE business.notifications (...);
CREATE TABLE business.notification_templates (...);

-- Esquema para reliable messaging
CREATE SCHEMA messaging;
CREATE TABLE messaging.reliable_messages (
    id UUID PRIMARY KEY,
    topic VARCHAR(255),
    channel_type VARCHAR(50),
    payload JSONB,
    tenant_id VARCHAR(100),
    created_at TIMESTAMP,
    processed_at TIMESTAMP,
    status VARCHAR(50)
);

CREATE TABLE messaging.dead_letter_store (
    id UUID PRIMARY KEY,
    original_message_id UUID,
    error_details JSONB,
    retry_count INTEGER,
    failed_at TIMESTAMP
);

CREATE TABLE messaging.outbox_events (
    id UUID PRIMARY KEY,
    aggregate_id UUID,
    event_type VARCHAR(255),
    payload JSONB,
    created_at TIMESTAMP,
    processed_at TIMESTAMP
);
```

### Implementación de Outbox Pattern:
```csharp
public class TrackingService
{
    public async Task CreateTrackingEventAsync(TrackingEventRequest request)
    {
        using var transaction = await _context.Database.BeginTransactionAsync();

        // 1. Guardar datos de negocio (schema business)
        var trackingEvent = new TrackingEvent(request);
        _context.TrackingEvents.Add(trackingEvent);

        // 2. Guardar evento en outbox (schema messaging)
        var outboxEvent = new OutboxEvent
        {
            AggregateId = trackingEvent.Id,
            EventType = "TrackingEventCreated",
            Payload = JsonSerializer.Serialize(trackingEvent)
        };
        _context.OutboxEvents.Add(outboxEvent);

        // 3. Commit transaccional (garantías ACID)
        await _context.SaveChangesAsync();
        await transaction.CommitAsync();
    }
}
```

## Consecuencias

### Ventajas:
✅ **Simplicidad Operacional**: Una sola base de datos que mantener
✅ **Transaccionalidad ACID**: Outbox pattern perfecto
✅ **Cero Configuración Externa**: Sin brokers, colas o infraestructura adicional
✅ **Desarrollo Rápido**: Sin complejidad de sincronización entre sistemas
✅ **Observabilidad**: SQL queries para debugging y monitoreo
✅ **Vendor Agnostic**: Interfaces permiten migración futura
✅ **Costo Mínimo**: Sin licencias o recursos adicionales

### Desventajas:
❌ **Latencia de Polling**: Menos eficiente que push notifications
❌ **Escalamiento Acoplado**: BD de negocio y messaging escalan juntas
❌ **Contención de Recursos**: Queries de negocio compiten con messaging

### Mitigaciones:
- **Índices Optimizados**: Para queries de polling eficientes
- **Particionamiento**: Por tenant_id y created_at
- **Batch Processing**: Múltiples mensajes por transacción
- **Background Services**: Procesamiento asíncrono desacoplado

## Plan de Migración (Fase 2)

### Opción A: Base de Datos Separada
```yaml
# Migración gradual
databases:
  business: corporate_services_data
  messaging: corporate_services_messaging
```

### Opción B: Message Broker Externo
```yaml
# Migración a RabbitMQ/Kafka
messaging:
  provider: "rabbitmq" # o "kafka"
  connection: "amqp://..."
  topics:
    - "notification.email"
    - "notification.sms"
    - "tracking.events"
```

## Implementación por Sistema

### Track & Trace System:
- `trackingEventStore`: Schema messaging para eventos
- `trackingDatabase`: Schema business para datos

### Notification System:
- `reliableMessageStore`: Schema messaging con routing por channel_type
- `notificationDB`: Schema business para templates/configuraciones

### SITA Messaging:
- `reliableMessageStore`: Schema messaging para eventos cross-system
- `sitaMessagingDB`: Schema business para templates SITA

## Métricas de Éxito

- **Latencia P95 < 500ms** para procesamiento de mensajes
- **Throughput > 1000 msgs/sec** por sistema
- **Zero Message Loss** garantizado por ACID transactions
- **Recovery Time < 30 segundos** para dead letter processing
- **Operational Overhead < 10%** comparado con brokers externos

## Referencias

- [Outbox Pattern - Microservices.io](https://microservices.io/patterns/data/transactional-outbox.html)
- [PostgreSQL Schemas Documentation](https://www.postgresql.org/docs/current/ddl-schemas.html)
- [Reliable Messaging Patterns](https://www.enterpriseintegrationpatterns.com/patterns/messaging/)
