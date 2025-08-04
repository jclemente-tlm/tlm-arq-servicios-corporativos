# 6. Vista de tiempo de ejecución

## 6.1 Escenario: Autenticación de Usuario (Login Flow)

### Descripción
Flujo completo de autenticación de usuario desde aplicación cliente hasta obtención de token JWT válido.

### Participantes
- **Client Application:** Aplicación web/móvil del usuario
- **API Gateway:** Punto de entrada unificado
- **Keycloak:** Proveedor de identidad central
- **Identity API:** API de gestión de identidades
- **Token Validation Service:** Servicio de validación distribuida

### Flujo de Ejecución

```mermaid
sequenceDiagram
    participant Client as Cliente
    participant Gateway as API Gateway
    participant KC as Keycloak
    participant IdAPI as Identity API
    participant TokenSvc as Token Service
    participant AuditSvc as Audit Service

    Client->>Gateway: 1. GET /api/protected-resource
    Gateway->>Gateway: 2. Verificar token JWT
    Gateway->>Client: 3. HTTP 401 Unauthorized

    Client->>KC: 4. POST /auth/realms/{tenant}/protocol/openid-connect/auth
    KC->>KC: 5. Validar credenciales
    KC->>IdAPI: 6. GET /api/user/{userId}/profile
    IdAPI->>KC: 7. User profile data
    KC->>AuditSvc: 8. Publish LOGIN_ATTEMPT event
    KC->>Client: 9. JWT Access Token + Refresh Token

    Client->>Gateway: 10. GET /api/protected-resource (with token)
    Gateway->>TokenSvc: 11. Validate JWT
    TokenSvc->>TokenSvc: 12. Verify signature & claims
    TokenSvc->>Gateway: 13. Token validation result
    Gateway->>Client: 14. HTTP 200 + Resource data
```

### Detalles Temporales
- **Paso 4-9:** Autenticación completa < 500ms
- **Paso 11-13:** Validación de token < 10ms (cached)
- **Timeout total:** 30 segundos para flow completo

## 6.2 Escenario: Provisioning de Usuario Multi-Tenant

### Descripción
Creación automática de usuario en múltiples realms cuando se registra en tenant específico.

### Participantes
- **Admin Console:** Interfaz administrativa
- **Identity API:** API de gestión
- **Keycloak Admin API:** API administrativa de Keycloak
- **User Federation Service:** Servicio de sincronización
- **Notification Service:** Servicio de notificaciones

### Flujo de Ejecución

```mermaid
sequenceDiagram
    participant Admin as Admin Console
    participant IdAPI as Identity API
    participant KC as Keycloak
    participant Fed as Federation Service
    participant NotifSvc as Notification Service
    participant LDAP as External LDAP

    Admin->>IdAPI: 1. POST /api/users (bulk create)
    IdAPI->>IdAPI: 2. Validate user data
    IdAPI->>KC: 3. POST /admin/realms/{tenant}/users
    KC->>Fed: 4. Trigger federation sync
    Fed->>LDAP: 5. CREATE user in LDAP
    LDAP->>Fed: 6. User created successfully
    Fed->>IdAPI: 7. Federation sync complete
    IdAPI->>NotifSvc: 8. Send welcome email
    NotifSvc->>Admin: 9. Email sent confirmation
    IdAPI->>Admin: 10. HTTP 201 User created
```

### Políticas de Retry
- **LDAP Sync Failure:** 3 reintentos con backoff exponencial
- **Email Failure:** 5 reintentos, fallback a SMS
- **Keycloak API Failure:** Circuit breaker tras 5 fallos consecutivos

## 6.3 Escenario: Token Refresh y Renovación

### Descripción
Renovación automática de tokens JWT antes de expiración para mantener sesión activa.

### Flujo de Ejecución

```mermaid
sequenceDiagram
    participant Client as Client App
    participant TokenSvc as Token Service
    participant KC as Keycloak
    participant Cache as Redis Cache
    participant AuditSvc as Audit Service

    Client->>Client: 1. Detect token expiring (5min before)
    Client->>KC: 2. POST /token/refresh
    KC->>Cache: 3. Check refresh token blacklist
    Cache->>KC: 4. Token valid
    KC->>KC: 5. Generate new access token
    KC->>Cache: 6. Cache new token metadata
    KC->>AuditSvc: 7. Log TOKEN_REFRESH event
    KC->>Client: 8. New access token

    Client->>TokenSvc: 9. Validate new token
    TokenSvc->>Cache: 10. Check token cache
    Cache->>TokenSvc: 11. Token metadata
    TokenSvc->>Client: 12. Token valid
```

### Performance Metrics
- **Token refresh time:** < 100ms
- **Cache hit ratio:** > 95%
- **Concurrent refresh capacity:** 1000 req/sec

## 6.4 Escenario: Federación con Identity Provider Externo

### Descripción
Autenticación delegada a proveedor externo (Azure AD, Google) con mapping de atributos.

### Flujo de Ejecución

