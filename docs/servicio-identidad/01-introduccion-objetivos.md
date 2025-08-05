# 1. Introducción y objetivos

El **Sistema de Identidad** es la plataforma centralizada de autenticación, autorización y gestión de identidades para todos los servicios corporativos. Basado en Keycloak, proporciona capacidades empresariales de Identity and Access Management (IAM) con soporte completo para arquitecturas multi-tenant y multi-país.

## 1.1 Descripción general de los requisitos

### Propósito del Sistema

El sistema de identidad actúa como la autoridad central de confianza para todos los servicios corporativos, proporcionando:
- **Single Sign-On (SSO)** para experiencia unificada de usuario
- **Federación de identidades** con proveedores externos
- **Gestión de ciclo de vida** de usuarios y roles
- **Compliance y auditoría** de accesos y autorizaciones

### Arquitectura del Sistema

| Componente | Propósito | Tecnología Base |
|------------|-----------|-----------------|
| **Keycloak Server** | Identity Provider central | Keycloak 23+, PostgreSQL |
| **Admin Console** | Gestión de realms, usuarios y roles | Keycloak Admin UI |
| **Identity API** | APIs programáticas para integración | Keycloak REST APIs |
| **Federation Connectors** | Integración con IdPs externos | LDAP, SAML, OIDC |

### Requisitos Funcionales Principales

| ID | Requisito | Descripción Detallada |
|----|-----------|-----------------------|
| **RF-ID-01** | **Multi-tenant Authentication** | Autenticación aislada por tenant/país con realms dedicados |
| **RF-ID-02** | **OAuth2/OIDC Compliance** | Soporte completo OAuth2, OIDC con flows estándar |
| **RF-ID-03** | **JWT Token Management** | Generación, validación y refresh de JWT tokens |
| **RF-ID-04** | **Role-Based Access Control** | RBAC granular con roles específicos por tenant |
| **RF-ID-05** | **Federation Support** | Integración con Google Workspace, Microsoft AD, LDAP |
| **RF-ID-06** | **User Lifecycle Management** | CRUD completo de usuarios, activación, desactivación |
| **RF-ID-07** | **Session Management** | Control de sesiones, timeout, concurrent sessions |
| **RF-ID-08** | **Multi-Factor Authentication** | MFA con TOTP, SMS, email para roles críticos |
| **RF-ID-09** | **Audit & Compliance** | Logging completo de eventos de autenticación/autorización |
| **RF-ID-10** | **Self-Service Portal** | Portal para usuarios (password reset, profile management) |

### Modelo Multi-Tenant

| Tenant/País | Realm Keycloak | Users Esperados | Integration Type |
|-------------|----------------|-----------------|------------------|
| **Peru Operations** | `peru-corp` | ~2,000 usuarios | LDAP + Local users |
| **Ecuador Operations** | `ecuador-corp` | ~800 usuarios | Google Workspace federation |
| **Colombia Operations** | `colombia-corp` | ~1,500 usuarios | Microsoft AD federation |
| **Mexico Operations** | `mexico-corp` | ~1,200 usuarios | LDAP + Local users |
| **Corporate Admin** | `admin-corp` | ~50 super-admin | Local users, enhanced MFA |

### Requisitos No Funcionales

| Categoría | Requisito | Target | Medición |
|-----------|-----------|--------|----------|
| **Performance** | Latencia de autenticación | < 200ms P95 | Response time monitoring |
| **Scalability** | Usuarios concurrentes | 10,000+ concurrent sessions | Session monitoring |
| **Availability** | Tiempo de actividad | 99.9% uptime | Health checks, SLA monitoring |
| **Security** | Cumplimiento de estándares | OIDC, SAML 2.0, OAuth 2.1 | Security audits |
| **Compliance** | Retención de logs | 2 años audit logs | Log retention policies |
| **Recovery** | Disaster recovery | RTO 30 min, RPO 5 min | Backup and recovery tests |

## 1.2 Stakeholders

### Stakeholders Principales

