# 12. Glosario

Este glosario define los términos técnicos, conceptos y acrónimos utilizados en la documentación del **Sistema de Notificaciones**, proporcionando claridad y consistencia en la comunicación entre equipos técnicos y stakeholders.

*[INSERTAR AQUÍ: Diagrama C4 - Notification System Terminology]*

## A

**Diseño API Primero** (API First Design)
: Estrategia de desarrollo donde el diseño de la API precede a la implementación, garantizando contratos claros entre servicios y mejor experiencia para desarrolladores.

**API Gateway**
: Punto de entrada unificado que maneja autenticación, autorización, limitación de velocidad y enrutamiento hacia microservicios específicos. En nuestro caso, implementado con YARP.

**Entrega Al-Menos-Una-Vez** (At-Least-Once Delivery)
: Garantía de entrega donde cada mensaje es entregado una o más veces. Requiere idempotencia en consumidores para manejar duplicados.

**Rastro de Auditoría** (Audit Trail)
: Registro cronológico e inmutable de todas las actividades del sistema, implementado mediante event sourcing para cumplimiento regulatorio y debugging.

**Auto-escalado** (Auto-scaling)
: Capacidad de ajustar automáticamente recursos computacionales (instancias, CPU, memoria) basado en métricas como utilización de CPU, profundidad de cola o tiempo de respuesta.

## B

**Backoff Exponencial**
: Estrategia de retry que incrementa exponencialmente el tiempo de espera entre reintentos (1s, 2s, 4s, 8s...) para evitar thundering herd y reducir carga en servicios failing.

**Procesamiento por Lotes** (Batch Processing)
: Procesamiento de múltiples elementos agrupados para optimizar throughput y reducir overhead. Usado en campañas de email y notificaciones masivas.

**Despliegue Azul-Verde** (Blue-Green Deployment)
: Estrategia de despliegue que mantiene dos ambientes idénticos (azul y verde) permitiendo cambios instantáneos y rollbacks seguros.

**Operaciones Masivas** (Bulk Operations)
: Operaciones que procesan múltiples elementos en una sola transacción, optimizando rendimiento y reduciendo latencia de red.

**Métricas de Negocio** (Business Metrics)
: Métricas que reflejan el impacto del negocio como tasas de entrega, uso de plantillas, satisfacción del cliente y costo por notificación.

## C

**Campaña**
: Envío masivo de notificaciones a múltiples destinatarios usando la misma plantilla y contenido, típicamente usado para marketing o comunicaciones corporativas.

**CAN-SPAM Act**
: Ley estadounidense que establece reglas para email comercial, requiriendo opt-out mechanisms, identificación clara del sender, y physical address.

**Cortocircuito** (Circuit Breaker)
: Patrón de resistencia que previene llamadas a servicios fallidos, con tres estados: Cerrado (normal), Abierto (fallando), Semi-Abierto (probando recuperación).

**Clean Architecture**
: Patrón arquitectónico que organiza código en capas concéntricas (Entities, Use Cases, Interface Adapters, Frameworks) con dependencies pointing inward.

**Consumer Group**
: Grupo de consumers Kafka que procesan mensajes de un topic en paralelo, con automatic load balancing y fault tolerance.

**Consumer Lag**
: Diferencia entre offset de último mensaje producido y último mensaje consumido en una partición Kafka, indicador crítico de performance.

**CQRS (Command Query Responsibility Segregation)**
: Patrón que separa operaciones de escritura (commands) y lectura (queries), permitiendo optimizaciones específicas para cada tipo.

## D

**Dead Letter Queue (DLQ)**
: Cola especial donde se almacenan mensajes que fallaron processing después de máximo número de reintentos, requiriendo intervención manual.

**Delivery Receipt**
: Confirmación del provider externo indicando que un mensaje fue entregado exitosamente al destinatario final.

**Domain Events**
: Eventos que representan algo significativo que ocurrió en el dominio del negocio, usado para loose coupling entre bounded contexts.

