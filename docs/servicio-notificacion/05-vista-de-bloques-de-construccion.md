# 5. Vista de bloques de construcción

## 5.1 Sistema general (Whitebox)

**Diagrama del sistema de notificaciones:**

![Sistema de Notificaciones](/diagrams/notification_system.png)

## 5.1.1 Diagramas de componentes detallados

- **Notification API:**
  ![Notification API](/diagrams/notification_system_api.png)
- **Notification Processor:**
  ![Notification Processor](/diagrams/notification_system_processor.png)
- **Email Processor:**
  ![Email Processor](/diagrams/notification_system_email_processor.png)
- **SMS Processor:**
  ![SMS Processor](/diagrams/notification_system_sms_processor.png)
- **Push Processor:**
  ![Push Processor](/diagrams/notification_system_push_processor.png)
- **WhatsApp Processor:**
  ![WhatsApp Processor](/diagrams/notification_system_whatsapp_processor.png)
- **Scheduler:**
  ![Scheduler](/diagrams/notification_system_scheduler.png)

## 5.2 Modelo de datos principal

A continuación se describe la estructura de las tablas principales del sistema de notificaciones:

### 5.2.1 Estructura de tablas principales

#### notificaciones

Representa cada notificación enviada por el sistema, incluyendo metadatos, estado y trazabilidad.

| campo               | tipo      | descripción                                      |
|---------------------|-----------|--------------------------------------------------|
| notificacion_id     | uuid      | Identificador único de la notificación           |
| tenant_id           | uuid      | Identificador del cliente/empresa (tenant)       |
| codigo_pais         | text      | Código del país de destino (ej: "PE", "CO")     |
| canal               | text      | Canal de envío (email, sms, whatsapp, etc.)      |
| contenido           | jsonb     | Contenido estructurado del mensaje               |
| estado              | text      | Estado actual (pendiente, enviado, fallido, etc.)|
| fecha_envio         | timestamp | Fecha y hora programada de envío                 |
| fecha_creacion      | timestamp | Fecha de creación de la notificación             |
| fecha_actualizacion | timestamp | Fecha de última actualización                    |

#### adjuntos

Registra los archivos adjuntos asociados a notificaciones, permitiendo trazabilidad y gestión de archivos.

| campo               | tipo      | descripción                                      |
|---------------------|-----------|--------------------------------------------------|
| adjunto_id          | uuid      | Identificador único del adjunto                  |
| notificacion_id     | uuid      | Referencia a la notificación asociada            |
| tenant_id           | uuid      | Identificador del cliente/empresa (tenant)       |
| codigo_pais         | text      | Código del país (ej: "PE", "CO")               |
| nombre_archivo      | text      | Nombre del archivo adjunto                       |
| url                 | text      | URL de almacenamiento del archivo                |
| tipo                | text      | Tipo de archivo (pdf, imagen, etc.)              |
| fecha_creacion      | timestamp | Fecha de creación del adjunto                    |
| fecha_actualizacion | timestamp | Fecha de última actualización                    |

#### preferencias_usuario

Almacena las preferencias de cada usuario para la recepción de notificaciones, canales y límites.

| campo               | tipo      | descripción                                      |
|---------------------|-----------|--------------------------------------------------|
| preferencia_id      | uuid      | Identificador único de la preferencia            |
| usuario_id          | uuid      | Identificador del usuario                        |
| tenant_id           | uuid      | Identificador del cliente/empresa (tenant)       |
| canales_preferidos  | text[]    | Lista de canales preferidos                      |
| opt_in              | boolean   | Indica si el usuario acepta recibir notificaciones|
| limites             | jsonb     | Configuración de límites diarios/horarios        |
| fecha_creacion      | timestamp | Fecha de creación de la preferencia              |
| fecha_actualizacion | timestamp | Fecha de última actualización                    |

#### canales

Define los canales disponibles por cliente y país, junto con su configuración específica.

| campo               | tipo      | descripción                                      |
|---------------------|-----------|--------------------------------------------------|
| canal_id            | uuid      | Identificador único del canal                    |
| tenant_id           | uuid      | Identificador del cliente/empresa (tenant)       |
| codigo_pais         | text      | Código del país (ej: "PE", "CO")               |
| nombre              | text      | Nombre del canal                                 |
| tipo                | text      | Tipo de canal (email, sms, etc.)                 |
| configuracion       | jsonb     | Configuración específica del canal                |
| fecha_creacion      | timestamp | Fecha de creación del canal                      |
| fecha_actualizacion | timestamp | Fecha de última actualización                    |

