# ADR-012: Gestión de trazas distribuidas (Distributed Tracing)

## Estado

Aceptada – Julio 2025

## Contexto

Para diagnosticar problemas y analizar el flujo de peticiones entre microservicios, se requiere trazabilidad distribuida. Las alternativas evaluadas fueron:

- AWS X-Ray
- OpenTelemetry + Jaeger
- Sin tracing

## Decisión

Se adopta **AWS X-Ray** como solución principal de tracing distribuido para los servicios desplegados en AWS, con posibilidad de extender a OpenTelemetry para escenarios multi-cloud.

## Justificación
- Integración nativa con AWS Lambda, ECS, API Gateway, etc.
- Visualización de flujos y cuellos de botella.
- Soporte para correlación de logs y métricas.
- Reducción de complejidad operativa.
- Cumplimiento de estándares de seguridad y auditoría.


### Comparativa de alternativas

| Criterio                | AWS X-Ray | OpenTelemetry/Jaeger | Sin tracing |
|------------------------|-----------|----------------------|-------------|
| Agnosticismo           | Bajo (lock-in AWS) | Alto (multi-cloud, open source) | N/A         |
| Integración AWS        | Nativa    | Parcial              | -           |
| Escalabilidad          | Alta      | Media                | -           |
| Costos                 | Pago por uso | Infra propia        | -           |
| Visualización          | Sí        | Sí                   | No          |
| Operación              | Gestionada| Autogestionada       | -           |

### Comparativa de costos estimados (2025)

| Solución        | Costo mensual base* | Costos adicionales | Infraestructura propia |
|-----------------|---------------------|--------------------|-----------------------|
| AWS X-Ray       | ~US$5/mes por 1M segmentos | Dashboards, traces | No                    |
| OpenTelemetry/Jaeger | ~US$20/mes (VM pequeña) | Mantenimiento, soporte | Sí                    |

*Precios aproximados, sujetos a variación según región, volumen y configuración. X-Ray escala según uso, OpenTelemetry/Jaeger requieren operación propia.

### Agnosticismo, lock-in y mitigación

- **Lock-in:** AWS X-Ray implica dependencia de AWS, mientras que OpenTelemetry/Jaeger pueden desplegarse en cualquier infraestructura.
- **Mitigación:** El uso de estándares abiertos (OpenTelemetry) facilita la migración entre soluciones de tracing.

### Comparativa de costos estimados (2025)

| Solución        | Costo mensual base* | Costos adicionales | Infraestructura propia |
|-----------------|---------------------|--------------------|-----------------------|
| AWS X-Ray       | Pago por uso        | Dashboards, traces | No                    |
| OpenTelemetry/Jaeger | ~US$20+ (VM/container pequeña) | Mantenimiento, soporte | Sí                    |

*Precios aproximados, sujetos a variación según región, volumen y configuración. X-Ray escala según uso, OpenTelemetry/Jaeger requieren operación propia.

## Alternativas descartadas
- OpenTelemetry/Jaeger: Mayor complejidad operativa, útil para multi-cloud.
- Sin tracing: No permite diagnóstico eficiente.

## Implicaciones
- Todos los servicios deben propagar y reportar trazas a X-Ray.
- Se recomienda estandarizar el uso de IDs de correlación.

## Referencias
- [AWS X-Ray](https://aws.amazon.com/xray/)
- [OpenTelemetry](https://opentelemetry.io/)
- [Arc42: Decisiones de arquitectura](https://arc42.org/decision/)
