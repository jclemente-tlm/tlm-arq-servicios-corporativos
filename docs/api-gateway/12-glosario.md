# 12. Glosario

## A

**API Gateway**: Punto de entrada único que gestiona todas las peticiones de clientes hacia los microservicios backend, proporcionando funcionalidades como routing, autenticación, rate limiting y monitoreo.

**Auto-scaling**: Capacidad de ajustar automáticamente la cantidad de recursos computacionales (instancias, contenedores) basándose en la demanda actual del sistema.

**AWS EKS**: Amazon Elastic Kubernetes Service, servicio gestionado de Kubernetes en Amazon Web Services.

## B

**Servicio Backend**: Servicio que procesa la lógica de negocio y que se encuentra detrás del API Gateway, no expuesto directamente a los clientes.

**Despliegue Blue-Green**: Estrategia de despliegue donde se mantienen dos entornos idénticos (azul y verde), permitiendo cambios sin downtime.

## C

**Circuit Breaker**: Patrón de diseño que previene llamadas a servicios que están fallando, evitando fallos en cascada y permitiendo recuperación automática.

**Claims**: Información contenida en un JWT token que describe atributos del usuario o la sesión autenticada.

**Client Credentials**: Flujo de OAuth2 donde un cliente obtiene un token de acceso usando sus credenciales, sin interacción del usuario final.

**Cluster**: En el contexto de YARP, conjunto de destinos (servicios backend) que pueden manejar requests para una ruta específica.

**CORS**: Cross-Origin Resource Sharing, mecanismo que permite a una aplicación web hacer peticiones a un dominio diferente al que la sirve.

## D

**Caché Distribuido**: Sistema de cache que opera a través de múltiples servidores, permitiendo compartir datos en cache entre diferentes instancias de aplicación.

**Trazabilidad Distribuida**: Técnica de observabilidad que rastrea requests a través de múltiples servicios distribuidos, proporcionando visibilidad completa del flujo.

**Docker**: Plataforma de contenedorización que permite empaquetar aplicaciones y sus dependencias en contenedores portables.

**Servicio Downstream**: Servicio que recibe requests del API Gateway; sinónimo de servicio backend.

## E

**Elasticsearch**: Motor de búsqueda y analítica distribuido usado para almacenar y analizar logs estructurados.

**ELK Stack**: Elasticsearch, Logstash y Kibana; conjunto de herramientas para logging, búsqueda y visualización.

**Envoy Proxy**: Proxy de aplicación distribuido diseñado para servicios en arquitecturas de microservicios.

## F

**Failover (Conmutación por error)**: Proceso automático de cambiar a un sistema redundante cuando el sistema principal falla.

**FluentValidation**: Biblioteca .NET para construcción de reglas de validación usando una interfaz fluida.

## G

**Grafana**: Plataforma de observabilidad para visualización de métricas y creación de dashboards.

**gRPC**: Framework de llamadas a procedimientos remotos (RPC) de alto rendimiento desarrollado por Google.

## H

**Health Check**: Verificación automatizada del estado de un servicio o componente del sistema.

**Helm**: Gestor de paquetes para Kubernetes que facilita el despliegue y gestión de aplicaciones.

**HPA**: Horizontal Pod Autoscaler, componente de Kubernetes que escala automáticamente el número de pods basándose en métricas.

**HTTP/2**: Versión mejorada del protocolo HTTP con multiplexing, compresión de headers y server push.

## I

**Identity Provider**: Servicio que autentica usuarios y emite tokens de identidad verificables.

**Ingress**: Objeto de Kubernetes que gestiona el acceso externo a servicios dentro del cluster.

**Istio**: Service mesh que proporciona gestión de tráfico, seguridad y observabilidad para microservicios.

## J

**Jaeger**: Sistema de tracing distribuido open source para monitorear y troubleshooter transacciones en sistemas distribuidos.

**JWT**: JSON Web Token, estándar para transmitir información entre partes de forma segura como objeto JSON.

## K

**Kubernetes**: Plataforma de orquestación de contenedores para automatizar despliegue, escalado y gestión de aplicaciones containerizadas.

**K6**: Herramienta moderna de testing de carga construida para equipos de DevOps y QA.

## L

**Load Balancer**: Dispositivo o software que distribuye tráfico de red o requests entre múltiples servidores.

**Logging**: Proceso de registrar eventos del sistema para debugging, auditoría y monitoreo.

## M

**Mapster**: Biblioteca .NET para mapeo de objetos con configuración mínima y alto rendimiento.

**Microservices**: Arquitectura donde una aplicación se construye como conjunto de servicios pequeños e independientes.

**Multi-tenant**: Arquitectura donde una sola instancia de aplicación sirve a múltiples tenants (clientes) de forma aislada.

## N

**NGINX**: Servidor web de alto rendimiento que también funciona como proxy reverso y load balancer.

**Node Affinity**: Característica de Kubernetes para controlar en qué nodos se programan los pods.

## O

**OAuth2**: Framework de autorización que permite a aplicaciones obtener acceso limitado a cuentas de usuario.

**OIDC**: OpenID Connect, capa de identidad sobre OAuth2 que permite verificar la identidad del usuario.

**OpenTelemetry**: Framework de observabilidad para generar, recopilar y exportar datos de telemetría.

## P

**Pod**: Unidad de despliegue más pequeña en Kubernetes que puede contener uno o más contenedores.

