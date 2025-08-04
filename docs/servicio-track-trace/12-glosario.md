# 12. Glosario

## A

**Aggregate**: Entidad raíz en DDD que mantiene consistencia transaccional y es la unidad de persistencia en Event Sourcing.

**Append-Only**: Característica del Event Store donde solo se pueden agregar eventos, nunca modificar o eliminar.

**At-least-once delivery**: Garantía de entrega donde un mensaje puede ser entregado múltiples veces pero nunca perdido.

## C

**Command**: Operación que representa una intención de cambiar el estado del sistema en el patrón CQRS.

**Concurrency Control**: Mecanismo para manejar acceso concurrente a datos, típicamente implementado como optimistic locking.

**CQRS**: Command Query Responsibility Segregation - Patrón que separa operaciones de lectura y escritura.

**Correlation ID**: Identificador único que permite rastrear una operación a través de múltiples servicios.

## D

**Domain Event**: Evento que representa algo significativo que ocurrió en el dominio del negocio.

**DDD**: Domain-Driven Design - Enfoque de desarrollo centrado en el dominio del negocio.

**Dead Letter Queue**: Cola especial para mensajes que no pudieron ser procesados exitosamente.

## E

**Event**: Hecho inmutable que representa un cambio de estado en el sistema.

**Event Handler**: Componente que procesa eventos específicos para actualizar read models o ejecutar side effects.

**Event Sourcing**: Patrón donde el estado se deriva de una secuencia de eventos inmutables.

**Event Store**: Base de datos especializada en almacenar eventos de forma inmutable y ordenada.

**Event Stream**: Secuencia ordenada de eventos para una entidad específica.

**Eventual Consistency**: Modelo donde el sistema alcanzará consistencia eventualmente, no inmediatamente.

## I

**Idempotence**: Propiedad donde múltiples ejecuciones de una operación producen el mismo resultado.

**Integration Event**: Evento publicado para comunicar cambios a otros bounded contexts o servicios.

## K

**Kafka**: Plataforma distribuida de streaming para manejo de eventos en tiempo real.

## O

**Optimistic Concurrency Control**: Técnica que asume que las operaciones concurrentes raramente entran en conflicto.

**Operational Event**: Evento que captura actividades operacionales del negocio para propósitos de trazabilidad.

## P

**Projection**: Vista materializada generada a partir de eventos para optimizar consultas específicas.

**PostgreSQL**: Sistema de gestión de base de datos relacional usado como Event Store.

## Q

**Query**: Operación que lee datos sin modificar el estado del sistema en el patrón CQRS.

**Query Model**: Modelo de datos optimizado para consultas, también conocido como read model.

## R

**Read Model**: Vista especializada de datos optimizada para casos de uso específicos de consulta.

**Replay**: Proceso de reproducir eventos históricos para reconstruir estado o generar nuevas proyecciones.

**Redis**: Base de datos en memoria utilizada para caching distribuido.

## S

**Saga**: Patrón para manejar transacciones distribuidas a través de múltiples agregados o servicios.

**Snapshot**: Estado capturado de un agregado en un momento específico para optimizar la reconstrucción.

**Stream**: Secuencia ordenada de eventos relacionados con una entidad específica.

**Strong Consistency**: Garantía de que todas las lecturas reciben la escritura más reciente.

## T

**Timeline**: Vista cronológica de eventos relacionados con una entidad específica.

**Tenant**: Organización cliente que usa el sistema con datos completamente aislados.

**Traceability**: Capacidad de rastrear el historial completo de cambios de una entidad.

## V

**Version**: Número incremental asociado a cada evento en un stream para control de concurrencia.

**Versioning**: Estrategia para evolucionar esquemas de eventos manteniendo compatibilidad.

## Conceptos de negocio específicos

**Entity Timeline**: Representación cronológica completa de todos los eventos relacionados con una entidad operacional específica.

**Operational Tracking**: Capacidad de seguimiento completo de actividades y cambios en procesos de negocio.

**Event Correlation**: Proceso de relacionar eventos que forman parte del mismo proceso de negocio.

**Audit Trail**: Rastro completo e inmutable de todas las actividades del sistema para propósitos de auditoría.

**Business Event**: Evento que tiene significado directo para el negocio y es relevante para stakeholders no técnicos.

**Performance Analytics**: Análisis de métricas derivadas de eventos operacionales para identificar tendencias y optimizaciones.

## Acrónimos técnicos

| Acrónimo | Significado | Contexto |
|----------|-------------|----------|
| ACID | Atomicity, Consistency, Isolation, Durability | Propiedades transaccionales |
| ADR | Architecture Decision Record | Documentación de decisiones |
| API | Application Programming Interface | Interfaz de servicios |
| CRUD | Create, Read, Update, Delete | Operaciones básicas |
| DDD | Domain-Driven Design | Metodología de diseño |
| ETL | Extract, Transform, Load | Procesamiento de datos |
| FIFO | First In, First Out | Orden de procesamiento |
| JSONB | JSON Binary | Tipo de dato PostgreSQL |
| JWT | JSON Web Token | Token de autenticación |
| KPI | Key Performance Indicator | Métrica de negocio |
| MTBF | Mean Time Between Failures | Métrica de confiabilidad |
| MTTR | Mean Time To Recovery | Métrica de recuperación |
| OLAP | Online Analytical Processing | Procesamiento analítico |
| OLTP | Online Transaction Processing | Procesamiento transaccional |
| REST | Representational State Transfer | Arquitectura de APIs |
| RPC | Remote Procedure Call | Llamada a procedimiento remoto |
| SLA | Service Level Agreement | Acuerdo de nivel de servicio |
| SQL | Structured Query Language | Lenguaje de consulta |
| TTL | Time To Live | Tiempo de vida de cache |
| UUID | Universally Unique Identifier | Identificador único global |

## Patrones y conceptos arquitectónicos

**Bounded Context**: Límite explícito dentro del cual un modelo de dominio es aplicable.

**Circuit Breaker**: Patrón que previene llamadas a servicios que están fallando.

**Command Handler**: Componente responsable de procesar un comando específico.

**Compensating Action**: Acción que deshace los efectos de una operación previa.

**Event Handler**: Componente que reacciona a eventos específicos.

**Message Bus**: Infraestructura para el intercambio asíncrono de mensajes.

**Query Handler**: Componente responsable de procesar una consulta específica.

**Repository**: Abstracción para acceso a datos que encapsula la lógica de persistencia.

**Unit of Work**: Patrón que mantiene una lista de objetos afectados por una transacción de negocio.
