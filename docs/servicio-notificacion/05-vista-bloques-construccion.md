# 5. Vista de bloques de construcción

## 5.1 Diagrama de componentes principales

```mermaid
C4Container
      title Servicio de Notificaciones - Contenedores
      Container(API, "API Notificaciones", "ASP.NET Core", "Expone endpoints REST para gestión de notificaciones")
      Container(Service, "Servicio de Envío", ".NET Worker", "Procesa y envía notificaciones a canales externos")
      Container(DB, "Base de Datos", "PostgreSQL", "Almacena notificaciones, logs y adjuntos")
      Container(Kafka, "Kafka", "Kafka", "Mensajería asíncrona para eventos y reintentos")
      Container(S3, "S3", "AWS S3", "Almacenamiento de adjuntos")
      Rel(API, Service, "Envía solicitudes de envío")
      Rel(Service, Kafka, "Publica eventos de estado")
      Rel(Service, S3, "Guarda/recupera adjuntos")
      Rel(Service, DB, "Lee/Escribe notificaciones")
```

## 5.2 Descripción de componentes

| Componente         | Descripción                                                      |
|--------------------|------------------------------------------------------------------|
| `API Notificaciones` | Expone endpoints REST para gestión y consulta de notificaciones |
| `Servicio de Envío`  | Procesa y envía notificaciones a canales externos               |
| `Base de Datos`      | Almacena notificaciones, logs y adjuntos                        |
| `Kafka`              | Mensajería asíncrona para eventos y reintentos                  |
| `S3`                 | Almacenamiento de adjuntos                                      |
