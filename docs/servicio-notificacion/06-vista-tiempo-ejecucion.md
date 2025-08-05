# 6. Vista de tiempo de ejecución

Esta sección describe los principales escenarios de ejecución del sistema, mostrando cómo los componentes interactúan durante el tiempo de ejecución para cumplir con los casos de uso más relevantes arquitectónicamente.

## 6.1 Escenario: Envío Transaccional Individual

### Descripción

Flujo crítico para notificaciones transaccionales de alta prioridad (confirmaciones, alertas críticas) que requieren entrega garantizada y baja latencia.

### Actores

- **Aplicación Cliente:** Sistema que origina la notificación
- **API Gateway:** Punto de entrada con autenticación
- **Notification API:** Servicio de ingesta y validación
- **Kafka:** Message broker para desacoplamiento
- **Channel Processors:** Procesadores especializados por canal
- **External Providers:** Servicios de entrega (SendGrid, Twilio, etc.)

### Flujo Principal

```mermaid
sequenceDiagram
    participant App as Aplicación Cliente
    participant Gateway as API Gateway
    participant API as Notification API
    participant EventBus as Event Bus
    participant Processor as Channel Processor
    participant Provider as External Provider
    participant DB as Database

    App->>Gateway: 1. POST /notifications/send
    Gateway->>Gateway: 2. Validate JWT token
    Gateway->>API: 3. Forward request

    API->>API: 4. Validate payload & template
    API->>DB: 5. Store notification record
    API->>Kafka: 6. Publish notification event
    API->>App: 7. HTTP 202 Accepted {messageId}

    Note over Kafka,Processor: Async Processing
    Kafka->>Processor: 8. Consume notification event
    Processor->>Processor: 9. Render template with data
    Processor->>Provider: 10. Send via provider API
    Provider->>Processor: 11. Delivery receipt
    Processor->>DB: 12. Update delivery status
    Processor->>Kafka: 13. Publish status event

    Note over Processor,App: Optional Webhook
    Processor->>App: 14. Webhook callback (if configured)
```

### Aspectos Notables

- **Respuesta inmediata:** API responde en <100ms con acknowledgment
- **Procesamiento asíncrono:** Desacopla ingesta de entrega
- **Idempotencia:** Cada request incluye messageId para deduplicación
- **Observabilidad:** Cada paso genera telemetría para tracking

### Métricas de Rendimiento

| Métrica | Target | Medición |
|---------|--------|----------|
| **API Response Time** | p95 < 100ms | APM monitoring |
| **Event Processing** | < 500ms | Custom metrics |
| **End-to-End Delivery** | < 30s (transactional) | Business metrics |
| **Throughput** | 10K req/min per instance | Load testing |

## 6.2 Escenario: Procesamiento de Eventos Track & Trace

### Descripción

Flujo automático triggered por eventos del sistema Track & Trace para notificaciones operacionales como actualizaciones de vuelo, cambios de puerta, etc.

### Flujo de Eventos

```mermaid
sequenceDiagram
    participant TrackTrace as Track & Trace
    participant EventBus as Event Bus
    participant EventConsumer as Event Consumer
    participant TemplateEngine as Template Engine
    participant ChannelRouter as Channel Router
    participant Processors as Channel Processors

    TrackTrace->>Kafka: 1. Publish flight event
    EventConsumer->>Kafka: 2. Consume event
    EventConsumer->>EventConsumer: 3. Transform to notification
    EventConsumer->>TemplateEngine: 4. Get template by event type
    TemplateEngine->>EventConsumer: 5. Return template definition
    EventConsumer->>ChannelRouter: 6. Route to appropriate channels

    par Email Channel
        ChannelRouter->>Processors: 7a. Email notification
    and SMS Channel
        ChannelRouter->>Processors: 7b. SMS notification
    and Push Channel
        ChannelRouter->>Processors: 7c. Push notification
    end

    Processors->>Processors: 8. Process in parallel
```

### Características Especiales

- **Event-driven:** Triggered automáticamente por eventos externos
- **Transformación de datos:** Mapping de eventos a formato de notificación
- **Multi-canal automático:** Routing inteligente según preferencias
- **Procesamiento paralelo:** Canales procesan simultáneamente

## 6.3 Escenario: Bulk Processing para Campañas

### Descripción

Procesamiento optimizado para envío masivo de notificaciones promocionales con rate limiting y batch processing.

### Flujo de Batch Processing

```mermaid
flowchart TD
    A[Bulk Request] --> B[Validate Batch]
    B --> C[Split into Chunks]
    C --> D[Queue Chunks]

    D --> E[Batch Processor 1]
    D --> F[Batch Processor 2]
    D --> G[Batch Processor N]

    E --> H[Rate Limiter]
    F --> H
    G --> H

    H --> I[Provider APIs]
    I --> J[Delivery Tracking]
    J --> K[Aggregate Results]
```

### Optimizaciones Aplicadas

