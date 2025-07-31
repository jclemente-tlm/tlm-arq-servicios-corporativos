# ADR-005: Implementación de Dead Letter Queue (DLQ)

## Estado

Aceptada – Julio 2025

## Contexto

El sistema requiere trazabilidad y recuperación ante fallos en el procesamiento de mensajes de notificación. Las alternativas evaluadas fueron:

- **DLQ en AWS SQS**
- **Reintentos sin DLQ**

## Decisión

Se implementa **DLQ** en las colas de notificación para gestionar mensajes fallidos.

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

**Evidencia:**

- AWS, Mercado Libre y Nubank utilizan DLQ para garantizar trazabilidad y recuperación ante fallos en sistemas críticos.
- Reintentos sin DLQ solo se usan en sistemas donde la pérdida de mensajes no es relevante.

## Alternativas descartadas

- **Reintentos sin DLQ**: Mayor riesgo de pérdida de mensajes y menor trazabilidad.

## Implicaciones

- Los mensajes fallidos se almacenan en DLQ para análisis y recuperación.
- Se deben definir políticas de reprocesamiento y monitoreo.

## Referencias

- [AWS SQS DLQ](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-dead-letter-queues.html)
- [Arc42: Decisiones de arquitectura](https://arc42.org/decision/)
