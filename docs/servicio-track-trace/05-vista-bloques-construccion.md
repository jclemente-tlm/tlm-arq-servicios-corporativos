# 5. Vista de bloques de construcción

## 5.1 Sistema Track & Trace - Nivel 1 (Whitebox)

### Responsabilidad
Sistema de trazabilidad operacional que captura, procesa y analiza eventos de negocio en tiempo real utilizando arquitectura CQRS + Event Sourcing para proporcionar visibilidad completa de operaciones críticas.

### Bloques de Construcción Contenidos

#### Event Ingestion Layer
- **Responsabilidad:** Captura de eventos de múltiples fuentes y normalización
- **Tecnología:** Apache Kafka Connect + Custom Connectors
- **Interfaz:** Event streaming + REST APIs para ingesta manual

#### Command Processing Service
- **Responsabilidad:** Procesamiento de comandos y orquestación de workflows
- **Tecnología:** .NET 8 con MediatR para CQRS
- **Interfaz:** REST API + gRPC para alta performance

#### Event Store
- **Responsabilidad:** Almacenamiento inmutable de eventos con replay capability
- **Tecnología:** Apache Kafka como event log + Apache Cassandra para indexing
- **Interfaz:** Kafka Streams + REST API para queries

#### Read Model Engine
- **Responsabilidad:** Proyección de eventos en modelos optimizados para consulta
- **Tecnología:** Kafka Streams + múltiples stores especializados
- **Interfaz:** MaterializedViews + REST APIs

#### Analytics & Reporting Service
- **Responsabilidad:** Análisis en tiempo real y generación de insights
- **Tecnología:** Apache Spark + MLlib para machine learning
- **Interfaz:** Real-time dashboards + scheduled reports

#### Notification Engine
- **Responsabilidad:** Alertas proactivas basadas en patrones y anomalías
- **Tecnología:** Complex Event Processing (CEP) con Apache Flink
- **Interfaz:** Push notifications + webhook callbacks

## 5.2 Event Ingestion Layer - Nivel 2 (Whitebox)

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

#### Corporate Services Connector
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

#### External Systems Connector
- **ERP Integration:** SAP, Oracle events via REST/SOAP
- **Legacy Mainframe:** IBM MQ message parsing
- **Mobile Apps:** Real-time event streaming via WebSockets
- **IoT Devices:** Sensor data via MQTT protocol

### Event Normalization Engine

#### Canonical Event Model
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

## 5.3 Command Processing Service - Nivel 2 (Whitebox)

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

#### Command Validation
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

### Workflow Orchestration

#### Saga Pattern Implementation
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

#### Business Process Engine
- **Flight Operations:** Departure → En Route → Arrival → Turnaround
- **Passenger Journey:** Check-in → Security → Boarding → Flight
- **Cargo Operations:** Acceptance → Loading → Transport → Delivery
- **Maintenance Cycle:** Inspection → Repair → Testing → Certification

## 5.4 Event Store - Nivel 2 (Whitebox)

### Apache Kafka as Event Log

#### Topic Architecture
```yaml
Event Topics:
  flight-operations:
    partitions: 24  # By hour for time-based partitioning
    replication: 3
    retention: 90 days

  passenger-journey:
    partitions: 12  # By terminal/gate
    replication: 3
    retention: 30 days

  cargo-operations:
    partitions: 6   # By cargo type
    replication: 3
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

### Cassandra for Event Indexing

#### Event Index Tables
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

#### Query Optimization
- **Time-based Partitioning:** Events partitioned by date
- **Entity Indexing:** Fast lookup by business entities
- **Materialized Views:** Pre-computed aggregations
- **TTL Management:** Automatic data expiration

## 5.5 Read Model Engine - Nivel 2 (Whitebox)

### Specialized Data Stores

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
    throughput FIELD,
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

## 5.6 Analytics & Reporting Service - Nivel 2 (Whitebox)

### Real-time Analytics Engine

#### Kafka Streams Processing
```java
StreamsBuilder builder = new StreamsBuilder();

KStream<String, FlightEvent> flightEvents = builder.stream("flight-operations");

// Calculate on-time performance
KTable<String, Double> onTimePerformance = flightEvents
    .filter((key, event) -> event.getEventType().equals("FLIGHT_ARRIVED"))
    .groupBy((key, event) -> event.getAirline())
    .aggregate(
        OnTimeMetrics::new,
        (airline, event, metrics) -> metrics.addFlight(event),
        Materialized.as("on-time-performance-store")
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

### Machine Learning Pipeline

#### Predictive Models
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

#### Anomaly Detection
```csharp
public class OperationalAnomalyDetector
{
    public async Task<AnomalyResult> DetectAnomalies(OperationalMetrics metrics)
    {
        // Statistical analysis for outlier detection
        // Pattern recognition for unusual sequences
        // Machine learning for behavior anomalies
        // Real-time scoring and alerting
    }
}
```

## 5.7 Notification Engine - Nivel 2 (Whitebox)

### Event Pattern Matching

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

#### Rule Engine Integration
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

### Alert Distribution

#### Multi-channel Notifications
- **Push Notifications:** Mobile apps, web dashboards
- **Email Alerts:** Stakeholder notifications
- **SMS/WhatsApp:** Critical operational alerts
- **Webhook Callbacks:** System-to-system notifications
- **Dashboard Updates:** Real-time UI refreshes

#### Escalation Policies
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

### Upstream Event Sources
```yaml
Event Producers:
  - SITA Messaging: Flight operational data
  - Mobile Apps: Passenger self-service events
  - Ground Systems: Baggage, cargo, maintenance
  - External APIs: Weather, traffic, delays
  - IoT Sensors: Location, temperature, weight
```

### Downstream Consumers
```yaml
Event Consumers:
  - Business Intelligence: Analytics and reporting
  - Customer Service: Real-time passenger assistance
  - Operations Control: Flight management
  - Mobile Apps: Passenger notifications
  - Partner Systems: Codeshare, alliances
```

### Integration Patterns
- **Event Streaming:** Kafka for real-time data flow
- **Request/Response:** REST APIs for synchronous operations
- **Batch Processing:** Scheduled ETL for historical data
- **WebSockets:** Real-time UI updates
- **GraphQL:** Flexible query interface for dashboards

## Referencias
- [Event Sourcing Patterns](https://microservices.io/patterns/data/event-sourcing.html)
- [CQRS Architecture Guide](https://docs.microsoft.com/en-us/azure/architecture/patterns/cqrs)
- [Apache Kafka Documentation](https://kafka.apache.org/documentation/)
- [Arc42 Building Blocks](https://docs.arc42.org/section-5/)
