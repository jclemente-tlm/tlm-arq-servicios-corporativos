# 12. Glosario

Este glosario define los términos técnicos, conceptos y acrónimos utilizados en la documentación del **Sistema de Identidad**, proporcionando claridad y consistencia en la comunicación entre equipos técnicos e interesados.

*[INSERTAR AQUÍ: Diagrama C4 - System Terminology Map]*

## A

**Token de Acceso**
: JWT que contiene información de autorización del usuario para acceder a recursos específicos. Tiene un tiempo de vida limitado (15 minutos por defecto) y debe ser validado en cada petición.

**ADR (Registro de Decisión Arquitectónica)**
: Documento que captura una decisión arquitectónica importante, incluyendo el contexto, opciones consideradas, decisión tomada y consecuencias.

**Puerta de Enlace API**
: Componente que actúa como punto de entrada único para todas las peticiones a los microservicios, proporcionando funcionalidades como enrutamiento, autenticación, autorización y limitación de velocidad.

**Rastro de Auditoría**
: Registro cronológico e inmutable de todas las actividades del sistema que pueden tener implicaciones de seguridad o cumplimiento, implementado mediante event sourcing.

**Autenticación**
: Proceso de verificar la identidad de un usuario, dispositivo o sistema. En nuestro contexto, implementado principalmente mediante OAuth2/OIDC.

**Autorización**
: Proceso de determinar qué acciones puede realizar un usuario autenticado sobre recursos específicos, implementado mediante RBAC y autorización basada en claims.

## B

**Token Portador**
: Tipo de token de acceso que se incluye en el header HTTP Authorization con el prefijo "Bearer ". Es el método estándar para autenticar peticiones API.

**BPMN (Notación de Modelado de Procesos de Negocio)**
: Notación gráfica estándar para modelar procesos de negocio, utilizada para documentar flujos de autenticación y autorización complejos.

**Patrón Mamparo**
: Patrón de diseño que aísla recursos críticos para prevenir que fallos en un componente afecten a otros, implementado mediante pools de threads separados.

## C

**C4 Model**
: Modelo de documentación arquitectónica que define cuatro niveles: Context, Containers, Components, y Code. Utilizado para crear diagramas consistentes y escalables.

**Cache Invalidation**
: Proceso de remover o marcar como obsoletos datos almacenados en cache cuando la información original cambia, crítico para mantener consistencia.

**Circuit Breaker**
: Patrón que previene cascading failures en sistemas distribuidos, monitoreando fallos y abriendo el circuito cuando se supera un threshold.

**Claims**
: Assertions sobre un usuario contenidas en un token JWT, como roles, permisos, tenant, department, etc. Basis de nuestro modelo de autorización.

**Client Credentials Grant**
: Flujo OAuth2 utilizado para autenticación service-to-service, donde la aplicación cliente se autentica directamente sin involucrar un usuario.

**CQRS (Command Query Responsibility Segregation)**
: Patrón que separa operaciones de lectura y escritura, utilizado para optimizar performance y escalabilidad del sistema.

## D

**Data Residency**
: Requerimiento legal/regulatorio que especifica la ubicación geográfica donde pueden almacenarse datos específicos, crítico para compliance multi-país.

**Trazado Distribuido**
: Técnica para rastrear requests a través de múltiples servicios en un sistema distribuido, implementada con OpenTelemetry.

## E

**Event Sourcing**
: Patrón de persistencia que almacena cambios de estado como secuencia de eventos inmutables, utilizado para audit trail y compliance.

**External Identity Provider**
: Servicio de identidad externo (Google Workspace, Azure AD, LDAP) federado con nuestro sistema mediante SAML o OIDC.

## F

**Federated Identity**
: Modelo donde usuarios pueden usar una sola identidad para acceder a múltiples sistemas/aplicaciones mediante protocolos estándar.

**FIDO2/WebAuthn**
: Estándares para autenticación sin contraseñas usando métodos biométricos o hardware security keys.

## G

**GDPR (General Data Protection Regulation)**
: Regulación europea de protección de datos que impacta cómo manejamos información personal de usuarios.

**Graceful Degradation**
: Capacidad del sistema de mantener funcionalidad esencial cuando algunos componentes fallan, implementado mediante fallbacks y circuit breakers.

## H

**Health Check**
: Endpoint que reporta el estado operacional de un servicio, utilizado por load balancers y monitoring systems para determinar disponibilidad.

**HMAC (Hash-based Message Authentication Code)**
: Algoritmo criptográfico utilizado para verificar integridad y autenticidad de mensajes, usado en webhook signatures.

## I

**IdP (Identity Provider)**
: Sistema que autentica usuarios y proporciona información de identidad a aplicaciones. Keycloak es nuestro IdP central.

