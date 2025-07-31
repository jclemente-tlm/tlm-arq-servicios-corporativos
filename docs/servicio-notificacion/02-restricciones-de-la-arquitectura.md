# 2. Restricciones de la arquitectura

Las siguientes restricciones son obligatorias para el diseño, implementación y evolución del sistema de notificaciones corporativas:

## Modularidad y separación de responsabilidades

- La arquitectura debe ser modular, permitiendo la evolución y despliegue independiente de canales (Email, SMS, WhatsApp, Push) y funciones (API, procesamiento, adjuntos, etc.).
- No se permite el uso de un monolito único; cada canal y función debe estar desacoplado y ser extensible.

## Clean Architecture y microservicios

- Se debe seguir el patrón de Clean Architecture, asegurando separación clara entre capas y dependencias.
- Los componentes deben implementarse como microservicios independientes cuando sea relevante para la escalabilidad y mantenibilidad.

## Evolutividad y mantenibilidad

- El sistema debe permitir la incorporación de nuevos canales y funciones sin afectar los existentes.
- Los cambios deben poder realizarse de forma incremental y controlada.

## Trazabilidad y control de versiones

- Todas las modificaciones en canales y funciones deben ser trazables y versionadas.


### Resumen de restricciones técnicas clave

| Restricción           | Descripción                                 |
|----------------------|---------------------------------------------|
| .NET 8 y C#          | Tecnología principal                        |
| AWS SQS/SNS/S3       | Colas y almacenamiento                      |
| PostgreSQL           | Base de datos principal                     |
| YARP                 | API Gateway                                 |
| Políticas de seguridad| Cumplimiento corporativo                    |
| Serverless preferido | Servicios gestionados                       |
| Multi-tenant         | Separación lógica de datos y recursos       |
| Multipaís            | Configuración regional y soporte de localización |

---

## Referencias

- [ADR-006: Modularidad por canal y función](docs/servicio-notificacion/adr/adr-006-modularidad.md)
- [Microservicios y modularidad](https://martinfowler.com/articles/microservices.html)
- [Arc42: Restricciones de arquitectura](https://arc42.org/section-2/)