# 7. Vista de implementación

## 7.1 Estructura del sistema

### 7.1.1 Organización de código

```
src/
├── TLM.Services.TrackTrace.API/           # REST API Layer
│   ├── Controllers/                       # API Controllers
│   ├── Middleware/                        # HTTP Middleware
│   ├── Configuration/                     # DI Configuration
│   └── Program.cs                         # Application Entry Point
├── TLM.Services.TrackTrace.Application/   # Application Layer
│   ├── Commands/                          # CQRS Commands
│   ├── Queries/                           # CQRS Queries
│   ├── Handlers/                          # Command/Query Handlers
│   ├── Validators/                        # FluentValidation Rules
│   ├── Services/                          # Application Services
│   └── DTOs/                              # Data Transfer Objects
├── TLM.Services.TrackTrace.Domain/        # Domain Layer
│   ├── Entities/                          # Domain Entities
│   ├── ValueObjects/                      # Value Objects
│   ├── Events/                            # Domain Events
│   ├── Repositories/                      # Repository Abstractions
│   └── Services/                          # Domain Services
├── TLM.Services.TrackTrace.Infrastructure/ # Infrastructure Layer
│   ├── EventStore/                        # Event Store Implementation
│   ├── ReadModels/                        # Read Model Projections
│   ├── Kafka/                             # Kafka Integration
│   ├── Authentication/                    # OAuth2/JWT
│   └── Monitoring/                        # Telemetry & Metrics
└── TLM.Services.TrackTrace.Tests/         # Test Projects
    ├── Unit/                              # Unit Tests
    ├── Integration/                       # Integration Tests
    └── Performance/                       # Load Tests
```

### 7.1.2 Módulos principales

#### Event Store Module
```csharp
// Core abstraction
public interface IEventStore
{
    Task<EventStream> GetEventsAsync(string streamId, long fromVersion = 0);
    Task<AppendResult> AppendEventsAsync(string streamId, long expectedVersion,
                                       IEnumerable<DomainEvent> events);
    Task<Snapshot> GetSnapshotAsync(string streamId);
    Task SaveSnapshotAsync(string streamId, Snapshot snapshot);
}

// PostgreSQL implementation
public class PostgreSqlEventStore : IEventStore
{
    private readonly IDbContext _context;
    private readonly IEventSerializer _serializer;

    public async Task<AppendResult> AppendEventsAsync(string streamId,
                                                     long expectedVersion,
                                                     IEnumerable<DomainEvent> events)
    {
        using var transaction = await _context.BeginTransactionAsync();

        // Optimistic concurrency check
        var currentVersion = await GetStreamVersionAsync(streamId);
        if (currentVersion != expectedVersion)
            throw new ConcurrencyException($"Expected version {expectedVersion}, got {currentVersion}");

        // Serialize and persist events
        foreach (var @event in events)
        {
            var eventData = _serializer.Serialize(@event);
            await _context.Events.AddAsync(new EventRecord
            {
                StreamId = streamId,
                Version = ++currentVersion,
                EventType = @event.GetType().Name,
                Data = eventData,
                Timestamp = DateTimeOffset.UtcNow
            });
        }

        await _context.SaveChangesAsync();
        await transaction.CommitAsync();

        return new AppendResult { Success = true, NewVersion = currentVersion };
    }
}
```

#### Read Model Projections
```csharp
// Entity timeline projection
public class EntityTimelineProjection : IEventHandler<EntityEvent>
{
    private readonly IReadModelStore _readStore;

    public async Task Handle(EntityEvent @event)
    {
        var timeline = await _readStore.GetTimelineAsync(@event.EntityId) ??
                      new EntityTimeline(@event.EntityId);

        timeline.AddEvent(new TimelineEvent
        {
            EventId = @event.Id,
            Timestamp = @event.Timestamp,
            EventType = @event.GetType().Name,
            Data = @event.ToTimelineData(),
            Metadata = @event.Metadata
        });

        await _readStore.SaveTimelineAsync(timeline);
    }
}

// Performance metrics projection
public class PerformanceMetricsProjection : IEventHandler<OperationalEvent>
{
    private readonly ITimeSeriesStore _timeSeriesStore;

    public async Task Handle(OperationalEvent @event)
    {
        var metrics = CalculateMetrics(@event);

        await _timeSeriesStore.WritePointAsync(new MetricPoint
        {
            Measurement = "operational_performance",
            Tags = new Dictionary<string, string>
            {
                ["tenant_id"] = @event.TenantId,
                ["entity_type"] = @event.EntityType,
                ["operation"] = @event.OperationType
            },
            Fields = metrics,
            Timestamp = @event.Timestamp
        });
    }
}
```

