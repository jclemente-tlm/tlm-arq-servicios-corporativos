# ADR-012: Gestión de trazas distribuidas ([Trazado Distribuido](https://opentelemetry.io/docs/concepts/distributed-tracing/))

## ✅ ESTADO

Aceptada – Julio 2025

---

## 🗺️ CONTEXTO

Para diagnosticar problemas y analizar el flujo de peticiones entre `microservicios`, se requiere trazabilidad distribuida.

Las alternativas evaluadas fueron:

- [AWS X-Ray](https://aws.amazon.com/xray/)
- [OpenTelemetry](https://opentelemetry.io/) + [Jaeger](https://www.jaegertracing.io/)
- Sin tracing

### Comparativa de alternativas

| Criterio                                              | AWS X-Ray | OpenTelemetry/Jaeger | Sin tracing |
|-------------------------------------------------------|-----------|----------------------|-------------|
| Facilidad de integración con frameworks/SDKs modernos | Muy alta (nativo AWS, SDKs .NET, Java, etc.) | Alta (SDKs multi-lenguaje, integración manual) | N/A         |
| Soporte para estándares abiertos (OpenTelemetry, W3C) | Parcial (exporter, integración indirecta) | Total (OpenTelemetry, W3C Trace Context) | N/A         |
| Visualización y análisis de trazas (UI, dashboards)   | Alta (consola AWS, Service Map) | Alta (Jaeger UI, Grafana Tempo, etc.) | N/A         |
| Automatización y DevOps (APIs, IaC, exporters)        | Alta (CloudFormation, APIs) | Alta (exporters, Helm, IaC) | N/A         |
| Comunidad y soporte                                  | Alta (AWS) | Muy alta (OSS global) | N/A         |
| Performance y overhead en servicios productivos       | Bajo (gestionado) | Medio (depende de despliegue) | N/A         |
| Costos totales (licencia, operación, retención)       | Pago por uso | Infra propia | N/A         |
| Riesgo de lock-in y portabilidad de datos de trazas   | Alto (AWS) | Bajo (estándares abiertos) | N/A         |
| Facilidad de migración entre soluciones               | Media | Alta | N/A         |
| Licenciamiento                                        | Propietario | OSS | N/A |

### Comparativa de costos estimados (2025)

| Solución        | Costo mensual base* | Costos adicionales | Infraestructura propia |
|-----------------|---------------------|--------------------|-----------------------|
| `AWS X-Ray`       | ~US$5/mes por 1M segmentos | Dashboards, traces | No                    |
| `OpenTelemetry`/`Jaeger` | ~US$20/mes (VM pequeña) | Mantenimiento, soporte | Sí                    |

*Precios aproximados, sujetos a variación según región, volumen y configuración. `X-Ray` escala según uso, `OpenTelemetry`/`Jaeger` requieren operación propia.

### Agnosticismo, lock-in y mitigación

- **Lock-in:** `AWS X-Ray` implica dependencia de `AWS`, mientras que `OpenTelemetry`/`Jaeger` pueden desplegarse en cualquier infraestructura.
- **Mitigación:** El uso de estándares abiertos (`OpenTelemetry`) facilita la migración entre soluciones de tracing.

---

## ✔️ DECISIÓN

Se adopta **[AWS X-Ray](https://aws.amazon.com/xray/)** como solución principal de tracing distribuido para los servicios desplegados en `AWS`, con posibilidad de extender a [OpenTelemetry](https://opentelemetry.io/) para escenarios `multi-cloud`.

## Justificación

- Integración nativa con AWS Lambda, ECS, API Gateway, etc.
- Visualización de flujos y cuellos de botella.
- Soporte para correlación de logs y métricas.
- Reducción de complejidad operativa.
- Cumplimiento de estándares de seguridad y auditoría.

## Alternativas descartadas

- OpenTelemetry/Jaeger: Mayor complejidad operativa, útil para multi-cloud.
- Sin tracing: No permite diagnóstico eficiente.

---

## ⚠️ CONSECUENCIAS

- Todos los servicios deben propagar y reportar trazas a X-Ray.
- Se recomienda estandarizar el uso de IDs de correlación.

---

## 📚 REFERENCIAS

- [AWS X-Ray](https://aws.amazon.com/xray/)
- [OpenTelemetry](https://opentelemetry.io/)
- [Arc42: Decisiones de arquitectura](https://arc42.org/decision/)