**Polly**: Biblioteca .NET para implementar patrones de resiliencia como retry, circuit breaker y timeout.

**Prometheus**: Sistema de monitoreo y alertas de código abierto diseñado para confiabilidad y escalabilidad.

## Q

**QoS**: Quality of Service, conjunto de tecnologías para garantizar niveles específicos de rendimiento y disponibilidad.

## R

**Rate Limiting**: Técnica para controlar la cantidad de requests que un cliente puede hacer en un período de tiempo.

**Redis**: Almacén de estructura de datos en memoria usado como base de datos, cache y message broker.

**Resilience**: Capacidad de un sistema para recuperarse y continuar operando ante fallos o perturbaciones.

**Retry Policy**: Configuración que define cómo y cuándo reintentar operaciones fallidas.

**Route**: En YARP, configuración que define cómo mapear requests entrantes a servicios backend específicos.

## S

**Serilog**: Biblioteca de logging estructurado para .NET con soporte para múltiples sinks y formatters.

**Service Discovery**: Mecanismo que permite a servicios encontrar y comunicarse entre sí automáticamente.

**Service Mesh**: Capa de infraestructura dedicada para manejar comunicación entre servicios.

**Sidecar**: Patrón donde un contenedor auxiliar se despliega junto al contenedor principal para proporcionar funcionalidades adicionales.

**SLA**: Service Level Agreement, compromiso formal sobre el nivel de servicio que se proporcionará.

**Sliding Window**: Algoritmo para rate limiting que mantiene un contador de requests en una ventana de tiempo móvil.

## T

**Tenant**: En sistemas multi-tenant, organización o cliente que usa el sistema de forma aislada de otros tenants.

**Throughput**: Número de requests o transacciones que un sistema puede manejar por unidad de tiempo.

**TLS**: Transport Layer Security, protocolo criptográfico para proporcionar seguridad en comunicaciones de red.

**Token Cache**: Almacén temporal de tokens JWT validados para evitar validaciones repetidas.

## U

**Upstream**: En el contexto de proxies, se refiere al servidor o servicio que recibe requests del proxy.

## V

**VPA**: Vertical Pod Autoscaler, componente de Kubernetes que ajusta automáticamente los recursos (CPU/memoria) de los pods.

## W

**WAF**: Web Application Firewall, sistema que filtra, monitorea y bloquea tráfico HTTP malicioso.

**WebSocket**: Protocolo de comunicación que proporciona canales de comunicación full-duplex sobre una conexión TCP.

## Y

**YAML**: Yet Another Markup Language, formato de serialización de datos legible por humanos usado para archivos de configuración.

**YARP**: Yet Another Reverse Proxy, proxy reverso de código abierto para .NET desarrollado por Microsoft.

## Z

**Zero-downtime Deployment**: Estrategia de despliegue que permite actualizar aplicaciones sin interrumpir el servicio.

---

## Términos específicos del proyecto

**API Gateway Corporativo**: Implementación específica del API Gateway usando YARP para los servicios corporativos de la organización.

**Corporate Services**: Conjunto de servicios empresariales que incluye Identity, Notifications, Track & Trace y SITA Messaging.

**Tenant Context**: Información contextual sobre el tenant actual, incluyendo configuraciones específicas y límites de recursos.

**YARP Configuration Provider**: Componente que proporciona configuración dinámica de rutas y clusters para YARP.

**Multi-Region Setup**: Configuración distribuida geográficamente para alta disponibilidad y baja latencia.

---

## Acrónimos y abreviaciones

| Acrónimo | Significado |
|----------|-------------|
| **API** | Application Programming Interface |
| **CORS** | Cross-Origin Resource Sharing |
| **CPU** | Central Processing Unit |
| **DNS** | Domain Name System |
| **EKS** | Elastic Kubernetes Service |
| **HTTP** | HyperText Transfer Protocol |
| **HTTPS** | HyperText Transfer Protocol Secure |
| **JWT** | JSON Web Token |
| **K8s** | Kubernetes (8 letras entre K y s) |
| **OIDC** | OpenID Connect |
| **RAM** | Random Access Memory |
| **REST** | Representational State Transfer |
| **RPC** | Remote Procedure Call |
| **SLA** | Service Level Agreement |
| **SLI** | Service Level Indicator |
| **SLO** | Service Level Objective |
| **TLS** | Transport Layer Security |
| **TTL** | Time To Live |
| **URI** | Uniform Resource Identifier |
| **URL** | Uniform Resource Locator |
| **UUID** | Universally Unique Identifier |

---

## Referencias técnicas

**Arc42**: Plantilla de documentación de arquitectura de software ampliamente adoptada que define 12 secciones estándar.

**C4 Model**: Modelo de diagramación de arquitectura que define cuatro niveles: Context, Containers, Components, Code.

**Clean Architecture**: Arquitectura de software que separa las preocupaciones en capas concéntricas, promoviendo independencia de frameworks y testabilidad.

**Domain-Driven Design (DDD)**: Enfoque de desarrollo de software que se centra en el dominio del negocio y su lógica.

**SOLID Principles**: Cinco principios de diseño de software orientado a objetos que promueven código mantenible y extensible.

**Twelve-Factor App**: Metodología para construir aplicaciones SaaS con mejores prácticas para portabilidad y escalabilidad.
