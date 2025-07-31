# ADR-008: Autenticaciones

## Estado

Aceptada – Julio 2025

## Contexto

Se necesita un mecanismo de autenticación seguro, interoperable y centralizado para servicios multi-tenant y multi-país, que permita integración con aplicaciones internas y externas y soporte automatización (machine-to-machine).

Las alternativas evaluadas fueron:
- **Keycloak (open source, multi-tenant, multi-país)**
- **Auth0 (SaaS, multi-tenant)**
- **Azure AD (cloud, multi-tenant)**
- **AWS Cognito (cloud, multi-tenant)**

## Decisión

Se define **Keycloak** como estándar de autenticación OAuth2, usando `client_credentials` y JWT para todos los servicios corporativos.

## Justificación
- Amplio soporte y adopción.
- Autenticación segura entre servicios.
- Soporte nativo multi-tenant y multi-país, con gestión centralizada por tenant y región.
- Validación local y escalable de tokens JWT.
- Integración con IdPs empresariales y externos.
- Soporte de scopes, expiración y claims personalizados.
- Facilita la rotación y reduce exposición de credenciales.

### Comparativa de alternativas
| Criterio                | Keycloak | Auth0 | Azure AD | AWS Cognito |
|------------------------|----------|-------|----------|-------------|
| Agnosticismo           | Alto (open source) | Medio (SaaS) | Medio (cloud) | Medio (cloud) |
| Multi-tenant           | Sí       | Sí    | Sí       | Sí          |
| Multi-país             | Sí       | Sí    | Sí       | Sí          |
| Seguridad              | Alta     | Alta  | Alta     | Alta        |
| Escalabilidad          | Alta     | Alta  | Alta     | Alta        |
| Interoperabilidad      | Alta     | Alta  | Alta     | Alta        |
| Soporte estándar       | Sí       | Sí    | Sí       | Sí          |
| Rotación credenciales  | Sencilla | Sencilla | Sencilla | Sencilla  |
| Claims y scopes        | Sí       | Sí    | Sí       | Sí          |
| Personalización        | Alta     | Media | Baja     | Baja        |
| Despliegue flexible    | Sí       | No    | No       | No          |

### Comparativa de costos estimados (2025)
| Solución        | Costo base*         | Costos adicionales                | Infraestructura propia |
|-----------------|---------------------|-----------------------------------|-----------------------|
| Keycloak        | Gratis (open source)| ~US$20/mes (VM pequeña) + operación| Sí                    |
| Auth0           | Gratis hasta 7,000 usuarios/mes | ~US$23/mes por 10,000 usuarios extra | No           |
| Azure AD        | ~US$0.00325/usuario/mes | ~US$0.00325/usuario extra/mes | No                |
| AWS Cognito     | Gratis hasta 50,000 MAU/mes | ~US$0.0055/MAU extra/mes | No            |

*Precios aproximados, sujetos a variación según proveedor y volumen. Los IdPs gestionados pueden tener costos por usuario, autenticación o características avanzadas.

### Agnosticismo, lock-in y mitigación
- **Lock-in:** Keycloak es open source y ampliamente soportado, minimiza lock-in frente a proveedores propietarios. Permite despliegue on-premises, en cloud o gestionado.
- **Mitigación:** Usar claims y scopes estándar y evitar dependencias propietarias facilita la migración entre IdPs.



## Alternativas descartadas

- **AWS Cognito:** Limitaciones en personalización, dependencia de AWS y costos crecientes multi-país.
- **Azure AD:** Complejidad de integración, dependencia de Microsoft y costos por usuario/app multi-tenant.
- **Auth0:** Lock-in, costos altos en alto volumen y menor control de despliegue.

## Implicaciones
- Todos los servicios deben validar tokens JWT y soportar OAuth2.
- Se requiere gestión centralizada de clientes y scopes.
- La documentación debe incluir ejemplos de integración y validación.

## Referencias
- [OAuth2 RFC6749](https://datatracker.ietf.org/doc/html/rfc6749)
- [JWT RFC7519](https://datatracker.ietf.org/doc/html/rfc7519)
- [Best Practices OAuth2](https://oauth.net/2/grant-types/client-credentials/)
- [Arc42: Decisiones de arquitectura](https://arc42.org/decision/)
