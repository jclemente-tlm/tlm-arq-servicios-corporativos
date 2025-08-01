# ADR-014: Automatización de despliegues (CI/CD) con GitHub Actions

## ✅ ESTADO

Aceptada – Julio 2025

---

## 🗺️ CONTEXTO

Se requiere una solución de CI/CD que permita automatizar pruebas, builds y despliegues de forma segura, repetible y auditable para todos los servicios y microservicios.

Las alternativas evaluadas fueron:

- GitHub Actions
- GitLab CI
- AWS CodePipeline
- Jenkins

### Comparativa de alternativas

| Criterio                | GitHub Actions | GitLab CI | CodePipeline | Jenkins |
|------------------------|---------------|-----------|--------------|---------|
| Agnosticismo           | Medio (lock-in GitHub, portable vía contenedores) | Alto (open source, portable) | Bajo (lock-in AWS) | Alto (open source, portable) |
| Integración GitHub     | Nativa        | Parcial   | Parcial      | Parcial |
| Facilidad de uso       | Alta          | Alta      | Media        | Media   |
| Comunidad              | Muy alta      | Alta      | Media        | Muy alta|
| Integración AWS        | Sí            | Sí        | Nativa       | Sí      |
| Costos                 | Bajo/Incluido | Bajo      | Pago por uso | Infra propia |
| Seguridad              | Alta          | Alta      | Alta         | Media   |
| Escalabilidad          | Alta          | Alta      | Alta         | Alta    |
| Operación              | Gestionada por proveedor | Gestionada por proveedor | Gestionada por proveedor | Gestionada por el equipo |

### Comparativa de costos estimados (2025)

| Solución        | Costo mensual base* | Costos adicionales | Infraestructura propia |
|-----------------|---------------------|--------------------|-----------------------|
| GitHub Actions  | Incluido en GitHub (2,000 min/mes gratis) | ~US$0.008/min extra | No                |
| GitLab CI       | Incluido en GitLab (400 min/mes gratis) | ~US$0.003/min extra | No              |
| CodePipeline    | ~US$1/mes por pipeline | -                  | No                    |
| Jenkins         | ~US$20/mes (VM pequeña) | Mantenimiento, soporte | Sí            |

*Precios aproximados, sujetos a variación según proveedor, volumen y configuración. Jenkins requiere operación propia, GitHub Actions y GitLab CI pueden tener costos por minutos o runners adicionales.

### Agnosticismo, lock-in y mitigación

- **Lock-in:** GitHub Actions y CodePipeline implican dependencia de sus plataformas, mientras que Jenkins y GitLab CI pueden desplegarse en cualquier infraestructura.
- **Mitigación:** El uso de pipelines como código y contenedores facilita la migración entre plataformas CI/CD.

---

## ✔️ DECISIÓN

Se adopta **GitHub Actions** como plataforma estándar de CI/CD para todos los repositorios y servicios corporativos.

## Justificación

- Integración nativa con GitHub y repositorios existentes.
- Workflows reutilizables y plantillas para distintos lenguajes y stacks.
- Marketplace de acciones y comunidad activa.
- Facilidad de integración con AWS y otros proveedores cloud.
- Seguridad, auditoría y control de permisos granular.
- Costos optimizados y escalabilidad gestionada.

## Alternativas descartadas

- GitLab CI: Menor integración con GitHub y AWS.
- CodePipeline: Menos flexible y menos comunidad.
- Jenkins: Mayor complejidad operativa y mantenimiento.

---

## ⚠️ CONSECUENCIAS

- Todos los servicios deben definir pipelines en GitHub Actions.
- Se recomienda estandarizar workflows y plantillas.

---

## 📚 REFERENCIAS

- [GitHub Actions](https://github.com/features/actions)
- [Arc42: Decisiones de arquitectura](https://arc42.org/decision/)