**DTO (Data Transfer Object)**
: Objeto inmutable usado para transferir datos entre capas o servicios, sin behavior, optimizado para serialization.

## E

**Event-Driven Architecture**
: Patrón arquitectónico donde componentes comunican mediante events asíncronos, promoviendo loose coupling y scalability.

**Event Sourcing**
: Patrón que persiste cambios de estado como secuencia inmutable de events, permitiendo audit trail completo y event replay.

**Exactly-Once Delivery**
: Garantía de entrega donde cada mensaje es procesado exactamente una vez, compleja de implementar y costosa en términos de performance.

## F

**Failover**
: Proceso automático de switching a un sistema backup cuando el primary falla, minimizando downtime y service disruption.

**Fan-Out Pattern**
: Patrón donde un evento se distribuye a múltiples consumers interesados, implementado típicamente con pub/sub systems.

**Feature Flag**
: Mechanism para activar/desactivar features en runtime sin deployments, permitiendo gradual rollouts y A/B testing.

## G

**GDPR (General Data Protection Regulation)**
: Regulación europea que establece reglas estrictas para processing de datos personales, incluyendo right to erasure y data portability.

**Graceful Degradation**
: Capacidad del sistema de mantener functionality esencial cuando algunos components fallan, degradando gradualmente en lugar de failing completamente.

## H

**Health Check**
: Endpoint que reporta el estado operacional de un service, usado por load balancers y monitoring systems para traffic routing.

**High Availability (HA)**
: Diseño de sistemas para minimizar downtime mediante redundancy, failover mechanisms, y elimination de single points of failure.

**Horizontal Scaling**
: Estrategia de scaling que añade más instances/nodes para handle increased load, contrastando con vertical scaling (más power per instance).

## I

**Idempotence**
: Propiedad donde múltiples executions del mismo operation producen el mismo resultado, crítico para retry mechanisms y at-least-once delivery.

**Integration Testing**
: Testing que verifica interacciones entre múltiples components/services, incluyendo database, external APIs, y message queues.

## J

**JWT (JSON Web Token)**
: Standard RFC 7519 para tokens de acceso que contienen claims codificados en JSON y firmados criptográficamente para authentication/authorization.

## K

**Event Bus**
: Plataforma agnóstica de streaming de eventos usada como message broker principal, proporcionando alto rendimiento, durabilidad y tolerancia a fallos.

**Kafka Connect**
: Framework para conectar Kafka con external systems (databases, file systems, cloud services) mediante reusable connectors.

**Kafka Streams**
: Library para building real-time stream processing applications que leen de y escriben a Kafka topics.

## L

**Liquid Template Engine**
: Template language desarrollado por Shopify, usado para dynamic content generation con syntax segura y features como filters y control flow.

**Load Balancer**
: Component que distribuye incoming requests entre múltiples instances de un service para optimizar resource utilization y availability.

**Logging**
: Práctica de recording events y activities del sistema para debugging, monitoring, audit, y troubleshooting.

## M

**Message Broker**
: Middleware que facilita communication entre applications mediante message passing, proporcionando decoupling y asynchronous processing.

**Microservices**
: Architectural pattern que estructura applications como collection de loosely coupled, independently deployable services.

**Multi-Provider Strategy**
: Approach que usa múltiples external providers para el mismo service (email, SMS) para redundancy y cost optimization.

**Multi-Tenancy**
: Architecture donde single instance de software sirve múltiples tenants con data isolation y customization per tenant.

## N

**Notification Channel**
: Medium específico usado para enviar notifications (email, SMS, push notifications, WhatsApp) con diferentes capabilities y providers.

**Notification Template**
: Predefined format para messages que incluye placeholders para dynamic content, branding, y layout específico por channel.

## O

**OAuth2**
: Authorization framework RFC 6749 que permite applications obtener limited access a user accounts mediante standardized flows.

**OpenTelemetry**
: Observability framework que proporciona APIs, libraries, agents, y instrumentation para collecting, processing, y exporting telemetry data.

**Orchestration**
: Pattern donde central controller manages y coordinates workflow entre múltiples services, contrastando con choreography.

