# Talma.CorporateServices.Messaging

## Descripción
Librería agnóstica corporativa para messaging confiable con soporte para múltiples proveedores y garantías de entrega.

## Características Principales
- **Vendor Agnostic**: Interfaces agnósticas con múltiples implementaciones
- **Reliability First**: Outbox pattern, acknowledgments y retry patterns
- **Zero Message Loss**: Garantías ACID y durabilidad configurable
- **Low Latency**: Optimizaciones para alta velocidad y procesamiento paralelo
- **Enterprise Ready**: Multi-tenant, observabilidad y configuración dinámica

## Interfaces Principales

### IReliableMessagePublisher
```csharp
public interface IReliableMessagePublisher
{
    Task<MessageResult> PublishAsync<T>(T message, PublishOptions options = null);
    Task<MessageResult> PublishTransactionalAsync<T>(T message, IDbTransaction transaction);
    Task<BatchResult> PublishBatchAsync<T>(IEnumerable<T> messages, PublishOptions options = null);
}
```

### IReliableMessageConsumer
```csharp
public interface IReliableMessageConsumer
{
    Task<ConsumeResult> ConsumeAsync<T>(Func<T, Task<ProcessResult>> handler, ConsumeOptions options = null);
    Task StartBackgroundProcessingAsync(CancellationToken cancellationToken);
    Task StopBackgroundProcessingAsync();
}
```

### IOutboxProcessor
```csharp
public interface IOutboxProcessor
{
    Task ProcessOutboxAsync(CancellationToken cancellationToken);
    Task<OutboxStatus> GetOutboxStatusAsync();
}
```

## Proveedores Soportados

### PostgreSQL Provider (Recomendado para Start)
- **Durabilidad**: ACID transactions
- **Latencia**: LISTEN/NOTIFY para baja latencia
- **Costo**: Minimal (usa BD existente)
- **Complexity**: Baja

### RabbitMQ Provider
- **Durabilidad**: Persistent queues + publisher confirms
- **Latencia**: Push-based delivery
- **Features**: Dead letter exchanges, clustering
- **Complexity**: Media

### Apache Kafka Provider
- **Durabilidad**: Replication + log persistence
- **Throughput**: Máximo para alta escala
- **Features**: Partitioning, stream processing
- **Complexity**: Alta

## Configuración por Ambiente

### Development
```json
{
  "Messaging": {
    "Provider": "PostgreSQL",
    "ConnectionString": "Host=localhost;Database=messaging;",
    "DefaultRetries": 3,
    "OutboxProcessingInterval": "00:00:05"
  }
}
```

### Production
```json
{
  "Messaging": {
    "Provider": "RabbitMQ",
    "ConnectionString": "amqp://user:pass@rabbitmq-cluster:5672/",
    "DefaultRetries": 5,
    "OutboxProcessingInterval": "00:00:01",
    "HighAvailability": true
  }
}
```

## Registro de Servicios

### Configuración Básica
```csharp
services.AddTalmaMessaging(options =>
{
    options.UsePostgreSQL(connectionString);
    options.WithOutboxPattern();
    options.WithRetryPolicy(retries: 5, backoff: TimeSpan.FromSeconds(2));
});
```

### Configuración Avanzada
```csharp
services.AddTalmaMessaging(options =>
{
    options.UseProvider("RabbitMQ") // Dynamic provider selection
        .WithConnectionString(Configuration.GetConnectionString("Messaging"))
        .WithOutboxPattern(enabled: true)
        .WithRetryPolicy(new ExponentialBackoffRetryPolicy())
        .WithDeadLetterQueue(enabled: true)
        .WithBatchProcessing(batchSize: 100)
        .WithTelemetry(enabled: true);
});
```

## Uso en Servicios

### Publisher Example
```csharp
public class NotificationService
{
    private readonly IReliableMessagePublisher _publisher;

    public async Task SendNotificationAsync(NotificationRequest request)
    {
        var notificationEvent = new NotificationEvent
        {
            Id = Guid.NewGuid(),
            Type = request.Type,
            Recipients = request.Recipients,
            Content = request.Content,
            Priority = request.Priority,
            TenantId = request.TenantId
        };

        var options = new PublishOptions
        {
            Priority = request.Priority,
            RequireAcknowledgment = true,
            CorrelationId = request.CorrelationId,
            MaxRetries = request.Priority == Priority.Critical ? 10 : 3
        };

        var result = await _publisher.PublishAsync(notificationEvent, options);

        if (result.Status != MessageStatus.Delivered)
        {
            throw new MessagingException($"Failed to publish notification: {result.Error}");
        }
    }
}
```

