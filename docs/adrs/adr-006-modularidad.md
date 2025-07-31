# ADR-006: Modularidad basada en microservicios vs. arquitectura monolítica

## Estado

Aceptada – Julio 2025

## Contexto

Se busca facilitar la mantenibilidad, escalabilidad y despliegue independiente de los servicios corporativos, separando responsabilidades en microservicios y componentes bien definidos. Las alternativas evaluadas fueron:

- **Arquitectura modular basada en microservicios**: Separación de dominios y funciones en servicios independientes, con despliegue desacoplado y comunicación vía APIs.
- **Arquitectura monolítica**: Un único despliegue que agrupa todos los dominios y funciones en una sola aplicación.

## Decisión

La arquitectura se diseñará siguiendo principios de modularidad, separando responsabilidades en microservicios y componentes bien definidos.

## Justificación

- Permite equipos trabajar de forma autónoma.
- Facilita la evolución y escalado de la solución.
- Reduce el impacto de cambios y errores.
- Mejora la trazabilidad y el control de versiones.
- Alineado con buenas prácticas de microservicios y Clean Architecture.

## Alternativas descartadas

- Arquitectura monolítica: Menor flexibilidad, mayor riesgo de cambios globales, escalabilidad limitada y dependencias acopladas.

## Implicaciones

- Los canales y funciones pueden evolucionar y desplegarse de forma independiente.
- El sistema es más resiliente y adaptable a nuevos requerimientos.

## Referencias

- [Microservicios y modularidad](https://martinfowler.com/articles/microservices.html)
- [Arc42: Decisiones de arquitectura](https://arc42.org/decision/)