## P

**Partitioning**
: Técnica de dividir data o processing en múltiples partitions para enabling parallel processing y horizontal scaling.

**Performance Testing**
: Testing que evalúa speed, scalability, y stability de applications bajo various load conditions.

**Provider API**
: External service API usado para actual message delivery (SendGrid para email, Twilio para SMS, FCM para push).

**Push Notification**
: Messages enviados directamente a user devices (mobile apps, web browsers) que aparecen como alerts o notifications.

## Q

**Queue Depth**
: Número de messages esperando processing en una queue, metric importante para monitoring system health y performance.

**Quality Gate**
: Automated check en CI/CD pipeline que debe pasar before code puede proceder al siguiente stage o environment.

## R

**Rate Limiting**
: Technique para controlling número de requests que client puede hacer en specific time period, protecting against abuse y overload.

**Redis**
: Almacén de estructuras de datos en memoria usado como base de datos, cache y message broker, proporcionando alto rendimiento para datos de acceso frecuente.

**Retry Policy**
: Strategy que define cuándo y cómo retry failed operations, típicamente con exponential backoff y maximum attempt limits.

**RBAC (Role-Based Access Control)**
: Security model donde permissions son assigned a roles, y roles a users, simplificando access management.

## S

**SLA (Service Level Agreement)**
: Formal agreement que define expected level de service, incluyendo availability, performance, y support metrics.

**SMS (Short Message Service)**
: Text messaging service component de mobile communication systems, usado para short notifications y alerts.

**SMTP (Simple Mail Transfer Protocol)**
: Standard protocol para email transmission across networks, usado por email providers para message delivery.

## T

**TCPA (Telephone Consumer Protection Act)**
: US law que regulates telemarketing calls, auto-dialed calls, prerecorded calls, text messages, y fax advertisements.

**Template Variable**
: Placeholder en notification templates que se reemplaza con actual data durante rendering process (ej: `{{user.name}}`, `{{flight.number}}`).

**Throughput**
: Measure de cantidad de work performed o transactions processed per unit time, metric clave para system performance.

**Throttling**
: Técnica de deliberately slowing down processing rate para prevent system overload o comply con external API rate limits.

## U

**Unsubscribe**
: Process donde users pueden opt-out de receiving future notifications, requerido por regulations como CAN-SPAM y GDPR.

**User Consent**
: Explicit permission dado por users para processing sus personal data, fundamental requirement para GDPR compliance.

## V

**Vertical Scaling**
: Strategy de increasing capacity de existing hardware/software by adding more power (CPU, RAM) to existing machines.

**Volume Testing**
: Type de performance testing que verifica system behavior cuando processing large amounts de data.

## W

**Webhook**
: HTTP callback que occurs cuando something happens, allowing real-time notifications entre systems cuando events occur.

**WhatsApp Business API**
: Official API provided por WhatsApp para businesses to send notifications y interact con customers en WhatsApp platform.

---

## Acrónimos Técnicos

