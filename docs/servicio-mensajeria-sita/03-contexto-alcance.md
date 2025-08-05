# 3. Contexto y alcance del sistema

El **Sistema de Mensajería SITA** es la plataforma especializada para generación, transmisión y gestión de mensajes aeronáuticos usando protocolos SITA SITATEX, conectando operaciones aeroportuarias con la red global de aviación.

## 3.1 Contexto de negocio

### Propósito del Sistema

El sistema de mensajería SITA actúa como el puente de comunicación con la industria aeronáutica, proporcionando:

- **Generación automática** de mensajes SITA basados en eventos operacionales
- **Transmisión confiable** a través de la red SITA global
- **Gestión de plantillas** para diferentes tipos de mensajes aeronáuticos
- **Trazabilidad completa** de mensajes enviados y recibidos
- **Compliance** con estándares internacionales de aviación

### Stakeholders Principales

| Stakeholder | Rol | Responsabilidad | Expectativa |
|-------------|-----|----------------|-------------|
| **Airport Operations Manager** | Gestión Operacional | Coordinación con aerolíneas | Comunicación automática, reducción manual |
| **Airline Operations Centers** | Operaciones Aerolíneas | Recepción información operacional | Mensajes precisos, formato SITA estándar |
| **Ground Handling Companies** | Servicios Tierra | Coordinación operaciones | Información oportuna, estado actualizado |
| **Air Traffic Control** | Control Tráfico Aéreo | Coordinación vuelos | Mensajes regulatorios, compliance |
| **SITA Network Operations** | Proveedor Red | Conectividad y transmisión | Formato correcto, compliance protocolo |
| **Compliance Officers** | Cumplimiento | Regulaciones aeronáuticas | Audit trail, cumplimiento ICAO |

### Objetivos de Negocio

| Objetivo | Descripción | Métricas de Éxito |
|----------|-------------|-------------------|
| **Automatización Operacional** | Reducir intervención manual en comunicaciones | 90% mensajes automáticos, < 5 min latencia |
| **Compliance ICAO/SITA** | Cumplimiento estándares aeronáuticos | 100% format compliance, zero protocol violations |
| **Interoperabilidad Global** | Comunicación seamless con aerolíneas | 500+ airlines reached, global coverage |
| **Trazabilidad Completa** | Audit trail completo de comunicaciones | 100% message tracking, delivery confirmation |
| **Confiabilidad Operacional** | Entrega garantizada de mensajes críticos | 99.9% delivery rate, redundancy capability |

## 3.2 Contexto técnico

### Posición en la Arquitectura

```text
┌─────────────────────────────────────────────────────────────────┐
│                      SITA GLOBAL NETWORK                       │
│  [SITATEX Network] [Partner Airlines] [Ground Handlers]       │
│  [ATC Systems] [Government Agencies] [Service Providers]      │
└─────────────────────┬───────────────────────────────────────────┘
                      │ SITATEX Protocol, Type B Messages
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                    SITA MESSAGING SYSTEM                       │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │                MESSAGE GENERATION ENGINE                    ││
│  │  [Template Engine] [Message Builder] [Validation Engine]   ││
│  └─────────────────────────────────────────────────────────────┘│
│  ┌─────────────────────────────────────────────────────────────┐│
│  │                 TRANSMISSION LAYER                          ││
│  │  [SITATEX Gateway] [Message Queue] [Delivery Tracking]     ││
│  └─────────────────────────────────────────────────────────────┘│
│  ┌─────────────────────────────────────────────────────────────┐│
│  │               INTEGRATION & EVENTS                          ││
│  │  [Event Consumers] [API Gateway] [Status Publisher]        ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────┬───────────────────────────────────────────┘
                      │ Events, Status Updates, Notifications
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                    INTERNAL CORPORATE SYSTEMS                  │
│  [Track & Trace] [Notification System] [Operations Dashboard] │
│  [Audit Systems] [Reporting Tools] [Management Interfaces]    │
└─────────────────────────────────────────────────────────────────┘
```

### Fronteras del Sistema

#### Dentro del Alcance

