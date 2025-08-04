# 6. Vista de tiempo de ejecución

## 6.1 Escenario: Envío de Notificación Email

### Descripción
Flujo completo desde solicitud de notificación hasta entrega y confirmación.

### Participantes
- **Cliente:** Aplicación que solicita el envío
- **Notification API:** API REST de notificaciones
- **Message Queue:** Apache Kafka para encolado
- **Email Processor:** Procesador especializado en email
- **Email Provider:** Proveedor externo (SendGrid/SES)
- **Audit Service:** Servicio de auditoría

### Flujo de Ejecución
```mermaid
sequenceDiagram
    participant Client as Cliente
    participant API as Notification API
    participant Queue as Message Queue
    participant Processor as Email Processor
    participant Provider as Email Provider
    participant Audit as Audit Service

    Client->>API: 1. POST /notifications/send
    API->>API: 2. Validate request & template
    API->>Queue: 3. Enqueue notification
    API->>Client: 4. HTTP 202 Accepted

    Queue->>Processor: 5. Dequeue message
    Processor->>Processor: 6. Render template
    Processor->>Provider: 7. Send email
    Provider->>Processor: 8. Delivery confirmation
    Processor->>Audit: 9. Log delivery event
    Processor->>Queue: 10. Update status
```

### Métricas de Performance
- **Enqueue time:** < 50ms
- **Processing time:** < 200ms
- **End-to-end:** < 5 segundos
- **Throughput:** 1000 notificaciones/segundo

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
