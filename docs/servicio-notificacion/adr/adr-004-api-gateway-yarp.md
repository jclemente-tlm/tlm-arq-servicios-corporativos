# ADR-004: Uso de YARP como API Gateway

## Estado

Aceptada – Julio 2025

## Contexto

El sistema requiere un punto de entrada único para las aplicaciones y microservicios, que permita centralizar la seguridad, el enrutamiento y la gestión de tráfico. Las alternativas evaluadas fueron:

- **YARP (Yet Another Reverse Proxy)**
- **AWS API Gateway**
- **NGINX/Traefik**

## Decisión

Se selecciona **YARP** como API Gateway para el sistema de notificaciones.

## Justificación

- Integración nativa con .NET y ecosistema C#.
- Flexibilidad para definir reglas de enrutamiento, balanceo y autenticación personalizada.
- Permite centralizar la seguridad (OAuth2, JWT, rate limiting) y la gestión de tráfico.
- Despliegue sencillo en contenedores y compatibilidad con ECS Fargate.
- Menor costo operativo comparado con soluciones gestionadas (AWS API Gateway).
- Extensible y personalizable para necesidades futuras.

## Alternativas descartadas

- **AWS API Gateway**: Solución gestionada, pero con mayor costo y menor flexibilidad para lógica personalizada.
- **NGINX/Traefik**: Requiere mayor esfuerzo de integración y personalización en entornos .NET.

## Implicaciones

- El tráfico de entrada se canaliza y controla desde YARP.
- La seguridad y el monitoreo se centralizan en el gateway.

## Referencias

- [YARP](https://microsoft.github.io/reverse-proxy/)
- [Arc42: Decisiones de arquitectura](https://arc42.org/decision/)
