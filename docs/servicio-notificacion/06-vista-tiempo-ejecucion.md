# 6. Vista De Tiempo De Ejecución

## 6.1 Escenarios Principales

| Escenario               | Flujo                              | Componentes         |
|-------------------------|------------------------------------|---------------------|
| Envío inmediato         | API → Orchestrator → Handler       | API, Processor      |
| Envío programado        | API → Repository → Scheduler       | API, Processor      |
| Procesamiento plantilla | Template Engine → Handler          | Processor           |

## 6.2 Patrones De Interacción

| Patrón      | Descripción                   | Tecnología         |
|-------------|------------------------------|--------------------|
| CQRS        | Separación comando/consulta  | API, Processor     |
| Queue       | Cola de mensajes             | `EventBus`         |
| Template    | Procesamiento de plantillas  | Motor de plantillas|

Esta sección describe los principales escenarios de ejecución del sistema, mostrando cómo los componentes interactúan durante el tiempo de ejecución para cumplir con los casos de uso más relevantes arquitectónicamente.

## 6.3 Escenario: Envío Transaccional Individual

### Descripción Del Envío Transaccional

Flujo crítico para notificaciones transaccionales de alta prioridad (confirmaciones, alertas críticas) que requieren entrega garantizada y baja latencia.

### Actores

- Aplicación Cliente: Sistema que origina la notificación
- `ApiGateway`: Punto de entrada con autenticación
- `NotificationApi`: Servicio de ingesta y validación
- `NotificationDb`: Persistencia de notificaciones
- `EventBus`: Intermediario de mensajes para desacoplamiento
- `NotificationProcessor`: Procesador especializado por canal
- `ProviderAdapter`: Adaptador a proveedor externo

### Flujo Principal

```mermaid
sequenceDiagram
    participant Cliente as Aplicación Cliente
    participant ApiGateway as ApiGateway
    participant NotificationApi as NotificationApi
    participant NotificationDb as NotificationDb
    participant EventBus as EventBus
    participant NotificationProcessor as NotificationProcessor
    participant ProviderAdapter as ProviderAdapter

    Cliente->>ApiGateway: 1. POST /notifications/send
    ApiGateway->>ApiGateway: 2. Validar JWT
    ApiGateway->>NotificationApi: 3. Reenviar solicitud

    NotificationApi->>NotificationApi: 4. Validar payload y plantilla
    NotificationApi->>NotificationDb: 5. Almacenar notificación
    NotificationApi->>EventBus: 6. Publicar evento
    NotificationApi->>Cliente: 7. HTTP 202 Accepted {messageId}

    Note over EventBus,NotificationProcessor: Procesamiento asíncrono
    EventBus->>NotificationProcessor: 8. Consumir evento
    NotificationProcessor->>NotificationProcessor: 9. Renderizar plantilla
    NotificationProcessor->>ProviderAdapter: 10. Enviar vía API externa
    ProviderAdapter->>NotificationProcessor: 11. Confirmación de entrega
    NotificationProcessor->>NotificationDb: 12. Actualizar estado
    NotificationProcessor->>EventBus: 13. Publicar evento de estado
```

### Aspectos Notables

- Respuesta inmediata: API responde en `< 100ms` con acknowledgment
- Procesamiento asíncrono: Desacopla ingesta de entrega
- Idempotencia: Cada request incluye `messageId` para deduplicación
- Observabilidad: Cada paso genera telemetría para tracking

### Métricas De Rendimiento

| Métrica                   | Target                | Medición                |
|---------------------------|----------------------|-------------------------|
| `API Response Time`       | `p95 < 100ms`        | Monitoreo APM           |
| `Event Processing`        | `< 500ms`            | Métricas personalizadas |
| `End-to-End Delivery`     | `< 30s` (transactional) | Métricas de negocio |
| `Capacidad de procesamiento` | `10K req/min/instancia` | Pruebas de carga   |

## 6.4 Escenario: Procesamiento De Eventos Track & Trace

### Descripción Del Procesamiento De Eventos

Flujo automático triggered por eventos del sistema Track & Trace para notificaciones operacionales como actualizaciones de vuelo, cambios de puerta, etc.

### Flujo De Eventos

