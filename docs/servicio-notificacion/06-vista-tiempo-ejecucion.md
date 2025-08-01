# 6. Vista de tiempo de ejecución

## 6.1 Escenario: Envío de notificación multicanal

```mermaid
sequenceDiagram
    participant U as Usuario
    participant API as API Notificaciones
    participant S as Servicio de Envío
    participant K as Kafka
    participant S3 as S3
    participant DB as Base de Datos
    U->>API: Solicita envío de notificación
    API->>DB: Guarda notificación
    API->>S: Envía solicitud de envío
    S->>S3: Adjunta archivos (si aplica)
    S->>K: Publica evento de envío
    S->>DB: Actualiza estado
    S->>U: Confirma entrega
```

## 6.2 Consideraciones

- **Reintentos automáticos** ante fallos de canal
- **Trazabilidad** de cada mensaje
- **Aislamiento multi-tenant** en cada paso
- **Logs estructurados** para auditoría