| Stakeholder | Rol | Responsabilidad | Expectativas |
|-------------|-----|-----------------|--------------|
| **CISO (Chief Information Security Officer)** | Aprobador | Políticas de seguridad y cumplimiento | Arquitectura zero-trust, cumplimiento GDPR/SOX |
| **Arquitectos Empresariales** | Diseñadores | Arquitectura e integración | Patrones consistentes, escalabilidad |
| **Equipos DevOps** | Operadores | Despliegue y operación | Automatización, monitoreo, confiabilidad |
| **Equipos de Aplicaciones** | Consumidores | Integración de servicios | APIs simples, documentación clara |
| **Usuarios Finales** | Usuarios finales | Experiencia de usuario | SSO sin fricciones, capacidades de autoservicio |
| **Oficiales de Cumplimiento** | Auditores | Auditoría y cumplimiento | Logs completos, reportes de acceso |

### Preocupaciones por Stakeholder

#### CISO & Equipo de Seguridad

- **Zero Trust:** Validación continua de identidad y contexto
- **Principio de Menor Privilegio:** Acceso mínimo necesario
- **Cumplimiento:** Cumplimiento GDPR, SOX, ISO 27001
- **Respuesta a Incidentes:** Detección y respuesta a anomalías

#### Equipos de Desarrollo de Aplicaciones

- **Experiencia del Desarrollador:** SDKs, documentación, ejemplos
- **Simplicidad de Integración:** Estándares de la industria
- **Manejo de Errores:** Mensajes de error claros y accionables
- **Soporte de Pruebas:** Ambientes de testing, servicios mock

#### Equipo de Operaciones

- **Excelencia Operacional:** Disponibilidad 24/7, monitoreo
- **Automatización:** Despliegue automatizado, escalado
- **Rendimiento:** Latencia baja, throughput alto
- **Recuperación ante Desastres:** Procedimientos de backup y recovery

## 1.3 Objetivos de Calidad

### Atributos de Calidad Priorizados

| Atributo | Prioridad | Descripción | Métricas de Éxito |
|----------|-----------|-------------|-------------------|
| **Security** | 🔴 Crítico | Protección de identidades y accesos | Zero security incidents, pentesting passed |
| **Reliability** | 🔴 Crítico | Disponibilidad continua del servicio | 99.9% uptime, MTTR < 15 min |
| **Performance** | 🟡 Alto | Baja latencia en autenticación | < 200ms login, < 100ms token validation |
| **Usability** | 🟡 Alto | Experiencia de usuario fluida | < 3 clicks for common tasks, user satisfaction > 4.5/5 |
| **Scalability** | 🟡 Alto | Soporte de crecimiento organizacional | Support 50K+ users, linear performance scaling |
| **Compliance** | 🔴 Crítico | Cumplimiento regulatorio | 100% audit compliance, GDPR data rights |
| **Maintainability** | 🟢 Medio | Facilidad de evolución | < 2 hours for minor changes, automated testing |
| **Interoperability** | 🟡 Alto | Integración con sistemas externos | Standard protocols (OIDC, SAML), API-first |

### Quality Tree

```text
Identity System Quality
├── Security (Critical)
│   ├── Authentication Security
│   │   ├── Multi-factor authentication
│   │   ├── Password policy enforcement
│   │   └── Session security
│   ├── Authorization Security
│   │   ├── RBAC implementation
│   │   ├── Fine-grained permissions
│   │   └── Tenant isolation
│   └── Data Protection
│       ├── Encryption at rest/transit
│       ├── PII protection
│       └── GDPR compliance
├── Reliability (Critical)
│   ├── High Availability
│   │   ├── Multi-AZ deployment
│   │   ├── Health monitoring
│   │   └── Automatic failover
│   ├── Disaster Recovery
│   │   ├── Backup strategies
│   │   ├── Cross-region replication
│   │   └── Recovery procedures
│   └── Fault Tolerance
│       ├── Circuit breakers
│       ├── Graceful degradation
│       └── Error handling
└── Performance (High)
    ├── Response Time
    │   ├── Authentication latency < 200ms
    │   ├── Token validation < 100ms
    │   └── SSO redirect < 300ms
    ├── Throughput
    │   ├── Concurrent users > 10K
    │   ├── Auth requests > 1K/sec
    │   └── Token generation > 5K/sec
    └── Resource Efficiency
        ├── Memory optimization
        ├── CPU utilization < 70%
        └── Database connection pooling
```

