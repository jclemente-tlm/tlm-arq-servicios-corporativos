# 3. Contexto y alcance del sistema

El **Sistema de Notificación Multi-canal** es la plataforma centralizada para envío de notificaciones a través de Email, SMS, WhatsApp y Push Notifications, integrándose con eventos operacionales y sistemas corporativos.

## 3.1 Contexto de negocio

### Propósito del Sistema

El sistema de notificación actúa como el hub central de comunicaciones, proporcionando:

- **Comunicación multi-canal** unificada para operaciones críticas
- **Notificaciones automáticas** basadas en eventos operacionales
- **Entrega confiable** con fallback y retry automático
- **Personalización** de contenido por tenant y contexto
- **Trazabilidad completa** de entregas y estados

### Stakeholders Principales

| Stakeholder | Rol | Responsabilidad | Expectativa |
|-------------|-----|----------------|-------------|
| **Operations Managers** | Gestión Operacional | Comunicación crítica, alertas | Notificaciones inmediatas, 100% entrega |
| **Customer Service** | Atención al Cliente | Comunicación con pasajeros | Multi-canal, personalización |
| **IT Operations** | Operaciones TI | Mantenimiento sistema, monitoreo | Sistema estable, alertas proactivas |
| **Compliance Officers** | Cumplimiento | Regulaciones comunicaciones | Opt-out compliance, audit trail |
| **End Users** | Usuarios Finales | Recepción notificaciones | Contenido relevante, canales preferidos |

### Objetivos de Negocio

| Objetivo | Descripción | Métricas de Éxito |
|----------|-------------|-------------------|
| **Entrega Confiable** | Garantizar entrega de notificaciones críticas | > 95% delivery rate across channels |
| **Experiencia Omnicanal** | Comunicación consistente en todos los canales | 90% user satisfaction, channel coverage |
| **Automatización Operacional** | Reducir intervención manual en comunicaciones | 80% automated notifications |
| **Compliance Regulatorio** | Cumplir regulaciones de comunicaciones | 100% opt-out compliance, zero violations |
| **Performance Operacional** | Notificaciones en tiempo real | < 5 seconds end-to-end latency |

## 3.2 Contexto técnico

### Posición en la Arquitectura

```text
┌─────────────────────────────────────────────────────────────────┐
│                    EXTERNAL NOTIFICATION PROVIDERS              │
│  [SendGrid]  [Twilio]  [WhatsApp API]  [Firebase FCM]          │
└─────────────────────┬───────────────────────────────────────────┘
                      │ Provider APIs
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                  NOTIFICATION SYSTEM                           │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐│
│  │Email        │ │SMS          │ │WhatsApp     │ │Push         ││
│  │Processor    │ │Processor    │ │Processor    │ │Processor    ││
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘│
│  ┌─────────────────────────────────────────────────────────────┐│
│  │        Notification API & Template Engine                  ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────┬───────────────────────────────────────────┘
                      │ Event Consumption & API Calls
                      ▲
┌─────────────────────────────────────────────────────────────────┐
│                    EVENT SOURCES & CLIENTS                     │
│  [Track&Trace] [SITA Messages] [Web Apps] [Mobile Apps]       │
└─────────────────────────────────────────────────────────────────┘
```

### Fronteras del Sistema

#### Dentro del Alcance

| Componente | Descripción | Responsabilidad |
|------------|-------------|-----------------|
| **Notification API** | REST API para envío notificaciones | Request handling, validation, queuing |
| **Template Engine** | Motor de plantillas multi-idioma | Template processing, personalization |
| **Channel Processors** | Procesadores específicos por canal | Email, SMS, WhatsApp, Push delivery |
| **Event Consumers** | Consumidores de eventos externos | Track&Trace, SITA event processing |
| **Delivery Tracking** | Seguimiento de entregas | Status tracking, retry management |
| **Audit & Logging** | Registro de operaciones | Delivery logs, compliance reporting |
| **Template Management** | Gestión de plantillas | Template CRUD, versioning, approval |

