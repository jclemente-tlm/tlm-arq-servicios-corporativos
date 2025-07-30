# 6. Vista de tiempo de ejecución

A continuación se describen los principales escenarios del servicio de notificaciones, mostrando cómo cada componente interactúa y cómo la configuración se utiliza en cada caso.

> **Nota transversal:**
> ConfigManager solo provee configuración y credenciales al inicio; los componentes usan directamente DB, S3 y servicios externos.

## 6.1 Envío multicanal (flujo principal)

**Descripción:** El usuario solicita una notificación multicanal. La API valida reglas y límites y encola el mensaje en la Cola de Ingesta. El Notification Processor recibe el mensaje, registra la notificación en la base de datos y la distribuye a la Cola de Canal (Email/SMS/WhatsApp). El Canal Processor (Email/SMS/WhatsApp) consume de la cola, realiza la entrega por el canal correspondiente y actualiza el estado de la notificación en la base de datos. La configuración se lee al inicio y no interviene en el flujo.

**Diagrama de secuencia:**

```mermaid
sequenceDiagram
    participant App as App Talma
    participant API as Notification API
    participant ColaIngesta as Cola de Ingesta
    participant Proc as Notification Processor
    participant DB as Base de Datos
    participant ColaCanal as Cola de Canal (Email/SMS/WhatsApp)
    participant CanalProc as Canal Processor (Email/SMS/WhatsApp)
    participant ProvEmail as Proveedor Email
    participant ProvSMS as Proveedor SMS
    participant ProvWhats as Proveedor WhatsApp

    App->>API: Solicita notificación multicanal
    API->>ColaIngesta: Encola mensaje
    ColaIngesta->>Proc: Mensaje recibido
    Proc->>DB: Registra notificación
    Proc->>ColaCanal: Encola Email
    Proc->>ColaCanal: Encola SMS
    Proc->>ColaCanal: Encola WhatsApp
    ColaCanal->>CanalProc: Consume mensaje Email
    ColaCanal->>CanalProc: Consume mensaje SMS
    ColaCanal->>CanalProc: Consume mensaje WhatsApp
    CanalProc->>ProvEmail: Envía email
    CanalProc->>ProvSMS: Envía SMS
    CanalProc->>ProvWhats: Envía WhatsApp
    ProvEmail-->>CanalProc: Respuesta email
    ProvSMS-->>CanalProc: Respuesta SMS
    ProvWhats-->>CanalProc: Respuesta WhatsApp
    CanalProc->>DB: Actualiza estado de notificación
```

**Ejemplo:**
Un usuario solicita el envío de una notificación por email, SMS y WhatsApp. El sistema encola el mensaje, el Notification Processor registra la notificación y la distribuye por canal, y el estado de la notificación se actualiza en la base de datos.

## 6.2 Validación de preferencias y límites

**Descripción:** Antes de enviar, se verifica que el canal esté habilitado y no se excedan límites, usando la configuración cargada al inicio.

**Diagrama de secuencia:**

```mermaid
sequenceDiagram
    participant API as Notification API
    participant ConfigMgr as ConfigManager
    Note over API: Configuración leída al iniciar
    API->>ConfigMgr: Obtiene preferencias y límites (inyección)
    API-->>API: Valida reglas
    API-->>App: Rechaza o acepta solicitud
```

**Ejemplo:**
Un usuario intenta enviar una notificación SMS, pero ha superado el límite diario. El sistema rechaza la solicitud y notifica el motivo.

## 6.3 Manejo de reintentos y Dead Letter Queue (DLQ)

**Descripción:** Si la entrega falla, el sistema reintenta según los parámetros configurados; si no se logra, envía el mensaje a la DLQ para revisión.

**Diagrama de flujo:**

```mermaid
flowchart TD
    A[Procesador de canal recibe mensaje de SQS]
    B{¿Entrega exitosa?}
    A --> B
    B -- Sí --> C[Actualiza estado a entregado]
    B -- No --> D[Reintenta hasta N veces]
    D -->|Exitoso| C
    D -->|Fallido| E[Envía a DLQ]
    E --> F[Notifica y registra para análisis]
    C:::config
    D:::config
    classDef config fill:#f9f,stroke:#333,stroke-width:1px;
    class C,D config;
```

**Ejemplo:**
El proveedor de email está caído. El sistema reintenta 3 veces y luego envía el mensaje a la DLQ para revisión manual.

## 6.4 Programación de notificaciones

**Descripción:** El usuario agenda una notificación; el Scheduler la envía en la fecha indicada usando la configuración inicial.

**Diagrama de secuencia:**

```mermaid
sequenceDiagram
    participant App as App Talma
    participant API as Notification API
    participant DB as DB
    participant Scheduler as Scheduler
    participant SQS as SQS
    Note over Scheduler: Configuración leída al iniciar
    App->>API: Solicitud de notificación programada
    API->>DB: Guarda notificación programada
    Scheduler->>DB: Consulta notificaciones pendientes
    Scheduler->>SQS: Encola notificación en fecha/hora
    SQS->>Proc: Procesa envío
```

**Ejemplo:**
Un usuario agenda una notificación para el día siguiente. El Scheduler la envía automáticamente en la fecha indicada.

## 6.5 Gestión de adjuntos

**Descripción:** El sistema permite adjuntar archivos a las notificaciones, gestionando su almacenamiento y recuperación. La configuración de almacenamiento y límites es leída al inicio; la interacción con S3 y DB es directa por los componentes.

**Diagrama de secuencia:**

```mermaid
sequenceDiagram
    participant App as App Talma
    participant API as Notification API
    participant S3 as S3
    participant DB as DB
    participant Proc as Notification Processor
    participant Canal as Canal Processor
    Note over API: Configuración leída al iniciar
    App->>API: Sube archivo adjunto
    API->>S3: Almacena archivo
    API->>DB: Registra metadato
    Proc->>DB: Consulta metadato de adjunto
    Canal->>S3: Descarga archivo para entrega
```

**Ejemplo:**
El usuario adjunta un PDF a la notificación. El archivo se almacena en S3 y el procesador de canal lo descarga para enviarlo por email.

## 6.6 Escenario de error y recuperación

**Descripción:** Ante errores, el sistema reintenta y alerta según la configuración; la recuperación es manual si el mensaje llega a la DLQ.

**Diagrama de secuencia:**

```mermaid
sequenceDiagram
    participant Canal as Canal Processor
    participant DLQ as Dead Letter Queue
    participant Ops as Operaciones
    Note over Canal: Configuración leída al iniciar
    Canal-->>Canal: Detecta error
    Canal->>Canal: Reintenta entrega
    Canal->>DLQ: Envía mensaje fallido
    DLQ->>Ops: Genera alerta y registro
    Ops->>DLQ: Recupera mensaje manualmente
```

**Ejemplo:**
El proveedor de WhatsApp rechaza la entrega. El sistema reintenta, envía a DLQ y genera una alerta para el equipo de operaciones, que puede recuperar el mensaje manualmente.
