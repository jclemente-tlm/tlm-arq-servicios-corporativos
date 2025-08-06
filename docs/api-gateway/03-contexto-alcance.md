# 3. Contexto y Alcance del Sistema

## 3.1 Contexto del Negocio

El API Gateway de Servicios Corporativos actúa como el punto de entrada unificado para todas las aplicaciones cliente, proporcionando un intermediario inteligente que gestiona la autenticación, autorización, enrutamiento y observabilidad de las comunicaciones entre sistemas externos e internos.

![API Gateway Context](../../diagrams/api_gateway.png)

*Diagrama C4 - Contexto del API Gateway mostrando clientes externos, servicios internos y flujos de comunicación.*

### Stakeholders Principales

| Stakeholder | Rol | Expectativas | Interés |
|-------------|-----|---------------|---------|
| **Desarrolladores Frontend** | Consumidores API | APIs consistentes, documentación clara | Productividad de desarrollo |
| **Desarrolladores Móviles** | Consumidores API | Rendimiento, compatibilidad offline | Experiencia de usuario |
| **Ingenieros DevOps** | Operadores | Observabilidad, escalabilidad | Estabilidad operacional |
| **Equipo de Seguridad** | Auditores | Compliance, seguridad centralizada | Gestión de riesgos |
| **Usuarios Empresariales** | Usuarios finales | Disponibilidad, rendimiento | Continuidad del negocio |
| **Socios Externos** | Integradores | Interfaces estables, SLAs claros | Integración confiable |

## 3.2 Contexto Técnico

### Arquitectura de Despliegue

```text
┌─────────────────────────────────────────────────────────────────┐
│                         INTERNET                                │
└─────────────────────┬───────────────────────────────────────────┘
                      │ HTTPS/TLS 1.3
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                        AWS LOAD BALANCER                       │
│            [Application Load Balancer - Multi-AZ]             │
└─────────────────────┬───────────────────────────────────────────┘
                      │ Load Distribution
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                      API GATEWAY (YARP)                        │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │         SECURITY & ROUTING MIDDLEWARE                       ││
│  │  [Auth] [Rate Limit] [Circuit Breaker] [Tenant Routing]    ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────┬───────────────────────────────────────────┘
                      │ Authenticated & Routed Requests
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                    DOWNSTREAM MICROSERVICES                    │
│  [Identity] [Notification] [Track&Trace] [SITA Messaging]     │
│  [Reporting] [Configuration] [Health Check]                   │
└─────────────────────────────────────────────────────────────────┘
```

### Especificaciones Técnicas

| Aspecto | Especificación | Rationale |
|---------|----------------|-----------|
| **Platform** | .NET 8 + ASP.NET Core | Rendimiento, ecosystem |
| **Reverse Proxy** | YARP (Yet Another Reverse Proxy) | Microsoft supported, flexible |
| **Authentication** | OAuth2 + JWT | Estándar de la industria |
| **Protocol** | HTTP/2, HTTPS only | Security, rendimiento |
| **Balanceador de Carga** | Round-robin con health checks | Confiabilidad |
| **Limitación de Velocidad** | Control de tráfico per tenant | Protección de recursos |
| **Circuit Breaker** | Framework Polly | Tolerancia a fallos |
| **Observability** | OpenTelemetry + Prometheus | Standards compliance |

### Protocolos de Comunicación

| Interface | Protocol | Port | Purpose | Security |
|-----------|----------|------|---------|----------|
| **Client API** | HTTPS/TLS 1.3 | 443 | Public interface | JWT + TLS |
| **Health Check** | HTTP | 8080 | ALB health probes | Internal only |
| **Metrics** | HTTP | 9090 | Prometheus scraping | Internal only |
| **Admin API** | HTTPS | 8443 | Configuration | mTLS |

### Configuración de Red

