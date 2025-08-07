# 5. Vista de bloques de construcción

![Sistema de Notificación - Vista General](/diagrams/servicios-corporativos/notification_system.png)

*Figura 5.1: Vista de contenedores del Sistema de Notificación*

![Notification API - Vista de Componentes](/diagrams/servicios-corporativos/notification_api_components.png)

*Figura 5.2: Vista de componentes del Notification API*

![Notification Processor - Vista de Componentes](/diagrams/servicios-corporativos/notification_processor_components.png)

*Figura 5.3: Vista de componentes del Notification Processor*

## 5.1 Contenedores principales

| Contenedor | Responsabilidad | Tecnología |
|------------|-----------------|------------|
| **Notification API** | Recepción de solicitudes | .NET 8 Web API |
| **Notification Processor** | Procesamiento y envío | .NET 8 Worker Service |
| **PostgreSQL** | Persistencia de datos | PostgreSQL 15+ |
| **Redis** | Cola de mensajes y cache | Redis 7+ |
| **File Storage** | Almacenamiento de adjuntos | Sistema de archivos |

## 5.2 Componentes del API

| Componente | Responsabilidad | Tecnología |
|------------|-----------------|------------|
| **Notification Controller** | Endpoint REST | ASP.NET Core |
| **Template Controller** | Gestión de plantillas | ASP.NET Core |
| **Attachment Service** | Gestión de adjuntos | .NET 8 |
| **Validation Service** | Validación de datos | FluentValidation |

## 5.3 Componentes del Processor

| Componente | Responsabilidad | Tecnología |
|------------|-----------------|------------|
| **Orchestrator Service** | Orquestación de envíos | .NET 8 |
| **Template Engine** | Procesamiento de plantillas | RazorEngine |
| **Email Handler** | Envío de emails | SMTP |
| **SMS Handler** | Envío de SMS | HTTP API |
| **Scheduler Service** | Programación de envíos | .NET 8 Timer |
