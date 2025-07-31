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

## Alternativas descartadas

- **Azure Key Vault**: Requiere integración adicional y mayor latencia fuera de Azure; no aporta ventajas en el contexto AWS.
- **HashiCorp Vault**: Solución robusta pero implica mayor complejidad operativa, despliegue y mantenimiento, innecesarios para el alcance actual.

## Implicaciones

- El ciclo de vida de los secretos será gestionado exclusivamente en AWS.
- Las aplicaciones y microservicios deben autenticarse vía IAM para acceder a los secretos.
- Se documentará el uso y acceso en los manuales de operación y seguridad.

## Referencias

- [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/)
- [Arc42: Decisiones de arquitectura](https://arc42.org/decision/)