| Componente | Descripción | Responsabilidad |
|------------|-------------|-----------------|
| **Message Generation API** | REST APIs para generación mensajes | Message creation, validation, queuing |
| **Template Engine** | Motor de plantillas SITA | Type B format, multi-language, customization |
| **SITATEX Gateway** | Interface con red SITA | Protocol compliance, transmission, error handling |
| **Message Tracking** | Seguimiento de mensajes | Delivery status, confirmations, retries |
| **Event Integration** | Integración con sistemas internos | Event consumption, status publishing |
| **Compliance Engine** | Validación estándares SITA/ICAO | Format validation, protocol compliance |
| **Audit & Logging** | Trazabilidad completa | Message logs, audit trails, reporting |
| **Configuration Management** | Gestión de configuraciones | Templates, addresses, routing rules |

#### Fuera del Alcance

| Componente | Razón de Exclusión | Responsable |
|------------|-------------------|-------------|
| **SITA Network Infrastructure** | Third-party network | SITA, Descartes |
| **Airline Systems** | External partners | Individual airlines |
| **Government Systems** | External authorities | Aviation authorities |
| **Event Generation** | Source responsibility | Track & Trace, airport systems |
| **Message Content Creation** | Business responsibility | Operations teams |

## 3.3 Interfaces externas

### Actores Principales

| Actor | Tipo | Descripción | Interacciones |
|-------|------|-------------|---------------|
| **Operations Coordinator** | Humano | Coordinación operaciones aeroportuarias | Manual message sending, status monitoring |
| **System Administrator** | Humano | Administración del sistema | Template management, configuration |
| **Airline Dispatcher** | Humano | Operaciones aerolíneas | Message reception, operational coordination |
| **Ground Handler** | Humano | Servicios de tierra | Operational messages, status updates |
| **Corporate Systems** | Sistema | Sistemas generadores de eventos | Automated message triggering |
| **SITA Network** | Sistema | Red global de comunicaciones | Message transmission, delivery confirmation |

### Sistemas Externos

| Sistema | Tipo | Protocolo | Propósito | Datos Intercambiados |
|---------|------|-----------|-----------|---------------------|
| **SITA Network (Descartes)** | External Service | SITATEX/X.25 | Message transmission | Type B messages, delivery confirmations |
| **Partner Airlines** | External Partners | SITATEX | Operational communication | Flight messages, status updates, coordination |
| **Ground Handling Systems** | External Partners | SITATEX/API | Service coordination | Baggage, cargo, passenger handling messages |
| **Air Traffic Control** | Government System | SITATEX | Flight coordination | Flight plans, clearances, coordination messages |
| **Track & Trace System** | Internal Service | Event Bus | Event-driven messaging | Operational events, trigger data |
| **Notification System** | Internal Service | Event Bus | Alert notifications | Message status, delivery failures |
| **Identity System** | Internal Service | OAuth2/OIDC | Authentication | User tokens, permissions, audit identity |
| **Airport Operations** | Internal System | REST API | Operational data | Flight data, gate assignments, resource status |

### Interfaces de Datos

#### Entrada de Datos

| Interface | Fuente | Tipo de Datos | Frecuencia | Formato |
|-----------|--------|---------------|------------|---------|
| **Operational Events** | Track & Trace | Flight/operation events | Real-time | Kafka messages (Avro) |
| **Manual Requests** | Operations staff | Ad-hoc messages | On-demand | REST API (JSON) |
| **Batch Operations** | Scheduled systems | Bulk message generation | Scheduled | REST API (JSON array) |
| **Template Updates** | Content management | Message templates | As needed | REST API (JSON) |
| **Configuration Changes** | Admin systems | System configuration | As needed | Configuration APIs |

#### Salida de Datos

| Interface | Destino | Tipo de Datos | Frecuencia | Formato |
|-----------|---------|---------------|------------|---------|
| **SITA Messages** | SITA Network | Type B messages | Real-time | SITATEX protocol |
| **Status Events** | Track & Trace | Message status updates | Event-driven | Kafka messages |
| **Delivery Confirmations** | Notification System | Success/failure notifications | Real-time | Kafka messages |
| **Audit Logs** | Compliance systems | Message audit trail | Continuous | Structured logs |
| **Metrics Data** | Monitoring systems | Performance metrics | Continuous | Prometheus metrics |
| **Reports** | Management systems | Operational reports | Scheduled | Report APIs |

## 3.4 Alcance funcional

### Funcionalidades Incluidas

