# 3. Contexto y alcance del sistema

El **Sistema de Identidad** actúa como la autoridad central de autenticación y autorización para todo el ecosistema de servicios corporativos, proporcionando Single Sign-On (SSO) y gestión de identidades multi-tenant.

## 3.1 Contexto de negocio

### Propósito del Sistema

El sistema de identidad es la piedra angular de la seguridad corporativa, proporcionando:

- **Autenticación centralizada** para todos los usuarios del ecosistema
- **Autorización granular** basada en roles y permisos específicos por tenant
- **Single Sign-On (SSO)** para una experiencia de usuario uniforme
- **Federación de identidades** con proveedores externos corporativos
- **Gestión de ciclo de vida** completo de usuarios y credenciales

### Stakeholders Principales

| Stakeholder | Rol | Responsabilidad | Expectativa |
|-------------|-----|----------------|-------------|
| **CISO** | Chief Information Security Officer | Políticas de seguridad, compliance | Sistema seguro, zero breaches |
| **HR Directors** | Recursos Humanos | Gestión de usuarios, onboarding/offboarding | Proceso eficiente, automatización |
| **IT Operations** | Operaciones TI | Mantenimiento diario, soporte usuarios | Sistema estable, fácil administración |
| **Compliance Officers** | Oficiales de Cumplimiento | Auditoría, regulaciones | Trazabilidad completa, reportes |
| **End Users** | Usuarios Finales | Acceso a aplicaciones | Experiencia fluida, seguridad transparente |

### Objetivos de Negocio

| Objetivo | Descripción | Métricas de Éxito |
|----------|-------------|-------------------|
| **Seguridad Centralizada** | Punto único de autenticación y autorización | Zero security breaches, 100% audit compliance |
| **Experiencia de Usuario** | SSO transparente para aplicaciones corporativas | < 3 clicks para acceso, 95% user satisfaction |
| **Eficiencia Operativa** | Automatización de gestión de usuarios | 80% self-service, tiempo onboarding < 15 min |
| **Compliance Regulatorio** | Cumplimiento GDPR, SOX, regulaciones locales | 100% audit success, zero violations |
| **Escalabilidad Multi-tenant** | Soporte crecimiento por países | Linear scaling, tenant isolation |

## 3.2 Contexto técnico

### Posición en la Arquitectura

```
┌─────────────────────────────────────────────────────────────────┐
│                    External Identity Providers                  │
│  [Google Workspace] [Microsoft AD] [Corporate LDAP] [Gov PKI]  │
└─────────────────────┬───────────────────────────────────────────┘
                      │ SAML/OIDC Federation
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                    IDENTITY SYSTEM (Keycloak)                  │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐│
│  │Peru Realm   │ │Ecuador Realm│ │Colombia Realm│ │Mexico Realm ││
│  │Users: 2000  │ │Users: 800   │ │Users: 1500  │ │Users: 1200 ││
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘│
└─────────────────────┬───────────────────────────────────────────┘
                      │ OAuth2/OIDC, JWT Tokens
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                      API GATEWAY (YARP)                        │
│              Token Validation & Authorization                   │
└─────────────────────┬───────────────────────────────────────────┘
                      │ Authenticated Requests
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                 CORPORATE SERVICES ECOSYSTEM                   │
│ [Notification] [Track&Trace] [SITA Messaging] [Web Apps]      │
└─────────────────────────────────────────────────────────────────┘
```

### Fronteras del Sistema

#### Dentro del Alcance

| Componente | Descripción | Responsabilidad |
|------------|-------------|-----------------|
| **Keycloak Identity Provider** | Core IdP server | Authentication, authorization, user management |
| **Realm Management** | Multi-tenant realms | Per-country tenant isolation |
| **User Federation** | External IdP integration | LDAP, SAML, OIDC federation |
| **Token Management** | JWT lifecycle | Token generation, validation, refresh |
| **Admin Console** | Management interface | User/role administration |
| **APIs Programáticas** | REST APIs | Programmatic user management |
| **Audit & Logging** | Security events | Complete audit trail |

#### Fuera del Alcance

