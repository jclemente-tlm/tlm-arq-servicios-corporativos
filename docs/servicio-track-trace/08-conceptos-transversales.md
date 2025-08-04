# 8. Conceptos transversales

## 8.1 Modelo de dominio

### 8.1.1 Event Sourcing como principio arquitectónico

**Concepto**: Todos los cambios de estado se capturan como eventos inmutables, garantizando auditabilidad completa y permitiendo reconstrucción de estado en cualquier momento.

**Implementación**:
- **Event Store**: Almacén inmutable de eventos como única fuente de verdad
- **Snapshots**: Optimización para reconstrucción rápida de estado
- **Event versioning**: Manejo de evolución de esquemas de eventos
- **Temporal queries**: Consultas de estado en puntos específicos del tiempo

**Ventajas específicas para Track & Trace**:
- Auditoría completa requerida por regulaciones
- Análisis temporal de patrones operacionales
- Capacidad de replay para debugging
- Soporte natural para analytics y reporting

### 8.1.2 CQRS (Command Query Responsibility Segregation)

**Separación de responsabilidades**:
- **Command side**: Escritura de eventos, validaciones de negocio
- **Query side**: Lectura optimizada desde read models especializados
- **Event handlers**: Sincronización asíncrona entre ambos lados

**Read models especializados**:
- Timeline views para trazabilidad
- Aggregated views para dashboards
- Search indexes para consultas complejas
- Analytics projections para KPIs

## 8.2 Seguridad

### 8.2.1 Autenticación y autorización

**OAuth2 + JWT**:
```csharp
public class TrackTraceAuthenticationOptions
{
    public string Authority { get; set; }
    public string Audience { get; set; }
    public string[] Scopes { get; set; }
    public bool RequireHttpsMetadata { get; set; } = true;
}

[Authorize(Policy = "TrackTraceRead")]
public async Task<TimelineView> GetTimeline(string entityId)
{
    var tenantId = GetTenantFromClaims();
    return await _queryHandler.Handle(new GetTimelineQuery(entityId, tenantId));
}
```

**Políticas de autorización**:
- **TrackTraceRead**: Lectura de datos de trazabilidad
- **TrackTraceWrite**: Creación de eventos de seguimiento
- **TrackTraceAdmin**: Gestión de configuraciones y analytics
- **TrackTraceAudit**: Acceso a logs de auditoría

### 8.2.2 Protección de datos

**Cifrado**:
- **En tránsito**: TLS 1.3 para todas las comunicaciones
- **En reposo**: AES-256 para datos sensibles en Event Store
- **Claves**: Rotación automática cada 90 días

**Data masking**:
```csharp
public class EventDataMasker
{
    public string MaskSensitiveData(string eventData, EventType eventType)
    {
        if (eventType.ContainsPII)
        {
            return _maskingEngine.ApplyRules(eventData, _piiMaskingRules);
        }
        return eventData;
    }
}
```

**Compliance**:
- **GDPR**: Right to be forgotten implementado via event compensation
- **SOX**: Inmutabilidad de registros financieros
- **Audit trails**: Logs tamper-proof con digital signatures

## 8.3 Multi-tenancy

### 8.3.1 Aislamiento de datos

**Estrategia**: Schema-per-tenant para aislamiento completo

```sql
-- Tenant-specific event streams
CREATE SCHEMA tenant_abc123;
CREATE TABLE tenant_abc123.events (
    stream_id VARCHAR(255) NOT NULL,
    version BIGINT NOT NULL,
    event_type VARCHAR(255) NOT NULL,
    event_data JSONB NOT NULL,
    metadata JSONB,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (stream_id, version)
);

-- Row-level security como backup
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON events
FOR ALL TO application_role
USING (tenant_id = current_setting('app.current_tenant_id'));
```

### 8.3.2 Configuración por tenant

```csharp
public class TenantConfiguration
{
    public string TenantId { get; set; }
    public EventRetentionPolicy RetentionPolicy { get; set; }
    public AnalyticsSettings Analytics { get; set; }
    public ComplianceSettings Compliance { get; set; }
    public IntegrationEndpoints Integrations { get; set; }
}

public class TenantConfigurationService
{
    public async Task<TenantConfiguration> GetConfigurationAsync(string tenantId)
    {
        return await _cache.GetOrSetAsync($"tenant:config:{tenantId}",
            () => _repository.GetTenantConfigurationAsync(tenantId),
            TimeSpan.FromHours(1));
    }
}
```

