# ADR-005: Uso de Dead Letter Queue (DLQ)

## Estado

Aceptada – Julio 2025

## Contexto

Se requiere manejar mensajes fallidos o no procesados en colas de mensajería para evitar pérdida de información y facilitar la recuperación en cualquier sistema distribuido. Las alternativas evaluadas fueron:

- **DLQ en AWS SQS**
- **Reintentos sin DLQ**

## Decisión

Se implementarán Dead Letter Queues (DLQ) en las colas SQS utilizadas por los microservicios y sistemas que requieran resiliencia en el procesamiento de mensajes.

## Justificación

- Permite aislar y analizar mensajes que no pudieron procesarse.
- Facilita la recuperación y reprocesamiento manual o automatizado.
- Mejora la trazabilidad y auditoría de errores.
- Integración nativa con AWS SQS y CloudWatch.
- Reduce el riesgo de pérdida de información.

### Comparativa de alternativas

| Criterio                | DLQ en AWS SQS     | Reintentos sin DLQ |
|-------------------------|--------------------|--------------------|
| Trazabilidad            | Alta               | Baja               |
| Recuperación            | Manual/Automatizada| Limitada           |
| Auditoría               | Integrada (CloudWatch) | Limitada      |
| Riesgo de pérdida       | Bajo               | Alto               |
| Costo operativo         | Bajo (incluido en SQS) | Bajo              |
| Mantenimiento           | Bajo               | Bajo               |
| Ejemplos en la industria| AWS, Mercado Libre, Nubank | -           |

## Alternativas descartadas

- **Reintentos sin DLQ**: Mayor riesgo de pérdida de mensajes y menor trazabilidad.

## Implicaciones

- Los mensajes fallidos se almacenan en DLQ para análisis y recuperación.
- Se deben definir políticas de reprocesamiento y monitoreo.

## Referencias

- [AWS SQS DLQ](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-dead-letter-queues.html)
- [Arc42: Decisiones de arquitectura](https://arc42.org/decision/)
