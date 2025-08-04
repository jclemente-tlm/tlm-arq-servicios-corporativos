# 3. Contexto y alcance del sistema

El **API Gateway corporativo** es el punto de entrada único y unificado para todos los servicios corporativos, proporcionando una fachada coherente, segura y escalable para clientes internos y externos en un entorno multi-tenant.

## 3.1 Contexto de negocio

### Propósito del Sistema

El API Gateway actúa como la puerta de entrada central, proporcionando:

- **Punto de entrada único** para todos los servicios corporativos
- **Seguridad centralizada** con autenticación y autorización uniforme
- **Gestión de tráfico** con rate limiting y circuit breakers
- **Enrutamiento inteligente** basado en tenant y contexto
- **Observabilidad unificada** de todas las interacciones de API

### Stakeholders Principales

| Stakeholder | Rol | Responsabilidad | Expectativa |
|-------------|-----|----------------|-------------|
| **Frontend Developers** | Desarrollo Cliente | Integración con APIs corporativas | APIs consistentes, documentación clara |
| **Mobile App Developers** | Desarrollo Móvil | Integración aplicaciones nativas | APIs optimizadas, manejo de errores |
| **External Partners** | Socios Externos | Integración sistemas terceros | APIs estables, SLAs garantizados |
| **DevOps Teams** | Operaciones | Deployment y monitoreo | Sistema confiable, métricas detalladas |
| **Security Team** | Seguridad | Políticas de acceso y compliance | Seguridad robusta, audit trails |
| **Product Managers** | Gestión Producto | Funcionalidades y performance | APIs rápidas, experiencia de usuario |

### Objetivos de Negocio

| Objetivo | Descripción | Métricas de Éxito |
|----------|-------------|-------------------|
| **Unificación de APIs** | Punto de entrada único para todos los servicios | 100% traffic routed through gateway |
| **Seguridad Centralizada** | Autenticación y autorización uniforme | Zero unauthorized access, 100% token validation |
| **Performance Optimization** | Respuesta rápida y confiable | p95 < 200ms, 99.9% availability |
| **Developer Experience** | APIs fáciles de usar y documentar | High API adoption, positive feedback |
| **Operational Efficiency** | Reducir complejidad operacional | Simplified monitoring, automated scaling |

## 3.2 Contexto técnico

### Posición en la Arquitectura

```text
┌─────────────────────────────────────────────────────────────────┐
│                        CLIENT APPLICATIONS                      │
│  [Web Apps Peru] [Web Apps Ecuador] [Mobile Apps] [Partners]   │
│  [External Systems] [Dashboard Apps] [Admin Interfaces]        │
└─────────────────────┬───────────────────────────────────────────┘
                      │ HTTPS/REST API Calls
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
│  [Reporting] [Configuration] [Health Monitoring]              │
└─────────────────────────────────────────────────────────────────┘
```

### Fronteras del Sistema

#### Dentro del Alcance

| Componente | Descripción | Responsabilidad |
|------------|-------------|-----------------|
| **YARP Reverse Proxy** | Core gateway engine | Request routing, load balancing |
| **Authentication Middleware** | JWT token validation | Token introspection, claims extraction |
| **Authorization Middleware** | Access control | Permission validation, RBAC enforcement |
| **Rate Limiting** | Traffic control | Request throttling, quota management |
| **Circuit Breaker** | Fault tolerance | Failure detection, graceful degradation |
| **Request/Response Transformation** | Data manipulation | Header injection, payload transformation |
| **Metrics & Logging** | Observability | Request tracking, performance metrics |
| **Health Monitoring** | Service health | Upstream health checks, failover |

#### Fuera del Alcance

| Componente | Razón de Exclusión | Responsable |
|------------|-------------------|-------------|
| **Client Applications** | Consumer responsibility | Frontend/mobile teams |
| **Downstream Services** | Service ownership | Individual service teams |
| **Load Balancer** | Infrastructure layer | AWS ALB |
| **DNS Management** | Infrastructure concern | Network team |
| **Certificate Management** | Security infrastructure | Security team |

## 3.3 Interfaces externas

### Actores Principales

| Actor | Tipo | Descripción | Interacciones |
|-------|------|-------------|---------------|
| **Web Application Users** | Humano | Usuarios de aplicaciones web corporativas | Browse web apps, API consumption |
| **Mobile App Users** | Humano | Usuarios de aplicaciones móviles | Mobile app usage, API consumption |
| **System Administrators** | Humano | Administradores del gateway | Configuration, monitoring, troubleshooting |
| **External Partners** | Humano/Sistema | Socios externos con integración API | Automated API calls, data exchange |
| **Client Applications** | Sistema | Aplicaciones frontend que consumen APIs | REST API calls, authentication flows |
| **Downstream Services** | Sistema | Microservicios internos | API proxying, health checks |

