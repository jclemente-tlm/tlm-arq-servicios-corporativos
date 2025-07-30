# 10. Requisitos de calidad

## 10.1 Descripción general

| Categoría | Descripción |
|-----------|-------------|
| Escalabilidad | Manejo de picos y crecimiento horizontal |
| Disponibilidad | Alta disponibilidad y tolerancia a fallos |
| Seguridad | Autenticación, autorización y privacidad |
| Fiabilidad | Entrega garantizada y trazabilidad |
| Mantenibilidad | Modularidad y facilidad de evolución |
| Eficiencia | Baja latencia y uso óptimo de recursos |

## 10.2 Escenarios de calidad

| ID | Nombre | Fuente | Estímulo | Entorno | Artefacto | Respuesta | Métrica |
|----|--------|--------|---------|---------|-----------|----------|--------|
| Q1 | Pico de envíos | Cliente | Solicitud masiva | Producción | API, Processor | Entrega sin pérdida | <1 seg/evento |
| Q2 | Fallo de canal | Worker | Error de envío | Producción | Processor, DLQ | Reintento y registro | 99.9% recuperado |
| Q3 | Nuevo canal | Dev | Solicitud de integración | Dev | API, Processor | Integración sin impacto | <2 días |
| Q4 | Seguridad | Auditor | Acceso no autorizado | Producción | API, DB | Bloqueo y alerta | 100% bloqueado |