**Immutable Infrastructure**
: Práctica donde infrastructure components no se modifican después del deployment, sino que se reemplazan completamente.

**JWT (JSON Web Token)**
: Estándar RFC 7519 para tokens de acceso que contienen claims codificados en JSON y firmados criptográficamente.

## K

**Keycloak**
: Solución open-source de identity and access management que implementa estándares OAuth2, OIDC, y SAML 2.0.

**Key Rotation**
: Proceso de reemplazar claves criptográficas periódicamente o cuando se comprometen, automatizado en nuestro sistema.

**KMS (Key Management Service)**
: Servicio para crear y controlar claves de cifrado. Utilizamos AWS KMS para gestión segura de claves.

## L

**LDAP (Lightweight Directory Access Protocol)**
: Protocolo para acceder y mantener servicios de directorio distribuido, utilizado para integración con Active Directory corporativo.

**Load Balancer**
: Componente que distribuye incoming requests entre múltiples instancias de un servicio para optimizar utilización de recursos.

## M

**MFA (Autenticación Multi-Factor)**
: Método de autenticación que requiere múltiples factores de verificación (algo que sabes, tienes, eres).

**Microservices**
: Patrón arquitectónico que estructura aplicaciones como colección de servicios pequeños, independientes y desplegables.

**Multi-Tenancy**
: Arquitectura donde una sola instancia de software sirve múltiples tenants, con aislamiento de datos y configuración.

## O

**OAuth2**
: Framework de autorización RFC 6749 que permite a aplicaciones obtener acceso limitado a cuentas de usuario.

**OIDC (OpenID Connect)**
: Capa de identidad sobre OAuth2 que permite verificar identidad de usuarios y obtener información básica de perfil.

**OpenTelemetry**
: Framework observability que proporciona APIs, librerías y agentes para recopilar, procesar y exportar telemetry data.

## P

**PII (Personally Identifiable Information)**
: Cualquier información que puede identificar a un individuo específico, sujeta a regulaciones de protección de datos.

**PKCE (Proof Key for Code Exchange)**
: Extensión OAuth2 RFC 7636 que mejora seguridad del authorization code flow para clientes públicos.

## R

**RBAC (Role-Based Access Control)**
: Modelo de autorización donde permisos se asignan a roles, y roles a usuarios, simplificando gestión de acceso.

**Realm**
: Concepto Keycloak que representa un espacio aislado para usuarios, roles, clients y configuraciones. Utilizamos un realm por tenant.

**Refresh Token**
: Token de larga duración utilizado para obtener nuevos access tokens sin requerir re-autenticación del usuario.

**Resilience**
: Capacidad del sistema de mantener operaciones aceptables ante fallos, implementada mediante circuit breakers, retries, y timeouts.

**RPO (Recovery Point Objective)**
: Máxima cantidad de datos que se puede permitir perder en caso de desastre, medido en tiempo.

**RTO (Recovery Time Objective)**
: Máximo tiempo permitido para restaurar servicios después de un desastre.

## S

**SAML (Security Assertion Markup Language)**
: Estándar XML para intercambiar datos de autenticación y autorización entre identity providers y service providers.

**SCIM (System for Cross-domain Identity Management)**
: Estándar para automatizar intercambio de información de identidad de usuario entre dominios de identidad.

**Service Mesh**
: Capa de infraestructura dedicada para manejar comunicación service-to-service en aplicaciones microservices.

**SLA (Service Level Agreement)**
: Acuerdo que define nivel esperado de servicio entre proveedor y cliente, incluyendo métricas como uptime y response time.

**SLI (Service Level Indicator)**
: Métrica cuantitativa de algún aspecto del nivel de servicio proporcionado.

**SLO (Service Level Objective)**
: Target value o rango de valores para un SLI, medido durante un período específico.

**SOX (Sarbanes-Oxley Act)**
: Ley estadounidense que establece estándares para control interno y reporting financiero, impactando controles de acceso.

**SPA (Single Page Application)**
: Aplicación web que interactúa dinámicamente con el usuario reescribiendo la página actual en lugar de cargar páginas nuevas.

**SPI (Service Provider Interface)**
: Mecanismo Keycloak que permite extender funcionalidad mediante plugins custom, utilizado para integraciones específicas.

## T

**Tenant**
: Entidad organizacional (país, división, cliente) con datos y configuraciones aisladas dentro del sistema multi-tenant.

**Token Introspection**
: Proceso de verificar estado y metadata de un token OAuth2, implementado según RFC 7662.

**TOTP (Time-based One-Time Password)**
: Algoritmo que genera passwords únicos basados en tiempo, utilizado para MFA.

## U

**User Federation**
: Capacidad de Keycloak de conectarse a external user stores (LDAP, databases) para autenticar usuarios.

