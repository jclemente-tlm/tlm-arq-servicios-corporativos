# ADR-002: Uso de SNS + SQS en vez de RabbitMQ para mensajería

## Estado

Aceptada – Julio 2025

## Contexto

Se requiere una solución de mensajería desacoplada, escalable y gestionada para fan-out y colas de procesamiento en sistemas distribuidos y microservicios. Las alternativas evaluadas fueron:

- **SNS + SQS (AWS)**
- **RabbitMQ (auto-gestionado o en cloud)**

## Decisión

Se selecciona **SNS + SQS** como solución de mensajería estándar para los sistemas y microservicios que requieran integración basada en eventos.

## Justificación

- Servicio gestionado y nativo en AWS, sin necesidad de administración de servidores ni mantenimiento.
- Escalabilidad automática y alta disponibilidad garantizada por AWS.
- Integración directa con otros servicios AWS (Lambda, IAM, CloudWatch, etc.).
- Fan-out nativo: SNS permite publicar a múltiples colas SQS y otros endpoints.
- Seguridad y control de acceso: Integración con IAM y cifrado en tránsito/reposo.
- Costos operativos reducidos: Pago por uso, sin infraestructura dedicada.
- Monitoreo y auditoría: Integración con CloudWatch y CloudTrail.
- Menor complejidad operativa: RabbitMQ requiere gestión de clúster, actualizaciones y monitoreo adicional.

### Comparativa de alternativas

| Criterio                | SNS + SQS (AWS) | RabbitMQ gestionado | RabbitMQ auto-gestionado |
|------------------------|-----------------|---------------------|--------------------------|
| Agnosticismo           | Bajo (lock-in AWS) | Medio (cloud lock-in, portable) | Alto (multi-cloud, on-premises) |
| Operación              | Gestionado      | Gestionado          | Autogestionado           |
| Escalabilidad          | Automática      | Manual/limitada     | Manual                   |
| Integración AWS        | Nativa          | Parcial             | Parcial                  |
| Fan-out                | Nativo          | Requiere configuración | Requiere configuración |
| Seguridad/Compliance   | IAM, cifrado    | SSL, plugins        | SSL, plugins             |
| Costos                 | Pago por uso    | Pago por instancia  | Infraestructura propia    |
| Mantenimiento          | Nulo            | Medio               | Alto                     |
| Alta disponibilidad    | Garantizada     | Requiere configuración | Requiere configuración |
| Auditoría/Monitoreo    | CloudWatch/CloudTrail | Plugins externos | Plugins externos         |
| Latencia               | Baja            | Variable            | Variable                 |

### Comparativa de costos estimados (2025)

| Solución                        | Costo mensual base* | Costo por millón de mensajes | Infraestructura propia |
|---------------------------------|---------------------|-----------------------------|-----------------------|
| SNS + SQS (AWS)                 | US$0.90             | US$0.90                     | No                    |
| RabbitMQ gestionado (AWS MQ)    | ~US$21              | Incluido en instancia        | No                    |
| RabbitMQ auto-gestionado        | ~US$19              | Incluido en instancia        | Sí                    |

*Precios aproximados, sujetos a variación según región, volumen y configuración. RabbitMQ gestionado y auto-gestionado pueden requerir costos adicionales por alta disponibilidad, soporte y operación.

### Agnosticismo, lock-in y mitigación

- **Lock-in:** SNS + SQS implica dependencia de AWS, pero se justifica por la integración nativa, menor latencia y operación simplificada en un entorno 100% AWS.
- **Mitigación:** El uso de interfaces desacopladas y patrones de mensajería estándar (pub/sub, colas) permite migrar a otras soluciones si el contexto cambia. RabbitMQ es más agnóstico, pero requiere mayor esfuerzo de integración y operación.
- **Evidencia:** En escenarios multi-cloud o on-premises, RabbitMQ puede ser preferible por su portabilidad, pero a costa de mayor complejidad y costos operativos.

## Alternativas descartadas

- **RabbitMQ**: Requiere despliegue, gestión y monitoreo propio, mayor complejidad y menor integración nativa con AWS.

## Implicaciones

- Todo el flujo de mensajería y fan-out se implementa con SNS y SQS.
- El sistema se mantiene alineado con la estrategia cloud-native y serverless.

## Referencias

- [AWS SNS Docs](https://docs.aws.amazon.com/sns/latest/dg/welcome.html)
- [AWS SQS Docs](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/welcome.html)
- [RabbitMQ Docs](https://www.rabbitmq.com/documentation.html)
- [Amazon MQ (RabbitMQ gestionado)](https://docs.aws.amazon.com/amazon-mq/latest/developer-guide/what-is-amazon-mq.html)
- [RabbitMQ vs SQS](https://aws.amazon.com/compare/the-difference-between-amazon-sqs-and-rabbitmq/)
- [Arc42: Decisiones de arquitectura](https://arc42.org/decision/)