- **Chunking:** División en lotes de 100-1000 recipients
- **Rate Limiting:** Respeto a límites de providers
- **Batch APIs:** Uso de APIs batch cuando están disponibles
- **Circuit Breaker:** Protección contra failures de providers

## 6.4 Escenario: Error Handling y Retry

### Descripción

Manejo de errores y sistema de reintentos con exponential backoff para garantizar entrega.

### Flujo de Resilience

```mermaid
stateDiagram-v2
    [*] --> Pending
    Pending --> Processing: Dequeue
    Processing --> Sent: Success
    Processing --> Retry: Transient Error
    Processing --> Failed: Permanent Error

    Retry --> Processing: Backoff Delay
    Retry --> DLQ: Max Retries Exceeded

    Sent --> Delivered: Provider Confirmation
    Sent --> Bounced: Provider Error

    Failed --> [*]
    Delivered --> [*]
    Bounced --> [*]
    DLQ --> [*]
```

### Políticas de Retry

| Error Type | Retry Count | Backoff | Dead Letter |
|------------|-------------|---------|-------------|
| **Network Timeout** | 3 | Exponential (2s, 4s, 8s) | After 3 failures |
| **Rate Limit** | 5 | Linear (60s intervals) | After 5 failures |
| **Provider Error 5xx** | 3 | Exponential | After 3 failures |
| **Invalid Data** | 0 | None | Immediate |

## 6.5 Escenario: Monitoring y Observabilidad

### Descripción

Flujo de telemetría y métricas para observabilidad del sistema en tiempo real.

### Pipeline de Observabilidad

```mermaid
graph LR
    A[Application] --> B[OpenTelemetry]
    B --> C[Jaeger Tracing]
    B --> D[Prometheus Metrics]
    B --> E[Structured Logs]

    C --> F[Trace Analysis]
    D --> G[Grafana Dashboards]
    E --> H[Log Aggregation]

    F --> I[Performance Insights]
    G --> J[Alerting]
    H --> K[Error Analysis]
```

### Métricas Clave Capturadas

- **Request Rate:** Notifications per second by channel
- **Error Rate:** Failed notifications percentage
- **Latency:** p50, p95, p99 processing times
- **Provider Health:** External API availability
- **Queue Depth:** Backlog size by priority

Cada escenario incluye puntos de instrumentación específicos para troubleshooting y optimización continua.

## 6.2 Escenario: Procesamiento Bulk de Notificaciones

### Descripción

Envío masivo de notificaciones con optimizaciones de batch processing.

### Flujo de Ejecución

```mermaid
sequenceDiagram
    participant Client as Cliente
    participant API as Notification API
    participant Splitter as Batch Splitter
    participant Queue as Message Queue
    participant Workers as Parallel Workers
    participant Providers as Multiple Providers

    Client->>API: 1. POST /notifications/bulk (10K recipients)
    API->>Splitter: 2. Split into batches (100 each)
    Splitter->>Queue: 3. Enqueue 100 batches
    API->>Client: 4. HTTP 202 Batch accepted

    loop Parallel Processing
        Queue->>Workers: 5. Dequeue batch
        Workers->>Providers: 6. Send batch via different providers
        Providers->>Workers: 7. Batch results
        Workers->>Queue: 8. Update batch status
    end
```

### Optimizaciones

- **Batch size:** 100 recipients per batch
- **Parallel workers:** 10 concurrent processors
- **Provider rotation:** Load balancing
- **Retry policy:** Exponential backoff

## 6.3 Escenario: Failover y Recovery

### Descripción

Manejo de fallos de proveedor con failover automático.

### Flujo de Ejecución

```mermaid
sequenceDiagram
    participant Processor as Email Processor
    participant Primary as Primary Provider
    participant Secondary as Secondary Provider
    participant Circuit as Circuit Breaker
    participant Monitor as Health Monitor

    Processor->>Primary: 1. Send email
    Primary-->>Processor: 2. Timeout/Error
    Processor->>Circuit: 3. Record failure
    Circuit->>Circuit: 4. Trip circuit after 5 failures
    Processor->>Secondary: 5. Failover to secondary
    Secondary->>Processor: 6. Success response

    Monitor->>Primary: 7. Health check
    Primary->>Monitor: 8. Service restored
    Monitor->>Circuit: 9. Reset circuit
```

### Recovery Policies

- **Circuit breaker:** 5 fallos consecutivos
- **Timeout:** 30 segundos por provider
- **Health check:** Cada 60 segundos
- **Auto-recovery:** Automático cuando provider responde

## 6.4 Escenario: Multi-canal con Fallback

### Descripción

Envío por canal preferido con fallback automático a canales alternativos.

### Flujo de Ejecución

