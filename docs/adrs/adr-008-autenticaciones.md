# ADR-008: Autenticaciones

## ✅ ESTADO

Aceptada – Julio 2025

---

## 🗺️ CONTEXTO

Se necesita un mecanismo de autenticación seguro, interoperable y centralizado para servicios `multi-tenant` y `multi-país`, que permita integración con aplicaciones internas y externas y soporte automatización (`machine-to-machine`).

Las alternativas evaluadas fueron:

- **[Keycloak](https://www.keycloak.org/)** (`open source`, `multi-tenant`, `multi-país`)
- **[Auth0](https://auth0.com/)** (`SaaS`, `multi-tenant`)
- **[Azure AD](https://azure.microsoft.com/en-us/services/active-directory/)** (`cloud`, `multi-tenant`)
- **[AWS Cognito](https://aws.amazon.com/cognito/)** (`cloud`, `multi-tenant`)

### Comparativa de alternativas

| Criterio                        | Keycloak | Auth0 | Azure AD | AWS Cognito |
|---------------------------------|----------|-------|----------|-------------|
| Agnosticismo/Portabilidad       | ✅ Totalmente agnóstico (`open source`) | ❌ Dependiente de proveedor (`SaaS`) | ❌ Dependiente de proveedor (`Azure`) | ❌ Dependiente de proveedor (`AWS`) |
| Gestión operativa               | Gestionada por el equipo | Gestionada por proveedor | Gestionada por proveedor | Gestionada por proveedor |
| Protocolos soportados (OIDC, SAML, LDAP, SCIM) | OIDC, SAML, LDAP, SCIM | OIDC, SAML, LDAP, SCIM | OIDC, SAML, SCIM | OIDC, SAML (limitado) |
| MFA/2FA                         | Sí (requiere configuración) | Sí (nativo) | Sí (nativo) | Sí (limitado) |
| Personalización de login/branding| Alta | Alta | Media | Baja |
| Facilidad de integración (SDKs, conectores, documentación) | Alta | Alta | Alta | Media |
| Extensibilidad/Flexibilidad     | Alta | Alta | Media | Baja |
| Gestión de usuarios y grupos    | Alta (delegable, self-service) | Alta | Alta | Media |
| Auditoría y reporting           | Media (requiere configuración) | Alta | Alta | Media |
| Seguridad/Compliance            | Alta (depende de despliegue y hardening) | Alta (certificaciones) | Alta (certificaciones) | Media |
| Cumplimiento normativo (GDPR, PCI, etc.) | Depende de despliegue | Certificaciones globales | Certificaciones globales | Limitado |
| Costos                          | Gratis (`open source`) + operación | Pago por usuario | Pago por usuario | Pago por usuario |
| Licenciamiento                  | OSS | SaaS | Propietario | Propietario |
| Comunidad y soporte             | Muy alta (open source) | Alta (SaaS) | Muy alta (enterprise) | Media |
| Portabilidad de datos           | Alta (export/import, backup) | Media | Baja | Baja |
| Automatización (APIs/IaC)       | Alta | Alta | Alta | Media |
| Soporte para automatización de flujos (hooks, triggers) | Alta | Alta | Media | Baja |
| Facilidad de migración          | Alta | Media | Baja | Baja |
| Performance y escalabilidad real| Alta | Alta | Alta | Media |
| Time-to-market para nuevas integraciones | Medio | Alto | Medio | Bajo |
| Riesgo de lock-in               | Bajo | Alto | Alto | Alto |

### Comparativa de costos estimados (2025)

| Solución        | Costo base*         | Costos adicionales                | Infraestructura propia |
|-----------------|---------------------|-----------------------------------|-----------------------|
| `Keycloak`        | Gratis (`open source`)| ~US$20/mes (VM pequeña) + operación| Sí                    |
| `Auth0`           | Gratis hasta 7,000 usuarios/mes | ~US$23/mes por 10,000 usuarios extra | No           |
| `Azure AD`        | ~US$0.00325/usuario/mes | ~US$0.00325/usuario extra/mes | No                |
| `AWS Cognito`     | Gratis hasta 50,000 MAU/mes | ~US$0.0055/MAU extra/mes | No            |

*Precios aproximados, sujetos a variación según proveedor y volumen. Los `IdPs` gestionados pueden tener costos por usuario, autenticación o características avanzadas.

### Agnosticismo, lock-in y mitigación

- **Lock-in:** `Keycloak` es `open source` y ampliamente soportado, minimiza lock-in frente a proveedores propietarios. Permite despliegue `on-premises`, en `cloud` o gestionado.
- **Mitigación:** Usar `claims` y `scopes` estándar y evitar dependencias propietarias facilita la migración entre `IdPs`.

---

## ✔️ DECISIÓN

Se define **[Keycloak](https://www.keycloak.org/)** como estándar de autenticación `OAuth2`, usando `client_credentials` y `JWT` para todos los servicios corporativos.

## Justificación

- Amplio soporte y adopción.
- Autenticación segura entre servicios.
- Soporte nativo `multi-tenant` y `multi-país`, con gestión centralizada por tenant y región.
- Validación local y escalable de tokens `JWT`.
- Integración con `IdPs` empresariales y externos.
- Soporte de scopes, expiración y claims personalizados.
- Facilita la rotación y reduce exposición de credenciales.

## Alternativas descartadas

- **AWS Cognito:** Limitaciones en personalización, dependencia de AWS y costos crecientes `multi-país`.
- **Azure AD:** Complejidad de integración, dependencia de Microsoft y costos por usuario/app `multi-tenant`.
- **Auth0:** Lock-in, costos altos en alto volumen y menor control de despliegue.

---

## ⚠️ CONSECUENCIAS

- Todos los servicios deben validar tokens `JWT` y soportar `OAuth2`.
- Se requiere gestión centralizada de clientes y scopes.
- La documentación debe incluir ejemplos de integración y validación.

---

## 📚 REFERENCIAS

- [OAuth2 RFC6749](https://datatracker.ietf.org/doc/html/rfc6749)
- [JWT RFC7519](https://datatracker.ietf.org/doc/html/rfc7519)
- [Best Practices OAuth2](https://oauth.net/2/grant-types/client-credentials/)
- [Arc42: Decisiones de arquitectura](https://arc42.org/decision/)