#### plantillas

Gestiona las plantillas de mensajes por cliente y país, con variables parametrizables para personalización.

| campo               | tipo      | descripción                                      |
|---------------------|-----------|--------------------------------------------------|
| plantilla_id        | uuid      | Identificador único de la plantilla              |
| tenant_id           | uuid      | Identificador del cliente/empresa (tenant)       |
| codigo_pais         | text      | Código del país (ej: "PE", "CO")               |
| nombre              | text      | Nombre de la plantilla                           |
| contenido           | text      | Contenido base de la plantilla                   |
| variables           | jsonb     | Variables disponibles para personalización       |
| fecha_creacion      | timestamp | Fecha de creación de la plantilla                |
| fecha_actualizacion | timestamp | Fecha de última actualización                    |

#### configuracion_tenant

Contiene la configuración general de cada cliente/empresa (tenant), incluyendo estado y parámetros regionales.

| campo               | tipo      | descripción                                      |
|---------------------|-----------|--------------------------------------------------|
| tenant_id           | uuid      | Identificador único del tenant                   |
| nombre              | text      | Nombre del cliente/empresa                       |
| codigo_pais         | text      | Código del país (ej: "PE", "CO")               |
| configuracion       | jsonb     | Configuración general y parámetros regionales     |
| estado              | text      | Estado del tenant (activo, inactivo, etc.)       |
| fecha_creacion      | timestamp | Fecha de creación del tenant                     |
| fecha_actualizacion | timestamp | Fecha de última actualización                    |

## 5.3 Endpoints principales

A continuación se describen los endpoints REST principales del sistema de notificaciones:

| Método | Ruta                                 | Descripción                              | Parámetros clave                |
|--------|--------------------------------------|------------------------------------------|---------------------------------|
| POST   | /api/v1/notifications                | Crear una nueva notificación             | tenant_id, país, canal, contenido|
| GET    | /api/v1/notifications/{id}           | Consultar estado de una notificación     | id, tenant_id                   |
| GET    | /api/v1/notifications                | Listar notificaciones                    | tenant_id, país, canal, estado  |
| POST   | /api/v1/notifications/schedule       | Programar notificación                   | tenant_id, país, canal, fecha_envio, contenido |
| POST   | /api/v1/attachments                  | Subir adjunto                            | tenant_id, país, archivo        |
| GET    | /api/v1/attachments/{id}             | Consultar metadatos de adjunto           | id, tenant_id                   |
| GET    | /api/v1/attachments/{id}/download    | Descargar adjunto                        | id, tenant_id                   |

### Definición de campos del payload de notificación

La siguiente tabla describe todos los campos posibles en el payload multicanal recomendado:

| Campo                        | Tipo                | Descripción                                                        |
|------------------------------|---------------------|--------------------------------------------------------------------|
| requestId                    | string              | Identificador único de la solicitud                                |
| notificationId               | string              | Identificador único de la notificación                             |
| timestamp                    | string (ISO 8601)   | Fecha y hora de creación de la solicitud o mensaje                 |
| notificationType             | string              | Tipo de notificación (ej: transactional, promotional, alert)       |
| channels                     | array[string]       | Canales por los que se enviará la notificación                     |
| recipient                    | objeto              | Información del destinatario                                       |
| recipient.userId             | string              | Identificador del usuario destinatario                             |
| recipient.email              | string              | Correo electrónico del destinatario                                |
| recipient.phone              | string              | Teléfono del destinatario (para SMS/WhatsApp)                      |
| message                      | objeto              | Contenido principal de la notificación                             |
| message.subject              | string              | Asunto del mensaje (email)                                         |
| message.body                 | objeto              | Cuerpo principal del mensaje (email, html/plainText)               |
| message.body.html            | string              | Contenido HTML del mensaje (correo electrónico)                    |
| message.body.plainText       | string              | Contenido en texto plano del mensaje (correo electrónico)          |
| message.attachments          | array[objeto]       | Archivos adjuntos (url, fileName, mimeType)                        |
| message.sms                  | objeto              | Contenido específico para SMS                                      |
| message.sms.text             | string              | Texto para el canal SMS                                            |
| message.push                 | objeto              | Detalle de la notificación push                                    |
| message.push.title           | string              | Título de la notificación push                                     |
| message.push.body            | string              | Cuerpo de la notificación push                                     |
| message.push.icon            | string              | URL del ícono para la notificación push                            |
| message.push.action          | objeto              | Acción asociada a la notificación push                             |
| message.push.action.type     | string              | Tipo de acción (ej: viewOrder)                                     |
| message.push.action.url      | string              | URL asociada a la acción                                           |
| message.whatsapp             | objeto              | Contenido específico para WhatsApp                                 |
| message.whatsapp.text        | string              | Texto para el canal WhatsApp                                       |
| schedule                     | objeto              | Información de programación de envío                               |
| schedule.sendAt              | string (ISO 8601)   | Fecha y hora programada para el envío                              |
| metadata                     | objeto              | Metadatos adicionales para control y priorización                  |
| metadata.priority            | string              | Prioridad de la notificación (ej: high, normal, low)               |
| metadata.retries             | integer             | Número de reintentos permitidos                                    |
| metadata.sentBy              | string              | Servicio o sistema que envió el mensaje                            |
| metadata.templateId          | string              | Identificador de la plantilla utilizada                            |