```mermaid
sequenceDiagram
    participant Client as Cliente
    participant API as Notification API
    participant Router as Channel Router
    participant WhatsApp as WhatsApp Processor
    participant SMS as SMS Processor
    participant Email as Email Processor

    Client->>API: 1. Send notification (preference: WhatsApp)
    API->>Router: 2. Route to preferred channel
    Router->>WhatsApp: 3. Attempt WhatsApp delivery
    WhatsApp-->>Router: 4. User not registered
    Router->>SMS: 5. Fallback to SMS
    SMS->>Router: 6. SMS sent successfully
    Router->>API: 7. Delivery confirmation
    API->>Client: 8. Success response with actual channel
```

### Fallback Chain

```yaml
Channel Priorities:
  High Priority:
    1. WhatsApp Business
    2. SMS
    3. Email
    4. Push Notification

  Standard Priority:
    1. Email
    2. SMS
    3. Push Notification

  Marketing:
    1. Email
    2. Push Notification
```

## 6.5 Escenario: Template Personalization

### Descripción

Procesamiento de templates con personalización dinámica y localización.

### Flujo de Ejecución

```mermaid
sequenceDiagram
    participant Processor as Notification Processor
    participant TemplateEngine as Template Engine
    participant UserService as User Service
    participant LocalizationService as Localization Service
    participant ContentDB as Content Database

    Processor->>TemplateEngine: 1. Process template request
    TemplateEngine->>UserService: 2. Get user profile
    UserService->>TemplateEngine: 3. User data + preferences
    TemplateEngine->>LocalizationService: 4. Get localized content
    LocalizationService->>ContentDB: 5. Fetch templates by locale
    ContentDB->>LocalizationService: 6. Localized templates
    LocalizationService->>TemplateEngine: 7. Localized content
    TemplateEngine->>Processor: 8. Rendered notification
```

### Personalization Features

- **Dynamic Content:** Variables from user profile
- **Conditional Logic:** if/else based on user attributes
- **Localization:** Multiple languages and regions
- **A/B Testing:** Template variant selection

## 6.6 Escenario: Compliance y Opt-out

### Descripción

Manejo de preferencias de usuario y compliance con regulaciones.

### Flujo de Ejecución

```mermaid
sequenceDiagram
    participant Client as Cliente
    participant API as Notification API
    participant ComplianceService as Compliance Service
    participant PreferenceDB as Preference Database
    participant AuditService as Audit Service

    Client->>API: 1. Send marketing notification
    API->>ComplianceService: 2. Check user preferences
    ComplianceService->>PreferenceDB: 3. Get opt-in status
    PreferenceDB->>ComplianceService: 4. User opted out
    ComplianceService->>AuditService: 5. Log blocked notification
    ComplianceService->>API: 6. Notification blocked
    API->>Client: 7. HTTP 403 User opted out
```

### Compliance Rules

- **GDPR:** Explicit consent required
- **CAN-SPAM:** Easy unsubscribe mechanism
- **TCPA:** SMS consent verification
- **Regional Laws:** Country-specific regulations

## 6.7 Escenario: Analytics y Tracking

### Descripción

Captura de métricas de entrega y engagement para analytics.

### Flujo de Ejecución

```mermaid
sequenceDiagram
    participant Provider as Email Provider
    participant Webhook as Webhook Handler
    participant EventProcessor as Event Processor
    participant AnalyticsDB as Analytics Database
    participant Dashboard as Analytics Dashboard

    Provider->>Webhook: 1. Delivery webhook
    Webhook->>EventProcessor: 2. Process delivery event
    EventProcessor->>AnalyticsDB: 3. Store metrics

    Note over Provider: User opens email
    Provider->>Webhook: 4. Open tracking webhook
    Webhook->>EventProcessor: 5. Process open event
    EventProcessor->>AnalyticsDB: 6. Update engagement metrics

    Dashboard->>AnalyticsDB: 7. Query real-time metrics
    AnalyticsDB->>Dashboard: 8. Return aggregated data
```

### Tracked Metrics

- **Delivery Rates:** Successful deliveries per channel
- **Open Rates:** Email opens, SMS reads
- **Click Rates:** Link clicks, call-to-action engagement
- **Conversion Rates:** Business goal completions
- **Bounce Rates:** Failed deliveries by reason

## Referencias

- [Message Queue Patterns](https://www.enterpriseintegrationpatterns.com/patterns/messaging/)
- [Circuit Breaker Pattern](https://martinfowler.com/bliki/CircuitBreaker.html)
- [Email Deliverability Best Practices](https://sendgrid.com/blog/email-deliverability-best-practices/)
- [Arc42 Runtime View](https://docs.arc42.org/section-6/)
    S->>S3: Adjunta archivos (si aplica)
    S->>K: Publica evento de envío
    S->>DB: Actualiza estado
    S->>U: Confirma entrega

```

## 6.2 Consideraciones

- **Reintentos automáticos** ante fallos de canal
- **Trazabilidad** de cada mensaje
- **Aislamiento multi-tenant** en cada paso
- **Logs estructurados** para auditoría
