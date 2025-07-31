# ADR-002: Uso de SNS + SQS en vez de RabbitMQ para mensajería

## Estado

Aceptada – Julio 2025

## Contexto

El sistema de notificaciones requiere una solución de mensajería desacoplada, escalable y gestionada para fan-out y colas de procesamiento. Las alternativas evaluadas fueron:

- **SNS + SQS (AWS)**
- **RabbitMQ (auto-gestionado o en cloud)**

## Decisión

Se selecciona **SNS + SQS** como solución de mensajería para el sistema de notificaciones.

## Justificación

- Servicio gestionado y nativo en AWS, sin necesidad de administración de servidores ni mantenimiento.
- Escalabilidad automática y alta disponibilidad garantizada por AWS.
- Integración directa con otros servicios AWS (Lambda, IAM, CloudWatch, etc.).
- Fan-out nativo: SNS permite publicar a múltiples colas SQS y otros endpoints.
- Seguridad y control de acceso: Integración con IAM y cifrado en tránsito/reposo.
- Costos operativos reducidos: Pago por uso, sin infraestructura dedicada.
- Monitoreo y auditoría: Integración con CloudWatch y CloudTrail.
- Menor complejidad operativa: RabbitMQ requiere gestión de clúster, actualizaciones y monitoreo adicional.

## Alternativas descartadas

- **RabbitMQ**: Requiere despliegue, gestión y monitoreo propio, mayor complejidad y menor integración nativa con AWS.

## Implicaciones

- Todo el flujo de notificaciones y fan-out se implementa con SNS y SQS.
- El sistema se mantiene alineado con la estrategia cloud-native y serverless.

## Referencias

- [AWS SNS](https://aws.amazon.com/sns/)
- [AWS SQS](https://aws.amazon.com/sqs/)
- [RabbitMQ vs SQS](https://aws.amazon.com/compare/the-difference-between-amazon-sqs-and-rabbitmq/)