```mermaid
sequenceDiagram
    participant User as Usuario
    participant App as App Cliente
    participant KC as Keycloak
    participant AzureAD as Azure AD
    participant IdAPI as Identity API
    participant AuditSvc as Audit Service

    User->>App: 1. Click "Login with Azure"
    App->>KC: 2. Redirect to federated login
    KC->>AzureAD: 3. SAML AuthnRequest
    AzureAD->>User: 4. Azure login page
    User->>AzureAD: 5. Enter credentials
    AzureAD->>KC: 6. SAML Response + attributes
    KC->>IdAPI: 7. Map external attributes
    IdAPI->>KC: 8. Enriched user profile
    KC->>AuditSvc: 9. Log FEDERATED_LOGIN
    KC->>App: 10. Redirect with JWT token
    App->>User: 11. Successful login
```

### Attribute Mapping
```yaml
Azure AD → Keycloak:
  - mail → email
  - givenName → firstName
  - surname → lastName
  - department → organization
  - groups → roles (conditional mapping)
```

## 6.5 Escenario: Logout y Session Termination

### Descripción
Terminación segura de sesión con invalidación de tokens en todos los servicios.

### Flujo de Ejecución

```mermaid
sequenceDiagram
    participant Client as Cliente
    participant Gateway as API Gateway
    participant KC as Keycloak
    participant TokenSvc as Token Service
    participant Cache as Redis Cache
    participant Services as Corp Services

    Client->>KC: 1. POST /logout
    KC->>Cache: 2. Blacklist refresh token
    KC->>TokenSvc: 3. Invalidate session tokens
    TokenSvc->>Cache: 4. Add access tokens to blacklist
    KC->>Services: 5. Broadcast LOGOUT event (SSE)
    Services->>Services: 6. Cleanup user sessions
    KC->>Gateway: 7. Revoke API gateway sessions
    KC->>Client: 8. Logout confirmation
    Client->>Client: 9. Clear local tokens
```

### Security Considerations
- **Token blacklist TTL:** Igual a token expiration time
- **Session cleanup:** Async para no bloquear logout
- **Event propagation:** < 5 segundos para todos los servicios

## 6.6 Escenario: Multi-Factor Authentication (MFA)

### Descripción
Flujo de autenticación de segundo factor utilizando TOTP o SMS.

### Flujo de Ejecución

```mermaid
sequenceDiagram
    participant User as Usuario
    participant Client as Cliente
    participant KC as Keycloak
    participant MFA as MFA Service
    participant SMS as SMS Provider
    participant AuditSvc as Audit Service

    User->>Client: 1. Submit credentials
    Client->>KC: 2. First factor authentication
    KC->>KC: 3. Check MFA requirement
    KC->>MFA: 4. Generate TOTP/SMS code
    MFA->>SMS: 5. Send SMS code (if SMS method)
    KC->>Client: 6. Request second factor
    Client->>User: 7. Show MFA prompt
    User->>Client: 8. Enter MFA code
    Client->>KC: 9. Submit MFA code
    KC->>MFA: 10. Validate code
    MFA->>KC: 11. Validation result
    KC->>AuditSvc: 12. Log MFA_SUCCESS/FAILURE
    KC->>Client: 13. Complete authentication
```

### MFA Policies
- **Code validity:** 30 segundos (TOTP), 5 minutos (SMS)
- **Rate limiting:** 3 intentos por 15 minutos
- **Backup codes:** 10 códigos de un solo uso

## 6.7 Escenario: Compliance y Auditoría

### Descripción
Captura automática de eventos de auditoría para cumplimiento regulatorio.

### Flujo de Ejecución

```mermaid
sequenceDiagram
    participant KC as Keycloak
    participant IdAPI as Identity API
    participant AuditSvc as Audit Service
    participant Kafka as Event Stream
    participant ComplianceDB as Compliance Store
    participant SIEM as SIEM System

    KC->>AuditSvc: 1. Auth event (login/logout/failed)
    IdAPI->>AuditSvc: 2. Admin action (user create/delete)
    AuditSvc->>Kafka: 3. Publish structured event
    Kafka->>ComplianceDB: 4. Store for long-term retention
    Kafka->>SIEM: 5. Real-time security monitoring

    Note over ComplianceDB: GDPR: 6 years retention
    Note over SIEM: Real-time alerting
```

### Audit Event Types
- **Authentication Events:** Login, logout, MFA, failed attempts
- **Administrative Events:** User CRUD, role changes, config updates
- **Access Events:** Resource access, permission checks
- **Security Events:** Suspicious activity, brute force, anomalies

## Referencias
- [OAuth2 Flow Specifications](https://tools.ietf.org/html/rfc6749)
- [Keycloak Event SPI Documentation](https://www.keycloak.org/docs/latest/server_development/#_events)
- [JWT Best Practices](https://tools.ietf.org/html/rfc8725)
- [Arc42 Runtime View](https://docs.arc42.org/section-6/)