| Parameter | Value | Purpose |
|-----------|-------|---------|
| **TLS Version** | 1.3 minimum | Security compliance |
| **HTTP Version** | HTTP/2 | Optimización de rendimiento |
| **Keep-Alive** | 60 seconds | Connection efficiency |
| **Request Timeout** | 30 seconds | User experience |
| **Header Size Limit** | 32KB | Security y rendimiento |

## 3.3 Alcance del Sistema

### Responsabilidades Incluidas

#### Core Functionality

- **Request Routing:** Enrutamiento inteligente basado en URL patterns y headers
- **Authentication:** Validación de JWT tokens y extracción de claims de usuario
- **Authorization:** Control de acceso basado en roles (RBAC) y contexto tenant
- **Limitación de Velocidad:** Control de tráfico por tenant, usuario y endpoint específico
- **Circuit Breaking:** Protección contra cascadas de fallos en servicios downstream
- **Balanceador de Carga:** Distribución de carga entre múltiples instancias de servicios

#### Conceptos Transversales

- **Observability:** Logging estructurado, métricas de rendimiento, trazado distribuido
- **Security:** TLS termination, HTTPS enforcement, security headers injection
- **Configuration:** Gestión dinámica de configuración sin downtime
- **Monitoreo de Salud:** Health checks proactivos de servicios downstream
- **Manejo de Errores:** Transformación de errores y standardización de responses

### Responsabilidades Excluidas

#### Fuera del Alcance

- **Lógica Empresarial:** No procesamiento de lógica de dominio específica
- **Data Storage:** No persistencia de datos de negocio (solo cache temporal)
- **User Management:** No CRUD de usuarios (delegado a Identity System)
- **File Processing:** No manipulación de archivos grandes o procesamiento multimedia
- **Background Jobs:** No procesamiento asíncrono de larga duración
- **Analytics:** No análisis avanzado de datos (solo métricas operacionales básicas)

#### Integration Boundaries

- **Frontend Rendering:** Delegado a SPAs y aplicaciones cliente
- **Database Operations:** Delegado a microservicios específicos de dominio
- **External Integrations:** Delegado a servicios de dominio correspondientes
- **Message Queuing:** Delegado a infrastructure de messaging confiable
- **File Storage:** Delegado a servicios de almacenamiento como S3

## 3.4 Interfaces Externas

### Actores del Sistema

| Actor | Tipo | Descripción | Interacciones Principales |
|-------|------|-------------|---------------------------|
| **Usuarios de Aplicaciones Web** | Humano | Usuarios finales de aplicaciones web corporativas | Navegación web, consumo de APIs |
| **Usuarios de Aplicaciones Móviles** | Humano | Usuarios de aplicaciones móviles iOS/Android | Uso de apps móviles, sincronización |
| **Administradores del Sistema** | Humano | Administradores del gateway y infraestructura | Configuración, monitoreo, resolución de problemas |
| **Socios Externos** | Sistema/Humano | Socios externos con integración API | Llamadas automatizadas, intercambio de datos |
| **Aplicaciones Cliente** | Sistema | Aplicaciones frontend (SPAs, mobile) | Llamadas REST API, flujos de autenticación |
| **Servicios Downstream** | Sistema | Microservicios internos corporativos | Proxy de APIs, health checks |

### Sistemas Externos Conectados

| Sistema | Tipo | Protocolo | Propósito | Datos Intercambiados |
|---------|------|-----------|-----------|---------------------|
| **Web Applications** | Client | HTTPS/REST | Acceso de interfaz usuario | Requests/responses API, sesiones usuario |
| **Mobile Applications** | Client | HTTPS/REST | Acceso móvil | Llamadas API, push notifications, sync offline |
| **Partner Systems** | External | HTTPS/REST | Integración B2B | Datos de negocio, eventos operacionales |
| **Identity System (Keycloak)** | Internal | HTTP/OIDC | Autenticación | Validación tokens, user info, claims |
| **Notification Service** | Internal | HTTP/REST | Mensajería | Requests notificaciones, status delivery |
| **Track & Trace Service** | Internal | HTTP/REST | Seguimiento eventos | Consultas eventos, actualizaciones real-time |
| **SITA Messaging Service** | Internal | HTTP/REST | Mensajería aviación | Requests mensajes, updates status |
| **Configuration Platform** | Internal | HTTPS/REST | Configuración dinámica | Configs rutas, feature flags |
| **Monitoring Systems** | Internal | HTTP/Metrics | Observabilidad | Métricas, logs, traces |