## 7.2 Configuración de despliegue

### 7.2.1 Docker Configuration

```dockerfile
# Multi-stage build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy project files
COPY ["src/TLM.Services.TrackTrace.API/", "TLM.Services.TrackTrace.API/"]
COPY ["src/TLM.Services.TrackTrace.Application/", "TLM.Services.TrackTrace.Application/"]
COPY ["src/TLM.Services.TrackTrace.Domain/", "TLM.Services.TrackTrace.Domain/"]
COPY ["src/TLM.Services.TrackTrace.Infrastructure/", "TLM.Services.TrackTrace.Infrastructure/"]

# Restore dependencies
RUN dotnet restore "TLM.Services.TrackTrace.API/TLM.Services.TrackTrace.API.csproj"

# Build application
RUN dotnet build "TLM.Services.TrackTrace.API/TLM.Services.TrackTrace.API.csproj" -c Release -o /app/build

# Publish
FROM build AS publish
RUN dotnet publish "TLM.Services.TrackTrace.API/TLM.Services.TrackTrace.API.csproj" -c Release -o /app/publish

# Runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

# Security: Run as non-root user
RUN adduser --disabled-password --home /app --gecos '' appuser && chown -R appuser /app
USER appuser

COPY --from=publish /app/publish .
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

ENTRYPOINT ["dotnet", "TLM.Services.TrackTrace.API.dll"]
```

### 7.2.2 Kubernetes Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tracktrace-api
  namespace: corporate-services
spec:
  replicas: 3
  selector:
    matchLabels:
      app: tracktrace-api
  template:
    metadata:
      labels:
        app: tracktrace-api
    spec:
      containers:
      - name: api
        image: tlm/tracktrace-api:latest
        ports:
        - containerPort: 8080
        env:
        - name: ASPNETCORE_ENVIRONMENT
          value: "Production"
        - name: ConnectionStrings__EventStore
          valueFrom:
            secretKeyRef:
              name: db-secrets
              key: eventstore-connection
        - name: Kafka__BootstrapServers
          valueFrom:
            configMapKeyRef:
              name: kafka-config
              key: bootstrap-servers
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health/live
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
```

### 7.2.3 Infrastructure as Code

```yaml
# Terraform configuration for AWS deployment
resource "aws_ecs_cluster" "tracktrace_cluster" {
  name = "corporate-services-tracktrace"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_service" "tracktrace_api" {
  name            = "tracktrace-api"
  cluster         = aws_ecs_cluster.tracktrace_cluster.id
  task_definition = aws_ecs_task_definition.tracktrace_api.arn
  desired_count   = 3

  load_balancer {
    target_group_arn = aws_lb_target_group.tracktrace_api.arn
    container_name   = "tracktrace-api"
    container_port   = 8080
  }

  deployment_configuration {
    maximum_percent         = 200
    minimum_healthy_percent = 100
  }

  # Blue/Green deployment
  deployment_controller {
    type = "CODE_DEPLOY"
  }
}

