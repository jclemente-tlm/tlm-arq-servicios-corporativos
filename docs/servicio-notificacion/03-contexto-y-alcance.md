# 3. Contexto y alcance

## 3.1 Diagrama de contexto

```mermaid
C4Context
      title Sistema de Notificaciones - Contexto
      Person(Usuario, "Usuario Final", "Recibe notificaciones por múltiples canales")
      System_Ext(ERP, "ERP Externo", "Sistema de gestión empresarial")
      System_Ext(CRM, "CRM Externo", "Gestión de clientes")
      System_Boundary(SistemaNotificaciones, "Servicio de Notificaciones") {
        Container(API, "API Notificaciones", "ASP.NET Core", "Expone endpoints REST para gestión de notificaciones")
        Container(DB, "Base de Datos", "PostgreSQL", "Almacena notificaciones, logs y adjuntos")
        Container(Kafka, "Kafka", "Kafka", "Mensajería asíncrona para eventos y reintentos")
      }
      Rel(Usuario, API, "Envía solicitudes de notificación")
      Rel(API, DB, "Lee/Escribe notificaciones y adjuntos")
      Rel(API, Kafka, "Publica eventos de notificación")
      Rel(ERP, API, "Solicita notificaciones automáticas")
      Rel(CRM, API, "Solicita notificaciones personalizadas")
```

## 3.2 Alcance

- **Incluye:**
  - Gestión y envío de notificaciones multicanal
  - Soporte multi-tenant y multi-país
  - Integración con sistemas externos (ERP, CRM)
  - Gestión de adjuntos y programación de envíos
- **Excluye:**
  - Generación de contenido de notificaciones (solo se envía contenido recibido)
  - Gestión de usuarios finales (delegada a sistemas externos)
