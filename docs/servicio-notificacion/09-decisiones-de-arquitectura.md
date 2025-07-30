# 9. Decisiones de arquitectura

| Título | Contexto | Decisión | Estado | Consecuencias |
|--------|----------|----------|--------|---------------|
| Uso de SQS/SNS | Necesidad de desacoplar y escalar | Adoptar colas gestionadas | Aceptada | Escalabilidad y tolerancia a fallos |
| API Gateway YARP | Unificar entrada y seguridad | Usar YARP | Aceptada | Centralización y flexibilidad |
| Serverless | Optimizar costos y operación | Usar Lambda/ECS | Aceptada | Menor mantenimiento, escalabilidad |
| DLQ | Manejo de fallos | Implementar DLQ en colas | Aceptada | Trazabilidad y recuperación |
| Modularidad | Evolución y mantenibilidad | Separar por canal y función | Aceptada | Facilidad de cambios y extensiones |
| Configuración por scripts | Baja frecuencia de cambios en tenants, canales y plantillas | Gestionar configuración mediante scripts (SQL, CLI, etc.) en vez de APIs | Aceptada | Menor costo y mantenimiento, requiere acceso controlado y personal técnico. Si la frecuencia de cambios aumenta o se requiere integración, se puede reconsiderar exponer una API. |
