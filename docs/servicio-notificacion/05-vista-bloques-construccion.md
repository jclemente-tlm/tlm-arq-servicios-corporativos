# 5. Vista de bloques de construcción

Esta sección describe la descomposición estática del sistema de notificaciones en sus componentes principales, siguiendo un enfoque jerárquico desde la vista general hasta los detalles de la implementación.

## 5.1 Sistema de Notificaciones - Nivel 1 (Whitebox)

**🏗️ Diagrama de Arquitectura General**
*[INSERTAR AQUÍ: Diagrama C4 - Container Level del Sistema de Notificaciones]*

### Motivación de la Descomposición

El sistema se estructura siguiendo los principios de Clean Architecture y Domain-Driven Design, separando claramente las responsabilidades:

- **Separación de canales:** Cada canal de notificación tiene características específicas
- **Escalabilidad independiente:** Los componentes pueden escalar según demanda
- **Mantenibilidad:** Módulos cohesivos con bajo acoplamiento
- **Testabilidad:** Interfaces bien definidas para testing

### Bloques de Construcción Principales

| Componente | Responsabilidad | Tecnología | Interfaces |
|------------|-----------------|------------|------------|
| **API de Notificación** | Punto de entrada REST, validación, encolado | ASP.NET Core 8 | REST API, Webhooks |
| **Procesador de Notificación** | Procesamiento asíncrono, orquestación | .NET 8 Worker Services | Bus de Eventos, APIs Internas |
| **Motor de Plantillas** | Gestión y renderizado de plantillas | Plantillas Liquid | API de Plantillas |
| **Procesadores de Canal** | Envío específico por canal | Patrón Strategy | APIs de Proveedor |
| **Base de Datos** | Persistencia de datos | PostgreSQL | Entity Framework |
| **Almacenamiento** | Almacenamiento de archivos | Compatible con S3 | API de Archivos |

#### API de Notificación

**Propósito/Responsabilidad:**

- Recepción de solicitudes de notificación vía REST API
- Validación de datos y autenticación
- Encolado de mensajes para procesamiento asíncrono
- Gestión de webhooks para actualizaciones de estado

**Interfaces:**

- Endpoints REST API (JSON)
- Callbacks webhook para estado de entrega
- Integración con API Gateway

**Tecnología:** ASP.NET Core 8, FluentValidation, Mapster

**Ubicación:** `/src/Notification.Api/`

#### Notification Processor


**Propósito/Responsabilidad:**

- Consumo de eventos del bus de mensajes
- Orquestación del pipeline de procesamiento
- Gestión de reintentos y manejo de errores
- Métricas y logging estructurado

**Interfaces:**

- Consumidor de eventos (eventos)
- Clientes HTTP hacia procesadores de canal
- Base de datos para seguimiento

**Tecnología:** .NET 8 Worker Services, Abstracción de Bus de Eventos

**Ubicación:** `/src/Notification.Processor/`


#### Motor de Plantillas

**Propósito/Responsabilidad:**

- Almacenamiento y versionado de plantillas
- Renderizado con datos dinámicos
- Soporte de internacionalización
- Cache de plantillas compiladas

**Interfaces:**

- API de gestión de plantillas
- Servicio de renderizado

**Tecnología:** Plantillas Liquid, Redis Cache

**Ubicación:** `/src/Notification.Templates/`

### Interfaces Importantes

#### Event Schema (Message Bus)

```json
{
  "messageId": "uuid",
  "tenantId": "string",
  "notificationType": "transaccional|promocional|operacional",
  "channels": ["email", "sms", "whatsapp", "push"],
  "recipients": [
    {
      "email": "string",
      "phone": "string",
      "deviceToken": "string",
      "preferences": {}
    }
  ],
  "template": {
    "id": "string",
    "version": "string",
    "data": {}
  },
  "scheduling": {
    "sendAt": "datetime",
    "timezone": "string"
  },
  "priority": "low|normal|high|critical"
}
```

#### API Response Schema

```json
{
  "messageId": "uuid",
  "status": "aceptado|procesando|enviado|entregado|fallido",
  "submittedAt": "datetime",
  "channels": [
    {
      "type": "email",
      "status": "pending|sent|delivered|bounced|failed",
      "providerId": "string",
      "deliveredAt": "datetime"
    }
  ]
}
```


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
- **Dependencias:** Servicio de Templates, Servicio de Validación, Event Publisher
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

## 5.8 Modelo de Datos y Persistencia

### Esquema de Base de Datos

**🗄️ Diagrama de Entidad-Relación**
*[INSERTAR AQUÍ: Diagrama C4 - Component Level Database Schema]*

#### Tabla: notifications

Tabla principal que almacena el ciclo de vida completo de cada notificación.

