# 3. Contexto y alcance del sistema

![Servicios Corporativos - Vista de Contexto](/diagrams/servicios-corporativos/corporate_services.png)

*Figura 3.1: Vista de contexto de los Servicios Corporativos*

![Sistema SITA Messaging - Vista de Contexto](/diagrams/servicios-corporativos/sita_messaging_system.png)

*Figura 3.2: Vista de contexto del Sistema SITA Messaging*

## 3.1 Alcance del sistema

| Aspecto | Descripción |
|---------|-------------|
| **Incluido** | Generación mensajes SITA, plantillas, enrutamiento AFTN, transmisión |
| **Excluido** | Contenido de mensajes, lógica de negocio, gestión de vuelos |

## 3.2 Actores externos

| Actor | Rol | Interacción |
|-------|-----|-------------|
| **Track & Trace System** | Proveedor | Eventos operacionales |
| **Red SITA Global** | Destinatario | Transmisión de mensajes |
| **Partners Aeronáuticos** | Destinatarios | Recepción de mensajes |
| **Sistema Identidad** | Proveedor | Autenticación |
| **Observabilidad** | Consumidor | Métricas y logs |
