# Índice de Documentación - Servicios Corporativos

## 📖 Documentación Principal

| Documento | Descripción | Audiencia | Estado |
|-----------|-------------|-----------|--------|
| **[Resumen Ejecutivo](executive-summary.md)** | Visión estratégica, beneficios empresariales y roadmap | Ejecutivos, Product Owners | ✅ Completo |
| **[Documentación Arc42](architecture-documentation-arc42.md)** | Arquitectura completa según metodología Arc42 | Arquitectos, Desarrolladores | ✅ Completo |
| **[Decisiones Arquitectónicas](adrs/)** | 20 ADRs con análisis robusto, criterios ponderados y TCO | Equipo técnico | ✅ Completo |

## 🏗️ Arquitectura por Sistema

### Servicios Core
| Sistema | Documentación | API Reference | Estado |
|---------|---------------|---------------|--------|
| **[API Gateway](api-gateway/)** | Arquitectura YARP, middleware, resiliencia | [API Docs](api/api-gateway.md) | ✅ Documentado |
| **[Sistema de Identidad](servicio-identidad/)** | Keycloak, OAuth2, multi-tenancy | [API Docs](api/identity-api.md) | ✅ Documentado |
| **[Notificaciones](servicio-notificacion/)** | Multicanal, plantillas, programación | [API Docs](api/notification-api.md) | ✅ Documentado |
| **[Track & Trace](servicio-track-trace/)** | CQRS, eventos, trazabilidad | [API Docs](api/track-trace-api.md) | ✅ Documentado |
| **[SITA Messaging](servicio-mensajeria-sita/)** | Generación archivos, partners | [Integration Docs](servicio-mensajeria-sita/partners.md) | ✅ Documentado |

## 📊 Diagramas de Arquitectura

### Modelo C4 - Vistas Principales
- **[Contexto General](../diagrams/corporate_services.png)** - Visión de alto nivel del sistema
- **[API Gateway](../diagrams/api_gateway_yarp.png)** - Componentes y flujos del gateway
- **[Sistema de Notificaciones](../diagrams/notification_system.png)** - Arquitectura completa de notificaciones
- **[Observabilidad](../diagrams/observability_overview.png)** - Logging, métricas y tracing

### Vistas de Despliegue
- **[Infraestructura AWS](../diagrams/notification_system_deployment.png)** - Despliegue en contenedores
- **[Monitoreo de Estado](../diagrams/health_monitoring.png)** - Verificaciones de estado y cortocircuitos
- **[Rastreo Distribuido](../diagrams/distributed_tracing.png)** - Trazabilidad entre servicios

## 🔒 Seguridad y Compliance

### Documentación de Seguridad
- **[Estrategia de Seguridad](security/)** - OAuth2, JWT, cifrado, RBAC
- **[Cumplimiento](compliance/)** - Auditoría, GDPR, regulaciones aeroportuarias
- **[Incident Response](incident-response/)** - Procedimientos de respuesta a incidentes

## 🛠️ Guías Operacionales

### Desarrollo
- **[Setup de Desarrollo](development/)** - Configuración local, coding standards
- **[Testing Guidelines](testing/)** - Unit, integration, E2E testing
- **[API Guidelines](api/)** - Estándares para APIs REST

### DevOps
- **[Deployment](deployment/)** - CI/CD, blue-green deployments, environments
- **[Monitoring](monitoring/)** - Prometheus, Grafana, Serilog, alertas
- **[Performance](performance/)** - Load testing, optimization, scaling

## 📋 Procesos y Metodologías

### Arquitectura
- **[Proceso ADR](processes/adr-process.md)** - Gestión de decisiones arquitectónicas
- **[C4 Model Guidelines](processes/c4-guidelines.md)** - Estándares de diagramación
- **[Architecture Reviews](processes/architecture-review.md)** - Proceso de revisión

### Desarrollo
- **[Development Workflow](processes/development-workflow.md)** - GitFlow, PR, code review
- **[Change Management](processes/change-management.md)** - Gestión de cambios
- **[Gestión de Configuración](configuration/)** - Configuración dinámica

---

## 📈 Estado del Proyecto

### Documentación Completada ✅
- Arquitectura C4 completa en Structurizr DSL
- Documentación Arc42 con 12 secciones
- Resumen ejecutivo para stakeholders
- Decisiones arquitectónicas principales (ADRs)

### En Progreso 🔄
- Documentación detallada por sistema
- API specifications (OpenAPI)
- Runbooks operacionales
- Testing guidelines

### Próximos Pasos 📋
- Distributed tracing implementation (Q4 2025)
- Performance optimization documentation
- Disaster recovery procedures
- Multi-cloud strategy evaluation

## 🏷️ Metadatos

**Versión:** 1.0
**Metodología:** Arc42
**Estándar de diagramas:** C4 Model
**Última actualización:** Agosto 2025
**Responsable:** Arquitectura de Software - jclemente-tlm

## 📞 Contacto y Soporte

- **Arquitectura:** jclemente-tlm
- **Slack:** #arquitectura-servicios-corporativos
- **Email:** arquitectura@talma.com.pe
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