```mermaid
sequenceDiagram
    participant TrackTraceApi as TrackTraceApi
    participant EventBus as EventBus
    participant NotificationEventConsumer as NotificationEventConsumer
    participant TemplateEngine as TemplateEngine
    participant ChannelRouter as ChannelRouter
    participant NotificationProcessor as NotificationProcessor

    TrackTraceApi->>EventBus: 1. Publicar evento de vuelo
    NotificationEventConsumer->>EventBus: 2. Consumir evento
    NotificationEventConsumer->>NotificationEventConsumer: 3. Transformar a notificación
    NotificationEventConsumer->>TemplateEngine: 4. Obtener plantilla por tipo de evento
    TemplateEngine->>NotificationEventConsumer: 5. Retornar plantilla
    NotificationEventConsumer->>ChannelRouter: 6. Enrutar a canales

    par Email Channel
        ChannelRouter->>NotificationProcessor: 7a. Notificación email
    and SMS Channel
        ChannelRouter->>NotificationProcessor: 7b. Notificación SMS
    and Push Channel
        ChannelRouter->>NotificationProcessor: 7c. Notificación push
    end

    NotificationProcessor->>NotificationProcessor: 8. Procesar en paralelo
```

### Características Especiales

- Event-driven: Triggered automáticamente por eventos externos
- Transformación de datos: Mapping de eventos a formato de notificación
- Multi-canal automático: Routing inteligente según preferencias
- Procesamiento paralelo: Canales procesan simultáneamente

## 6.8 Escenario: Bulk De Notificaciones

### Descripción Del Bulk De Notificaciones

Envío masivo de notificaciones con optimizaciones de batch processing.

### Flujo De Ejecución

```mermaid
sequenceDiagram
    participant Cliente as Aplicación Cliente
    participant NotificationApi as NotificationApi
    participant BatchSplitter as BatchSplitter
    participant EventBus as EventBus
    participant NotificationProcessor as NotificationProcessor
    participant ProviderAdapter as ProviderAdapter
    participant NotificationDb as NotificationDb

    Cliente->>NotificationApi: 1. POST /notifications/bulk (10K destinatarios)
    NotificationApi->>BatchSplitter: 2. Dividir en lotes (100 c/u)
    BatchSplitter->>EventBus: 3. Publicar lotes en EventBus
    NotificationApi->>Cliente: 4. HTTP 202 Batch accepted

    loop Procesamiento paralelo
        EventBus->>NotificationProcessor: 5. Consumir lote
        NotificationProcessor->>ProviderAdapter: 6. Enviar lote a proveedor
        ProviderAdapter->>NotificationProcessor: 7. Resultados de entrega
        NotificationProcessor->>NotificationDb: 8. Actualizar estado de lote
    end
```

### Optimizaciones

- Batch size: 100 recipients por batch
- Parallel workers: 10 procesadores concurrentes
- Provider rotation: Balanceo de carga
- Retry policy: Exponential backoff

## 6.9 Escenario: Failover Y Recovery

### Descripción De Failover Y Recovery

Manejo de fallos de proveedor con failover automático.

### Flujo De Ejecución

```mermaid
sequenceDiagram
    participant NotificationProcessor as NotificationProcessor
    participant PrimaryProvider as PrimaryProvider
    participant SecondaryProvider as SecondaryProvider
    participant CircuitBreaker as CircuitBreaker
    participant HealthMonitor as HealthMonitor

    NotificationProcessor->>PrimaryProvider: 1. Enviar notificación
    PrimaryProvider-->>NotificationProcessor: 2. Timeout/Error
    NotificationProcessor->>CircuitBreaker: 3. Registrar fallo
    CircuitBreaker->>CircuitBreaker: 4. Abrir circuito tras 5 fallos
    NotificationProcessor->>SecondaryProvider: 5. Failover a secundario
    SecondaryProvider->>NotificationProcessor: 6. Respuesta exitosa

    HealthMonitor->>PrimaryProvider: 7. Health check
    PrimaryProvider->>HealthMonitor: 8. Servicio restaurado
    HealthMonitor->>CircuitBreaker: 9. Resetear circuito
```

### Recovery Policies

- Circuit breaker: 5 fallos consecutivos
- Timeout: 30 segundos por provider
- Health check: Cada 60 segundos
- Auto-recovery: Automático cuando provider responde

## 6.14 Consideraciones Generales

- Reintentos automáticos ante fallos de canal
- Trazabilidad de cada mensaje
- Aislamiento multi-tenant en cada paso
- Logs estructurados para auditoría
