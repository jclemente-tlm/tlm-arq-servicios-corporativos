# 3. Contexto y alcance del sistema

![Servicios Corporativos - Vista de Contexto](/diagrams/servicios-corporativos/corporate_services.png)

*Figura 3.1: Vista de contexto de los Servicios Corporativos*

![Sistema de Notificación - Vista de Contexto](/diagrams/servicios-corporativos/notification_system.png)

*Figura 3.2: Vista de contexto del Sistema de Notificación*

## 3.1 Alcance del sistema

| Aspecto | Descripción |
|---------|-------------|
| **Incluido** | Envío multi-canal, plantillas, programación, adjuntos, auditoría |
| **Excluido** | Contenido de mensajes, lógica de negocio, gestión de usuarios |

## 3.2 Actores externos

| Actor | Rol | Interacción |
|-------|-----|-------------|
| **Aplicaciones Corporativas** | Clientes | Solicitudes de envío |
| **Usuarios Finales** | Destinatarios | Recepción de notificaciones |
| **Proveedores Email** | Servicios | SMTP/API para email |
| **Proveedores SMS** | Servicios | API para SMS |
| **Sistema Identidad** | Proveedor | Autenticación |
| **Observabilidad** | Consumidor | Métricas y logs |
