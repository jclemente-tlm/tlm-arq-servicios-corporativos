# ADR-011: Monitoreo y observabilidad centralizada

## ✅ ESTADO

Aceptada – Julio 2025

---

## 🗺️ CONTEXTO

Se requiere monitoreo centralizado y observabilidad de todos los servicios y `microservicios` para garantizar disponibilidad, detectar incidentes y facilitar troubleshooting.

Las alternativas evaluadas fueron:

- **[Prometheus](https://prometheus.io/)** + **[Grafana](https://grafana.com/)** (`open source`)
- **[AWS CloudWatch](https://aws.amazon.com/cloudwatch/)** (servicio gestionado de `AWS`)
- **[ELK Stack](https://www.elastic.co/what-is/elk-stack)** (`Elasticsearch`, `Logstash`, `Kibana`)
- **[Datadog](https://www.datadoghq.com/)** (`SaaS`, observabilidad)
- **[New Relic](https://newrelic.com/)** (`SaaS`, observabilidad)

### Comparativa de alternativas

| Criterio                | CloudWatch | Prometheus/Grafana | ELK Stack | Datadog | New Relic |
|------------------------|------------|--------------------|-----------|---------|-----------|
| Agnosticismo           | Bajo (lock-in `AWS`) | Alto (`open source`, `multi-cloud`) | Alto (`open source`, `multi-cloud`) | Alto (`SaaS`, multi-cloud) | Alto (`SaaS`, multi-cloud) |
| Integración AWS        | Nativa     | Parcial            | Parcial   | Parcial | Parcial   |
| Escalabilidad          | Alta       | Media              | Media     | Alta    | Alta      |
| Costos                 | Pago por uso | Infra propia      | Infra propia| Pago por uso | Pago por uso |
| Alertas                | Sí         | Sí                 | Sí        | Sí      | Sí        |
| Dashboards             | Sí         | Sí                 | Sí        | Sí      | Sí        |
| Operación              | Gestionada por proveedor | Gestionada por el equipo | Gestionada por el equipo | Gestionada por proveedor | Gestionada por proveedor |

### Comparativa de costos estimados (2025)

| Solución        | Costo mensual base* | Costos adicionales | Infraestructura propia |
|-----------------|---------------------|--------------------|-----------------------|
| `CloudWatch`      | ~US$0.30/GB logs + ~US$0.10/alarma/mes | Dashboards, logs   | No                    |
| `Prometheus`/`Grafana` | ~US$20/mes (VM pequeña) | Mantenimiento, soporte | Sí                    |
| `ELK Stack`       | ~US$30/mes (VM pequeña) | Mantenimiento, soporte | Sí                    |
| `Datadog`         | ~US$15/mes (básico) | Por uso (métricas, logs) | No                    |
| `New Relic`       | ~US$99/mes (básico) | Por uso (métricas, logs) | No                    |

*Precios aproximados, sujetos a variación según región, volumen y configuración. `CloudWatch` escala según uso, `Prometheus`/`ELK` requieren operación propia.

### Agnosticismo, lock-in y mitigación

- **Lock-in:** `CloudWatch` implica dependencia de `AWS`, mientras que `Prometheus`/`Grafana`, `ELK Stack`, `Datadog` y `New Relic` pueden desplegarse en cualquier infraestructura.
- **Mitigación:** El uso de métricas y logs estándar permite migrar entre soluciones con esfuerzo de integración.

---

## ✔️ DECISIÓN

Se adopta **[AWS CloudWatch](https://aws.amazon.com/cloudwatch/)** como solución principal de monitoreo y observabilidad para los servicios desplegados en `AWS`, complementado con **[Prometheus](https://prometheus.io/)**/**[Grafana](https://grafana.com/)** para métricas personalizadas cuando sea necesario.

## Justificación

- Integración nativa con servicios `AWS` como `ECS`, `Lambda`, `RDS`, `SQS`, etc.
- Alertas, dashboards y logs centralizados.
- Escalabilidad y alta disponibilidad gestionada.
- Reducción de complejidad operativa.
- Cumplimiento de estándares de seguridad y auditoría.
- Permite segmentar métricas, alertas y dashboards por `tenant` y `país`, facilitando la operación y el soporte en entornos `multi-tenant` y `multi-país`.
- Posibilidad de extender con `Prometheus`/`Grafana` para métricas custom.

## Alternativas descartadas

- **[Prometheus](https://prometheus.io/)**/**[Grafana](https://grafana.com/)**: Mayor complejidad operativa, requiere gestión de infraestructura propia, despliegue de `exporters` y mantenimiento de `dashboards` personalizados.
- **[ELK Stack](https://www.elastic.co/what-is/elk-stack)** (`Elasticsearch`, `Logstash`, `Kibana`): Orientado principalmente a logs, mayor complejidad y costos, requiere integración adicional para métricas y visualización avanzada.
- **[Datadog](https://www.datadoghq.com/)** y **[New Relic](https://newrelic.com/)**: Soluciones SaaS potentes y agnósticas, pero con costos por volumen y lock-in en la plataforma, útiles para escenarios multi-cloud o cuando se requiere observabilidad avanzada sin operar infraestructura propia.

---

## ⚠️ CONSECUENCIAS

- Todos los servicios deben enviar métricas y logs a `CloudWatch`.
- Se recomienda estandarizar dashboards y alertas.

---

## 📚 REFERENCIAS

- [AWS CloudWatch](https://aws.amazon.com/cloudwatch/)
- [Prometheus](https://prometheus.io/)
- [Grafana](https://grafana.com/)
- [Arc42: Decisiones de arquitectura](https://arc42.org/decision/)
