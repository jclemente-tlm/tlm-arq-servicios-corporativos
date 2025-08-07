# 5. Vista de bloques de construcción

## 5.1 Sistema Track & Trace - Nivel 1 (Caja Blanca)

![Sistema Track & Trace - Vista General](/diagrams/servicios-corporativos/track_and_trace_system.png)

*Figura 5.1: Vista de contenedores del Sistema Track & Trace mostrando la separación entre Tracking API y Event Processor*

### Responsabilidad
Sistema de trazabilidad operacional que captura, procesa y analiza eventos empresariales en tiempo real utilizando arquitectura CQRS + Event Sourcing para proporcionar visibilidad completa de operaciones críticas.

### Bloques de Construcción Contenidos

#### Capa de Ingesta de Eventos
- **Responsabilidad:** Captura de eventos de múltiples fuentes y normalización
- **Tecnología:** Event connectors + REST APIs para ingesta manual
- **Interfaz:** Event streaming + REST APIs para ingesta manual

#### Servicio de Procesamiento de Comandos
- **Responsabilidad:** Procesamiento de comandos y orquestación de workflows
- **Tecnología:** .NET 8 con MediatR para CQRS
- **Interfaz:** REST API + gRPC para alto rendimiento

#### Event Store
- **Responsabilidad:** Almacenamiento inmutable de eventos para Event Sourcing
- **Tecnología:** PostgreSQL para inicio, escalable a SNS+SQS según volumen
- **Interfaz:** IEventStore abstraction para intercambio de tecnología

#### Query Engine
- **Responsabilidad:** Procesamiento de consultas complejas y projections
- **Tecnología:** Event stream processing + múltiples stores especializados
- **Interfaz:** GraphQL + REST APIs optimizadas

#### Servicio de Analytics y Reportes
- **Responsabilidad:** Análisis en tiempo real y generación de insights
- **Tecnología:** Apache Spark + MLlib para machine learning
- **Interfaz:** Real-time dashboards + scheduled reports

#### Motor de Notificaciones
- **Responsabilidad:** Alertas proactivas basadas en patrones y anomalías
- **Tecnología:** Complex Event Processing (CEP) con Apache Flink
- **Interfaz:** Push notifications + webhook callbacks

## 5.2 Capa de Ingesta de Eventos - Nivel 2 (Caja Blanca)

### Conectores de Entrada

#### SITA Message Connector
```csharp
public class SitaMessageConnector : IEventConnector
{
    public async Task<EventBatch> ProcessSitaMessages(SitaMessageBatch messages)
    {
        // Parse Type B messages
        // Extract flight operations data
        // Normalize to canonical event format
        // Apply business rules validation
    }
}
```

#### Conector de Servicios Corporativos
```csharp
public class CorporateServicesConnector : IEventConnector
{
    public async Task<EventBatch> ProcessServiceEvents(ServiceEventBatch events)
    {
        // Identity service events
        // Notification service events
        // Business service events
        // Correlation with existing traces
    }
}
```

#### Conector de Sistemas Externos
- **ERP Integration:** SAP, Oracle events via REST/SOAP
- **Legacy Mainframe:** IBM MQ message parsing
- **Aplicaciones Móviles:** Real-time event streaming via WebSockets
- **IoT Devices:** Sensor data via MQTT protocol

### Motor de Normalización de Eventos

#### Modelo de Evento Canónico
```json
{
  "eventId": "uuid",
  "traceId": "correlation-id",
  "timestamp": "2024-08-04T10:30:00Z",
  "source": "system-identifier",
  "eventType": "FLIGHT_DEPARTED",
  "version": "1.0",
  "payload": {
    "flightNumber": "LA123",
    "origin": "LIM",
    "destination": "MIA",
    "actualDeparture": "2024-08-04T10:30:00Z"
  },
  "metadata": {
    "tenantId": "airline-123",
    "correlationChain": ["check-in", "boarding", "departure"]
  }
}
```

#### Schema Registry Integration
- **Avro Schemas:** Versioned event schemas
- **Schema Evolution:** Backward/forward compatibility
- **Validation:** Real-time schema validation
- **Documentation:** Auto-generated from schemas

## 5.3 Servicio de Procesamiento de Comandos - Nivel 2 (Caja Blanca)

