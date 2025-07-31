# ADR-011: Monitoreo y observabilidad centralizada

## Estado

Aceptada – Julio 2025

## Contexto

Se requiere monitoreo centralizado y observabilidad de todos los servicios y microservicios para garantizar disponibilidad, detectar incidentes y facilitar troubleshooting. Las alternativas evaluadas fueron:

- Prometheus + Grafana (open source)
- AWS CloudWatch (gestionado)
- ELK Stack (Elasticsearch, Logstash, Kibana)

## Decisión

Se adopta **AWS CloudWatch** como solución principal de monitoreo y observabilidad para los servicios desplegados en AWS, complementado con Prometheus/Grafana para métricas personalizadas cuando sea necesario.

## Justificación
- Integración nativa con servicios AWS (ECS, Lambda, RDS, SQS, etc.).
- Alertas, dashboards y logs centralizados.
- Escalabilidad y alta disponibilidad gestionada.
- Reducción de complejidad operativa.
- Cumplimiento de estándares de seguridad y auditoría.
- Permite segmentar métricas, alertas y dashboards por tenant y país, facilitando la operación y el soporte en entornos multi-tenant y multi-país.
- Posibilidad de extender con Prometheus/Grafana para métricas custom.


### Comparativa de alternativas

| Criterio                | CloudWatch | Prometheus/Grafana | ELK Stack |
|------------------------|------------|--------------------|-----------|
| Agnosticismo           | Bajo (lock-in AWS) | Alto (open source, multi-cloud) | Alto (open source, multi-cloud) |
| Integración AWS        | Nativa     | Parcial            | Parcial   |
| Escalabilidad          | Alta       | Media              | Media     |
| Costos                 | Pago por uso | Infra propia      | Infra propia |
| Alertas                | Sí         | Sí                 | Sí        |
| Dashboards             | Sí         | Sí                 | Sí        |
| Operación              | Gestionada | Autogestionada     | Autogestionada |

### Comparativa de costos estimados (2025)

| Solución        | Costo mensual base* | Costos adicionales | Infraestructura propia |
|-----------------|---------------------|--------------------|-----------------------|
| CloudWatch      | ~US$0.30/GB logs + ~US$0.10/alarma/mes | Dashboards, logs   | No                    |
| Prometheus/Grafana | ~US$20/mes (VM pequeña) | Mantenimiento, soporte | Sí                    |
| ELK Stack       | ~US$30/mes (VM pequeña) | Mantenimiento, soporte | Sí                    |

*Precios aproximados, sujetos a variación según región, volumen y configuración. CloudWatch escala según uso, Prometheus/ELK requieren operación propia.

### Agnosticismo, lock-in y mitigación

- **Lock-in:** CloudWatch implica dependencia de AWS, mientras que Prometheus/Grafana y ELK Stack pueden desplegarse en cualquier infraestructura.
- **Mitigación:** El uso de métricas y logs estándar permite migrar entre soluciones con esfuerzo de integración.

## Alternativas descartadas
- Prometheus/Grafana: Mayor complejidad operativa, requiere gestión de infraestructura.
- ELK Stack: Orientado a logs, mayor complejidad y costos.

## Implicaciones
- Todos los servicios deben enviar métricas y logs a CloudWatch.
- Se recomienda estandarizar dashboards y alertas.

## Referencias
- [AWS CloudWatch](https://aws.amazon.com/cloudwatch/)
- [Prometheus](https://prometheus.io/)
- [Grafana](https://grafana.com/)
- [Arc42: Decisiones de arquitectura](https://arc42.org/decision/)
