# 5. Vista de bloques de construcción

## 5.1 Sistema de Identidad - Nivel 1 (Whitebox)

### Responsabilidad
El sistema de identidad centraliza la autenticación y autorización para todo el ecosistema de servicios corporativos, proporcionando un single sign-on (SSO) seguro y escalable.

### Bloques de Construcción Contenidos

#### Keycloak Identity Provider
- **Responsabilidad:** Proveedor de identidad central basado en estándares
- **Tecnología:** Keycloak 23+ con extensiones custom
- **Interfaz:** OAuth2/OIDC, SAML 2.0, LDAP/AD integration

#### Identity Management API
- **Responsabilidad:** API REST para gestión programática de identidades
- **Tecnología:** ASP.NET Core 8 con middleware personalizado
- **Interfaz:** RESTful endpoints + GraphQL queries

#### Token Validation Service
- **Responsabilidad:** Validación distribuida de tokens JWT
- **Tecnología:** .NET 8 con cache distribuido
- **Interfaz:** gRPC para alta performance

#### Audit & Compliance Service
- **Responsabilidad:** Logging y auditoría de eventos de seguridad
- **Tecnología:** Event sourcing con Apache Kafka
- **Interfaz:** Event streams + REST reporting API

## 5.2 Keycloak Identity Provider - Nivel 2 (Whitebox)

### Responsabilidad General
Gestión completa del ciclo de vida de identidades con soporte multi-tenant y multi-región.

### Bloques de Construcción Internos

#### Realm Manager
```
Responsabilidad: Gestión de realms por tenant/país
Interfaz: Admin API + Custom SPI
Implementación: Keycloak Custom Provider
```

#### Authentication Flows
```
Responsabilidad: Flujos de autenticación personalizados
Componentes:
  - MFA Flow (SMS, Email, TOTP)
  - Risk Assessment Flow
  - Device Registration Flow
  - Federated Login Flow
```

#### User Federation
```
Responsabilidad: Integración con directorios existentes
Integraciones:
  - Active Directory LDAP
  - Azure AD (SAML/OIDC)
  - Legacy Database Users
  - HR Systems (SCIM)
```

#### Session Management
```
Responsabilidad: Gestión de sesiones distribuidas
Tecnología: Redis Cluster para session store
Características:
  - Session timeout personalizable
  - Concurrent session control
  - Cross-realm SSO
```

## 5.3 Identity Management API - Nivel 2 (Whitebox)

### Controladores Principales

#### User Management Controller
```csharp
[Route("api/v1/users")]
public class UserController : ControllerBase
{
    // CRUD operations
    // Bulk user operations
    // Profile management
    // Password reset workflows
}
```

#### Tenant Management Controller
```csharp
[Route("api/v1/tenants")]
public class TenantController : ControllerBase
{
    // Tenant provisioning
    // Realm configuration
    // Branding customization
    // Feature toggles
}
```

#### Role & Permission Controller
```csharp
[Route("api/v1/roles")]
public class RoleController : ControllerBase
{
    // RBAC management
    // Permission assignments
    // Role hierarchies
    // Attribute-based access control
}
```

### Servicios de Dominio

#### User Provisioning Service
- **Responsabilidad:** Orquestación de creación de usuarios
- **Dependencias:** Keycloak Admin API, Notification Service
- **Patrones:** Saga pattern para operaciones distribuidas

#### Compliance Service
- **Responsabilidad:** Cumplimiento GDPR, SOX, auditorías
- **Características:** Data retention, anonymization, export
- **Storage:** Event store para trazabilidad completa

#### Integration Service
- **Responsabilidad:** Conectores con sistemas externos
- **Protocolos:** SCIM 2.0, LDAP, REST APIs
- **Sync:** Real-time + batch synchronization

## 5.4 Token Validation Service - Nivel 2 (Whitebox)

### Componentes Core

#### JWT Validator
```csharp
public interface IJwtValidator
{
    Task<ValidationResult> ValidateTokenAsync(string token);
    Task<ClaimsPrincipal> GetPrincipalAsync(string token);
    Task<bool> IsTokenActiveAsync(string jti);
}
```

#### Key Management
- **Responsabilidad:** Rotación automática de claves JWT
- **Algoritmos:** RS256, ES256, PS256
- **Storage:** Azure Key Vault + local cache
- **Rotation:** Automated every 90 days

#### Token Cache
- **Tecnología:** Redis con TTL automático
- **Estrategia:** Token signature + claims cache
- **Invalidation:** Real-time via pub/sub
- **Performance:** < 5ms token validation

#### Introspection Endpoint
```http
POST /token/introspect
Content-Type: application/x-www-form-urlencoded

token=<access_token>&
token_type_hint=access_token
```

## 5.5 Audit & Compliance Service - Nivel 2 (Whitebox)

### Event Collectors

#### Authentication Events
```json
{
  "eventType": "USER_LOGIN",
  "timestamp": "2024-08-04T10:30:00Z",
  "userId": "user123",
  "tenantId": "tenant456",
  "sourceIp": "192.168.1.100",
  "userAgent": "Mozilla/5.0...",
  "result": "SUCCESS",
  "mfaMethod": "TOTP"
}
```

#### Administrative Events
```json
{
  "eventType": "USER_CREATED",
  "timestamp": "2024-08-04T10:30:00Z",
  "adminUserId": "admin123",
  "targetUserId": "user456",
  "changes": {
    "email": "new@example.com",
    "roles": ["USER", "VIEWER"]
  }
}
```

### Compliance Reporters

#### GDPR Compliance
- **Data Subject Requests:** Automated export/delete
- **Consent Management:** Granular permission tracking
- **Data Mapping:** Complete user data inventory
- **Breach Notification:** Automated regulatory reporting

#### SOX Compliance
- **Access Reviews:** Quarterly certification workflows
- **Segregation of Duties:** Conflict detection
- **Change Management:** All identity changes logged
- **Financial Controls:** ERP system access monitoring

## 5.6 Interfaces Externas

### Downstream Services
```yaml
Service Integrations:
  - API Gateway: Token validation
  - Notification Service: MFA codes, alerts
  - Audit Service: Security events
  - Corporate Services: User context
```

### External Identity Providers
```yaml
Federation Partners:
  - Microsoft Azure AD
  - Google Workspace
  - SAML Enterprise IdPs
  - LDAP Directories
```

### Monitoring & Observability
```yaml
Integrations:
  - Prometheus: Metrics export
  - Grafana: Identity dashboards
  - Jaeger: Distributed tracing
  - ELK Stack: Centralized logging
```

## Referencias
- [Keycloak Architecture Guide](https://www.keycloak.org/docs/latest/server_development/)
- [OAuth2/OIDC Specifications](https://oauth.net/2/)
- [NIST Digital Identity Guidelines](https://pages.nist.gov/800-63-3/)
- [Arc42 Building Blocks](https://docs.arc42.org/section-5/)