| Función | Descripción | Usuarios Objetivo | Prioridad |
|---------|-------------|-------------------|-----------|
| **Automatic Message Generation** | Generación automática basada en eventos | Sistema automático | Alta |
| **Template Management** | Gestión de plantillas Type B | System administrators | Alta |
| **SITATEX Transmission** | Envío a través de red SITA | Sistema automático | Alta |
| **Message Tracking** | Seguimiento de entrega | Operations, administrators | Alta |
| **Manual Message Sending** | Envío manual para casos especiales | Operations coordinators | Media |
| **Multi-language Support** | Plantillas en múltiples idiomas | International operations | Media |
| **Delivery Confirmation** | Confirmación de entrega | Operations monitoring | Media |
| **Error Handling & Retry** | Manejo de errores y reintentos | Sistema automático | Media |
| **Compliance Validation** | Validación estándares SITA/ICAO | Compliance officers | Baja |
| **Audit & Reporting** | Reportes y auditoría | Management, compliance | Baja |

### Funcionalidades Excluidas

| Función | Razón de Exclusión | Alternativa |
|---------|-------------------|-------------|
| **Message Content Creation** | Business domain responsibility | Operations teams, business rules |
| **SITA Network Management** | Third-party service | SITA/Descartes network operations |
| **Airline System Integration** | Partner responsibility | Individual airline systems |
| **Event Generation** | Source system responsibility | Track & Trace, airport systems |
| **Business Intelligence** | Specialized BI tools | Dedicated analytics platforms |

## 3.5 Casos de uso principales

### Generación Automática de Mensaje

```text
Actor: Track & Trace System
Precondición: Evento operacional crítico (cambio de gate)
Flujo Principal:
1. Track & Trace detecta cambio de gate para vuelo
2. Sistema publica evento a Kafka topic
3. SITA Messaging consume evento relevante
4. Sistema identifica template para tipo evento
5. Sistema extrae datos necesarios del evento
6. Template engine genera mensaje Type B
7. Sistema valida formato contra estándares SITA
8. Mensaje enviado a SITA network via SITATEX
9. Sistema rastrea estado de entrega
10. Confirmación de entrega registrada
Postcondición: Aerolíneas notificadas de cambio operacional
```

### Envío Manual de Mensaje

```text
Actor: Operations Coordinator
Precondición: Coordinador autenticado con permisos
Flujo Principal:
1. Coordinador accede a interface de mensajería
2. Coordinador selecciona tipo de mensaje
3. Sistema presenta template correspondiente
4. Coordinador completa campos requeridos
5. Sistema valida contenido y formato
6. Coordinador confirma envío
7. Sistema genera mensaje Type B
8. Mensaje enviado a destinatarios SITA
9. Sistema confirma entrega a coordinador
Postcondición: Mensaje manual enviado exitosamente
```

### Gestión de Templates SITA

```text
Actor: System Administrator
Precondición: Admin autenticado con permisos de configuración
Flujo Principal:
1. Admin accede a template management
2. Admin selecciona tipo de mensaje SITA
3. Admin modifica template Type B
4. Sistema valida sintaxis y compliance
5. Admin prueba template con datos sample
6. Sistema valida resultado contra estándares
7. Admin activa template para producción
8. Sistema notifica cambio a stakeholders
Postcondición: Template actualizado y activo
```

### Tracking de Mensaje y Confirmación

```text
Actor: Operations Monitor
Precondición: Mensajes enviados al SITA network
Flujo Principal:
1. Monitor accede a tracking dashboard
2. Sistema muestra mensajes en tránsito
3. SITA network retorna confirmaciones
4. Sistema actualiza estado de mensajes
5. Monitor puede ver delivery status
6. Sistema genera alertas para fallos
7. Monitor puede reintentar mensajes fallidos
8. Sistema registra acciones en audit log
Postcondición: Estado de mensajes monitoreado y gestionado
```

## 3.6 Tipos de mensajes SITA

### Mensajes de Vuelo (Flight Messages)

