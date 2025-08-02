# ADR-006: Modularidad basada en [microservicios](https://martinfowler.com/articles/microservices.html) vs. arquitectura monolítica

## ✅ ESTADO

Aceptada – Julio 2025

---

## 🗺️ CONTEXTO

Se busca facilitar la mantenibilidad, escalabilidad y despliegue independiente de los servicios corporativos, separando responsabilidades en `microservicios` y componentes bien definidos.

Las alternativas evaluadas fueron:

- **Arquitectura modular basada en `microservicios`**: Separación de dominios y funciones en servicios independientes, con despliegue desacoplado y comunicación vía `APIs`.
- **Monolito modularizado**: Un único despliegue, pero con separación lógica de módulos y capas internas bien definidas.
- **Arquitectura monolítica clásica**: Un único despliegue que agrupa todos los dominios y funciones en una sola aplicación, sin modularidad interna clara.

### Comparativa de alternativas

| Criterio                    | Microservicios | Monolito modularizado | Monolito clásico |
|-----------------------------|----------------|----------------------|------------------|
| Mantenibilidad              | Alta           | Media                | Baja             |
| Escalabilidad               | Alta           | Media                | Baja             |
| Despliegue independiente    | Sí             | No                   | No               |
| Flexibilidad/extensibilidad | Alta           | Media                | Baja             |
| Resiliencia                 | Alta           | Media                | Baja             |
| Complejidad operativa       | Alta           | Media                | Baja             |
| Time-to-market              | Media          | Alta                 | Alta             |
| Costos operativos           | Alto           | Medio                | Bajo             |
| Trazabilidad/auditoría      | Alta           | Media                | Baja             |
| Acoplamiento de dependencias| Bajo           | Medio                | Alto             |

---

## ✔️ DECISIÓN

La arquitectura se diseñará siguiendo principios de modularidad, separando responsabilidades en `microservicios` y componentes bien definidos.

## Justificación

- Permite equipos trabajar de forma autónoma.
- Facilita la evolución y escalado de la solución.
- Reduce el impacto de cambios y errores.
- Mejora la trazabilidad y el control de versiones.
- Alineado con buenas prácticas de `microservicios` y [Clean Architecture](https://8thlight.com/blog/uncle-bob/2012/08/13/the-clean-architecture.html).

## Alternativas descartadas

- Arquitectura monolítica: Menor flexibilidad, mayor riesgo de cambios globales, escalabilidad limitada y dependencias acopladas.

---

## ⚠️ CONSECUENCIAS

- Los canales y funciones pueden evolucionar y desplegarse de forma independiente.
- El sistema es más resiliente y adaptable a nuevos requerimientos.

---

## 📚 REFERENCIAS

- [Microservicios y modularidad](https://martinfowler.com/articles/microservices.html)
- [Arc42: Decisiones de arquitectura](https://arc42.org/decision/)
