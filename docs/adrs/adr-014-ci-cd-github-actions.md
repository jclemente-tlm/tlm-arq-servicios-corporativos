# ADR-014: Automatización de despliegues (CI/CD) con [`GitHub Actions`](https://github.com/features/actions)

## ✅ ESTADO

Aceptada – Julio 2025

---

## 🗺️ CONTEXTO

Se requiere una solución de `CI/CD` que permita automatizar pruebas, builds y despliegues de forma segura, repetible y auditable para todos los servicios y `microservicios`.

Las alternativas evaluadas fueron:

- **[GitHub Actions](https://github.com/features/actions)** (integración nativa con `GitHub`, `workflows` como código)
- **[GitLab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/)** (`open source`, portable)
- **[AWS CodePipeline](https://aws.amazon.com/codepipeline/)** (servicio gestionado de `AWS`)
- **[Jenkins](https://www.jenkins.io/)** (`open source`, gestión de `pipelines` y `runners` propios)
- **[Azure DevOps Pipelines](https://azure.microsoft.com/en-us/services/devops/pipelines/)** (`cloud`, integración nativa con Azure y .NET)

### Comparativa de alternativas

| Criterio                                              | GitHub Actions | GitLab CI | CodePipeline | Jenkins | Azure DevOps Pipelines |
|-------------------------------------------------------|---------------|-----------|--------------|---------|-----------------------|
| Facilidad de integración con repositorios y cloud     | Muy alta (GitHub, AWS, Azure) | Alta (GitLab, AWS, Azure) | Alta (AWS) | Alta (cualquier repo) | Muy alta (Azure, GitHub) |
| Soporte para pipelines como código y reutilización    | Muy alta (YAML, plantillas, composite actions) | Alta (YAML, plantillas) | Media | Alta (Jenkinsfile, shared libs) | Alta (YAML, plantillas) |
| Automatización y DevOps (APIs, triggers, IaC)         | Alta (APIs, triggers, matrix) | Alta | Media | Alta | Alta |
| Comunidad, soporte y ecosistema de plugins/acciones   | Muy alta (marketplace, comunidad activa) | Alta | Media | Muy alta (plugins) | Alta |
| Performance y tiempos de build/deploy                 | Alta | Alta | Media | Media (depende de runners) | Alta |
| Seguridad y control de permisos                       | Muy alta (granular, OIDC, secrets) | Alta | Alta | Media | Alta |
| Riesgo de lock-in y portabilidad de pipelines         | Medio (YAML portable, pero dependiente de GitHub) | Bajo (open source, portable) | Alto (AWS) | Bajo (open source) | Alto (Azure) |
| Facilidad de migración entre plataformas              | Media | Alta | Baja | Alta | Media |
| Costos                                               | Bajo/incluido | Bajo | Pago por uso | Infra propia | Bajo/incluido |
| Licenciamiento                                       | SaaS | OSS | Propietario | OSS | SaaS |

### Comparativa de costos estimados (2025)

| Solución        | Costo mensual base* | Costos adicionales | Infraestructura propia |
|-----------------|---------------------|--------------------|-----------------------|
| `GitHub Actions`  | Incluido en `GitHub` (2,000 min/mes gratis) | ~US$0.008/min extra | No                |
| `GitLab CI`       | Incluido en `GitLab` (400 min/mes gratis) | ~US$0.003/min extra | No              |
| `CodePipeline`    | ~US$1/mes por pipeline | -                  | No                    |
| `Jenkins`         | ~US$20/mes (VM pequeña) | Mantenimiento, soporte | Sí            |
| `Azure DevOps Pipelines` | Incluido en Azure (1,800 min/mes gratis) | ~US$0.005/min extra | No              |

*Precios aproximados, sujetos a variación según proveedor, volumen y configuración. `Jenkins` requiere operación propia, `GitHub Actions` y `GitLab CI` pueden tener costos por minutos o `runners` adicionales.

### Agnosticismo, lock-in y mitigación

- **Lock-in:** `GitHub Actions` y `CodePipeline` implican dependencia de sus plataformas, mientras que `Jenkins` y `GitLab CI` pueden desplegarse en cualquier infraestructura.
- **Mitigación:** El uso de `pipelines` como código y contenedores (`Docker`) facilita la migración entre plataformas `CI/CD`.

---

## ✔️ DECISIÓN

Se adopta **[GitHub Actions](https://github.com/features/actions)** como plataforma estándar de `CI/CD` para todos los repositorios y servicios corporativos.

## Justificación

- Integración nativa con `GitHub` y repositorios existentes.
- `Workflows` reutilizables y plantillas para distintos lenguajes y stacks.
- Marketplace de acciones y comunidad activa.
- Facilidad de integración con `AWS` y otros proveedores cloud.
- Seguridad, auditoría y control de permisos granular.
- Costos optimizados y escalabilidad gestionada.

## Alternativas descartadas

- **[GitLab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/)**: Menor integración con `GitHub` y `AWS`.
- **[AWS CodePipeline](https://aws.amazon.com/codepipeline/)**: Menos flexible y menos comunidad.
- **[Jenkins](https://www.jenkins.io/)**: Mayor complejidad operativa y mantenimiento, requiere gestión de `pipelines` y `runners` propios.
- **[Azure DevOps Pipelines](https://azure.microsoft.com/en-us/services/devops/pipelines/)**: Muy relevante para proyectos .NET y Azure, pero menos adoptado en ecosistemas AWS puros.

---

## ⚠️ CONSECUENCIAS

- Todos los servicios deben definir `pipelines` en `GitHub Actions`.
- Se recomienda estandarizar `workflows` y plantillas.

---

## 📚 REFERENCIAS

- [GitHub Actions](https://github.com/features/actions)
- [Arc42: Decisiones de arquitectura](https://arc42.org/decision/)
