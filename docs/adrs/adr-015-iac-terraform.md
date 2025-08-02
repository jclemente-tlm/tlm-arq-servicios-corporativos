# ADR-015: Infraestructura como código (IaC) con [Terraform](https://www.terraform.io/)

## ✅ ESTADO

Aceptada – Julio 2025

---

## 🗺️ CONTEXTO

Se requiere una solución de Infraestructura como Código (IaC) que permita gestionar recursos de forma declarativa, auditable y multi-cloud para los entornos de los servicios corporativos.

Las alternativas evaluadas fueron:

- **[Terraform](https://www.terraform.io/)** (`open source`, multi-cloud)
- **[AWS CloudFormation](https://aws.amazon.com/cloudformation/)** (gestionado, propietario)
- **[Pulumi](https://www.pulumi.com/)** (`open source`, multi-cloud)
- **Scripts manuales**

### Comparativa de alternativas

| Criterio                                              | Terraform | CloudFormation | Pulumi | Scripts manuales |
|-------------------------------------------------------|-----------|---------------|--------|------------------|
| Facilidad de integración con CI/CD y cloud            | Muy alta (integración nativa, plugins) | Alta (AWS nativo) | Alta (multi-cloud, SDKs) | Baja |
| Soporte para módulos reutilizables y comunidad        | Muy alta (ecosistema global) | Media | Alta | Nula |
| Facilidad de aprendizaje y curva de adopción          | Media (HCL propio) | Alta (YAML/JSON) | Media (requiere lenguaje) | Alta (scripts conocidos) |
| Automatización, testing y validación de infraestructura| Alta (plan, validate, test) | Media | Alta | Baja |
| Portabilidad y migración entre nubes/proveedores      | Muy alta | Baja (solo AWS) | Muy alta | Baja |
| Seguridad, control de acceso y compliance             | Alta (integración IAM, Sentinel) | Alta (IAM AWS) | Alta | Baja |
| Riesgo de lock-in y portabilidad de definiciones      | Bajo (HCL estándar, OSS) | Alto (propietario) | Bajo (código abierto) | Alto (ad-hoc, no portable) |
| Performance en despliegues grandes                    | Alta | Alta | Alta | Baja |
| Costos ocultos (state management, soporte empresarial)| Medio (Terraform Cloud opcional) | Bajo | Medio | Bajo |
| Licenciamiento                                        | OSS | Propietario | OSS | N/A |

---

## ✔️ DECISIÓN

Se adopta **[Terraform](https://www.terraform.io/)** como herramienta estándar de `IaC` para la gestión de recursos `cloud` y `on-premises` en todos los servicios y sistemas corporativos.

## Justificación

- Soporte `multi-cloud` (`AWS`, `Azure`, `GCP`, `on-premises`, `SaaS`).
- Gran ecosistema de módulos reutilizables y comunidad activa.
- Sintaxis declarativa y control de cambios versionado.
- Integración con `pipelines CI/CD` y control de acceso granular.
- Permite validación, pruebas y despliegues automatizados.
- Facilita la portabilidad y el rollback de infraestructura.
- Independencia respecto a proveedores cloud (evita lock-in).

## Alternativas descartadas

- **[AWS CloudFormation](https://aws.amazon.com/cloudformation/)**: Solo soporta `AWS`, menor portabilidad y comunidad más limitada fuera de `AWS`.
- **[Pulumi](https://www.pulumi.com/)**: Potente y flexible, pero menor adopción y comunidad que `Terraform`.
- **[AWS CDK](https://aws.amazon.com/cdk/)**: Muy relevante para desarrolladores .NET/C#, pero genera lock-in con AWS y menor portabilidad multi-cloud.
- Scripts manuales: Mayor riesgo de errores, menor trazabilidad y automatización, dependientes de `CLI`/`SDK` propietarios.

---

## ⚠️ CONSECUENCIAS

- Todo recurso `cloud` debe ser gestionado vía `Terraform` salvo justificación técnica documentada.
- Se recomienda estandarizar módulos y plantillas reutilizables.
- La documentación debe incluir ejemplos y buenas prácticas de uso.

---

## 📚 REFERENCIAS

- [Terraform Docs](https://www.terraform.io/docs)
- [Terraform Cloud Pricing](https://www.hashicorp.com/products/terraform/pricing)
- [AWS CloudFormation](https://aws.amazon.com/cloudformation/)
- [Pulumi](https://www.pulumi.com/)
- [Arc42: Decisiones de arquitectura](https://arc42.org/decision/)