## 1.4 Casos de Uso Principales

### Escenarios de Autenticación

#### UC-ID-01: Employee Login (Primary Flow)

```mermaid
sequenceDiagram
Actor: Corporate Employee
Goal: Acceder al sistema con credenciales corporativas

Preconditions:
- Usuario tiene cuenta activa en el tenant correspondiente
- Usuario tiene credenciales válidas

Main Flow:
1. Usuario accede a aplicación corporativa
2. Sistema redirige a Keycloak login
3. Usuario ingresa credenciales (email/password)
4. Keycloak valida credenciales
5. Keycloak genera JWT token
6. Usuario es redirigido a aplicación con token
7. Aplicación valida token y otorga acceso

Alternative Flows:
- 3a. Usuario selecciona "Login with Google" → Federation flow
- 4a. Credenciales inválidas → Error message, retry
- 4b. Cuenta bloqueada → Contact admin message
- 6a. MFA required → TOTP/SMS verification step

Success Criteria:
- Login completed in < 5 seconds
- JWT token issued with correct claims
- User session established
```

#### UC-ID-02: Service-to-Service Authentication
```
Actor: Microservice (e.g., Notification Service)
Goal: Obtener token para llamar a otro servicio

Preconditions:
- Service tiene client credentials configuradas
- Downstream service acepta tokens de este IdP

Main Flow:
1. Service inicia request a otro service
2. Service verifica si tiene token válido en cache
3. Si no, service solicita token vía client_credentials flow
4. Keycloak valida client credentials
5. Keycloak emite access token con scopes apropiados
6. Service usa token en Authorization header
7. Downstream service valida token
8. Request procesado exitosamente

Success Criteria:
- Token obtained in < 100ms
- Token cached for reuse
- Service-to-service call authenticated
```

#### UC-ID-03: Administrative User Management
```
Actor: Tenant Administrator
Goal: Gestionar usuarios del tenant

Preconditions:
- Admin autenticado con rol admin
- Acceso a Keycloak Admin Console o APIs

Main Flow:
1. Admin accede a user management interface
2. Admin busca/filtra usuarios del tenant
3. Admin selecciona acción (create/update/disable user)
4. Sistema valida permisos de admin para el tenant
5. Operación ejecutada con audit logging
6. Confirmación de operación exitosa

Success Criteria:
- Only tenant users visible/manageable
- All actions logged for audit
- Changes reflected immediately
```

### Escenarios de Federación

#### UC-ID-04: Google Workspace Federation
```
Actor: Employee with Google Account
Goal: Login usando cuenta de Google

Preconditions:
- Google Workspace federation configurada
- Usuario existe en Google directory
- Email domain configurado para federation

Main Flow:
1. Usuario inicia login
2. Usuario selecciona "Login with Google"
3. Redirect a Google OAuth consent
4. Usuario autoriza acceso (si requerido)
5. Google retorna authorization code
6. Keycloak intercambia code por tokens
7. Keycloak mapea claims de Google a usuario local
8. Usuario autenticado en aplicación

Success Criteria:
- Seamless federation experience
- User attributes mapped correctly
- Session established in Keycloak
```

## 1.5 Modelo Operacional

### Gestión Multi-Tenant

| Aspecto | Implementación | Beneficios |
|---------|----------------|------------|
| **Realm Isolation** | Separate Keycloak realms per tenant | Complete tenant data isolation |
| **Admin Delegation** | Realm-specific admin roles | Decentralized user management |
| **Branding** | Custom themes per realm | Tenant-specific UX |
| **Federation** | Different IdP per tenant | Flexible identity source integration |
| **Policies** | Tenant-specific security policies | Compliance per jurisdiction |

### Ciclo de Vida de Usuarios

```text
User Lifecycle States:
PENDING → ACTIVE → SUSPENDED → DISABLED → DELETED

Transitions:
- PENDING → ACTIVE: Email verification or admin approval
- ACTIVE → SUSPENDED: Temporary suspension (policy violation)
- ACTIVE → DISABLED: Permanent deactivation (employee departure)
- SUSPENDED → ACTIVE: Admin reactivation
- DISABLED → DELETED: Data retention policy (after 2 years)
```

