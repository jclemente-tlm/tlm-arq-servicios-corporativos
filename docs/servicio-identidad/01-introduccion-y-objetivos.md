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
| **Performance** | Token validation latency | p95 < 50ms | APM monitoring |
| **Performance** | Authentication throughput | 1,000 logins/minute | Load testing |
| **Availability** | Identity service uptime | 99.9% | SLA monitoring |
| **Security** | Token security | RSA-256 signing, short TTL | Security audits |
| **Scalability** | Concurrent users | 10,000 concurrent sessions | Capacity testing |
| **Compliance** | Audit trail completeness | 100% events logged | Audit verification |

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

| Rol | Scope | Responsabilidades | Herramientas |
|-----|-------|-------------------|--------------|
| **Global Identity Admin** | All realms | Platform management, security policies | Keycloak Admin Console |
| **Realm Administrators** | Single country/tenant | User management, role assignment | Realm-specific admin UI |
| **HR Administrators** | User lifecycle | User onboarding, offboarding | HR integration tools |
| **Security Administrators** | Security policies | MFA policies, security monitoring | Security dashboards |
| **Audit Administrators** | Compliance | Audit reports, compliance monitoring | Audit tools, SIEM |

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

### Autoridades de Compliance

| Authority | Jurisdiction | Requirements | Reporting |
|-----------|--------------|--------------|-----------|
| **Data Protection Authorities** | EU (GDPR) | Data privacy, consent management | Privacy impact assessments |
| **Financial Regulators** | Local (SOX) | Financial data access controls | Access control reports |
| **Aviation Authorities** | All countries | Operational security, safety | Security compliance reports |
| **Internal Audit** | Corporate | Internal controls, policy compliance | Quarterly audit reports |

### Matriz de Comunicación

| Stakeholder | Frecuencia | Canal | Contenido |
|-------------|------------|-------|-----------|
| **CISO** | Weekly | Security reports | Threat analysis, access patterns |
| **HR Directors** | Monthly | User reports | User lifecycle metrics, role changes |
| **IT Directors** | Bi-weekly | Technical reviews | Performance metrics, capacity planning |
| **Compliance** | Quarterly | Audit reports | Compliance status, audit findings |
| **Operations** | Real-time | Dashboards, alerts | Service status, authentication issues |

### Escalation Procedures

| Issue Type | L1 Support | L2 Support | L3 Support | External |
|------------|------------|------------|------------|----------|
| **Authentication Failures** | IT Helpdesk | Identity Team | Security Team | Keycloak Support |
| **Security Incidents** | SOC Team | CISO | Executive Team | External Security |
| **Performance Issues** | Operations | DevOps Team | Architecture Team | Infrastructure Vendor |
| **Compliance Issues** | Compliance Officer | Legal Team | Executive Leadership | External Auditors |
| **Integration Problems** | Development Team | Solution Architect | Principal Architect | Vendor Support |
