# 4. Estrategia de solución

| Objetivo de calidad | Enfoque de solución |
|---------------------|--------------------|
| Escalabilidad | Procesadores por canal, colas desacopladas, escalabilidad horizontal |
| Disponibilidad | Serverless, DLQ, multi-AZ, replicación y balanceo de carga |
| Seguridad | OAuth2, RBAC, rate limiting |
| Fiabilidad | Reintentos, logs, métricas, DLQ |
| Mantenibilidad | Modularidad, patrones DDD |
| Multi-tenant | Separación de datos y configuración por cliente |
| Multipaís | Adaptación de canales y reglas por país |
| Almacenamiento eficiente | Bases relacionales, NoSQL y blobs para adjuntos, caché para preferencias |
| Estrategia de archivado | Para datos históricos |
