# Estrategia de Colas para Alta Confiabilidad y Baja Latencia

## 🎯 Requerimientos Críticos

### No Pérdida de Información
- **Persistencia durável**: Todos los mensajes deben sobrevivir a fallos del sistema
- **Acknowledgments obligatorios**: Confirmación de procesamiento antes de eliminar mensajes
- **Dead Letter Queues (DLQ)**: Manejo de mensajes fallidos sin pérdida
- **Transacciones**: Garantizar atomicidad en operaciones críticas

### Baja Latencia para Consumidores
- **Desacoplamiento asíncrono**: Servicios consumidores no bloquean productores
- **Processing paralelo**: Múltiples workers por servicio
- **In-memory buffering**: Cache local para mensajes frecuentes
- **Retry patterns**: Reintentos inteligentes sin bloqueo

## 🏗️ Arquitectura Agnóstica Recomendada

### 1. Patrón Publisher-Subscriber con Garantías

```csharp
// Interfaz agnóstica para reliability
public interface IReliableMessagePublisher
{
    Task<MessageResult> PublishAsync<T>(T message, PublishOptions options = null);
    Task<MessageResult> PublishTransactionalAsync<T>(T message, IDbTransaction transaction);
}

public interface IReliableMessageConsumer
{
    Task<ConsumeResult> ConsumeAsync<T>(Func<T, Task<ProcessResult>> handler, ConsumeOptions options = null);
    Task StartBackgroundProcessingAsync(CancellationToken cancellationToken);
}

public class PublishOptions
{
    public int MaxRetries { get; set; } = 3;
    public TimeSpan RetryDelay { get; set; } = TimeSpan.FromSeconds(1);
    public bool RequireAcknowledgment { get; set; } = true;
    public bool PersistToDisk { get; set; } = true;
    public string CorrelationId { get; set; }
    public int Priority { get; set; } = 0; // 0=Normal, 1=High, 2=Critical
}
```

### 2. Outbox Pattern para Consistencia

```csharp
// Tabla de outbox en cada microservicio
public class OutboxEvent
{
    public Guid Id { get; set; }
    public string EventType { get; set; }
    public string Payload { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? ProcessedAt { get; set; }
    public int RetryCount { get; set; }
    public string Status { get; set; } // Pending, Sent, Failed
}

// Publisher con outbox
public class OutboxMessagePublisher : IReliableMessagePublisher
{
    public async Task<MessageResult> PublishTransactionalAsync<T>(T message, IDbTransaction transaction)
    {
        // 1. Guardar en outbox dentro de la transacción
        await SaveToOutboxAsync(message, transaction);

        // 2. Background service procesa outbox
        // 3. Marca como enviado solo después de ACK del broker
        return MessageResult.Queued;
    }
}
```

## 🚀 Implementaciones por Proveedor

### Opción 1: PostgreSQL + Polling (Máximo Control)

**Ventajas para tu caso:**
- ✅ **Cero pérdida**: ACID transactions garantizadas
- ✅ **Baja latencia**: Polling optimizado con LISTEN/NOTIFY
- ✅ **Sin dependencias externas**: Usa tu BD existente
- ✅ **Costo mínimo**: Solo PostgreSQL

```sql
-- Tabla de mensajes confiable
CREATE TABLE reliable_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    queue_name VARCHAR(100) NOT NULL,
    message_type VARCHAR(100) NOT NULL,
    payload JSONB NOT NULL,
    priority INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    scheduled_for TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    processed_at TIMESTAMP WITH TIME ZONE,
    retry_count INTEGER DEFAULT 0,
    max_retries INTEGER DEFAULT 3,
    status VARCHAR(20) DEFAULT 'pending', -- pending, processing, completed, failed
    correlation_id VARCHAR(100),
    tenant_id VARCHAR(50),
    country_code VARCHAR(3)
);

-- Índices para performance
CREATE INDEX idx_messages_queue_status ON reliable_messages(queue_name, status, scheduled_for);
CREATE INDEX idx_messages_priority ON reliable_messages(priority DESC, created_at);

-- LISTEN/NOTIFY para baja latencia
CREATE OR REPLACE FUNCTION notify_new_message() RETURNS TRIGGER AS $$
BEGIN
    PERFORM pg_notify('new_message_' || NEW.queue_name, NEW.id::text);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_notify_message
AFTER INSERT ON reliable_messages
FOR EACH ROW EXECUTE FUNCTION notify_new_message();
```

```csharp
// Implementación PostgreSQL con LISTEN/NOTIFY
public class PostgreSQLReliableConsumer : IReliableMessageConsumer
{
    private readonly NpgsqlConnection _connection;

    public async Task StartBackgroundProcessingAsync(CancellationToken cancellationToken)
    {
        // 1. LISTEN para nuevos mensajes
        await _connection.ExecuteAsync($"LISTEN new_message_{_queueName}");

        // 2. Polling híbrido: NOTIFY + polling backup cada 5s
        while (!cancellationToken.IsCancellationRequested)
        {
            await ProcessPendingMessagesAsync();
            await WaitForNotificationAsync(TimeSpan.FromSeconds(5));
        }
    }

    private async Task ProcessPendingMessagesAsync()
    {
        var messages = await GetPendingMessagesAsync(batchSize: 10);

        await Parallel.ForEachAsync(messages,
            new ParallelOptions { MaxDegreeOfParallelism = Environment.ProcessorCount },
            async (message, ct) => await ProcessMessageAsync(message, ct));
    }
}
```

### Opción 2: RabbitMQ (Balance Confiabilidad/Performance)

