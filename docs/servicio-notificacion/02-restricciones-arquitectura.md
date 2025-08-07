# 2. Restricciones de la arquitectura

## 2.1 Restricciones técnicas

| Categoría | Restricción | Justificación |
|------------|---------------|---------------|
| **Runtime** | .NET 8 | Estándar corporativo |
| **Base de datos** | PostgreSQL | Robustez y ACID |
| **Cache/Cola** | Redis | Rendimiento |
| **Contenedores** | Docker | Portabilidad |
| **APIs** | REST + OpenAPI | Estándar industria |
| **ORM** | Entity Framework Core | Productividad |
| **Validaciones** | FluentValidation | Seguridad |
| **Logging** | Serilog | Monitoreo |
| **Mapeo DTOs** | Mapster | Eficiencia |
| **Testing** | xUnit | Calidad |
| **Análisis de código** | SonarQube | Mantenibilidad |
| **Seguridad IaC** | Checkov | Cumplimiento |

## 2.2 Restricciones de rendimiento

| Métrica | Objetivo | Razón |
|---------|----------|-------|
| **Capacidad** | 100,000+ notificaciones/hora | Volumen esperado |
| **Latencia** | < 5s envío | Experiencia usuario |
| **Disponibilidad** | 99.9% | SLA empresarial |
| **Escalabilidad** | Horizontal | Crecimiento |

## 2.3 Restricciones de seguridad

| Aspecto | Requerimiento | Estándar |
|---------|---------------|----------|
| **Cumplimiento** | GDPR, LGPD | Regulatorio |
| **Cifrado** | AES-256, TLS 1.3 | Mejores prácticas |
| **Autenticación** | JWT obligatorio | Zero trust |
| **Auditoría** | Trazabilidad completa | Compliance |

## 2.4 Restricciones organizacionales

| Área | Restricción | Impacto |
|------|---------------|--------|
| **Multi-tenancy** | Aislamiento por país | Regulaciones locales |
| **Operaciones** | DevOps 24/7 | Continuidad negocio |
| **Documentación** | ARC42 actualizada | Mantenibilidad |

> <span style="color:#d32f2f"><b>Nota:</b></span> Todas las configuraciones se gestionan por <code>scripts</code>, no por API. La autenticación es vía <code>OAuth2</code> con <code>JWT</code> (`client_credentials`).
- Uso obligatorio de <b>contenedores</b> para todos los servicios.
- <b>Multi-tenant</b> y <b>multi-país</b> como requerimiento transversal.
- Cumplimiento de normativas locales de privacidad y mensajería.
- Integración con sistemas externos vía <code>API REST</code> y <code>Kafka</code>.
- Despliegue en <b>AWS</b> (EC2, RDS, Lambda, S3, etc.).
