# 4. Estrategia De Solución

## 4.1 Decisiones Clave

| Decisión         | Alternativa Elegida                | Justificación                                                                 |
|------------------|------------------------------------|-------------------------------------------------------------------------------|
| Arquitectura     | API REST + Procesadores asíncronos | Separación de responsabilidades, escalabilidad y desacoplamiento por colas    |
| Cola             | Amazon SQS                         | Alta disponibilidad, integración nativa con AWS, soporte para DLQ y reintentos|
| Persistencia     | PostgreSQL                         | Robustez, soporte multi-tenant, particionamiento y auditoría                  |
| Plantillas       | Liquid Templates                   | Flexibilidad, soporte i18n, versionado y fácil integración                    |
| Multi-canal      | Adaptadores por canal              | Extensibilidad y desacoplamiento de proveedores externos                      |
| Observabilidad   | Serilog + Prometheus               | Logging estructurado y métricas centralizadas                                 |
| Seguridad        | OAuth2/JWT + RBAC                  | Autenticación robusta y control de acceso granular                            |

> **Nota profesional:** Todas las decisiones priorizan la resiliencia, la trazabilidad y la facilidad de evolución, alineadas con los objetivos de calidad y las restricciones técnicas del sistema.

## 4.2 Patrones Aplicados

| Patrón             | Propósito                                 | Implementación                        |
|--------------------|-------------------------------------------|---------------------------------------|
| Outbox             | Garantía de entrega y consistencia        | Publicación a SQS desde PostgreSQL    |
| Adapter            | Integración multi-canal y desacoplada     | Adaptadores para Email, SMS, WhatsApp, Push |
| Repository         | Acceso desacoplado a datos                | Entity Framework Core                 |
| Validation         | Validación robusta de requests            | FluentValidation                      |
| Mapping            | Transformación eficiente de modelos       | Mapster                               |
| Observability      | Monitoreo y trazabilidad                  | Serilog, Prometheus                   |

> **Nota profesional:** El uso de patrones reconocidos permite mantener la mantenibilidad, facilitar pruebas y soportar la evolución incremental del sistema.

## 4.3 Multi-canal

| Canal        | Tecnología/Proveedor              | Propósito                        |
|--------------|----------------------------------|-----------------------------------|
| Email        | Amazon SES, SMTP                 | Notificaciones principales        |
| SMS          | AWS SNS, Proveedor local         | Alertas urgentes                  |
| WhatsApp     | Proveedor WhatsApp API           | Mensajería instantánea            |
| Push         | Proveedor Push API               | Notificaciones móviles            |

> **Nota profesional:** La arquitectura multi-canal desacopla la lógica de negocio de los proveedores, permitiendo cambios o ampliaciones sin impacto en el core del sistema. El uso de colas y adaptadores garantiza resiliencia y escalabilidad.
