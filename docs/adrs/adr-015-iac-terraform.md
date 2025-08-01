# ADR-015: Estandarización de Infraestructura como Código (IaC) con [`Terraform`](https://www.terraform.io/)

## ✅ ESTADO

Aceptada – Julio 2025

---

## 🗺️ CONTEXTO

Se requiere gestionar la infraestructura de manera automatizada, auditable y reproducible para todos los entornos (`desarrollo`, `QA`, `producción`) de los servicios corporativos. Es necesario soportar despliegues `multi-cloud`, reutilización de módulos y control de cambios versionado.

Las alternativas evaluadas fueron:

- **[Terraform](https://www.terraform.io/)** (`open source`, `multi-cloud`, módulos reutilizables)
- **[AWS CloudFormation](https://aws.amazon.com/cloudformation/)** (solo `AWS`, integración nativa)
- **[Pulumi](https://www.pulumi.com/)** (`open source`, `multi-cloud`, programación en varios lenguajes)
- **[AWS CDK](https://aws.amazon.com/cdk/)** (Infraestructura como código en C#/TypeScript, solo AWS)
- Scripts manuales (`CLI`, `SDK`)

### Comparativa de alternativas

| Criterio                | Terraform | CloudFormation | Pulumi | AWS CDK | Scripts manuales |
|------------------------|-----------|---------------|--------|---------|------------------|
| Agnosticismo           | Alto (`multi-cloud`, `open source`) | Bajo (`AWS`-only) | Alto (`multi-cloud`, `open source`) | Bajo (`AWS`-only) | Bajo (dependencia de `CLI`/`SDK`) |
| Soporte multi-cloud     | Sí        | No            | Sí     | No      | Parcial          |
| Reutilización de módulos| Alta      | Media         | Alta   | Alta    | Baja             |
| Comunidad              | Muy alta  | Alta          | Media  | Alta    | N/A              |
| Control de cambios     | Sí        | Sí            | Sí     | Sí      | No               |
| Integración CI/CD      | Sí        | Sí            | Sí     | Sí      | Parcial          |
| Curva de aprendizaje   | Media     | Baja          | Media  | Media   | Baja             |
| Costos                 | Gratis (`open source`) | Gratis   | Gratis (`open source`) | Gratis | Bajo              |

### Comparativa de costos estimados (2025)

| Solución        | Costo mensual base* | Costos adicionales | Infraestructura propia |
|-----------------|---------------------|--------------------|-----------------------|
| `Terraform OSS`   | Gratis (`open source`)| ~US$20/mes (VM pequeña para `runners`) | Opcional              |
| `Terraform Cloud` | Gratis hasta 500 recursos | ~US$7/usuario/mes (plan Team+) | No                    |
| `CloudFormation`  | Gratis              | Pago por recursos `AWS` | No                    |
| `Pulumi`          | Gratis (`open source`)| ~US$20/mes (VM `runners`) | Opcional              |
| Scripts manuales  | Gratis              | Mayor esfuerzo operativo | Opcional              |

*Precios aproximados, sujetos a variación según proveedor, volumen y configuración.

### Agnosticismo, lock-in y mitigación

- **Lock-in:** `Terraform` y `Pulumi` minimizan el lock-in al soportar múltiples proveedores y tener formato `open source`. `CloudFormation` genera lock-in con `AWS`. Los scripts manuales dependen de cada `CLI`/`SDK`.
- **Mitigación:** Usar módulos y recursos estándar, evitar extensiones propietarias y mantener IaC versionado facilita la migración entre nubes y la portabilidad.

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