### Sistemas Externos

| Sistema | Tipo | Protocolo | Propósito | Datos Intercambiados |
|---------|------|-----------|-----------|---------------------|
| **Web Applications** | Client System | HTTPS/REST | User interface access | API requests/responses, user sessions |
| **Mobile Applications** | Client System | HTTPS/REST | Mobile access | API calls, push notifications, offline sync |
| **Partner Systems** | External Partner | HTTPS/REST | B2B integration | Business data, operational events |
| **Identity System (Keycloak)** | Internal Service | HTTP/OIDC | Authentication | Token validation, user info, claims |
| **Notification Service** | Internal Service | HTTP/REST | Messaging | Notification requests, delivery status |
| **Track & Trace Service** | Internal Service | HTTP/REST | Event tracking | Event queries, real-time updates |
| **SITA Messaging Service** | Internal Service | HTTP/REST | Aviation messaging | Message requests, status updates |
| **Configuration Platform** | Internal Service | HTTPS/REST | Dynamic configuration | Route configs, feature flags |
| **Monitoring Systems** | Internal Tools | HTTP/Metrics | Observability | Metrics, logs, traces |

### Interfaces de Datos

#### Entrada de Datos

| Interface | Fuente | Tipo de Datos | Frecuencia | Formato |
|-----------|--------|---------------|------------|---------|
| **API Requests** | Client applications | Business requests | Real-time | HTTP/REST (JSON) |
| **Authentication Tokens** | Client applications | JWT tokens | Per request | HTTP headers |
| **Configuration Updates** | Config platform | Gateway configuration | Periodic | HTTP/JSON |
| **Health Checks** | Monitoring systems | Health probes | Continuous | HTTP/JSON |

#### Salida de Datos

| Interface | Destino | Tipo de Datos | Frecuencia | Formato |
|-----------|---------|---------------|------------|---------|
| **Proxied Requests** | Downstream services | Business requests | Real-time | HTTP/REST |
| **Authentication Queries** | Identity system | Token validation | Per request | HTTP/OIDC |
| **Metrics Data** | Monitoring systems | Performance metrics | Continuous | Prometheus metrics |
| **Access Logs** | Logging systems | Request logs | Continuous | Structured JSON |
| **Health Status** | Load balancer | Service health | Continuous | HTTP status codes |

## 3.4 Alcance funcional

### Funcionalidades Incluidas

| Función | Descripción | Usuarios Objetivo | Prioridad |
|---------|-------------|-------------------|-----------|
| **Request Routing** | Enrutamiento inteligente a servicios downstream | All clients | Alta |
| **Authentication Validation** | Validación de tokens JWT | All authenticated users | Alta |
| **Rate Limiting** | Control de tráfico por cliente/API | All clients | Alta |
| **Circuit Breaking** | Protección contra fallos de servicios | System resilience | Alta |
| **Load Balancing** | Distribución de carga entre instancias | System performance | Media |
| **Request/Response Transformation** | Modificación de headers y payloads | API standardization | Media |
| **API Versioning** | Soporte para múltiples versiones de API | API evolution | Media |
| **Tenant Isolation** | Enrutamiento basado en tenant | Multi-tenant operations | Media |
| **Caching** | Cache de respuestas para optimización | Performance optimization | Baja |
| **API Documentation** | Documentación automática de APIs | Developers | Baja |

### Funcionalidades Excluidas

| Función | Razón de Exclusión | Alternativa |
|---------|-------------------|-------------|
| **Business Logic** | Not gateway responsibility | Downstream microservices |
| **Data Storage** | Stateless gateway design | Individual service databases |
| **User Management** | Identity service responsibility | Keycloak identity system |
| **Message Queuing** | Async communication pattern | Service-to-service messaging |
| **File Storage** | Not API gateway concern | Dedicated storage services |

## 3.5 Casos de uso principales

### Autenticación y Enrutamiento de Request

```text
Actor: Web Application
Precondición: Usuario autenticado con JWT token válido
Flujo Principal:
1. Web app envía request con JWT token en header
2. API Gateway recibe request en load balancer
3. Gateway extrae y valida JWT token
4. Gateway consulta Identity System para validación
5. Gateway determina tenant desde token claims
6. Gateway identifica servicio destino basado en path
7. Gateway aplica rate limiting para cliente
8. Gateway verifica health de servicio destino
9. Gateway enruta request a instancia saludable
10. Servicio procesa request y retorna response
11. Gateway retorna response a web app
Postcondición: Request procesado exitosamente
```

### Manejo de Circuit Breaker