### Consumer Example
```csharp
public class NotificationProcessor : BackgroundService
{
    private readonly IReliableMessageConsumer _consumer;

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        var options = new ConsumeOptions
        {
            QueueName = "notifications",
            MaxConcurrency = Environment.ProcessorCount * 2,
            PrefetchCount = 10,
            AutoAcknowledge = false
        };

        await _consumer.ConsumeAsync<NotificationEvent>(
            handler: ProcessNotificationAsync,
            options: options
        );
    }

    private async Task<ProcessResult> ProcessNotificationAsync(NotificationEvent notification)
    {
        try
        {
            // Process notification logic
            await SendActualNotificationAsync(notification);
            return ProcessResult.Success();
        }
        catch (TemporaryException ex)
        {
            return ProcessResult.Retry(ex.Message);
        }
        catch (Exception ex)
        {
            return ProcessResult.Fail(ex.Message);
        }
    }
}
```

## Outbox Pattern Implementation

### Outbox Entity
```csharp
public class OutboxEvent
{
    public Guid Id { get; set; }
    public string EventType { get; set; }
    public string QueueName { get; set; }
    public string Payload { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? ProcessedAt { get; set; }
    public int RetryCount { get; set; }
    public int MaxRetries { get; set; }
    public string Status { get; set; } // Pending, Processing, Sent, Failed
    public string Error { get; set; }
    public string CorrelationId { get; set; }
    public string TenantId { get; set; }
}
```

### Transactional Publishing
```csharp
public async Task CreateOrderWithNotificationAsync(CreateOrderRequest request)
{
    using var transaction = await _dbContext.Database.BeginTransactionAsync();

    try
    {
        // 1. Create order in database
        var order = new Order(request);
        await _dbContext.Orders.AddAsync(order);

        // 2. Publish notification via outbox (same transaction)
        var notification = new OrderCreatedEvent { OrderId = order.Id };
        await _messagePublisher.PublishTransactionalAsync(notification, transaction.GetDbTransaction());

        // 3. Commit both operations atomically
        await _dbContext.SaveChangesAsync();
        await transaction.CommitAsync();
    }
    catch
    {
        await transaction.RollbackAsync();
        throw;
    }
}
```

## Monitoring y Observabilidad

### Métricas Expuestas
- `messaging_published_total`: Total messages published
- `messaging_consumed_total`: Total messages consumed
- `messaging_failed_total`: Total failed messages
- `messaging_retry_total`: Total retry attempts
- `messaging_processing_duration`: Message processing time
- `messaging_queue_depth`: Current queue depth
- `messaging_outbox_pending`: Pending outbox events

### Health Checks
```csharp
services.AddHealthChecks()
    .AddTalmaMessaging() // Adds messaging health checks
    .AddCheck<OutboxHealthCheck>("outbox")
    .AddCheck<QueueDepthHealthCheck>("queue-depth");
```

## Package Dependencies

```xml
<PackageReference Include="Microsoft.Extensions.DependencyInjection" Version="8.0.0" />
<PackageReference Include="Microsoft.Extensions.Hosting" Version="8.0.0" />
<PackageReference Include="Microsoft.Extensions.Logging" Version="8.0.0" />
<PackageReference Include="Npgsql" Version="8.0.0" Condition="'$(PostgreSQLProvider)' == 'true'" />
<PackageReference Include="RabbitMQ.Client" Version="6.8.1" Condition="'$(RabbitMQProvider)' == 'true'" />
<PackageReference Include="Confluent.Kafka" Version="2.3.0" Condition="'$(KafkaProvider)' == 'true'" />
<PackageReference Include="System.Text.Json" Version="8.0.0" />
```

## Migration Strategy

### Phase 1: PostgreSQL Foundation
1. Implement PostgreSQL provider with outbox
2. Migrate notification service
3. Migrate track & trace service

### Phase 2: Production Hardening
1. Add RabbitMQ provider
2. Implement monitoring dashboards
3. Load testing and optimization

### Phase 3: Scale Preparation
1. Add Kafka provider
2. Implement sharding strategies
3. Multi-region support
