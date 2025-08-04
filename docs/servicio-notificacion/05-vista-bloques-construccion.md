# 5. Vista de bloques de construcción

## 5.1 Sistema de Notificaciones - Nivel 1 (Whitebox)

### Responsabilidad
Sistema multi-canal para envío de notificaciones (Email, SMS, WhatsApp, Push) con alta disponibilidad, trazabilidad completa y soporte para múltiples proveedores.

### Bloques de Construcción Contenidos

#### Notification API Service
- **Responsabilidad:** API REST para recepción y gestión de solicitudes de notificación
- **Tecnología:** ASP.NET Core 8 con middleware de autenticación
- **Interfaz:** RESTful endpoints + Webhook callbacks

#### Channel Processing Engine
- **Responsabilidad:** Orquestación y procesamiento de notificaciones por canal
- **Tecnología:** .NET 8 Worker Services con patrón Command/Handler
- **Interfaz:** Event-driven architecture via Apache Kafka

#### Template & Personalization Service
- **Responsabilidad:** Gestión de plantillas y personalización de contenido
- **Tecnología:** Razor Engine + Liquid templates
- **Interfaz:** Template API + bulk operations

#### Delivery Orchestrator
- **Responsabilidad:** Coordinación de envíos, reintentos y fallbacks
- **Tecnología:** Hangfire para job scheduling + Polly para resilience
- **Interfaz:** Background job processing + status reporting

#### Provider Integration Layer
- **Responsabilidad:** Adaptadores para múltiples proveedores de notificación
- **Tecnología:** Strategy pattern con implementaciones específicas
- **Interfaz:** Unified provider abstraction

## 5.2 Notification API Service - Nivel 2 (Whitebox)

### Controladores Principales

#### Notification Controller
```csharp
[Route("api/v1/notifications")]
public class NotificationController : ControllerBase
{
    [HttpPost("send")]
    public async Task<IActionResult> SendNotification([FromBody] NotificationRequest request);

    [HttpPost("bulk")]
    public async Task<IActionResult> SendBulkNotifications([FromBody] BulkNotificationRequest request);

    [HttpGet("{id}/status")]
    public async Task<IActionResult> GetNotificationStatus(Guid id);
}
```

#### Template Controller
```csharp
[Route("api/v1/templates")]
public class TemplateController : ControllerBase
{
    [HttpPost]
    public async Task<IActionResult> CreateTemplate([FromBody] TemplateCreateRequest request);

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateTemplate(Guid id, [FromBody] TemplateUpdateRequest request);

    [HttpPost("{id}/preview")]
    public async Task<IActionResult> PreviewTemplate(Guid id, [FromBody] object data);
}
```

#### Webhook Controller
```csharp
[Route("api/v1/webhooks")]
public class WebhookController : ControllerBase
{
    [HttpPost("delivery-status")]
    public async Task<IActionResult> HandleDeliveryStatus([FromBody] DeliveryStatusWebhook webhook);
}
```

### Servicios de Aplicación

#### Notification Service
- **Responsabilidad:** Validación, enriquecimiento y encolado de notificaciones
- **Dependencias:** Template Service, Validation Service, Event Publisher
- **Patrones:** CQRS para separación read/write operations

#### Validation Service
- **Responsabilidad:** Validación de destinatarios, contenido y compliance
- **Características:** Anti-spam, GDPR compliance, rate limiting
- **Reglas:** Configurable per tenant/channel

## 5.3 Channel Processing Engine - Nivel 2 (Whitebox)

### Procesadores por Canal

#### Email Processor
```csharp
public class EmailProcessor : IChannelProcessor
{
    // Provider rotation: SendGrid -> SES -> Mailgun
    // HTML/Text rendering
    // Attachment handling
    // Bounce/complaint processing
}
```

#### SMS Processor
```csharp
public class SmsProcessor : IChannelProcessor
{
    // Provider rotation: Twilio -> AWS SNS -> MessageBird
    // International formatting
    // Character encoding (GSM7/UCS2)
    // Delivery receipt handling
}
```

#### WhatsApp Processor
```csharp
public class WhatsAppProcessor : IChannelProcessor
{
    // WhatsApp Business API
    // Template message compliance
    // Media message support
    // Conversation tracking
}
```

#### Push Notification Processor
```csharp
public class PushProcessor : IChannelProcessor
{
    // FCM for Android
    // APNS for iOS
    // Device token management
    // Rich notification support
}
```

### Event Handlers

#### Notification Event Handler
```csharp
public class NotificationEventHandler : IEventHandler<NotificationRequested>
{
    public async Task Handle(NotificationRequested @event)
    {
        // Route to appropriate channel processor
        // Apply tenant-specific configurations
        // Initialize tracking and audit trail
    }
}
```

## 5.4 Template & Personalization Service - Nivel 2 (Whitebox)

### Template Engine

#### Razor Template Processor
```csharp
public interface ITemplateProcessor
{
    Task<string> ProcessAsync(string template, object model);
    Task<TemplateValidationResult> ValidateAsync(string template);
}
```