| Tipo | Código SITA | Descripción | Trigger Event | Frecuencia |
|------|-------------|-------------|---------------|------------|
| **Flight Plan** | FPL | Plan de vuelo | Flight schedule creation | Per flight |
| **Change Message** | CHG | Cambios al vuelo | Schedule/route changes | As needed |
| **Cancellation** | CNL | Cancelación de vuelo | Flight cancellation | As needed |
| **Delay Message** | DLA | Retraso de vuelo | Delay detection | Real-time |
| **Departure** | DEP | Salida del vuelo | Aircraft departure | Per departure |
| **Arrival** | ARR | Llegada del vuelo | Aircraft arrival | Per arrival |

### Mensajes Operacionales (Operational Messages)

| Tipo | Código SITA | Descripción | Trigger Event | Frecuencia |
|------|-------------|-------------|---------------|------------|
| **Gate Assignment** | GAT | Asignación de puerta | Gate allocation | Per assignment |
| **Baggage** | BAG | Información de equipaje | Baggage processing | Per bag batch |
| **Passenger** | PAX | Información pasajeros | Check-in completion | Per flight |
| **Cargo** | CGO | Información de carga | Cargo loading | Per cargo batch |
| **Fuel** | FUE | Información combustible | Fuel service | Per fueling |

### Mensajes de Coordinación (Coordination Messages)

| Tipo | Código SITA | Descripción | Trigger Event | Frecuencia |
|------|-------------|-------------|---------------|------------|
| **Ground Handling** | GHD | Servicios de tierra | Service assignment | Per service |
| **Crew** | CRW | Información tripulación | Crew changes | As needed |
| **Maintenance** | MNT | Mantenimiento | Maintenance events | As needed |
| **Security** | SEC | Información seguridad | Security events | As needed |

## 3.7 Atributos de calidad

### Reliability

| Atributo | Métrica | Target | Medición |
|----------|---------|--------|----------|
| **Message Delivery Rate** | Successful transmissions | 99.9% | SITA network confirmations |
| **System Availability** | Service uptime | 99.95% | Health monitoring |
| **Format Compliance** | SITA standard adherence | 100% | Validation checks |
| **Delivery Confirmation** | Confirmed delivery rate | 95% | Network acknowledgments |

### Performance

| Atributo | Métrica | Target | Medición |
|----------|---------|--------|----------|
| **Message Generation Time** | Template to message | < 2 seconds | Processing time |
| **Transmission Latency** | Send to network delivery | < 30 seconds | End-to-end monitoring |
| **Throughput** | Messages per hour | 10,000 messages/hour | Load testing |
| **Template Processing** | Template render time | < 1 second | Performance profiling |

### Compliance

| Atributo | Métrica | Target | Medición |
|----------|---------|--------|----------|
| **ICAO Compliance** | Standard adherence | 100% | Regulatory audits |
| **SITA Protocol Compliance** | Protocol violations | Zero | Protocol validation |
| **Message Format** | Type B format compliance | 100% | Format validation |
| **Audit Completeness** | Audit trail coverage | 100% | Audit verification |

### Interoperability

| Atributo | Métrica | Target | Medición |
|----------|---------|--------|----------|
| **Airline Coverage** | Reachable airlines | 500+ airlines | Network connectivity |
| **Message Types** | Supported SITA types | 20+ message types | Type coverage |
| **Multi-language** | Language support | 5+ languages | Template coverage |
| **Character Encoding** | Encoding support | UTF-8, SITA charset | Encoding validation |

## Referencias

### SITA Standards and Protocols

- [SITA SITATEX Protocol Specification](https://www.sita.aero/solutions/airline-operations/sitatex/)
- [SITA Type B Message Standard](https://www.sita.aero/resources/type-b-message-standard/)
- [SITA Network Documentation](https://www.sita.aero/about/what-we-do/networks/)

### Aviation Standards

- [ICAO Doc 4444 (PANS-ATM)](https://www.icao.int/publications/documents/4444_cons_en.pdf)
- [AFTN Manual (ICAO Doc 7030)](https://www.icao.int/publications/pages/publication.aspx?docnum=7030)
- [ICAO Annex 10 (Aeronautical Telecommunications)](https://www.icao.int/safety/airnavigation/pages/annex-10---aeronautical-telecommunications.aspx)

### Technical Integration

- [Event Bus Documentation](https://docs.microsoft.com/en-us/azure/service-bus-messaging/service-bus-messaging-overview)
- [Event-Driven Architecture](https://martinfowler.com/articles/201701-event-driven.html)
- [Arc42 Context Template](https://docs.arc42.org/section-3/)
