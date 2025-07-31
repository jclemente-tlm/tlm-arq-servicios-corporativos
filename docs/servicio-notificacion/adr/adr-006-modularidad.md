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


# Este ADR ha sido migrado a /docs/adrs/adr-006-modularidad.md

Consulta la versión centralizada para la decisión arquitectónica actualizada.

- **Monolito único**: Menor flexibilidad, mayor riesgo de regresiones y menor escalabilidad.

- Los canales y funciones pueden evolucionar y desplegarse de forma independiente.
- El sistema es más resiliente y adaptable a nuevos requerimientos.

## Referencias

- [Microservicios y modularidad](https://martinfowler.com/articles/microservices.html)
- [Arc42: Decisiones de arquitectura](https://arc42.org/decision/)
