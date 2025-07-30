# 3. Contexto y alcance

## 3.1 Contexto empresarial

**Diagrama de flujo multi-tenant y multipaís:**

```mermaid
flowchart TD
    A[Cliente Empresa A] -->|Solicita notificación| S(Servicio de Notificaciones)
    B[Cliente Empresa B] -->|Solicita notificación| S
    S -->|Envía notificación| U1[Usuario País 1]
    S -->|Envía notificación| U2[Usuario País 2]
    S -->|Envía notificación| U3[Usuario País 3]
    Admin -->|Configura canales y reglas| S
```

**Diagrama de casos de uso multi-tenant y multipaís (simulado):**

```mermaid
flowchart TD
    Empresa((Empresa))
    Administrador((Administrador))
    Usuario((Usuario))
    SolicitarNotificacion([Solicitar notificación])
    ConsultarEstado([Consultar estado de envío])
    ConfigurarCanales([Configurar canales y reglas por país])
    GestionarPlantillas([Gestionar plantillas por tenant])
    RecibirNotificacion([Recibir notificación])
    Empresa --> SolicitarNotificacion
    Empresa --> ConsultarEstado
    Administrador --> ConfigurarCanales
    Administrador --> GestionarPlantillas
    Usuario --> RecibirNotificacion
```

| Interlocutor | Entrada | Salida |
|--------------|--------|--------|
| App Talma | Solicitud de notificación | Estado de envío |
| Admin | Configuración de plantillas/canales | Confirmación |
| Usuario final | - | Notificación recibida |

## 3.2 Contexto técnico

| Sistema | Canal | Protocolo |
|---------|-------|----------|
| API Gateway | HTTP | REST |
| SQS/SNS | Mensajería | AWS |
| S3 | Archivos | AWS |
| PostgreSQL | Datos | SQL |