### Flujos de Datos

#### Datos de Entrada

| Interface | Fuente | Tipo de Datos | Frecuencia | Formato |
|-----------|--------|---------------|------------|---------|
| **API Requests** | Aplicaciones cliente | Solicitudes empresariales | Tiempo real | HTTP/REST (JSON) |
| **Authentication Tokens** | Aplicaciones cliente | JWT tokens | Por request | HTTP headers |
| **Configuration Updates** | Plataforma config | Configuración gateway | Periódica | HTTP/JSON |
| **Health Checks** | Sistemas monitoreo | Health probes | Continua | HTTP/JSON |

#### Datos de Salida

| Interface | Destino | Tipo de Datos | Frecuencia | Formato |
|-----------|---------|---------------|------------|---------|
| **Proxied Requests** | Servicios downstream | Solicitudes empresariales | Tiempo real | HTTP/REST |
| **Authentication Queries** | Sistema identidad | Validación tokens | Por request | HTTP/OIDC |
| **Metrics Data** | Sistemas monitoreo | Métricas de rendimiento | Continua | Prometheus metrics |
| **Access Logs** | Sistemas logging | Logs requests | Continua | JSON estructurado |
| **Health Status** | Load balancer | Estado servicios | Continua | HTTP status codes |

## 3.5 Configuración Multi-tenant

### Identificación de Tenants

| Método | Fuente | Prioridad | Caso de Uso |
|--------|--------|-----------|-------------|
| **JWT Claims** | Token tenant claim | 1 | Usuarios autenticados |
| **API Key** | Custom header | 2 | Partners externos |
| **Subdomain** | Host header | 3 | Aplicaciones web |
| **Query Parameter** | URL parameter | 4 | Sistemas legacy |

### Configuración Específica por Tenant

| Tenant | País | Subdominio | Rate Limits | Backend Pool |
|--------|------|-----------|-------------|--------------|
| **talma-pe** | Perú | pe.corporate.talma.com | 10k req/hour | pe-backend-pool |
| **talma-ec** | Ecuador | ec.corporate.talma.com | 5k req/hour | ec-backend-pool |
| **talma-co** | Colombia | co.corporate.talma.com | 8k req/hour | co-backend-pool |
| **talma-mx** | México | mx.corporate.talma.com | 6k req/hour | mx-backend-pool |

### Estándares y Protocolos

| Categoría | Estándar/Protocolo | Versión | Uso en el Sistema |
|-----------|-------------------|---------|-------------------|
| **HTTP** | HTTP/2, HTTP/3 | Latest | Comunicación cliente |
| **Security** | TLS 1.3 | Current | Encriptación en tránsito |
| **Authentication** | OAuth2 + JWT | RFC 6749, RFC 7519 | Autenticación basada en tokens |
| **API Design** | OpenAPI | 3.0+ | Especificación de APIs |
| **Logging** | JSON estructurado | Schema custom | Observabilidad |
| **Metrics** | Prometheus | Latest | Monitoreo de rendimiento |

## Referencias

- [Arc42 Context Template](https://docs.arc42.org/section-3/)
- [C4 Model for Architecture](https://c4model.com/)
- [YARP Documentation](https://microsoft.github.io/reverse-proxy/)
- [OAuth2 RFC 6749](https://tools.ietf.org/html/rfc6749)
- [JWT RFC 7519](https://tools.ietf.org/html/rfc7519)
