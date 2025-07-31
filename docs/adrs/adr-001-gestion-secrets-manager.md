# ADR-001: Selección de AWS Secrets Manager para gestión de secretos

## Estado

Aceptada – Julio 2025

## Contexto

El sistema de notificaciones requiere gestionar secretos y credenciales (tokens, claves API, contraseñas de servicios externos) de forma segura, centralizada y auditable. Las alternativas evaluadas fueron:

- **AWS Secrets Manager**
- **Azure Key Vault**
- **HashiCorp Vault**

## Decisión

Se selecciona **AWS Secrets Manager** como solución para la gestión de secretos en todos los entornos del servicio de notificaciones.

## Justificación

- Integración nativa con AWS IAM y servicios AWS (EC2, Lambda, ECS, SQS, etc.), facilitando la gestión de permisos y rotación automática de credenciales.
- Reducción de complejidad operativa: No requiere despliegue ni mantenimiento adicional, a diferencia de HashiCorp Vault.
- Alta disponibilidad y escalabilidad gestionada por AWS, sin necesidad de configuración manual.
- Auditoría y trazabilidad: Registros de acceso y cambios integrados con CloudTrail.
- Costos operativos optimizados: Incluido en el ecosistema AWS, sin costos adicionales por infraestructura dedicada.
- Cumplimiento de estándares de seguridad (PCI DSS, ISO, SOC) y cifrado en tránsito y en reposo.
- Desempeño y latencia: Menor latencia para servicios desplegados en AWS, comparado con Azure Key Vault.
- Simplicidad de integración: SDK y APIs compatibles con .NET y automatización vía IaC (CloudFormation, Terraform).

### Comparativa de alternativas

| Criterio                | AWS Secrets Manager | Azure Key Vault | HashiCorp Vault |
|------------------------|--------------------|-----------------|-----------------|
| Agnosticismo           | Bajo (cloud lock-in AWS) | Medio (cloud lock-in Azure) | Alto (multi-cloud, on-premises) |
| Operación              | Gestionado         | Gestionado      | Autogestionado  |
| Seguridad/Compliance   | Alto (PCI, ISO, SOC) | Alto           | Alto            |
| Integración .NET/IaC   | Excelente          | Buena           | Buena           |
| Latencia en AWS        | Muy baja           | Alta            | Variable        |
| Costos                 | Pago por uso, sin infra propia | Pago por uso | Infraestructura dedicada + licencias |
| Auditoría              | Integrada (CloudTrail) | Integrada      | Requiere configuración |
| Rotación automática    | Sí                 | Sí              | Requiere scripts |
| Complejidad operativa  | Muy baja           | Baja            | Alta            |
| Portabilidad           | Baja               | Baja            | Alta            |

### Comparativa de costos estimados (2025)

| Solución                        | Costo mensual base* | Costo por secreto adicional | Costo por 10K operaciones | Infraestructura propia |
|---------------------------------|---------------------|----------------------------|--------------------------|-----------------------|
| AWS Secrets Manager             | ~US$0.40/secreto    | ~US$0.40/secreto           | ~US$0.05/10K operaciones | No                    |
| Azure Key Vault                 | ~US$0.03/secreto    | ~US$0.03/secreto           | ~US$0.03/10K operaciones | No                    |
| HashiCorp Vault OSS (mínima)    | US$85/mes           | US$0                       | US$0                     | Sí                    |
| HashiCorp Vault Enterprise (mínima) | US$2,085/mes     | US$0                       | US$0                     | Sí                    |

*Precios aproximados, sujetos a variación según región y volumen. HashiCorp Vault OSS es gratuito pero requiere infraestructura propia y operación dedicada; la versión Enterprise tiene costos adicionales.

### Ejemplos de cálculo de costos mensuales

#### AWS Secrets Manager

- 100 secretos activos: 100 × US$0.40 = US$40/mes
- 100,000 operaciones API: 10 × US$0.05 = US$0.50/mes
- **Total estimado:** US$40.50/mes

#### Azure Key Vault

- 100 secretos activos: 100 × US$0.03 = US$3/mes
- 100,000 operaciones API: 10 × US$0.03 = US$0.30/mes
- **Total estimado:** US$3.30/mes

#### HashiCorp Vault (OSS, instalación mínima)

- Licencia OSS: US$0
- Infraestructura mínima: 1 VM t3.medium AWS (~US$30/mes), almacenamiento y backup (~US$5/mes)
- Operación y mantenimiento: estimado US$50/mes (tiempo técnico)
- **Total estimado:** US$85/mes (solo infraestructura y operación básica, sin HA ni soporte)

#### HashiCorp Vault (Enterprise, instalación mínima)

- Licencia Enterprise: ~US$2,000/mes (precio base, puede variar)
- Infraestructura mínima: 1 VM t3.medium AWS (~US$30/mes), almacenamiento y backup (~US$5/mes)
- Operación y mantenimiento: estimado US$50/mes (tiempo técnico)
- **Total estimado:** US$2,085/mes (solo infraestructura y operación básica, sin HA ni soporte)

> Nota: HashiCorp Vault OSS no genera gastos por licencias, pero sí por infraestructura, operación y mantenimiento. La versión Enterprise puede superar los US$2,000/mes dependiendo de la escala y soporte.

### Límites y consideraciones

- **AWS Secrets Manager:** hasta 500,000 secretos por cuenta, 10,000 solicitudes API/segundo, tamaño máximo de secreto 64 KB.
- **Azure Key Vault:** hasta 1 millón de secretos por bóveda, límites de solicitudes API por región.
- **HashiCorp Vault:** sin límites por software, pero limitado por capacidad de infraestructura y configuración.

### Agnosticismo, lock-in y mitigación

- **Lock-in:** AWS Secrets Manager implica dependencia de AWS, pero se justifica por la integración nativa, menor latencia y operación simplificada en un entorno 100% AWS.
- **Mitigación:** El uso de SDKs estándar y automatización IaC permite migrar a otras soluciones si el contexto cambia. La arquitectura desacopla el acceso a secretos mediante interfaces, facilitando un eventual reemplazo.

## Alternativas descartadas

- **Azure Key Vault:** Requiere integración adicional y mayor latencia fuera de Azure; no aporta ventajas en el contexto AWS.
- **HashiCorp Vault:** Solución robusta pero implica mayor complejidad operativa, despliegue y mantenimiento, innecesarios para el alcance actual.

## Implicaciones

- El ciclo de vida de los secretos será gestionado exclusivamente en AWS.
- Las aplicaciones y microservicios deben autenticarse vía IAM para acceder a los secretos.
- Se documentará el uso y acceso en los manuales de operación y seguridad.

## Referencias

- [AWS Secrets Manager Pricing](https://aws.amazon.com/secrets-manager/pricing/)
- [AWS Secrets Manager Docs](https://docs.aws.amazon.com/secretsmanager/latest/userguide/intro.html)
- [Azure Key Vault Pricing](https://azure.microsoft.com/en-us/pricing/details/key-vault/)
- [Azure Key Vault Docs](https://learn.microsoft.com/en-us/azure/key-vault/general/)
- [HashiCorp Vault Pricing](https://www.hashicorp.com/products/vault/pricing)
- [HashiCorp Vault Docs](https://www.vaultproject.io/docs/)
- [Comparativa HashiCorp Vault vs AWS Secrets Manager vs Azure Key Vault](https://sanj.dev/post/hashicorp-vault-aws-secrets-azure-key-vault-comparison)
- [Arc42: Decisiones de arquitectura](https://arc42.org/decision/)
