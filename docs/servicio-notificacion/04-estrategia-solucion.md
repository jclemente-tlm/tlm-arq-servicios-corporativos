# 4. Estrategia de solución

La solución se basa en una arquitectura **Clean Architecture** y **microservicios** desplegados en <span style="color:#1976d2"><b>AWS</b></span>, con integración de canales de mensajería y almacenamiento eficiente de adjuntos.

## 4.1 Principios clave

- **Separación de responsabilidades** (`SRP`)
- **Escalabilidad horizontal**
- **Aislamiento multi-tenant**
- **Automatización de despliegues** (`CI/CD`)
- **Observabilidad** (logs estructurados, métricas, trazas)

## 4.2 Patrones y tecnologías

| Patrón/Tecnología         | Uso principal                                 |
|--------------------------|-----------------------------------------------|
| `Clean Architecture`     | Organización modular y desacoplada            |
| `Microservicios`         | Independencia y escalabilidad                 |
| `Event-driven`           | Procesamiento asíncrono con <b>Event Bus</b>  |
| `API REST`               | Exposición de servicios                       |
| `PostgreSQL`             | Persistencia de datos                         |
| `S3`                     | Almacenamiento de adjuntos                    |
| `Docker`                 | Contenerización y portabilidad                |
| `CI/CD`                  | Despliegue automatizado                       |
| `OAuth2/JWT`             | Seguridad y autenticación                     |
| `FluentValidation`       | Validación de datos                           |
| `Serilog`                | Logging estructurado                          |
| `Mapster`                | Mapeo de DTOs                                 |

> <span style="color:#0288d1"><b>Nota:</b></span> Se prioriza la extensibilidad y la integración con nuevos canales y proveedores.