### CQRS Implementation

#### Command Handlers
```csharp
public class TrackFlightCommandHandler : IRequestHandler<TrackFlightCommand, CommandResult>
{
    public async Task<CommandResult> Handle(TrackFlightCommand command)
    {
        // Validate business rules
        // Create tracking events
        // Update aggregate state
        // Publish domain events
    }
}
```

#### Validación de Comandos
```csharp
public class TrackFlightCommandValidator : AbstractValidator<TrackFlightCommand>
{
    public TrackFlightCommandValidator()
    {
        RuleFor(x => x.FlightNumber).NotEmpty().Matches(@"^[A-Z]{2}\d{3,4}$");
        RuleFor(x => x.Route).Must(ValidateRoute).WithMessage("Invalid route");
        RuleFor(x => x.Timestamp).Must(BeValidTimestamp);
    }
}
```

### Orquestación de Flujos de Trabajo

#### Implementación del Patrón Saga
```csharp
public class FlightOperationSaga : ISaga<FlightDepartureEvent>
{
    public async Task Handle(FlightDepartureEvent @event)
    {
        // Start passenger boarding tracking
        // Initiate baggage loading monitoring
        // Schedule arrival predictions
        // Create maintenance checkpoints
    }
}
```

#### Motor de Procesos Empresariales
- **Flight Operations:** Departure → En Route → Arrival → Turnaround
- **Passenger Journey:** Check-in → Security → Boarding → Flight
- **Cargo Operations:** Acceptance → Loading → Transport → Delivery
- **Maintenance Cycle:** Inspection → Repair → Testing → Certification

## 5.4 Event Store - Nivel 2 (Caja Blanca)

### Event Store Agnóstico

#### Abstracción de Tecnología
```csharp
public interface IEventStore
{
    Task AppendEventsAsync(string streamId, IEnumerable<EventData> events);
    Task<IEnumerable<EventData>> ReadEventsAsync(string streamId, int fromVersion);
    Task<EventStream> ReadStreamAsync(string streamId);
}

// Implementaciones según volumen:
// - PostgreSQLEventStore (< 1,000 eventos/hora)
// - SnsEventStore (1,000-10,000 eventos/hora)
// - RabbitMQEventStore (> 10,000 eventos/hora)
```

#### Estructura de Eventos
```yaml
Event Schema:
  eventId: UUID
  eventType: string
  aggregateId: string
  timestamp: DateTime
  tenantId: string
  payload: object
  metadata:
    source: string
    correlationId: string
    causationId: string
    retention: 180 days
```

#### Event Serialization
```csharp
public class EventSerializer : ISerializer<TrackingEvent>
{
    public byte[] Serialize(TrackingEvent @event)
    {
        // Avro serialization with compression
        // Schema evolution support
        // Encryption for sensitive events
        return AvroConvert.Serialize(@event, Schema);
    }
}
```

### Cassandra para Indexación de Eventos

#### Tablas de Índice de Eventos
```cql
CREATE TABLE events_by_trace (
    trace_id UUID,
    timestamp TIMESTAMP,
    event_id UUID,
    event_type TEXT,
    source_system TEXT,
    payload BLOB,
    PRIMARY KEY (trace_id, timestamp, event_id)
) WITH CLUSTERING ORDER BY (timestamp DESC);

CREATE TABLE events_by_entity (
    entity_type TEXT,
    entity_id TEXT,
    timestamp TIMESTAMP,
    event_id UUID,
    trace_id UUID,
    PRIMARY KEY ((entity_type, entity_id), timestamp, event_id)
) WITH CLUSTERING ORDER BY (timestamp DESC);
```

#### Optimización de Consultas
- **Time-based Partitioning:** Events partitioned by date
- **Entity Indexing:** Fast lookup by business entities
- **Materialized Views:** Pre-computed aggregations
- **TTL Management:** Automatic data expiration

## 5.5 Motor de Modelos de Lectura - Nivel 2 (Caja Blanca)

### Almacenes de Datos Especializados