## 8.4 Observabilidad

### 8.4.1 Structured logging

**Serilog configuration**:
```csharp
Log.Logger = new LoggerConfiguration()
    .Enrich.WithProperty("Service", "TrackTrace")
    .Enrich.WithProperty("Version", Assembly.GetExecutingAssembly().GetName().Version)
    .Enrich.WithCorrelationId()
    .WriteTo.Console(new JsonFormatter())
    .WriteTo.Elasticsearch(new ElasticsearchSinkOptions(new Uri(elasticUrl))
    {
        IndexFormat = "tracktrace-logs-{0:yyyy.MM.dd}",
        AutoRegisterTemplate = true
    })
    .CreateLogger();
```

**Contexto de eventos**:
```csharp
public class EventLoggingContext
{
    public string CorrelationId { get; set; }
    public string TenantId { get; set; }
    public string EntityId { get; set; }
    public string EventType { get; set; }
    public string UserId { get; set; }
    public DateTime Timestamp { get; set; }
}

// Usage in event handler
using (LogContext.PushProperty("TenantId", @event.TenantId))
using (LogContext.PushProperty("EntityId", @event.EntityId))
{
    _logger.LogInformation("Processing event {@Event}", @event);
}
```

### 8.4.2 Métricas y telemetría

**Custom metrics**:
```csharp
public class TrackTraceMetrics
{
    private readonly IMetricLogger _metrics;

    public void RecordEventProcessed(string eventType, string tenantId, TimeSpan duration)
    {
        _metrics.Counter("events_processed_total")
               .WithTag("event_type", eventType)
               .WithTag("tenant_id", tenantId)
               .Increment();

        _metrics.Histogram("event_processing_duration_ms")
               .WithTag("event_type", eventType)
               .Record(duration.TotalMilliseconds);
    }

    public void RecordQueryExecuted(string queryType, bool fromCache, TimeSpan duration)
    {
        _metrics.Counter("queries_executed_total")
               .WithTag("query_type", queryType)
               .WithTag("cache_hit", fromCache.ToString())
               .Increment();
    }
}
```

**Distributed tracing**:
```csharp
public class EventHandler
{
    private readonly ActivitySource _activitySource = new("TrackTrace.Events");

    public async Task Handle(DomainEvent @event)
    {
        using var activity = _activitySource.StartActivity("EventHandler.Handle");
        activity?.SetTag("event.type", @event.GetType().Name);
        activity?.SetTag("event.id", @event.Id);
        activity?.SetTag("tenant.id", @event.TenantId);

        // Process event
        await ProcessEvent(@event);
    }
}
```

## 8.5 Performance y escalabilidad

### 8.5.1 Estrategias de cache

**Niveles de cache**:
1. **L1 (In-memory)**: Cache local para hot data
2. **L2 (Redis)**: Cache distribuido para read models
3. **L3 (CDN)**: Cache de edge para datos públicos

```csharp
public class CachedTimelineService
{
    public async Task<TimelineView> GetTimelineAsync(string entityId, string tenantId)
    {
        var cacheKey = $"timeline:{tenantId}:{entityId}";

        // L1 Cache
        if (_memoryCache.TryGetValue(cacheKey, out TimelineView cachedTimeline))
            return cachedTimeline;

        // L2 Cache
        var timelineJson = await _distributedCache.GetStringAsync(cacheKey);
        if (timelineJson != null)
        {
            var timeline = JsonSerializer.Deserialize<TimelineView>(timelineJson);
            _memoryCache.Set(cacheKey, timeline, TimeSpan.FromMinutes(5));
            return timeline;
        }

        // Database query
        var freshTimeline = await _queryHandler.Handle(new GetTimelineQuery(entityId, tenantId));
        await _distributedCache.SetStringAsync(cacheKey, JsonSerializer.Serialize(freshTimeline),
                                             new DistributedCacheEntryOptions
                                             {
                                                 SlidingExpiration = TimeSpan.FromMinutes(15)
                                             });
        return freshTimeline;
    }
}
```

