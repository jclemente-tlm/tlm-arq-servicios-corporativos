# ADRs Comunes (Architectural Decision Records)

Este directorio contiene las decisiones arquitectónicas que aplican de forma transversal a todos los servicios y sistemas del ecosistema de servicios corporativos.

## ¿Cómo usar este directorio?
- Cada ADR aquí documentado debe ser referenciado desde la documentación de cada microservicio o sistema cuando aplique.
- Si una decisión es específica de un servicio, debe residir en la carpeta `adrs` de ese servicio.
- Mantén este directorio actualizado y revisa periódicamente la vigencia de las decisiones.

## Índice de ADRs comunes

- [ADR-001: Selección de AWS Secrets Manager para gestión de secretos](./adr-001-gestion-secrets-manager.md)
- [ADR-002: Uso de SNS + SQS en vez de RabbitMQ para mensajería](./adr-002-sqs-sns.md)
- [ADR-003: Uso de ECS Fargate para despliegue de microservicios](./adr-003-ecs-fargate.md)
- [ADR-004: API Gateway con YARP](./adr-004-api-gateway-yarp.md)
- [ADR-005: Uso de Dead Letter Queue (DLQ)](./adr-005-dlq.md)
- [ADR-006: Modularidad basada en microservicios vs. arquitectura monolítica](./adr-006-modularidad.md)
- [ADR-007: Configuración gestionada por scripts](./adr-007-configuracion-scripts.md)
- [ADR-008: Autenticaciones](./adr-008-autenticaciones.md)
- [ADR-009: Uso de PostgreSQL como base de datos estándar](./adr-009-postgresql-standard.md)
- [ADR-010: Logging estructurado con Serilog](./adr-010-logging-serilog.md)
- [ADR-011: Monitoreo y observabilidad centralizada](./adr-011-monitoreo-observabilidad.md)
- [ADR-012: Gestión de trazas distribuidas (Distributed Tracing)](./adr-012-tracing-distribuido.md)
- [ADR-013: Estrategia de versionado de APIs](./adr-013-versionado-apis.md)
- [ADR-014: Automatización de despliegues (CI/CD) con GitHub Actions](./adr-014-ci-cd-github-actions.md)
- [ADR-015: Estandarización de Infraestructura como Código (IaC) con Terraform](./adr-015-iac-terraform.md)

_Agrega aquí los ADRs comunes que vayas generando._
