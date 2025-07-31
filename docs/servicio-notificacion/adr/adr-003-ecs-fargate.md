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

## Alternativas descartadas

- **EC2**: Mayor carga operativa, menor agilidad y escalabilidad, más puntos de falla.

## Implicaciones

- Todos los microservicios se despliegan como tareas Fargate en ECS.
- El equipo se enfoca en desarrollo y operación de servicios, no en infraestructura.

## Referencias

- [AWS ECS Fargate](https://aws.amazon.com/fargate/)
- [Comparación EC2 vs Fargate](https://aws.amazon.com/blogs/containers/should-you-use-amazon-ecs-or-amazon-ec2/)