**UMA (User-Managed Access)**
: Protocolo que extiende OAuth2 para permitir gestión de recursos por parte del usuario.

## V

**Vulnerability Scanning**
: Proceso automatizado de identificar vulnerabilidades de seguridad en código, dependencias y infrastructure.

## W

**WAF (Web Application Firewall)**
: Firewall que filtra, monitorea y bloquea tráfico HTTP hacia/desde aplicaciones web.

**WebAuthn**
: Estándar web para autenticación sin contraseñas usando authenticators criptográficos.

## X

**XSS (Cross-Site Scripting)**
: Vulnerabilidad de seguridad que permite inyectar scripts maliciosos en páginas web vistas por otros usuarios.

## Y

**YARP (Yet Another Reverse Proxy)**
: Biblioteca .NET de Microsoft para crear reverse proxies, utilizada en nuestro API Gateway.

## Z

**Zero Trust**
: Modelo de seguridad que requiere verificación de identidad para every person y device tratando de acceder recursos en una red privada.

---

## Acrónimos Técnicos

| Acrónimo | Significado Completo | Contexto |
|----------|---------------------|----------|
| **2FA** | Two-Factor Authentication | Subset de MFA con exactamente dos factores |
| **ACL** | Access Control List | Lista de permisos asociados a un objeto |
| **AES** | Advanced Encryption Standard | Algoritmo de cifrado simétrico |
| **API** | Application Programming Interface | Interfaz para comunicación entre sistemas |
| **ARN** | Amazon Resource Name | Identificador único AWS |
| **CORS** | Cross-Origin Resource Sharing | Mecanismo que permite requests cross-domain |
| **CSRF** | Cross-Site Request Forgery | Ataque que força user actions no autorizadas |
| **DDoS** | Distributed Denial of Service | Ataque que satura recursos del sistema |
| **DNS** | Domain Name System | Sistema de nombres de dominio |
| **ECS** | Elastic Container Service | Servicio de containers de AWS |
| **FQDN** | Fully Qualified Domain Name | Nombre de dominio completo |
| **HSM** | Hardware Security Module | Dispositivo dedicado para gestión de claves |
| **HTTP** | HyperText Transfer Protocol | Protocolo de transferencia web |
| **HTTPS** | HTTP Secure | HTTP sobre TLS/SSL |
| **IAM** | Identity and Access Management | Gestión de identidades y acceso |
| **JSON** | JavaScript Object Notation | Formato de intercambio de datos |
| **MTBF** | Mean Time Between Failures | Tiempo promedio entre fallos |
| **MTTR** | Mean Time To Recovery | Tiempo promedio de recuperación |
| **NIST** | National Institute of Standards and Technology | Organismo de estándares US |
| **PKI** | Public Key Infrastructure | Infraestructura de clave pública |
| **REST** | Representational State Transfer | Estilo arquitectónico para APIs |
| **RSA** | Rivest-Shamir-Adleman | Algoritmo de criptografía asimétrica |
| **SDK** | Software Development Kit | Kit de desarrollo de software |
| **SPA** | Single Page Application | Aplicación de página única |
| **SSL** | Secure Sockets Layer | Protocolo de seguridad (legacy) |
| **SSO** | Single Sign-On | Autenticación única para múltiples sistemas |
| **TLS** | Transport Layer Security | Protocolo de seguridad (successor de SSL) |
| **TTL** | Time To Live | Tiempo de vida de un dato/token |
| **URI** | Uniform Resource Identifier | Identificador uniforme de recurso |
| **URL** | Uniform Resource Locator | Localizador uniforme de recurso |
| **UUID** | Universally Unique Identifier | Identificador único universal |
| **VPC** | Virtual Private Cloud | Red privada virtual |
| **YAML** | YAML Ain't Markup Language | Formato de serialización de datos |

---

## Referencias Normativas

### Estándares de Identidad
- **RFC 6749**: OAuth 2.0 Authorization Framework
- **RFC 8252**: OAuth 2.0 for Native Apps
- **RFC 7636**: Proof Key for Code Exchange (PKCE)
- **OpenID Connect Core 1.0**: Identity layer on top of OAuth 2.0

### Estándares de Seguridad
- **RFC 7515**: JSON Web Signature (JWS)
- **RFC 7516**: JSON Web Encryption (JWE)
- **RFC 7517**: JSON Web Key (JWK)
- **RFC 7518**: JSON Web Algorithms (JWA)
- **RFC 7519**: JSON Web Token (JWT)

### Compliance y Regulaciones
- **GDPR**: General Data Protection Regulation (EU 2016/679)
- **SOX**: Sarbanes-Oxley Act of 2002
- **ISO 27001**: Information Security Management Systems
- **NIST Cybersecurity Framework**: Framework for Improving Critical Infrastructure Cybersecurity