| Campo | Tipo | Descripción | Índices |
|-------|------|-------------|---------|
| `notification_id` | UUID | PK - Identificador único | PK, IDX |
| `tenant_id` | UUID | FK - Identificador del tenant | IDX |
| `country_code` | VARCHAR(3) | Código país ISO (PE, CO, EC, MX) | IDX |
| `message_type` | VARCHAR(50) | transactional\|promotional\|operational | IDX |
| `channels` | JSONB | Array de canales [email, sms, whatsapp, push] | GIN |
| `recipient_data` | JSONB | Datos del destinatario | GIN |
| `template_id` | UUID | FK - Referencia a template | IDX |
| `template_data` | JSONB | Variables para renderizado | GIN |
| `status` | VARCHAR(20) | pending\|processing\|sent\|delivered\|failed | IDX |
| `priority` | VARCHAR(10) | low\|normal\|high\|critical | IDX |
| `scheduled_at` | TIMESTAMPTZ | Fecha programada de envío | IDX |
| `sent_at` | TIMESTAMPTZ | Fecha real de envío | IDX |
| `created_at` | TIMESTAMPTZ | Fecha de creación | IDX |
| `updated_at` | TIMESTAMPTZ | Fecha de última actualización | IDX |
| `channels` | JSONB | Array de canales [email, sms, whatsapp, push] | GIN |
| `recipient_data` | JSONB | Datos del destinatario | GIN |
| `template_id` | UUID | FK - Referencia a template | IDX |
| `template_data` | JSONB | Variables para renderizado | GIN |
| `status` | VARCHAR(20) | pending\|processing\|sent\|delivered\|failed | IDX |
| `priority` | VARCHAR(10) | low\|normal\|high\|critical | IDX |
| `scheduled_at` | TIMESTAMPTZ | Fecha programada de envío | IDX |
| `sent_at` | TIMESTAMPTZ | Fecha real de envío | IDX |
| `created_at` | TIMESTAMPTZ | Fecha de creación | IDX |
| `updated_at` | TIMESTAMPTZ | Fecha de última actualización | IDX |

#### Tabla: channel_deliveries

Tracking detallado por canal de cada notificación.

| Campo | Tipo | Descripción | Índices |
|-------|------|-------------|---------|
| `delivery_id` | UUID | PK - Identificador único | PK |
| `notification_id` | UUID | FK - Referencia a notificación | IDX |
| `channel_type` | VARCHAR(20) | email\|sms\|whatsapp\|push | IDX |
| `provider_id` | VARCHAR(50) | sendgrid\|twilio\|whatsapp-api\|fcm | IDX |
| `provider_message_id` | VARCHAR(255) | ID del proveedor externo | IDX |
| `recipient_address` | VARCHAR(255) | Email, teléfono, device token | IDX |
| `status` | VARCHAR(20) | pending\|sent\|delivered\|bounced\|failed | IDX |
| `attempts` | INTEGER | Número de intentos realizados | - |
| `last_attempt_at` | TIMESTAMPTZ | Fecha del último intento | IDX |
| `delivered_at` | TIMESTAMPTZ | Fecha de entrega confirmada | IDX |
| `error_details` | JSONB | Detalles de errores si aplica | GIN |
| `cost` | DECIMAL(10,4) | Costo de envío por este canal | - |

#### Tabla: templates

Gestión de templates multi-tenant con versionado.

| Campo | Tipo | Descripción | Índices |
|-------|------|-------------|---------|
| `template_id` | UUID | PK - Identificador único | PK |
| `tenant_id` | UUID | FK - Identificador del tenant | IDX |
| `name` | VARCHAR(100) | Nombre del template | IDX |
| `category` | VARCHAR(50) | transactional\|promotional\|operational | IDX |
| `version` | INTEGER | Versión del template | IDX |
| `is_active` | BOOLEAN | Template activo | IDX |
| `supported_channels` | VARCHAR[] | Canales soportados | GIN |
| `content` | JSONB | Contenido por canal | GIN |
| `variables_schema` | JSONB | Esquema de variables requeridas | GIN |
| `approval_status` | VARCHAR(20) | draft\|pending\|approved\|rejected | IDX |
| `created_at` | TIMESTAMPTZ | Fecha de creación | IDX |
| `updated_at` | TIMESTAMPTZ | Fecha de actualización | IDX |

### Patrones de Acceso a Datos

#### Repository Pattern

```csharp
public interface INotificationRepository
{
    Task<Notification> CreateAsync(Notification notification);
    Task<Notification> GetByIdAsync(Guid notificationId, Guid tenantId);
    Task<PagedResult<Notification>> GetByTenantAsync(
        Guid tenantId,
        NotificationFilter filter,
        PaginationOptions pagination);
    Task UpdateStatusAsync(Guid notificationId, NotificationStatus status);
    Task<IEnumerable<Notification>> GetPendingNotificationsAsync(int batchSize);
}
```

#### Multi-tenant Data Isolation

```csharp
// Automatic tenant filtering in base repository
public abstract class TenantRepository<T> : IRepository<T> where T : ITenantEntity
{
    protected IQueryable<T> ApplyTenantFilter(IQueryable<T> query)
    {
        var tenantId = _tenantContext.CurrentTenantId;
        return query.Where(e => e.TenantId == tenantId);
    }
}
```

## Referencias

- [Notification System Design Patterns](https://microservices.io/patterns/data/event-driven-architecture.html)
- [Multi-channel Communication Best Practices](https://aws.amazon.com/blogs/messaging-and-targeting/)
- [Template Engine Performance Guidelines](https://docs.microsoft.com/en-us/aspnet/core/mvc/views/razor)
- [Arc42 Building Blocks](https://docs.arc42.org/section-5/)
