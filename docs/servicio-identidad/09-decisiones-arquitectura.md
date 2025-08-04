# 9. Decisiones de arquitectura

## ADR-001: Adopción de Keycloak como Identity Provider

**Estado:** Aprobado
**Fecha:** 2024-01-15
**Decidido por:** Equipo de Arquitectura

### Contexto
Necesitamos un proveedor de identidad centralizado que soporte OAuth2/OIDC, multi-tenancy y federación con sistemas externos.

### Decisión
Adoptamos Keycloak como proveedor de identidad central.

### Justificación
- **Open Source:** Sin costos de licencia
- **Estándares:** Soporte completo OAuth2/OIDC, SAML
- **Multi-tenancy:** Realms nativos
- **Extensibilidad:** SPI para customizaciones
- **Comunidad:** Amplia adopción y soporte

### Consecuencias
- **Positivas:** Reducción de costos, flexibilidad, control total
- **Negativas:** Responsabilidad de mantenimiento y actualizaciones
- **Mitigaciones:** Team dedicado, automatización de deployments

## ADR-002: JWT como Formato de Token

**Estado:** Aprobado
**Fecha:** 2024-01-20
**Decidido por:** Equipo de Seguridad

### Contexto
Necesitamos un formato de token que sea stateless, seguro y ampliamente soportado.

### Decisión
Utilizamos JWT (JSON Web Tokens) con firma RS256.

### Justificación
- **Stateless:** No requiere almacenamiento de estado en servidor
- **Estándar:** RFC 7519, amplio soporte en bibliotecas
- **Seguridad:** Firma digital para integridad
- **Payload:** Claims estructurados para contexto

### Consecuencias
- **Positivas:** Escalabilidad, performance, interoperabilidad
- **Negativas:** Tamaño mayor que tokens opacos
- **Mitigaciones:** Optimización de claims, compression

## ADR-003: Multi-Realm Strategy para Multi-Tenancy

**Estado:** Aprobado
**Fecha:** 2024-02-01
**Decidido por:** Equipo de Producto

### Contexto
Necesitamos aislar datos y configuraciones entre diferentes tenants/países.

### Decisión
Un realm Keycloak separado por tenant/país.

### Justificación
- **Aislamiento:** Separación completa de datos
- **Customización:** Configuraciones específicas por tenant
- **Compliance:** Cumplimiento de regulaciones locales
- **Escalabilidad:** Growth horizontal por tenant

### Consecuencias
- **Positivas:** Aislamiento perfecto, flexibilidad total
- **Negativas:** Complejidad operacional
- **Mitigaciones:** Automatización de provisioning, templates

## ADR-004: Redis para Token Caching

**Estado:** Aprobado
**Fecha:** 2024-02-10
**Decidido por:** Equipo de Performance

### Contexto
La validación de JWT requiere verificación de firma en cada request, impactando performance.

### Decisión
Implementar cache distribuido con Redis para metadatos de tokens.

### Justificación
- **Performance:** Validación < 5ms vs 50ms sin cache
- **Scalability:** Cache distribuido entre instancias
- **TTL:** Automático basado en token expiration
- **High Availability:** Redis Cluster para redundancia

### Consecuencias
- **Positivas:** Mejora significativa de performance
- **Negativas:** Complejidad adicional, dependency extra
- **Mitigaciones:** Health checks, fallback a validación directa

## ADR-005: Event Sourcing para Audit Trail

**Estado:** Aprobado
**Fecha:** 2024-02-15
**Decidido por:** Equipo de Compliance

### Contexto
Requerimientos regulatorios exigen trazabilidad completa de eventos de seguridad.

### Decisión
Implementar Event Sourcing con Apache Kafka para audit trail.

### Justificación
- **Immutability:** Eventos inmutables para compliance
- **Completeness:** Captura de todos los eventos
- **Scalability:** Kafka maneja alto volumen
- **Real-time:** Procesamiento en tiempo real

### Consecuencias
- **Positivas:** Compliance total, analytics avanzados
- **Negativas:** Complejidad de implementación
- **Mitigaciones:** Bibliotecas de abstracción, tooling

## Resumen de Decisiones

| Decisión | Alternativas Evaluadas | Estado | Impacto |
|----------|----------------------|--------|---------|
| Keycloak | Auth0, AWS Cognito, Azure AD B2C | Aprobado | Alto |
| JWT Tokens | SAML, Opaque tokens | Aprobado | Alto |
| Multi-Realm | Shared realm con atributos | Aprobado | Medio |
| Redis Cache | In-memory, Database cache | Aprobado | Medio |
| Event Sourcing | Traditional auditing | Aprobado | Alto |

## Referencias
- [Architecture Decision Records](https://adr.github.io/)
- [Keycloak Architecture Guide](https://www.keycloak.org/docs/latest/server_development/)
- [JWT Best Practices](https://tools.ietf.org/html/rfc8725)
- [Arc42 Architecture Decisions](https://docs.arc42.org/section-9/)