| Acrónimo | Significado Completo | Contexto |
|----------|---------------------|----------|
| **ALB** | Application Load Balancer | AWS load balancing service |
| **API** | Application Programming Interface | Interface para communication entre systems |
| **AWS** | Amazon Web Services | Cloud platform provider |
| **CD** | Continuous Deployment | Automated deployment practices |
| **CI** | Continuous Integration | Automated testing y integration |
| **CORS** | Cross-Origin Resource Sharing | Web security feature |
| **CPU** | Central Processing Unit | Computing resource metric |
| **CRUD** | Create, Read, Update, Delete | Basic data operations |
| **DNS** | Domain Name System | Internet naming system |
| **FCM** | Firebase Cloud Messaging | Google push notification service |
| **FIFO** | First In, First Out | Queue ordering strategy |
| **GDPR** | General Data Protection Regulation | EU privacy regulation |
| **HTTP** | HyperText Transfer Protocol | Web communication protocol |
| **HTTPS** | HTTP Secure | Encrypted HTTP |
| **IAM** | Identity and Access Management | Security management system |
| **JSON** | JavaScript Object Notation | Data interchange format |
| **JWT** | JSON Web Token | Security token format |
| **LDAP** | Lightweight Directory Access Protocol | Directory service protocol |
| **MTBF** | Mean Time Between Failures | Reliability metric |
| **MTTR** | Mean Time To Recovery | Recovery speed metric |
| **PII** | Personally Identifiable Information | Privacy-sensitive data |
| **RAM** | Random Access Memory | Computer memory |
| **REST** | Representational State Transfer | API architectural style |
| **RPO** | Recovery Point Objective | Data loss tolerance metric |
| **RTO** | Recovery Time Objective | Downtime tolerance metric |
| **SES** | Simple Email Service | AWS email service |
| **SLA** | Service Level Agreement | Service quality commitment |
| **SLI** | Service Level Indicator | Performance measurement |
| **SLO** | Service Level Objective | Performance target |
| **SMS** | Short Message Service | Text messaging |
| **SNS** | Simple Notification Service | AWS messaging service |
| **SQL** | Structured Query Language | Database query language |
| **SQS** | Simple Queue Service | AWS message queue service |
| **SSL** | Secure Sockets Layer | Security protocol (legacy) |
| **TLS** | Transport Layer Security | Modern security protocol |
| **TTL** | Time To Live | Data expiration setting |
| **UUID** | Universally Unique Identifier | Unique identifier standard |
| **YAML** | YAML Ain't Markup Language | Configuration file format |

---

## Términos de Negocio

**Bounce Rate**
: Percentage de emails que no pudieron ser delivered debido a permanent issues (invalid email addresses, domain issues).

**Campaign Analytics**
: Metrics y reports que muestran performance de notification campaigns incluyendo delivery rates, open rates, click rates.

**Compliance Officer**
: Persona responsible de ensuring que organization cumple con relevant laws, regulations, y company policies.

**Delivery Rate**
: Percentage de notifications que fueron successfully delivered a recipients compared al total sent.

**Marketing Automation**
: Technology que automates marketing processes y campaigns based en predefined triggers y user behaviors.

**Opt-In/Opt-Out**
: Process donde users explicitly agree (opt-in) o decline (opt-out) to receive certain types de communications.

**Soft Bounce**
: Temporary email delivery failure debido a issues como full mailbox o temporary server problems.

**Template Library**
: Collection de pre-designed notification templates que business users pueden customize para different use cases.

**Transactional Email**
: Automated emails triggered por specific user actions o events (confirmations, receipts, alerts) rather than marketing purposes.

---

## Referencias Técnicas

### Notification Standards

- **RFC 5321**: Simple Mail Transfer Protocol
- **RFC 6376**: DomainKeys Identified Mail (DKIM) Signatures
- **RFC 7208**: Sender Policy Framework (SPF) for Authorizing Use of Domains in Email

### Security Standards

- **RFC 6749**: OAuth 2.0 Authorization Framework
- **RFC 7519**: JSON Web Token (JWT)
- **RFC 8551**: Secure/Multipurpose Internet Mail Extensions (S/MIME) Version 4.0

### Message Queue Standards

- **AMQP**: Advanced Message Queuing Protocol
- **Event Bus Protocol**: Protocolos estándar para event streaming agnóstico
- **CloudEvents**: Specification for describing event data in common formats

**Eventual Consistency**: Modelo de consistencia donde el sistema alcanzará consistencia eventualmente, no inmediatamente.

## F

**Failover**: Capacidad de cambiar automáticamente a un sistema de respaldo cuando el principal falla.

**FluentValidation**: Librería .NET para construir reglas de validación de manera fluida y expresiva.

## I

**Idempotencia**: Propiedad que garantiza que múltiples ejecuciones de una operación produzcan el mismo resultado.

**Infrastructure as Code (IaC)**: Gestión de infraestructura a través de archivos de configuración legibles por máquina.

## J

**JWT**: JSON Web Token - Estándar para tokens de acceso seguros basados en JSON.

## K