#### Fuera del Alcance

| Componente | Razón de Exclusión | Responsable |
|------------|-------------------|-------------|
| **External Providers** | Third-party services | SendGrid, Twilio, WhatsApp, Firebase |
| **Content Creation** | Business content | Business teams, marketing |
| **Event Generation** | Source events | Track&Trace, SITA Messaging services |
| **User Preferences** | Notification preferences | User management in Identity System |
| **Network Infrastructure** | Connectivity layer | Infrastructure team |

## 3.3 Interfaces externas

### Actores Principales

| Actor | Tipo | Descripción | Interacciones |
|-------|------|-------------|---------------|
| **Operations Manager** | Humano | Gestión de notificaciones operacionales | Template management, delivery monitoring |
| **Customer Service Agent** | Humano | Envío de notificaciones manuales | Individual notifications, customer communication |
| **System Administrator** | Humano | Administración del sistema | Configuration, monitoring, troubleshooting |
| **Notification Recipients** | Humano | Destinatarios finales | Receive notifications, preference management |
| **Corporate Services** | Sistema | Servicios internos generadores de eventos | Automated notification triggers |

### Sistemas Externos

| Sistema | Tipo | Protocolo | Propósito | Datos Intercambiados |
|---------|------|-----------|-----------|---------------------|
| **SendGrid** | Email Provider | REST API | Email delivery | Email content, recipient data, delivery status |
| **Amazon SES** | Email Provider | REST API | Email delivery fallback | Email messages, bounce/complaint handling |
| **Twilio** | SMS Provider | REST API | SMS delivery | SMS content, phone numbers, delivery receipts |
| **WhatsApp Business API** | Messaging Provider | REST API | WhatsApp delivery | Template messages, media, delivery status |
| **Firebase FCM** | Push Provider | REST API | Push notifications | Device tokens, push payloads, delivery stats |
| **Track & Trace System** | Internal Service | Apache Kafka | Event-driven notifications | Operational events, flight updates, alerts |
| **SITA Messaging** | Internal Service | Apache Kafka | Message status notifications | Message delivery status, errors, confirmations |
| **Identity System** | Internal Service | OAuth2/OIDC | Authentication & user data | User tokens, profile data, permissions |
| **Template Storage** | Internal Service | REST API | Template management | Template content, metadata, versions |

### Interfaces de Datos

#### Entrada de Datos

| Interface | Fuente | Tipo de Datos | Frecuencia | Formato |
|-----------|--------|---------------|------------|---------|
| **Event Stream** | Track & Trace | Operational events | Real-time | Kafka messages (Avro) |
| **Message Events** | SITA Messaging | Message status updates | Real-time | Kafka messages (JSON) |
| **API Requests** | Web/Mobile apps | Manual notifications | On-demand | REST API (JSON) |
| **Bulk Requests** | Corporate systems | Batch notifications | Scheduled | REST API (JSON Array) |
| **Template Updates** | Content management | Template changes | As needed | REST API (JSON) |

#### Salida de Datos

| Interface | Destino | Tipo de Datos | Frecuencia | Formato |
|-----------|---------|---------------|------------|---------|
| **Email Messages** | Email providers | Email content + metadata | Real-time | SMTP/API calls |
| **SMS Messages** | SMS providers | Text messages + metadata | Real-time | REST API calls |
| **WhatsApp Messages** | WhatsApp API | Template messages | Real-time | REST API calls |
| **Push Notifications** | FCM/APNS | Push payloads | Real-time | Provider APIs |
| **Delivery Reports** | Monitoring systems | Status updates | Real-time | Webhook callbacks |
| **Audit Logs** | SIEM systems | Delivery logs, errors | Continuous | Structured logs |

## 3.4 Alcance funcional

### Funcionalidades Incluidas