### Integración con Sistemas Corporativos

| Sistema | Tipo Integración | Protocolo | Datos Sincronizados |
|---------|-----------------|-----------|-------------------|
| **LDAP Corporate** | User Federation | LDAP/LDAPS | Users, groups, attributes |
| **Google Workspace** | Identity Federation | OIDC | Authentication only |
| **Microsoft AD** | User Federation | LDAP + OIDC | Users, groups, authentication |
| **HRIS System** | User Provisioning | SCIM 2.0 | Employee data, roles |
| **Audit System** | Event Streaming | Kafka | Authentication events, changes |

## Referencias

- [Keycloak Documentation](https://www.keycloak.org/documentation)
- [OAuth 2.1 Security Best Practices](https://datatracker.ietf.org/doc/html/draft-ietf-oauth-security-topics)
- [OpenID Connect Core 1.0](https://openid.net/specs/openid-connect-core-1_0.html)
- [NIST Digital Identity Guidelines](https://pages.nist.gov/800-63-3/)
- [GDPR Compliance for Identity Systems](https://gdpr.eu/compliance/)

### Tipos de Usuarios y Roles

| Tipo Usuario | Descripción | Roles Típicos | MFA Requerido |
|--------------|-------------|---------------|---------------|
| **Operators** | Personal operativo aeroportuario | Operator, Supervisor | No |
| **Managers** | Gestión operacional y administrativa | Manager, Admin | Sí |
| **IT Staff** | Personal técnico y desarrollo | Developer, SysAdmin | Sí |
| **Executives** | Directivos y alta gerencia | Executive, C-Level | Sí |
| **External Partners** | Aerolíneas, proveedores | Partner-Read, Partner-Write | Sí |
| **Service Accounts** | Cuentas para servicios/APIs | System, Integration | No (certificate-based) |

## 1.2 Objetivos de calidad

### Objetivos Primarios

| Prioridad | Objetivo | Escenario | Métrica Objetivo |
|-----------|----------|-----------|------------------|
| **1** | **Security** | Autenticación robusta, tokens seguros | Zero security breaches |
| **2** | **Availability** | Servicio siempre disponible para autenticación | 99.9% uptime |
| **3** | **Performance** | Validación rápida de tokens | p95 < 50ms |

### Objetivos Secundarios

| Objetivo | Descripción | Métrica |
|----------|-------------|---------|
| **Usability** | Experiencia de usuario fluida, SSO efectivo | < 3 clicks to access |
| **Compliance** | Cumplimiento GDPR, SOX, regulaciones locales | 100% audit compliance |
| **Scalability** | Soporte para crecimiento de usuarios | Linear scaling |
| **Maintainability** | Gestión simple de usuarios y roles | Self-service > 80% |

### Atributos de Calidad Específicos

| Atributo | Definición | Implementación | Verificación |
|----------|------------|----------------|--------------|
| **Token Security** | Tokens criptográficamente seguros | RSA-256, short TTL, rotation | Security testing |
| **Session Integrity** | Sesiones no comprometibles | Secure cookies, CSRF protection | Penetration testing |
| **Identity Federation** | Integración confiable con IdPs externos | Standard protocols, error handling | Integration testing |
| **Audit Completeness** | Registro completo de eventos de seguridad | Structured logging, SIEM integration | Audit verification |

## 1.3 Partes interesadas

### Stakeholders Principales

| Rol | Contacto | Responsabilidades | Expectativas |
|-----|----------|-------------------|--------------|
| **CISO (Chief Information Security Officer)** | Security Team | Políticas de seguridad, compliance | Robust security, zero breaches |
| **HR Directors** | HR Teams | User lifecycle, organizational changes | Easy user management, accurate roles |
| **IT Directors** | IT Management | Technical standards, infrastructure | Reliable service, scalable solution |
| **Compliance Officers** | Legal/Audit | Regulatory compliance, audit preparation | Complete audit trails, policy compliance |
| **Operations Managers** | Operations Teams | Day-to-day user access, productivity | Fast authentication, minimal downtime |

### Administradores del Sistema

| Rol | Alcance | Responsabilidades | Herramientas |
|-----|-------|-------------------|--------------|
| **Administrador Global de Identidad** | Todos los realms | Gestión de plataforma, políticas de seguridad | Consola de Administración Keycloak |
| **Administradores de Realm** | Un solo país/tenant | Gestión de usuarios, asignación de roles | UI de administración específica del realm |
| **Administradores de RRHH** | Ciclo de vida de usuarios | Onboarding de usuarios, offboarding | Herramientas de integración RRHH |
| **Administradores de Seguridad** | Políticas de seguridad | Políticas MFA, monitoreo de seguridad | Dashboards de seguridad |
| **Administradores de Auditoría** | Cumplimiento | Reportes de auditoría, monitoreo de cumplimiento | Herramientas de auditoría, SIEM |

### Sistemas Cliente (Service Providers)

| Servicio | Integration Type | Authentication Flow | Token Usage |
|----------|------------------|---------------------|-------------|
| **API Gateway** | OIDC Client | Client Credentials, Authorization Code | JWT validation per request |
| **Notification System** | OIDC Client | Client Credentials | Service-to-service auth |
| **Track & Trace** | OIDC Client | Authorization Code | User context in events |
| **SITA Messaging** | OIDC Client | Client Credentials | Background service auth |
| **Web Applications** | OIDC Client | Authorization Code + PKCE | User session management |
| **Mobile Applications** | OIDC Client | Authorization Code + PKCE | Mobile-optimized flows |

### Proveedores de Identidad Externos

| Provider | Countries | Integration Type | User Count |
|----------|-----------|------------------|------------|
| **Google Workspace** | Ecuador | OIDC Federation | ~800 users |
| **Microsoft AD** | Colombia | SAML Federation | ~1,500 users |
| **Corporate LDAP** | Peru, Mexico | LDAP Connection | ~3,200 users |
| **Government PKI** | All (optional) | Certificate-based | Executive level |

### Autoridades de Cumplimiento

| Autoridad | Jurisdicción | Requisitos | Reportes |
|-----------|--------------|--------------|-----------|
| **Autoridades de Protección de Datos** | UE (GDPR) | Privacidad de datos, gestión de consentimiento | Evaluaciones de impacto de privacidad |
| **Reguladores Financieros** | Local (SOX) | Controles de acceso a datos financieros | Reportes de control de acceso |
| **Autoridades de Aviación** | Todos los países | Seguridad operacional, safety | Reportes de cumplimiento de seguridad |
| **Auditoría Interna** | Corporativo | Controles internos, cumplimiento de políticas | Reportes trimestrales de auditoría |

### Matriz de Comunicación

| Stakeholder | Frecuencia | Canal | Contenido |
|-------------|------------|-------|-----------|
| **CISO** | Semanal | Reportes de seguridad | Análisis de amenazas, patrones de acceso |
| **Directores de RRHH** | Mensual | Reportes de usuarios | Métricas de ciclo de vida de usuarios, cambios de roles |
| **Directores de IT** | Quincenal | Revisiones técnicas | Métricas de rendimiento, planificación de capacidad |
| **Cumplimiento** | Trimestral | Reportes de auditoría | Estado de cumplimiento, hallazgos de auditoría |
| **Operaciones** | Tiempo real | Dashboards, alertas | Estado del servicio, problemas de autenticación |

### Escalation Procedures

| Tipo de Incidente | Soporte L1 | Soporte L2 | Soporte L3 | Externo |
|------------|------------|------------|------------|----------|
| **Fallos de Autenticación** | Mesa de Ayuda IT | Equipo de Identidad | Equipo de Seguridad | Soporte Keycloak |
| **Incidentes de Seguridad** | Equipo SOC | CISO | Equipo Ejecutivo | Seguridad Externa |
| **Problemas de Rendimiento** | Operaciones | Equipo DevOps | Equipo de Arquitectura | Proveedor de Infraestructura |
| **Problemas de Cumplimiento** | Oficial de Cumplimiento | Equipo Legal | Liderazgo Ejecutivo | Auditores Externos |
| **Problemas de Integración** | Equipo de Desarrollo | Arquitecto de Soluciones | Arquitecto Principal | Soporte del Proveedor |
