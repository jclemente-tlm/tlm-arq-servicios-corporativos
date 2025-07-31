# ADR-006: Modularidad por canal y función

## Estado

Aceptada – Julio 2025

## Contexto

El sistema debe ser evolutivo y mantenible, permitiendo cambios y extensiones por canal y función. Las alternativas evaluadas fueron:

- **Separación por canal y función (microservicios)**
- **Monolito único**

## Decisión

Se adopta una arquitectura modular, separando componentes por canal (Email, SMS, WhatsApp, Push) y por función (API, procesamiento, adjuntos, etc.).

## Justificación

- Facilita la evolución y el mantenimiento.
- Permite escalar y desplegar canales de forma independiente.
- Reduce el impacto de cambios y errores.
- Mejora la trazabilidad y el control de versiones.
- Alineado con buenas prácticas de microservicios y Clean Architecture.

## Alternativas descartadas

- **Monolito único**: Menor flexibilidad, mayor riesgo de regresiones y menor escalabilidad.

## Implicaciones

- Los canales y funciones pueden evolucionar y desplegarse de forma independiente.
- El sistema es más resiliente y adaptable a nuevos requerimientos.

## Referencias

- [Microservicios y modularidad](https://martinfowler.com/articles/microservices.html)
- [Arc42: Decisiones de arquitectura](https://arc42.org/decision/)
