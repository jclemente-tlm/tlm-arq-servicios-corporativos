# 12. Glosario

## A

**API Gateway**: Punto de entrada unificado que maneja todas las solicitudes de clientes y las enruta a los microservicios apropiados.

**Audit Trail**: Registro cronológico de actividades del sistema que permite rastrear operaciones y cambios para cumplimiento y debugging.

**Auto-scaling**: Capacidad de aumentar o disminuir automáticamente recursos computacionales basado en métricas de carga.

## B

**Backoff Exponencial**: Estrategia de retry que incrementa exponencialmente el tiempo de espera entre reintentos para evitar sobrecarga.

**Bulk Operations**: Operaciones que procesan múltiples elementos en una sola transacción para optimizar performance.

## C

**Circuit Breaker**: Patrón que previene llamadas a servicios que están fallando, permitiendo recuperación automática.

**CI/CD**: Integración y despliegue continuo - Prácticas para automatizar testing y deployment.

**Clean Architecture**: Patrón de organización modular y desacoplada que separa responsabilidades por capas.

**CQRS**: Command Query Responsibility Segregation - Patrón que separa operaciones de lectura y escritura.

**Consumer Lag**: Diferencia entre mensajes producidos y consumidos en una cola, indicador de performance en Kafka.

## D

**DDD**: Domain Driven Design - Enfoque de desarrollo centrado en el dominio del negocio.

**Dead Letter Queue (DLQ)**: Cola especial donde se almacenan mensajes que no pudieron ser procesados después de múltiples reintentos.

**DTO**: Data Transfer Object - Objeto usado para transferir datos entre capas o servicios.

## E

**Event Sourcing**: Patrón que almacena cambios de estado como secuencia de eventos en lugar del estado actual.

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
