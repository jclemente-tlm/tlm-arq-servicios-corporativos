# ADR-003: Uso de ECS Fargate en vez de EC2 para despliegue de microservicios

## Estado

Aceptada – Julio 2025

## Contexto

El sistema de notificaciones requiere ejecutar microservicios en contenedores, con alta disponibilidad y mínima gestión operativa. Las alternativas evaluadas fueron:

- **ECS Fargate (serverless containers)**
- **EC2 (máquinas virtuales gestionadas)**

## Decisión

Se selecciona **ECS Fargate** para el despliegue de microservicios.

## Justificación

- Modelo serverless: No requiere gestión de servidores, escalado ni parches de sistema operativo.
- Despliegue y escalado automático: Fargate ajusta recursos según demanda, sin intervención manual.
- Integración nativa con AWS IAM, VPC, CloudWatch, Secrets Manager, etc.
- Costos optimizados: Pago por uso de recursos, sin costos fijos de instancias.
- Seguridad mejorada: Aislamiento de tareas y control granular de permisos.
- Reducción de complejidad operativa: EC2 requiere gestión de AMIs, actualizaciones, monitoreo y escalado manual.
- Menor tiempo de provisión y despliegue: Fargate permite despliegues rápidos y consistentes.

### Comparativa de alternativas

| Criterio                | ECS Fargate         | EC2 gestionado         |
|------------------------|---------------------|------------------------|
| Agnosticismo           | Bajo (lock-in AWS)  | Medio (cloud lock-in, portable) |
| Operación              | Serverless gestionado | VM gestionada         |
| Escalabilidad          | Automática          | Manual                 |
| Integración AWS        | Nativa              | Nativa                 |
| Seguridad/Compliance   | IAM, aislamiento    | IAM, requiere configuración |
| Costos                 | Pago por uso        | Pago por instancia     |
| Mantenimiento          | Nulo                | Medio/Alto             |
| Alta disponibilidad    | Garantizada         | Requiere configuración |
| Auditoría/Monitoreo    | CloudWatch/CloudTrail | CloudWatch/CloudTrail |
| Latencia               | Baja                | Baja                   |
| Provisionamiento       | Rápido              | Lento                  |

### Comparativa de costos estimados (2025)

| Solución        | Costo mensual base* | Costo por vCPU/hora | Infraestructura propia |
|-----------------|---------------------|---------------------|-----------------------|
| ECS Fargate     | ~US$15 (1 vCPU, 2GB RAM, 30 días) | US$0.04048           | No                    |
| EC2 t3.medium   | ~US$25 (on-demand, 1 vCPU, 4GB RAM, 30 días) | US$0.0416            | No                    |

*Precios aproximados, sujetos a variación según región, tipo de instancia y uso. EC2 puede requerir costos adicionales por almacenamiento, operación y alta disponibilidad.

### Argumentos de agnosticismo y lock-in

- **Lock-in:** ECS Fargate implica dependencia de AWS, pero se justifica por la operación simplificada, escalabilidad y menor mantenimiento en un entorno 100% AWS.
- **Mitigación:** El uso de contenedores y estándares como Docker permite migrar a otros orquestadores (Kubernetes, Azure Container Instances) si el contexto cambia, aunque con esfuerzo de integración.
- **Evidencia:** EC2 es más portable, pero requiere mayor gestión operativa y no aporta ventajas significativas en el contexto actual.

## Alternativas descartadas

- **EC2**: Mayor carga operativa, menor agilidad y escalabilidad, más puntos de falla.

## Implicaciones

- Todos los microservicios se despliegan como tareas Fargate en ECS.
- El equipo se enfoca en desarrollo y operación de servicios, no en infraestructura.

## Referencias

- [AWS ECS Fargate](https://aws.amazon.com/fargate/)
- [Comparación EC2 vs Fargate](https://aws.amazon.com/blogs/containers/should-you-use-amazon-ecs-or-amazon-ec2/)