| Componente | Razón de Exclusión | Responsable |
|------------|-------------------|-------------|
| **External Identity Providers** | Third-party systems | Google, Microsoft, IT Teams |
| **Client Applications** | Service consumers | Individual service teams |
| **Network Infrastructure** | Infrastructure layer | Infrastructure team |
| **Certificate Management** | PKI infrastructure | Security team |
| **Monitoring Platform** | Observability tools | DevOps team |

## 3.3 Interfaces externas

### Actores Principales

| Actor | Tipo | Descripción | Interacciones |
|-------|------|-------------|---------------|
| **System Administrator** | Humano | Administrador global del sistema | Configuración realms, políticas globales |
| **Realm Administrator** | Humano | Administrador por país/tenant | Gestión usuarios, roles específicos |
| **HR Administrator** | Humano | Gestión de recursos humanos | Onboarding, offboarding usuarios |
| **End User** | Humano | Usuario final del sistema | Login, profile management, password reset |
| **Service Account** | Sistema | Cuentas para servicios/APIs | Service-to-service authentication |

### Sistemas Externos

| Sistema | Tipo | Protocolo | Propósito | Datos Intercambiados |
|---------|------|-----------|-----------|---------------------|
| **Google Workspace** | External IdP | OIDC Federation | Autenticación Ecuador | User profile, groups, authentication |
| **Microsoft AD** | External IdP | SAML Federation | Autenticación Colombia | User attributes, group membership |
| **Corporate LDAP** | Directory | LDAP v3 | User federation Peru/Mexico | User data, organizational structure |
| **API Gateway** | Internal Service | OAuth2/OIDC | Token validation | JWT tokens, user claims |
| **Notification System** | Internal Service | OAuth2 Client Credentials | Service authentication | Service tokens, scopes |
| **Track & Trace** | Internal Service | OAuth2 Authorization Code | User context | User tokens, permissions |
| **SITA Messaging** | Internal Service | OAuth2 Client Credentials | Background authentication | Service tokens, API access |

### Interfaces de Datos

#### Entrada de Datos

| Interface | Fuente | Tipo de Datos | Frecuencia | Formato |
|-----------|--------|---------------|------------|---------|
| **User Federation** | LDAP Directories | User attributes, groups | Sync: 4x/day | LDAP entries |
| **SAML Assertions** | External IdPs | Authentication responses | Real-time | SAML XML |
| **API Requests** | Client applications | Authentication requests | Real-time | OAuth2/OIDC |
| **Admin Operations** | Administrators | User management | On-demand | REST API calls |

#### Salida de Datos

| Interface | Destino | Tipo de Datos | Frecuencia | Formato |
|-----------|---------|---------------|------------|---------|
| **JWT Tokens** | Client applications | User claims, permissions | Real-time | JWT (JSON) |
| **User Info** | Authorized clients | User profile data | On-demand | JSON |
| **Audit Events** | SIEM systems | Security events | Real-time | Structured logs |
| **Metrics** | Monitoring systems | Performance metrics | Continuous | Prometheus metrics |

## 3.4 Alcance funcional

### Funcionalidades Incluidas

| Función | Descripción | Usuarios Objetivo | Prioridad |
|---------|-------------|-------------------|-----------|
| **Multi-tenant Authentication** | Autenticación aislada por realm/país | Todos los usuarios | Alta |
| **Single Sign-On (SSO)** | Acceso unificado a aplicaciones | End users | Alta |
| **Role-Based Access Control** | Autorización granular basada en roles | Administradores, end users | Alta |
| **Identity Federation** | Integración con IdPs externos | Usuarios federados | Alta |
| **User Lifecycle Management** | CRUD completo de usuarios | HR administrators | Media |
| **Self-Service Portal** | Gestión autónoma de perfiles | End users | Media |
| **Multi-Factor Authentication** | Seguridad adicional para roles críticos | Usuarios privilegiados | Media |
| **Session Management** | Control de sesiones y timeouts | Todos los usuarios | Media |
| **Audit & Compliance** | Logging y reportes de seguridad | Compliance officers | Baja |

### Funcionalidades Excluidas

| Función | Razón de Exclusión | Alternativa |
|---------|-------------------|-------------|
| **Certificate Authority** | Fuera del dominio de identidad | External PKI systems |
| **Email Server** | No es responsabilidad de identidad | Corporate email systems |
| **LDAP Server** | Federación, no hosting | External LDAP directories |
| **Application Authorization** | Responsabilidad de aplicaciones | Application-level RBAC |
| **Data Storage** | Solo metadata de usuario | Business data in applications |