### 8.5.2 Particionado y sharding

**Event store partitioning**:
```sql
-- Partition by tenant and time for optimal query performance
CREATE TABLE events (
    stream_id VARCHAR(255) NOT NULL,
    version BIGINT NOT NULL,
    tenant_id VARCHAR(50) NOT NULL,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    event_type VARCHAR(255) NOT NULL,
    event_data JSONB NOT NULL
) PARTITION BY RANGE (timestamp);

-- Monthly partitions
CREATE TABLE events_2024_01 PARTITION OF events
FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

CREATE TABLE events_2024_02 PARTITION OF events
FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');
```

## 8.6 Manejo de errores

### 8.6.1 Estrategias de retry

```csharp
public class RetryPolicy
{
    public static async Task<T> ExecuteWithRetryAsync<T>(
        Func<Task<T>> operation,
        int maxAttempts = 3,
        TimeSpan delay = default)
    {
        var attempts = 0;
        while (attempts < maxAttempts)
        {
            try
            {
                return await operation();
            }
            catch (Exception ex) when (IsRetriableException(ex) && attempts < maxAttempts - 1)
            {
                attempts++;
                var waitTime = CalculateBackoffDelay(attempts, delay);
                await Task.Delay(waitTime);
            }
        }

        throw new MaxRetryAttemptsExceededException(maxAttempts);
    }

    private static bool IsRetriableException(Exception ex)
    {
        return ex is TimeoutException ||
               ex is HttpRequestException ||
               ex is PostgresException { SqlState: "40001" }; // Serialization failure
    }
}
```

### 8.6.2 Circuit breaker pattern

```csharp
public class EventStoreCircuitBreaker
{
    private readonly CircuitBreakerOptions _options;
    private volatile CircuitBreakerState _state = CircuitBreakerState.Closed;
    private volatile int _failureCount = 0;
    private volatile DateTime _lastFailureTime = DateTime.MinValue;

    public async Task<T> ExecuteAsync<T>(Func<Task<T>> operation)
    {
        if (_state == CircuitBreakerState.Open)
        {
            if (DateTime.UtcNow.Subtract(_lastFailureTime) > _options.OpenTimeout)
            {
                _state = CircuitBreakerState.HalfOpen;
            }
            else
            {
                throw new CircuitBreakerOpenException("Event store circuit breaker is open");
            }
        }

        try
        {
            var result = await operation();
            OnSuccess();
            return result;
        }
        catch (Exception ex)
        {
            OnFailure(ex);
            throw;
        }
    }
}
```

## 8.7 Testing

### 8.7.1 Test strategies

**Event sourcing tests**:
```csharp
public class EventStoreTests
{
    [Fact]
    public async Task Should_Reconstruct_Entity_State_From_Events()
    {
        // Given
        var entityId = "entity-123";
        var events = new List<DomainEvent>
        {
            new EntityCreated(entityId, "Test Entity"),
            new EntityStatusChanged(entityId, Status.Active),
            new EntityUpdated(entityId, "Updated Entity")
        };

        // When
        foreach (var @event in events)
        {
            await _eventStore.AppendEventsAsync(entityId, @event.Version - 1, new[] { @event });
        }

        var reconstructedEntity = await _entityRepository.GetByIdAsync(entityId);

        // Then
        reconstructedEntity.Should().NotBeNull();
        reconstructedEntity.Name.Should().Be("Updated Entity");
        reconstructedEntity.Status.Should().Be(Status.Active);
    }
}
```

**Integration tests**:
```csharp
public class TimelineIntegrationTests : IClassFixture<WebApplicationFactory<Program>>
{
    [Fact]
    public async Task Should_Return_Timeline_For_Valid_Entity()
    {
        // Given
        var client = _factory.CreateClient();
        var entityId = await CreateTestEntity();

        // When
        var response = await client.GetAsync($"/api/v1/timeline/{entityId}");

        // Then
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var timeline = await response.Content.ReadFromJsonAsync<TimelineView>();
        timeline.Events.Should().NotBeEmpty();
    }
}
```