#### PostgreSQL - Operational Views
```sql
-- Real-time flight status
CREATE TABLE flight_status_view (
    flight_id UUID PRIMARY KEY,
    flight_number VARCHAR(10),
    route VARCHAR(10),
    status VARCHAR(20),
    current_location JSONB,
    next_milestone JSONB,
    updated_at TIMESTAMP
);

-- Passenger journey tracking
CREATE TABLE passenger_journey_view (
    passenger_id UUID,
    flight_id UUID,
    journey_stage VARCHAR(30),
    current_location VARCHAR(50),
    estimated_completion TIMESTAMP,
    PRIMARY KEY (passenger_id, flight_id)
);
```

#### InfluxDB - Time Series Analytics
```sql
-- Flight performance metrics
CREATE MEASUREMENT flight_metrics (
    time TIMESTAMP,
    flight_id TAG,
    airline TAG,
    route TAG,
    on_time_performance FIELD,
    delay_minutes FIELD,
    passenger_load_factor FIELD
);

-- Operational KPIs
CREATE MEASUREMENT operational_kpis (
    time TIMESTAMP,
    airport TAG,
    terminal TAG,
    capacidad de procesamiento FIELD,
    average_wait_time FIELD,
    security_queue_length FIELD
);
```

#### Elasticsearch - Search & Analytics
```json
{
  "mappings": {
    "properties": {
      "traceId": { "type": "keyword" },
      "timestamp": { "type": "date" },
      "eventType": { "type": "keyword" },
      "flightNumber": { "type": "keyword" },
      "passengerName": { "type": "text", "analyzer": "standard" },
      "location": { "type": "geo_point" },
      "payload": { "type": "object", "dynamic": true }
    }
  }
}
```

#### Redis - Real-time Cache
```csharp
public class RealTimeCacheService
{
    public async Task<FlightStatus> GetCurrentFlightStatus(string flightNumber)
    {
        var key = $"flight:status:{flightNumber}";
        var cached = await _redis.GetAsync<FlightStatus>(key);

        if (cached == null)
        {
            cached = await BuildFlightStatusFromEvents(flightNumber);
            await _redis.SetAsync(key, cached, TimeSpan.FromMinutes(5));
        }

        return cached;
    }
}
```

### Projection Handlers

#### Flight Status Projection
```csharp
public class FlightStatusProjectionHandler : IEventHandler<FlightEvent>
{
    public async Task Handle(FlightEvent @event)
    {
        switch (@event.EventType)
        {
            case "FLIGHT_SCHEDULED":
                await CreateFlightStatusRecord(@event);
                break;
            case "FLIGHT_DEPARTED":
                await UpdateFlightStatus(@event, "DEPARTED");
                break;
            case "FLIGHT_ARRIVED":
                await UpdateFlightStatus(@event, "ARRIVED");
                break;
        }
    }
}
```

## 5.6 Servicio de Analytics y Reportes - Nivel 2 (Caja Blanca)

### Motor de Analytics en Tiempo Real

#### Event Stream Processing
```csharp
public class FlightAnalyticsProcessor : IEventHandler<FlightEvent>
{
    private readonly IEventStore _eventStore;
    private readonly IMetricsStore _metricsStore;

    public async Task Handle(FlightEvent @event)
    {
        switch (@event.EventType)
        {
            case "FLIGHT_ARRIVED":
                await CalculateOnTimePerformance(@event);
                break;
            case "FLIGHT_DELAYED":
                await UpdateDelayMetrics(@event);
                break;
        }
    }

    private async Task CalculateOnTimePerformance(FlightEvent @event)
    {
        var metrics = await _metricsStore.GetAirlineMetrics(@event.Airline);
        metrics.AddFlight(@event);
        await _metricsStore.UpdateMetrics(metrics);
    }
}
    )
    .mapValues(metrics -> metrics.getOnTimePercentage());
```

#### Complex Event Processing
```csharp
public class FlightDelayDetectionRule : IEventRule
{
    public async Task<RuleResult> Evaluate(EventContext context)
    {
        var recentEvents = await GetRecentFlightEvents(context.FlightId);

        if (IsDelayPatternDetected(recentEvents))
        {
            return RuleResult.CreateAlert(
                AlertType.DELAY_RISK,
                $"Flight {context.FlightNumber} showing delay pattern",
                Severity.Medium
            );
        }

        return RuleResult.NoAction();
    }
}
```

### Pipeline de Machine Learning