```text
Actor: Mobile Application
Precondición: Servicio downstream experimenta fallos
Flujo Principal:
1. Mobile app envía request a API endpoint
2. API Gateway recibe request
3. Gateway detecta múltiples fallos en servicio destino
4. Circuit breaker se activa (estado OPEN)
5. Gateway retorna error controlado sin llamar servicio
6. Error response incluye retry-after header
7. Gateway continúa monitoreando servicio
8. Servicio se recupera después de tiempo
9. Circuit breaker transiciona a HALF-OPEN
10. Gateway permite requests limitados para testing
11. Servicio confirma estabilidad
12. Circuit breaker retorna a estado CLOSED
Postcondición: Servicio protegido de sobrecarga
```

### Configuración Dinámica de Rutas

```text
Actor: System Administrator
Precondición: Necesidad de agregar nuevo servicio
Flujo Principal:
1. Admin accede a configuration platform
2. Admin define nueva ruta para servicio
3. Configuration platform valida configuración
4. Configuración publicada a gateway instances
5. Gateway detecta cambio de configuración
6. Gateway actualiza tabla de enrutamiento
7. Nuevas requests utilizan nueva configuración
8. Gateway reporta configuración activa
Postcondición: Nueva ruta disponible sin restart
```

### Rate Limiting por Tenant

```text
Actor: External Partner System
Precondición: Partner tiene quota asignada
Flujo Principal:
1. Partner system envía requests con API key
2. Gateway identifica partner desde API key
3. Gateway consulta quota asignada para partner
4. Gateway verifica requests consumidos en ventana
5. Si dentro de quota, request procesado normalmente
6. Gateway actualiza contador de requests
7. Si quota excedida, gateway retorna 429 error
8. Response incluye headers de rate limit status
Postcondición: Quota respetada, partner informado
```

## 3.6 Atributos de calidad específicos

### Performance

| Atributo | Métrica | Target | Medición |
|----------|---------|--------|----------|
| **Response Latency** | p95 response time | < 200ms | APM monitoring |
| **Throughput** | Requests per second | 50,000 req/sec | Load testing |
| **Connection Handling** | Concurrent connections | 10,000 concurrent | Connection monitoring |
| **Memory Usage** | Gateway memory consumption | < 2GB per instance | Resource monitoring |

### Reliability

| Atributo | Métrica | Target | Medición |
|----------|---------|--------|----------|
| **Service Availability** | Gateway uptime | 99.9% | Health monitoring |
| **Error Rate** | Failed requests | < 0.1% | Error tracking |
| **Circuit Breaker Effectiveness** | Fault isolation | 95% fault containment | Failure analysis |
| **Recovery Time** | MTTR | < 5 minutes | Incident response |

### Security

| Atributo | Métrica | Target | Medición |
|----------|---------|--------|----------|
| **Token Validation** | Invalid token blocking | 100% | Security monitoring |
| **Rate Limit Enforcement** | Quota violations blocked | 100% | Rate limit tracking |
| **Unauthorized Access** | Blocked unauthorized requests | 100% | Access monitoring |
| **Audit Coverage** | Request logging | 100% | Audit verification |

### Scalability

| Atributo | Métrica | Target | Medición |
|----------|---------|--------|----------|
| **Horizontal Scaling** | Auto-scaling responsiveness | < 2 minutes | Scaling metrics |
| **Load Distribution** | Traffic balancing | Even distribution | Load balancer metrics |
| **Resource Efficiency** | CPU/memory per request | Optimal utilization | Resource profiling |
| **Connection Pooling** | Connection reuse | > 90% reuse rate | Connection analytics |

## 3.7 Configuración multi-tenant

### Tenant Identification

| Method | Source | Priority | Use Case |
|--------|--------|----------|----------|
| **JWT Claims** | Token tenant claim | 1 | Authenticated users |
| **API Key** | Custom header | 2 | External partners |
| **Subdomain** | Host header | 3 | Web applications |
| **Query Parameter** | URL parameter | 4 | Legacy systems |

### Tenant-Specific Routing

| Tenant | Country | Subdomain | Service Instances | Rate Limits |
|--------|---------|-----------|-------------------|-------------|
| **peru-corp** | Peru | pe.corporate.com | 3 instances per service | 10k req/hour |
| **ecuador-corp** | Ecuador | ec.corporate.com | 2 instances per service | 5k req/hour |
| **colombia-corp** | Colombia | co.corporate.com | 3 instances per service | 8k req/hour |
| **mexico-corp** | Mexico | mx.corporate.com | 2 instances per service | 6k req/hour |

### Tenant Configuration

