# Arquitectura de Soluciones Corporativas

Documentación técnica y decisiones arquitectónicas de los servicios corporativos.

## Documentación principal

| Documento        | Descripción breve                                                                 | Estado     | Aprobación requerida |
|------------------|----------------------------------------------------------------------------------|------------|----------------------|
| [API Gateway](./api-gateway/01-introduccion-y-objetivos.md)         | Centraliza tráfico, seguridad, balanceo, integración con microservicios y soporte multi-tenant/multipaís. | Borrador   | Arquitecto           |
| [Identidad](./servicio-identidad/01-introduccion-y-objetivos.md)    | Gestión de autenticación, autorización y perfiles de usuario multi-tenant/multipaís.                      | Borrador   | Arquitecto           |
| [Mensajería SITA](./servicio-mensajeria-sita/01-introduccion-y-objetivos.md) | Envío y recepción de mensajes SITA para aerolíneas y sistemas asociados.                                 | Borrador   | Arquitecto           |
| [Track & Trace](./servicio-track-trace/01-introduccion-y-objetivos.md) | Seguimiento y trazabilidad de eventos corporativos.                                                      | Borrador   | Arquitecto           |
| [Notificación](./servicio-notificacion/01-introduccion-y-objetivos.md) | Plataforma multicanal para envío de notificaciones (email, SMS, WhatsApp, push, in-app).                 | Borrador   | Arquitecto           |

## Decisiones arquitectónicas (ADR)

| ADR/Título | Descripción breve | Estado | Aprobación requerida |
|------------|-------------------|--------|----------------------|
| [ADR-001: Gestión de Secrets Manager](./adrs/adr-001-gestion-secrets-manager.md) | Selección de AWS Secrets Manager para gestión centralizada de secretos. | Aceptada | Equipo |
| [ADR-002: SQS y SNS](./adrs/adr-002-sqs-sns.md) | Uso de SNS+SQS en vez de RabbitMQ para mensajería desacoplada y escalable. | Aceptada | Equipo |
| [ADR-003: ECS Fargate](./adrs/adr-003-ecs-fargate.md) | Despliegue de microservicios en AWS ECS Fargate (serverless containers). | Aceptada | Equipo |
| [ADR-004: API Gateway y YARP](./adrs/adr-004-api-gateway-yarp.md) | Exposición de APIs con YARP como reverse proxy flexible/extensible. | Aceptada | Equipo |
| [ADR-005: DLQ](./adrs/adr-005-dlq.md) | Uso de Dead Letter Queue para manejo de mensajes fallidos en colas. | Aceptada | Equipo |
| [ADR-006: Modularidad](./adrs/adr-006-modularidad.md) | Separación de dominios en microservicios vs. arquitectura monolítica. | Aceptada | Arquitecto |
| [ADR-007: Configuración por scripts](./adrs/adr-007-configuracion-scripts.md) | Gestión de configuración auditable y reproducible mediante scripts. | Aceptada | Arquitecto |
| [ADR-008: Autenticaciones](./adrs/adr-008-autenticaciones.md) | Mecanismo de autenticación seguro y centralizado (Keycloak, Auth0, etc.). | Aceptada | Equipo |
| [ADR-009: PostgreSQL estándar](./adrs/adr-009-postgresql-standard.md) | Uso de PostgreSQL como base de datos relacional estándar. | Aceptada | Equipo |
| [ADR-010: Logging con Serilog](./adrs/adr-010-logging-serilog.md) | Logging estructurado y flexible con Serilog para .NET. | Aceptada | Arquitecto |
| [ADR-011: Monitoreo y observabilidad](./adrs/adr-011-monitoreo-observabilidad.md) | Observabilidad centralizada con Prometheus, Grafana, CloudWatch, etc. | Aceptada | Equipo |
| [ADR-012: Tracing distribuido](./adrs/adr-012-tracing-distribuido.md) | Gestión de trazas distribuidas con OpenTelemetry, Jaeger, AWS X-Ray. | Aceptada | Equipo |
| [ADR-013: Versionado de APIs](./adrs/adr-013-versionado-apis.md) | Estrategia de versionado de APIs para compatibilidad y evolución controlada. | Aceptada | Arquitecto |
| [ADR-014: CI/CD con GitHub Actions](./adrs/adr-014-ci-cd-github-actions.md) | Automatización de pruebas, builds y despliegues con GitHub Actions. | Aceptada | Equipo |
| [ADR-015: IaC con Terraform](./adrs/adr-015-iac-terraform.md) | Estandarización de infraestructura como código con Terraform. | Aceptada | Equipo |