| Función | Descripción | Usuarios Objetivo | Prioridad |
|---------|-------------|-------------------|-----------|
| **Multi-channel Delivery** | Envío Email, SMS, WhatsApp, Push | Todos los usuarios | Alta |
| **Event-driven Notifications** | Automatización basada en eventos | Sistemas internos | Alta |
| **Template Management** | Gestión centralizada de plantillas | Content managers | Alta |
| **Delivery Tracking** | Seguimiento estado entregas | Operations, customer service | Alta |
| **Retry & Fallback** | Reintentos automáticos y canales alternativos | Sistema automático | Media |
| **Personalization** | Contenido personalizado por usuario/contexto | End users | Media |
| **Bulk Notifications** | Envío masivo eficiente | Marketing, operations | Media |
| **A/B Testing** | Pruebas de variantes de contenido | Marketing teams | Baja |
| **Analytics & Reporting** | Métricas de entrega y engagement | Management | Baja |

### Funcionalidades Excluidas

| Función | Razón de Exclusión | Alternativa |
|---------|-------------------|-------------|
| **Content Creation Tools** | Fuera del dominio técnico | Business content management tools |
| **User Preference Management** | Responsabilidad de Identity System | User profile management |
| **Campaign Management** | Marketing functionality | Dedicated marketing platforms |
| **Customer Database** | Data ownership elsewhere | CRM systems, user databases |
| **Payment Notifications** | Specialized domain | Payment gateway notifications |

## 3.5 Casos de uso principales

### Notificación Automática por Evento

```text
Actor: Track & Trace System
Precondición: Evento operacional crítico ocurre
Flujo Principal:
1. Track & Trace detecta evento crítico (retraso vuelo)
2. Sistema publica evento a Kafka topic
3. Notification System consume evento
4. Sistema identifica template por tipo evento
5. Sistema obtiene lista destinatarios afectados
6. Sistema personaliza contenido por destinatario
7. Sistema envía notificaciones por canales preferidos
8. Sistema rastrea estado de entrega
9. Sistema maneja reintentos si hay fallos
Postcondición: Destinatarios notificados de evento crítico
```

### Envío Manual de Notificación

```text
Actor: Customer Service Agent
Precondición: Agente autenticado con permisos
Flujo Principal:
1. Agente accede a interfaz de notificaciones
2. Agente selecciona destinatario(s)
3. Agente elige template o crea contenido personalizado
4. Agente selecciona canales de entrega
5. Sistema valida contenido y destinatarios
6. Sistema procesa y envía notificación
7. Sistema retorna confirmación a agente
8. Agente puede monitorear estado entrega
Postcondición: Notificación manual enviada exitosamente
```

### Gestión de Template Multi-idioma

```text
Actor: Content Manager
Precondición: Manager autenticado con permisos de template
Flujo Principal:
1. Content manager accede a template management
2. Manager crea/edita template base
3. Manager agrega versiones por idioma/país
4. Manager define variables de personalización
5. Sistema valida sintaxis y variables
6. Manager somete template para aprobación
7. Approver revisa y aprueba template
8. Sistema activa template para uso
Postcondición: Template multi-idioma disponible
```

### Procesamiento Masivo de Notificaciones

```text
Actor: Corporate System
Precondición: Sistema con credenciales válidas
Flujo Principal:
1. Sistema corporativo prepara lote de notificaciones
2. Sistema llama API bulk notification endpoint
3. Notification System valida y acepta lote
4. Sistema divide lote en chunks procesables
5. Sistema procesa chunks en paralelo
6. Sistema envía notificaciones por canales
7. Sistema agrega estados de entrega
8. Sistema retorna resumen de procesamiento
Postcondición: Lote procesado con reporte de entrega
```

## 3.6 Canales de notificación

### Email Channel

| Aspecto | Especificación | Providers | Capacidades |
|---------|---------------|-----------|-------------|
| **Delivery** | High-volume transactional email | SendGrid (primary), Amazon SES (fallback) | 100k emails/hour |
| **Features** | Templates, attachments, tracking | HTML/text, DKIM/SPF, open/click tracking | Rich content support |
| **Compliance** | CAN-SPAM, GDPR compliant | Unsubscribe, list management | Automated compliance |

### SMS Channel