resource "aws_rds_cluster" "eventstore" {
  cluster_identifier     = "tracktrace-eventstore"
  engine                = "aurora-postgresql"
  engine_version        = "13.7"
  database_name         = "eventstore"
  master_username       = "eventstore_user"
  master_password       = var.db_password
  backup_retention_period = 7
  preferred_backup_window = "03:00-04:00"

  # Multi-AZ for high availability
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]

  # Encryption at rest
  storage_encrypted = true
  kms_key_id       = aws_kms_key.eventstore.arn
}
```

## 7.3 Configuración

### 7.3.1 Application Configuration

```json
{
  "EventStore": {
    "ConnectionString": "Host=eventstore-db;Database=tracktrace_events;Username=eventstore;Password=${DB_PASSWORD}",
    "SnapshotFrequency": 100,
    "RetentionPolicy": {
      "MaxAge": "P365D",
      "SnapshotAge": "P30D"
    }
  },
  "ReadModels": {
    "ConnectionString": "Host=readmodel-db;Database=tracktrace_views;Username=readonly;Password=${DB_PASSWORD}",
    "RefreshInterval": "00:00:05",
    "CacheSettings": {
      "DefaultTTL": "00:15:00",
      "MaxSize": "500MB"
    }
  },
  "Kafka": {
    "BootstrapServers": "kafka-cluster:9092",
    "Topics": {
      "DomainEvents": "corporate.tracktrace.events",
      "IntegrationEvents": "corporate.integration.events"
    },
    "Consumer": {
      "GroupId": "tracktrace-projections",
      "AutoOffsetReset": "Earliest",
      "EnableAutoCommit": false
    }
  },
  "Authentication": {
    "Authority": "https://identity.corporate.com",
    "Audience": "corporate-tracktrace-api",
    "RequireHttpsMetadata": true
  },
  "Monitoring": {
    "Metrics": {
      "Enabled": true,
      "Endpoint": "/metrics",
      "Tags": {
        "service": "tracktrace-api",
        "version": "1.0.0"
      }
    },
    "Tracing": {
      "Enabled": true,
      "Endpoint": "http://jaeger-collector:14268/api/traces",
      "SamplingRate": 0.1
    }
  }
}
```

## 7.4 Patrones de implementación

### 7.4.1 Dependency Injection Configuration

```csharp
public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddTrackTraceServices(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        // Event Store
        services.AddScoped<IEventStore, PostgreSqlEventStore>();
        services.AddScoped<IEventSerializer, JsonEventSerializer>();

        // CQRS
        services.AddMediatR(typeof(CreateEventCommand).Assembly);
        services.AddValidatorsFromAssembly(typeof(CreateEventValidator).Assembly);

        // Read Models
        services.AddScoped<IReadModelStore, PostgreSqlReadModelStore>();
        services.AddHostedService<ProjectionHostedService>();

        // Kafka Integration
        services.AddSingleton<IKafkaProducer, KafkaProducer>();
        services.AddHostedService<KafkaConsumerService>();

        // Caching
        services.AddStackExchangeRedisCache(options => {
            options.Configuration = configuration.GetConnectionString("Redis");
        });

        // Monitoring
        services.AddOpenTelemetryTracing(builder => {
            builder.AddAspNetCoreInstrumentation()
                   .AddHttpClientInstrumentation()
                   .AddJaegerExporter();
        });

        return services;
    }
}
```

### 7.4.2 Background Services

```csharp
public class ProjectionHostedService : BackgroundService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly ILogger<ProjectionHostedService> _logger;

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        await foreach (var @event in _kafkaConsumer.ConsumeAsync(stoppingToken))
        {
            using var scope = _serviceProvider.CreateScope();
            var projectionManager = scope.ServiceProvider.GetRequiredService<IProjectionManager>();

            try
            {
                await projectionManager.ProjectAsync(@event);
                await _kafkaConsumer.CommitAsync(@event);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to project event {EventId}", @event.Id);
                // Handle poison messages, dead letter queue, etc.
            }
        }
    }
}
```

## 7.5 Gestión de configuración

### 7.5.1 Configuration Sources

1. **appsettings.json**: Base configuration
2. **Environment variables**: Runtime overrides
3. **Azure Key Vault**: Secrets management
4. **ConfigMaps/Secrets**: Kubernetes configuration
5. **Feature flags**: Dynamic configuration

### 7.5.2 Configuration validation

```csharp
public class EventStoreOptions
{
    public const string SectionName = "EventStore";

    [Required]
    public string ConnectionString { get; set; }

    [Range(1, 1000)]
    public int SnapshotFrequency { get; set; } = 100;

    public RetentionPolicyOptions RetentionPolicy { get; set; } = new();
}

// Startup validation
services.AddOptions<EventStoreOptions>()
        .Bind(configuration.GetSection(EventStoreOptions.SectionName))
        .ValidateDataAnnotations()
        .ValidateOnStart();
```