#### Ejemplo de payload multicanal

```json
{
  "requestId": "solicitud456",
  "notificationId": "notif78910",
  "timestamp": "2025-07-29T10:30:00Z",
  "notificationType": "operacional",
  "channels": ["email", "sms", "push", "whatsapp"],
  "recipient": {
    "userId": "empleado321",
    "email": "operaciones@talma.com",
    "phone": "+51123456789"
  },
  "message": {
    "subject": "Confirmación de despacho de carga - Guía 987654",
    "body": {
      "html": "<html><body><h1>Despacho confirmado</h1><p>La carga con guía 987654 ha sido despachada exitosamente. Consulte el estado en el sistema Talma Cargo.</p></body></html>",
      "plainText": "Despacho confirmado. La carga con guía 987654 ha sido despachada exitosamente. Consulte el estado en el sistema Talma Cargo."
    },
    "attachments": [
      {
        "url": "https://talma.com/documentos/guia987654.pdf",
        "fileName": "guia987654.pdf",
        "mimeType": "application/pdf"
      }
    ],
    "sms": {
      "text": "Despacho confirmado. Guía 987654. Verifique en Talma Cargo."
    },
    "push": {
      "title": "Despacho de carga confirmado",
      "body": "La carga con guía 987654 ha sido despachada. Consulte el sistema Talma Cargo.",
      "icon": "https://talma.com/imagenes/icono-carga.png",
      "action": {
        "type": "verGuia",
        "url": "https://talma.com/cargo/guia/987654"
      }
    },
    "whatsapp": {
      "text": "Talma: Despacho confirmado para la guía 987654. Más detalles en el sistema."
    }
  },
  "schedule": {
    "sendAt": "2025-07-29T11:00:00Z"
  },
  "metadata": {
    "priority": "alta",
    "retries": 2,
    "sentBy": "SistemaCargo",
    "templateId": "confirmacionDespacho"
  }
}
```

#### Ejemplo de payload multicanal con reemplazo de parámetros

```json
{
  "requestId": "solicitud789",
  "notificationId": "notif112233",
  "timestamp": "2025-07-29T12:00:00Z",
  "notificationType": "operacional",
  "channels": ["email", "sms", "push"],
  "recipient": {
    "userId": "empleado654",
    "email": "seguridad@talma.com",
    "phone": "+51198765432"
  },
  "message": {
    "subject": "Alerta de acceso restringido - Área {{area}}",
    "body": {
      "html": "<html><body><h1>Alerta de acceso</h1><p>El empleado {{nombre_empleado}} ha intentado acceder al área {{area}} el {{fecha}}.</p></body></html>",
      "plainText": "Alerta: El empleado {{nombre_empleado}} intentó acceder a {{area}} el {{fecha}}."
    },
    "variables": {
      "nombre_empleado": "Juan Pérez",
      "area": "Carga Internacional",
      "fecha": "2025-07-29 11:55"
    },
    "sms": {
      "text": "Alerta: {{nombre_empleado}} intentó acceder a {{area}} el {{fecha}}."
    },
    "push": {
      "title": "Acceso restringido detectado",
      "body": "{{nombre_empleado}} intentó acceder a {{area}} el {{fecha}}."
    }
  },
  "metadata": {
    "priority": "alta",
    "templateId": "alertaAcceso",
    "sentBy": "SistemaSeguridad"
  }
}
```
