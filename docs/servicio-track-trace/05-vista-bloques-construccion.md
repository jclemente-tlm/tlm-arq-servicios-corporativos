# 5. Vista de bloques de construcción

![Sistema Track & Trace - Vista General](/diagrams/servicios-corporativos/track_and_trace_system.png)

*Figura 5.1: Vista de contenedores del Sistema Track & Trace*

![Command API - Vista de Componentes](/diagrams/servicios-corporativos/track_and_trace_tracking_api.png)

*Figura 5.2: Vista de componentes del Command API*

![Query API - Vista de Componentes](/diagrams/servicios-corporativos/track_and_trace_tracking_api.png)

*Figura 5.3: Vista de componentes del Query API*

## 5.1 Contenedores principales

| Contenedor | Responsabilidad | Tecnología |
|------------|-----------------|------------|
| **Command API** | Ingesta de eventos (Write Side) | .NET 8 Web API |
| **Query API** | Consultas de trazabilidad (Read Side) | .NET 8 Web API |
| **Event Store** | Almacenamiento inmutable de eventos | PostgreSQL 15+ |
| **Read Models** | Vistas optimizadas para consultas | PostgreSQL 15+ |

## 5.2 Componentes del Command API

| Componente | Responsabilidad | Tecnología |
|------------|-----------------|------------|
| **Event Controller** | Endpoint REST para eventos | ASP.NET Core |
| **Event Validator** | Validación de eventos | FluentValidation |
| **Event Store Service** | Persistencia de eventos | .NET 8 |
| **Event Publisher** | Publicación de eventos | .NET 8 |

## 5.3 Componentes del Query API

| Componente | Responsabilidad | Tecnología |
|------------|-----------------|------------|
| **Query Controller** | Endpoints REST y GraphQL | ASP.NET Core |
| **Query Handler** | Procesamiento de consultas | .NET 8 |
| **Read Model Service** | Acceso a vistas optimizadas | Entity Framework |
| **Analytics Service** | Análisis de patrones | .NET 8 |