| Aspecto | Especificación | Providers | Capacidades |
|---------|---------------|-----------|-------------|
| **Delivery** | Global SMS delivery | Twilio (primary), local providers (fallback) | 50k SMS/hour |
| **Features** | Unicode support, delivery receipts | 160/70 char limits, concatenation | Multi-language support |
| **Compliance** | Carrier regulations, opt-out | STOP keyword, carrier compliance | Automated opt-out |

### WhatsApp Channel

| Aspecto | Especificación | Providers | Capacidades |
|---------|---------------|-----------|-------------|
| **Delivery** | WhatsApp Business messaging | WhatsApp Business API | 10k messages/hour |
| **Features** | Template messages, media support | Pre-approved templates, images/docs | Rich media messaging |
| **Compliance** | WhatsApp policies | Template approval, content guidelines | Platform compliance |

### Push Notifications Channel

| Aspecto | Especificación | Providers | Capacidades |
|---------|---------------|-----------|-------------|
| **Delivery** | Mobile push notifications | Firebase FCM, Apple APNS | 1M pushes/hour |
| **Features** | Rich notifications, deep links | Images, actions, custom data | Interactive notifications |
| **Compliance** | Platform guidelines | Permission management, badge control | User consent required |

## 3.7 Atributos de calidad

### Reliability

| Atributo | Métrica | Target | Medición |
|----------|---------|--------|----------|
| **Delivery Rate** | Successful deliveries | > 95% across all channels | Provider webhooks, tracking |
| **System Availability** | Service uptime | 99.9% | Health monitoring |
| **Message Durability** | Message loss rate | < 0.01% | Queue monitoring |
| **Retry Success** | Retry delivery rate | > 80% after retries | Retry analytics |

### Performance

| Atributo | Métrica | Target | Medición |
|----------|---------|--------|----------|
| **Processing Latency** | End-to-end delivery time | p95 < 5 seconds | APM monitoring |
| **Throughput** | Messages per hour | 100k messages/hour | Load testing |
| **Template Processing** | Template render time | < 500ms | Performance profiling |
| **API Response Time** | REST API latency | p95 < 200ms | API monitoring |

### Scalability

| Atributo | Métrica | Target | Medición |
|----------|---------|--------|----------|
| **Horizontal Scaling** | Auto-scaling capability | Linear scaling | Load testing |
| **Queue Capacity** | Message queue depth | Handle 1M queued messages | Queue monitoring |
| **Concurrent Processing** | Parallel message handling | 1000 concurrent processors | Concurrency testing |
| **Storage Scaling** | Template/log storage | Automatic expansion | Storage monitoring |

## Referencias

### External Provider APIs

- [SendGrid API Documentation](https://docs.sendgrid.com/api-reference)
- [Twilio SMS API](https://www.twilio.com/docs/sms)
- [WhatsApp Business API](https://developers.facebook.com/docs/whatsapp)
- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)

### Compliance Standards

- [CAN-SPAM Act Compliance](https://www.ftc.gov/enforcement/rules/rulemaking-regulatory-reform-proceedings/can-spam-rule)
- [GDPR Article 7 (Consent)](https://gdpr-info.eu/art-7-gdpr/)
- [CASL (Canada Anti-Spam Legislation)](https://crtc.gc.ca/eng/casl-lcap/)

### Architecture References

- [Event-Driven Architecture Patterns](https://microservices.io/patterns/data/event-driven-architecture.html)
- [Apache Kafka Documentation](https://kafka.apache.org/documentation/)
- [Arc42 Context Template](https://docs.arc42.org/section-3/)
```

## 3.2 Alcance

- **Incluye:**
  - Gestión y envío de notificaciones multicanal
  - Soporte multi-tenant y multi-país
  - Integración con sistemas externos (ERP, CRM)
  - Gestión de adjuntos y programación de envíos
- **Excluye:**
  - Generación de contenido de notificaciones (solo se envía contenido recibido)
  - Gestión de usuarios finales (delegada a sistemas externos)