**Ventajas para tu caso:**
- ✅ **Durabilidad**: Persistent queues + confirm mode
- ✅ **Baja latencia**: Push-based delivery
- ✅ **DLQ nativo**: Dead letter exchanges
- ✅ **Clustering**: Alta disponibilidad

```csharp
// RabbitMQ con garantías
public class RabbitMQReliablePublisher : IReliableMessagePublisher
{
    public async Task<MessageResult> PublishAsync<T>(T message, PublishOptions options)
    {
        var properties = _channel.CreateBasicProperties();
        properties.Persistent = options.PersistToDisk; // Durabilidad
        properties.CorrelationId = options.CorrelationId;
        properties.Priority = (byte)options.Priority;

        // Publisher confirms para garantizar entrega
        _channel.ConfirmSelect();

        _channel.BasicPublish(
            exchange: _exchangeName,
            routingKey: _routingKey,
            mandatory: true, // Falla si no hay queue
            basicProperties: properties,
            body: SerializeMessage(message)
        );

        // Esperar confirmación
        return _channel.WaitForConfirms(TimeSpan.FromSeconds(5))
            ? MessageResult.Delivered
            : MessageResult.Failed;
    }
}
```

### Opción 3: Híbrida PostgreSQL + Kafka (Enterprise Grade)

**Para máxima confiabilidad:**
- PostgreSQL como **outbox durável**
- Kafka como **transport de alta velocidad**
- Debezium para **CDC automático**

```yaml
# docker-compose para híbrida
version: '3.8'
services:
  # PostgreSQL ya existente

  kafka:
    image: confluentinc/cp-kafka:latest
    environment:
      KAFKA_LOG_RETENTION_HOURS: 168 # 7 días retención
      KAFKA_LOG_SEGMENT_BYTES: 1073741824 # 1GB segments
      KAFKA_NUM_PARTITIONS: 3 # Paralelismo

  debezium:
    image: debezium/connect:latest
    environment:
      # CDC automático: PostgreSQL -> Kafka
      CONNECT_CONFIG_STORAGE_REPLICATION_FACTOR: 1
```

## 📊 Comparativa para tus Requerimientos

| Criterio | PostgreSQL + Polling | RabbitMQ | Híbrida PG+Kafka |
|----------|---------------------|----------|------------------|
| **No pérdida datos** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Baja latencia** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Simplicidad** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| **Costo operacional** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| **Vendor agnostic** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |

## 🎯 Recomendación Específica para Notificaciones y Track & Trace

### Fase 1: PostgreSQL con Optimizaciones
```csharp
// Configuración específica para tus servicios
public class NotificationQueueConfig
{
    public const string NOTIFICATION_QUEUE = "notifications";
    public const string TRACK_TRACE_QUEUE = "track_trace";

    // Prioridades por tipo
    public static readonly Dictionary<string, int> Priorities = new()
    {
        ["email"] = 0,      // Normal
        ["sms"] = 1,        // Alta
        ["push"] = 1,       // Alta
        ["whatsapp"] = 2,   // Crítica
        ["tracking"] = 2    // Crítica
    };

    // SLA por queue
    public static readonly Dictionary<string, TimeSpan> SLA = new()
    {
        [NOTIFICATION_QUEUE] = TimeSpan.FromSeconds(30),
        [TRACK_TRACE_QUEUE] = TimeSpan.FromSeconds(10) // Más crítico
    };
}
```

### Configuración de Retry Patterns
```csharp
public class RetryConfiguration
{
    // Backoff exponencial para notificaciones
    public static readonly RetryPolicy NotificationRetry = new()
    {
        MaxRetries = 5,
        BaseDelay = TimeSpan.FromSeconds(1),
        MaxDelay = TimeSpan.FromMinutes(10),
        BackoffType = BackoffType.Exponential
    };

    // Retry agresivo para tracking
    public static readonly RetryPolicy TrackingRetry = new()
    {
        MaxRetries = 10,
        BaseDelay = TimeSpan.FromMilliseconds(500),
        MaxDelay = TimeSpan.FromMinutes(2),
        BackoffType = BackoffType.Linear
    };
}
```

### Monitoreo de SLA
```csharp
public class QueueHealthChecker
{
    public async Task<QueueHealth> CheckQueueHealthAsync(string queueName)
    {
        var metrics = await GetQueueMetricsAsync(queueName);

        return new QueueHealth
        {
            QueueName = queueName,
            PendingMessages = metrics.PendingCount,
            AverageProcessingTime = metrics.AvgProcessingTime,
            SLACompliance = metrics.AvgProcessingTime < NotificationQueueConfig.SLA[queueName],
            FailureRate = metrics.FailedCount / (double)metrics.TotalCount
        };
    }
}
```

## 🚀 Plan de Implementación

### Semana 1: Base Confiable
1. Implementar tablas `reliable_messages` en PostgreSQL
2. Crear `IReliableMessagePublisher/Consumer`
3. Implementar PostgreSQL provider con LISTEN/NOTIFY

### Semana 2: Outbox Pattern
1. Integrar outbox en servicios de notificación y tracking
2. Background services para procesar outbox
3. Monitoreo básico

### Semana 3: Optimizaciones
1. Tunning de índices y queries
2. Implementar retry patterns inteligentes
3. Métricas de SLA

### Semana 4: Preparación para Escalado
1. Implementar RabbitMQ provider (agnóstico)
2. Testing de carga
3. Documentar migration path a Kafka si es necesario

¿Te parece bien esta estrategia? ¿Quieres que profundice en algún aspecto específico o empezamos con la implementación del PostgreSQL provider?