## 3.5 Casos de uso principales

### Autenticación de Usuario

```
Actor: End User
Precondición: Usuario tiene credenciales válidas
Flujo Principal:
1. Usuario accede a aplicación corporativa
2. Aplicación redirige a Identity System
3. Identity System presenta login form
4. Usuario ingresa credenciales
5. Identity System valida credenciales
6. Sistema genera JWT token
7. Usuario es redirigido a aplicación con token
8. Aplicación valida token y otorga acceso
Postcondición: Usuario autenticado con sesión activa
```

### Federación con External IdP

```
Actor: External User (via Google/Microsoft)
Precondición: Federación configurada
Flujo Principal:
1. Usuario accede a aplicación corporativa
2. Aplicación redirige a Identity System
3. Usuario selecciona external IdP
4. Identity System redirige a external IdP
5. Usuario se autentica en external IdP
6. External IdP retorna SAML/OIDC assertion
7. Identity System procesa assertion
8. Sistema genera JWT token interno
9. Usuario redirigido a aplicación
Postcondición: Usuario federado autenticado
```

### Gestión de Usuarios por HR

```
Actor: HR Administrator
Precondición: Administrator tiene permisos de gestión
Flujo Principal:
1. HR admin accede a admin console
2. Admin selecciona realm específico
3. Admin crea nuevo usuario
4. Sistema valida datos y reglas de negocio
5. Usuario creado en realm correspondiente
6. Sistema envía notificación de activación
7. Sistema registra acción en audit log
Postcondición: Usuario disponible para autenticación
```

### Service-to-Service Authentication

```
Actor: Corporate Service
Precondición: Service tiene client credentials
Flujo Principal:
1. Service necesita acceder a otro service
2. Service solicita token con client credentials
3. Identity System valida client credentials
4. Sistema genera service token con scopes
5. Service usa token para llamar API destino
6. API destino valida token con Identity System
7. API otorga acceso basado en scopes
Postcondición: Service-to-service communication autorizada
```

## 3.6 Atributos de calidad

### Performance

| Atributo | Métrica | Target | Medición |
|----------|---------|--------|----------|
| **Authentication Latency** | Response time | p95 < 100ms | APM monitoring |
| **Token Validation** | Validation time | p95 < 50ms | API monitoring |
| **Concurrent Users** | Simultaneous sessions | 10,000 users | Load testing |
| **Throughput** | Authentications/second | 1,000 auth/sec | Performance testing |

### Security

| Atributo | Métrica | Target | Medición |
|----------|---------|--------|----------|
| **Security Incidents** | Breaches per year | Zero incidents | Security monitoring |
| **Token Security** | Compromised tokens | Zero compromises | Token monitoring |
| **Failed Login Attempts** | Brute force attacks | < 0.1% success rate | Authentication monitoring |
| **Audit Completeness** | Events logged | 100% coverage | Audit verification |

### Availability

| Atributo | Métrica | Target | Medición |
|----------|---------|--------|----------|
| **System Uptime** | Service availability | 99.9% | Health monitoring |
| **Recovery Time** | RTO | < 4 hours | Disaster recovery testing |
| **Data Loss** | RPO | < 15 minutes | Backup validation |
| **Mean Time to Recovery** | MTTR | < 30 minutes | Incident response |

## Referencias

### Standards y Protocolos
- [OAuth 2.0 Authorization Framework (RFC 6749)](https://tools.ietf.org/html/rfc6749)
- [OpenID Connect Core 1.0](https://openid.net/specs/openid-connect-core-1_0.html)
- [SAML 2.0 Core Specification](https://docs.oasis-open.org/security/saml/v2.0/saml-core-2.0-os.pdf)

### Keycloak Documentation
- [Keycloak Server Administration Guide](https://www.keycloak.org/docs/latest/server_admin/)
- [Keycloak Securing Applications Guide](https://www.keycloak.org/docs/latest/securing_apps/)

### Architecture References
- [Arc42 Context Template](https://docs.arc42.org/section-3/)
- [C4 Model for Software Architecture](https://c4model.com/)