**Kafka**: Plataforma distribuida de streaming para manejo de eventos en tiempo real y mensajería asíncrona.

## L

**Liquid Template**: Motor de plantillas seguro y flexible usado para generar contenido dinámico.

**Load Balancer**: Componente que distribuye tráfico entre múltiples instancias de servicio.

## M

**Mapster**: Librería .NET para mapeo de objetos de alto rendimiento entre DTOs.

**Multi-AZ**: Alta disponibilidad en varias zonas geográficas para tolerancia a fallos.

**Multi-país**: Soporte para operación en varios países con configuraciones regionales específicas.

**Multi-tenant**: Capacidad de servir a múltiples clientes con aislamiento seguro de datos.

**MTBF**: Mean Time Between Failures - Tiempo promedio entre fallos del sistema.

**MTTR**: Mean Time To Recovery - Tiempo promedio para recuperarse de un fallo.

## O

**OAuth2**: Framework de autorización que permite acceso limitado a recursos sin exponer credenciales.

**OpenAPI**: Especificación para describir APIs REST de manera estándar.

**Opt-in/Opt-out**: Mecanismos para permitir/denegar explícitamente el envío de comunicaciones.

## P

**Processor**: Servicio que consume y procesa mensajes de notificación desde colas.

**Provider**: Servicio externo que proporciona capacidades específicas (envío de emails, SMS, etc.).

**PostgreSQL**: Sistema de gestión de base de datos relacional de código abierto.

## Q

**Queue**: Estructura de datos FIFO usada para comunicación asíncrona entre componentes.

## R

**Rate Limiting**: Técnica para controlar la frecuencia de solicitudes para prevenir abuso.

**RBAC**: Control de acceso basado en roles para autorización granular.

**Redis**: Base de datos en memoria usada para caché y almacenamiento de sesiones.

**Retry Policy**: Estrategia para reintentar operaciones fallidas con reglas específicas.

**RTO**: Recovery Time Objective - Tiempo máximo aceptable para restaurar servicio tras incidente.

**RPO**: Recovery Point Objective - Cantidad máxima de datos que se puede perder tras incidente.

## S

**S3**: Servicio de almacenamiento de objetos de AWS para archivos y adjuntos.

**Scheduler**: Servicio que programa envíos futuros de notificaciones.

**Serilog**: Librería de logging estructurado para .NET que facilita análisis y monitoreo.

**SLA**: Service Level Agreement - Acuerdo que define niveles de servicio esperados.

**SNS**: Simple Notification Service - Servicio de notificaciones de AWS.

**SQS**: Simple Queue Service - Servicio de colas de AWS.

**Structured Logging**: Práctica de generar logs en formato estructurado para mejor análisis.

## T

**Template Engine**: Componente que combina plantillas con datos para generar contenido final.

**Tenant**: Cliente o organización individual en un sistema multi-tenant.

**Throughput**: Cantidad de transacciones o operaciones procesadas por unidad de tiempo.

**TLS**: Transport Layer Security - Protocolo criptográfico para comunicaciones seguras.

## W

**Webhook**: Método para que aplicaciones proporcionen información en tiempo real a otras aplicaciones.

**WhatsApp Business API**: API oficial de Meta para envío de mensajes comerciales por WhatsApp.

**Worker**: Proceso que envía notificaciones por canal específico (email, SMS, push, WhatsApp).

## Y

**YARP**: Yet Another Reverse Proxy - Proxy reverso de Microsoft para .NET usado como API Gateway.

## Conceptos de negocio

**Canal de notificación**: Medio por el cual se envía una notificación (email, SMS, push, WhatsApp).

**Plantilla**: Estructura predefinida para generar contenido de notificaciones con datos dinámicos.

**Proveedor de canal**: Servicio externo especializado en un tipo específico de notificación.

**Tenant**: Organización cliente que usa el sistema de notificaciones con datos aislados.

**Territorio**: Región geográfica con regulaciones y configuraciones específicas.

**Trazabilidad**: Capacidad de seguir el ciclo completo de una notificación desde solicitud hasta entrega.