| Aspect | Configuration | Scope | Management |
|--------|---------------|-------|------------|
| **Feature Flags** | Per-tenant feature enablement | Individual tenants | Configuration platform |
| **Rate Limits** | Tenant-specific quotas | Per tenant/API | Dynamic configuration |
| **Custom Headers** | Tenant-specific headers | Request/response | Middleware configuration |
| **Monitoring** | Tenant-specific metrics | Observability | Metrics aggregation |

## Referencias

### Microsoft YARP

- [YARP Documentation](https://microsoft.github.io/reverse-proxy/)
- [YARP Configuration](https://microsoft.github.io/reverse-proxy/articles/config-files.html)
- [YARP Transforms](https://microsoft.github.io/reverse-proxy/articles/transforms.html)

### API Gateway Patterns

- [API Gateway Pattern](https://microservices.io/patterns/apigateway.html)
- [Backend for Frontend Pattern](https://docs.microsoft.com/en-us/azure/architecture/patterns/backends-for-frontends)
- [Circuit Breaker Pattern](https://docs.microsoft.com/en-us/azure/architecture/patterns/circuit-breaker)

### AWS Integration

- [AWS Application Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/)
- [AWS ECS Service Discovery](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-discovery.html)
- [AWS CloudWatch Metrics](https://docs.aws.amazon.com/cloudwatch/)

### Architecture References

- [Arc42 Context Template](https://docs.arc42.org/section-3/)
- [C4 Model for Architecture](https://c4model.com/)
                       │ • Request Routing│
                       └──────────────────┘
                                │
                       ┌──────────────────┐
                       │   Support Sys    │
                       │                  │
                       │ • Config Platform│
                       │ • Observability  │
                       │ • Secret Manager │
                       └──────────────────┘
```

### Interfaces Técnicas

| Interface | Protocolo | Propósito | Características |
|-----------|-----------|-----------|-----------------|
| **Public HTTP API** | HTTPS/TLS 1.3 | Client requests | JWT required, rate limited |
| **Downstream APIs** | HTTP | Microservice calls | Internal network, load balanced |
| **Health Endpoints** | HTTP | Service monitoring | Unauthenticated, high frequency |
| **Metrics Endpoint** | HTTP | Prometheus scraping | Internal only, time series data |
| **Configuration API** | HTTPS | Dynamic config | Polling-based, cached locally |

### Protocolos y Estándares

| Categoría | Estándar/Protocolo | Versión | Uso |
|-----------|-------------------|---------|-----|
| **HTTP** | HTTP/2, HTTP/3 | Latest | Client communication |
| **Security** | TLS 1.3 | Current | Encryption in transit |
| **Authentication** | OAuth2 + JWT | RFC 6749, RFC 7519 | Token-based auth |
| **API Design** | OpenAPI | 3.0+ | API specification |
| **Logging** | JSON structured | Custom schema | Observability |
| **Metrics** | Prometheus | Latest | Performance monitoring |

## 3.3 Alcance del Sistema

### Responsabilidades Incluidas

#### Core Functionality
- **Request Routing:** Enrutamiento inteligente basado en URL patterns
- **Authentication:** Validación de JWT tokens y extracción de claims
- **Authorization:** RBAC basado en roles y tenant context
- **Rate Limiting:** Control de tráfico por tenant, usuario y endpoint
- **Circuit Breaking:** Protección contra cascadas de fallos
- **Load Balancing:** Distribución de carga entre instancias

#### Cross-cutting Concerns
- **Observability:** Logging estructurado, métricas, distributed tracing
- **Security:** TLS termination, HTTPS enforcement, security headers
- **Configuration:** Dynamic configuration management sin downtime
- **Health Monitoring:** Health checks de servicios downstream
- **Error Handling:** Error transformation y response standardization

### Responsabilidades Excluidas

#### Out of Scope
- **Business Logic:** No procesamiento de dominio específico
- **Data Storage:** No persistencia de datos de negocio
- **User Management:** No CRUD de usuarios (delegado a Identity System)
- **File Processing:** No manipulación de archivos grandes
- **Background Jobs:** No procesamiento asíncrono de larga duración
- **Analytics:** No análisis avanzado de datos (solo métricas básicas)

#### Integration Boundaries
- **Frontend Rendering:** Delegado a SPAs y aplicaciones cliente
- **Database Operations:** Delegado a microservicios específicos
- **External Integrations:** Delegado a servicios de dominio
- **Message Queuing:** Delegado a reliable messaging infrastructure
- **File Storage:** Delegado a S3 y servicios de storage

### Límites del Sistema

| Límite | Descripción | Rationale |
|--------|-------------|-----------|
| **Northbound** | Public-facing APIs only | Security, simplicity |
| **Southbound** | Internal microservices only | Trust boundary |
| **East-West** | Configuration and observability | Support services |
| **Data Plane** | Stateless request processing | Scalability |
| **Control Plane** | Configuration and monitoring | Operational separation |