#### Template Storage
- **Database:** Template definitions y versiones
- **Cache:** Redis para templates frecuentemente usados
- **CDN:** Assets estáticos (imágenes, CSS)
- **Backup:** S3 para disaster recovery

### Personalization Features

#### Dynamic Content
- **Merge Fields:** {{user.firstName}}, {{order.total}}
- **Conditional Logic:** if/else statements
- **Loops:** Para contenido repetitivo
- **Formatters:** Fechas, números, monedas

#### A/B Testing
- **Variant Management:** Múltiples versiones por template
- **Traffic Splitting:** Configurable por tenant
- **Metrics Collection:** Open rates, click rates
- **Statistical Significance:** Automated test conclusions

## 5.5 Delivery Orchestrator - Nivel 2 (Whitebox)

### Job Management

#### Background Jobs
```csharp
[AutomaticRetry(Attempts = 3, DelaysInSeconds = new[] { 30, 300, 3600 })]
public class NotificationDeliveryJob
{
    public async Task Execute(NotificationDeliveryContext context)
    {
        // Provider selection based on SLA
        // Rate limiting enforcement
        // Retry logic with exponential backoff
    }
}
```

#### Scheduled Jobs
- **Batch Processing:** Off-peak bulk notifications
- **Cleanup Jobs:** Old notification cleanup
- **Analytics Jobs:** Daily/weekly reporting
- **Health Checks:** Provider availability monitoring

### Resilience Patterns

#### Circuit Breaker
```csharp
public class ProviderCircuitBreaker
{
    // Auto-failover to backup providers
    // Health check integration
    // Automatic recovery detection
}
```

#### Retry Policies
```yaml
Retry Configuration:
  MaxAttempts: 5
  BackoffStrategy: Exponential
  BaseDelay: 30s
  MaxDelay: 1h
  JitterEnabled: true
```

## 5.6 Provider Integration Layer - Nivel 2 (Whitebox)

### Email Providers

#### SendGrid Integration
```csharp
public class SendGridProvider : IEmailProvider
{
    public async Task<DeliveryResult> SendAsync(EmailMessage message)
    {
        // API key rotation
        // Webhook signature validation
        // Suppression list management
    }
}
```

#### Amazon SES Integration
```csharp
public class SesProvider : IEmailProvider
{
    public async Task<DeliveryResult> SendAsync(EmailMessage message)
    {
        // IAM role-based authentication
        // Regional endpoint selection
        // Bounce/complaint handling
    }
}
```

### SMS Providers

#### Twilio Integration
- **Features:** Global SMS, short codes, long codes
- **Compliance:** Carrier filtering, opt-out management
- **Analytics:** Delivery rates por país/carrier

#### AWS SNS Integration
- **Features:** Global reach, cost optimization
- **Routing:** Intelligent routing por región
- **Monitoring:** CloudWatch integration

### Provider Selection Strategy

#### Load Balancing
```yaml
Provider Priority Matrix:
  Email:
    Primary: SendGrid (70%)
    Secondary: SES (25%)
    Fallback: Mailgun (5%)
  SMS:
    Primary: Twilio (80%)
    Secondary: SNS (20%)
```

#### Cost Optimization
- **Volume Tiers:** Automatic provider switching
- **Geographic Routing:** Lowest cost per region
- **Performance Monitoring:** SLA-based selection

## 5.7 Interfaces Externas

### Upstream Dependencies
```yaml
Required Services:
  - Identity Service: User authentication/authorization
  - Template Service: Dynamic content generation
  - File Storage: Attachment management
  - Metrics Service: Analytics and reporting
```

### Downstream Integrations
```yaml
External Providers:
  Email: [SendGrid, AWS SES, Mailgun]
  SMS: [Twilio, AWS SNS, MessageBird]
  WhatsApp: [WhatsApp Business API]
  Push: [FCM, APNS]
```

### Event Integrations
```yaml
Event Streams:
  - notification.requested
  - notification.sent
  - notification.delivered
  - notification.failed
  - notification.bounced
```

## Referencias
- [Notification System Design Patterns](https://microservices.io/patterns/data/event-driven-architecture.html)
- [Multi-channel Communication Best Practices](https://aws.amazon.com/blogs/messaging-and-targeting/)
- [Template Engine Performance Guidelines](https://docs.microsoft.com/en-us/aspnet/core/mvc/views/razor)
- [Arc42 Building Blocks](https://docs.arc42.org/section-5/)
      Rel(Service, DB, "Lee/Escribe notificaciones")
```

## 5.2 Descripción de componentes

| Componente         | Descripción                                                      |
|--------------------|------------------------------------------------------------------|
| `API Notificaciones` | Expone endpoints REST para gestión y consulta de notificaciones |
| `Servicio de Envío`  | Procesa y envía notificaciones a canales externos               |
| `Base de Datos`      | Almacena notificaciones, logs y adjuntos                        |
| `Kafka`              | Mensajería asíncrona para eventos y reintentos                  |
| `S3`                 | Almacenamiento de adjuntos                                      |