#### Modelos Predictivos
```python
class FlightDelayPredictor:
    def __init__(self):
        self.model = MLPRegressor(hidden_layer_sizes=(100, 50))

    def predict_delay(self, flight_features):
        # Features: weather, aircraft type, route, historical performance
        # Output: predicted delay in minutes
        return self.model.predict(flight_features.reshape(1, -1))

    def train_model(self, historical_data):
        features = self.extract_features(historical_data)
        labels = self.extract_delay_labels(historical_data)
        self.model.fit(features, labels)
```

#### Detección de Anomalías
```csharp
public class OperationalAnomalyDetector
{
    public async Task<AnomalyResult> DetectAnomalies(OperationalMetrics metrics)
    {
        // Statistical analysis for outlier detection
        // Pattern recognition for unusual sequences
        // Machine learning for behavior anomalies
        // Real-time scoring and alertas
    }
}
```

## 5.7 Motor de Notificaciones - Nivel 2 (Caja Blanca)

### Coincidencia de Patrones de Eventos

#### Complex Event Processing with Apache Flink
```java
public class FlightDelayPattern extends PatternProcessFunction<FlightEvent, DelayAlert> {
    @Override
    public void processMatch(Map<String, List<FlightEvent>> match, Context ctx, Collector<DelayAlert> out) {
        List<FlightEvent> delayEvents = match.get("delay");

        if (delayEvents.size() >= 3) {
            DelayAlert alert = new DelayAlert(
                delayEvents.get(0).getFlightId(),
                "Multiple delay events detected",
                AlertSeverity.HIGH
            );
            out.collect(alert);
        }
    }
}
```

#### Integración del Motor de Reglas
```csharp
public class BusinessRuleEngine
{
    public async Task<List<Alert>> EvaluateRules(TrackingEvent @event)
    {
        var applicableRules = await GetRulesForEvent(@event);
        var alerts = new List<Alert>();

        foreach (var rule in applicableRules)
        {
            var result = await rule.Evaluate(@event);
            if (result.ShouldAlert)
            {
                alerts.Add(result.Alert);
            }
        }

        return alerts;
    }
}
```

### Distribución de Alertas

#### Notificaciones Multi-canal
- **Push Notifications:** Mobile apps, web dashboards
- **Email Alerts:** Stakeholder notifications
- **SMS/WhatsApp:** Critical operational alerts
- **Webhook Callbacks:** System-to-system notifications
- **Dashboard Updates:** Real-time UI refreshes

#### Políticas de Escalamiento
```yaml
Escalation Rules:
  Critical Alerts:
    - Immediate: Operations team via SMS
    - 5 minutes: Management via email + SMS
    - 15 minutes: Executive team via phone call

  High Priority:
    - Immediate: Operations team via push notification
    - 10 minutes: Supervisor via email

  Medium Priority:
    - Operations team via dashboard
    - Daily digest email to stakeholders
```

## 5.8 Interfaces Externas

### Fuentes de Eventos Upstream
```yaml
Event Producers:
  - SITA Messaging: Flight operational data
  - Aplicaciones Móviles: Passenger self-service events
  - Ground Systems: Baggage, cargo, maintenance
  - External APIs: Weather, traffic, delays
  - IoT Sensors: Location, temperature, weight
```

### Consumidores Downstream
```yaml
Event Consumers:
  - Business Intelligence: Analytics and reporting
  - Customer Service: Real-time passenger assistance
  - Operations Control: Flight management
  - Aplicaciones Móviles: Passenger notifications
  - Partner Systems: Codeshare, alliances
```

### Patrones de Integración
- **Event Streaming:** Event-driven architecture for real-time data flow
- **Request/Response:** REST APIs for synchronous operations
- **Batch Processing:** Scheduled ETL for historical data
- **WebSockets:** Real-time UI updates
- **GraphQL:** Flexible query interface for dashboards

### Referencias
- [CQRS Pattern](https://martinfowler.com/bliki/CQRS.html)
- [Event Sourcing Pattern](https://martinfowler.com/eaaDev/EventSourcing.html)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Amazon SNS Documentation](https://docs.aws.amazon.com/sns/)
- [RabbitMQ Documentation](https://www.rabbitmq.com/documentation.html)
