# 9. Decisiones de arquitectura

| Título | Contexto | Decisión | Estado | Consecuencias | Detalle/ADR |
|--------|----------|----------|--------|---------------|-------------|
| Gestión de secretos | Seguridad y cumplimiento | Usar AWS Secrets Manager | Aceptada | Centralización, auditoría y rotación automática | [ADR-001 Gestión Secrets Manager](adr/adr-001-gestion-secrets-manager.md) |
| Uso de SQS/SNS | Necesidad de desacoplar y escalar | Adoptar colas gestionadas | Aceptada | Escalabilidad y tolerancia a fallos | [ADR-002 SQS+SNS](adr/adr-002-sqs-sns.md) |
| Serverless (ECS Fargate) | Optimizar costos y operación | Usar ECS Fargate | Aceptada | Menor mantenimiento, escalabilidad | [ADR-003 ECS Fargate](adr/adr-003-ecs-fargate.md) |
| API Gateway YARP | Unificar entrada y seguridad | Usar YARP | Aceptada | Centralización y flexibilidad | [ADR-004 API Gateway YARP](adr/adr-004-api-gateway-yarp.md) |
| DLQ | Manejo de fallos | Implementar DLQ en colas | Aceptada | Trazabilidad y recuperación | [ADR-005 DLQ](adr/adr-005-dlq.md) |
| Modularidad | Evolución y mantenibilidad | Separar por canal y función | Aceptada | Facilidad de cambios y extensiones | [ADR-006 Modularidad](adr/adr-006-modularidad.md) |
| Configuración por scripts | Baja frecuencia de cambios en tenants, canales y plantillas | Gestionar configuración mediante scripts (SQL, CLI, etc.) en vez de APIs | Aceptada | Menor costo y mantenimiento, requiere acceso controlado y personal técnico. Si la frecuencia de cambios aumenta o se requiere integración, se puede reconsiderar exponer una API. | [ADR-007 Configuración por scripts](adr/adr-007-configuracion-scripts.md) |
