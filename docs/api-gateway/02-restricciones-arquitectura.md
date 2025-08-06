# 2. Restricciones de la Arquitectura

Esta sección define las restricciones técnicas, organizacionales y operacionales que guían el diseño del API Gateway.

## 2.1 Restricciones Técnicas

### 🔧 Stack Tecnológico Obligatorio

| Componente | Tecnología | Justificación |
|------------|------------|---------------|
| **Runtime** | .NET 8 LTS | Estándar corporativo |
| **Proxy** | YARP | Integración nativa .NET |
| **Contenedores** | Docker + ECS | Estándar de despliegue |
| **Base de datos** | PostgreSQL | Estándar corporativo |
| **Cache** | Redis | Rendimiento y escalabilidad |

### 🌐 Protocolos y Estándares

- **OAuth2 + OIDC** para autenticación
- **JWT (RS256)** para tokens
- **TLS 1.3** mínimo para transporte
- **HTTP/2** para rendimiento
- **OpenAPI 3.0** para documentación

### 📊 Requisitos de Rendimiento

| Métrica | Requisito | Justificación |
|---------|-----------|---------------|
| **Latencia P95** | < 100ms | Experiencia de usuario |
| **Rendimiento** | > 5,000 RPS | Carga esperada |
| **Utilización CPU** | < 70% promedio | Planificación de capacidad |
| **Disponibilidad** | 99.9% | SLA empresarial |

## 2.2 Restricciones Organizacionales

### 🏢 Multi-tenancy Obligatorio

- **Aislamiento por país**: Perú, Ecuador, Colombia, México
- **Configuración independiente** por tenant
- **Rate limiting** específico por tenant
- **Datos segregados** por regulaciones locales

### 🔐 Seguridad Corporativa

- **Arquitectura zero trust** - Todo request debe ser autenticado
- **Implementación RBAC** - Roles definidos por tenant
- **Registro de auditoría** completo para cumplimiento
- **Cifrado de datos** en tránsito y reposo

## 2.3 Restricciones Operacionales

### 🚀 Deployment y DevOps

| Aspecto | Restricción | Impacto |
|---------|-------------|---------|
| **Deployment** | Blue-green únicamente | Cero tiempo de inactividad |
| **Configuración** | Almacén externo de configuración | Sin hardcoding |
| **Secretos** | AWS Secrets Manager | Cumplimiento de seguridad |
| **Monitoreo** | Prometheus + Grafana | Observabilidad estándar |

### ☁️ Proveedor Cloud

- **Primario**: AWS (ECS, ALB, RDS)
- **Portabilidad**: Diseño agnóstico de proveedor
- **Plan de respaldo**: Arquitectura lista para multi-cloud

### 🔍 Observabilidad Mandatoria

- **Logging estructurado** con Serilog
- **Distributed tracing** con OpenTelemetry
- **Recolección de métricas** con Prometheus
- **Alertas automáticas** en incidentes

## 2.4 Restricciones de Integración

### 🔗 Servicios Downstream

El API Gateway **SOLO** puede enrutar a estos servicios:

- **Identity Service** (Keycloak)
- **Sistema de Notificaciones**
- **Track & Trace**
- **SITA Messaging**

### 📡 Dependencias Externas

| Servicio | Propósito | Restricción |
|----------|-----------|-------------|
| **Keycloak** | Autenticación | Única fuente de verdad |
| **Plataforma de Configuración** | Configuración dinámica | Polling, no push |
| **Servicios AWS** | Infraestructura | Regiones específicas |

## 2.5 Restricciones Específicas de YARP

### Gestión de Configuración

| Aspecto | Restricción | Implementación | Gobierno |
|---------|-------------|----------------|----------|
| **Configuración Dinámica** | Recarga en caliente sin reinicio | Proveedores de configuración | Validación de cambios, capacidad de rollback |
| **Versionado de Rutas** | Soporte para versionado de API | Enrutamiento basado en header/path | Pruebas de compatibilidad de versiones |
| **Balanceador de Carga** | Soporte para múltiples algoritmos | Round-robin, menos conexiones | Enrutamiento basado en salud |
| **Transformaciones** | Modificación de request/response | Manipulación de headers, reescritura de paths | Validación de transformaciones |

### Health Checks y Monitoreo

| Componente | Requisito | Implementación | Alertas |
|-----------|-----------|----------------|---------|
| **Salud Upstream** | Monitoreo activo de salud | Endpoints HTTP de health | Alertas de indisponibilidad de servicio |
| **Circuit Breakers** | Tolerancia a fallos | Integración con Polly | Monitoreo de estado de circuitos |
| **Políticas de Reintentos** | Patrones de resiliencia | Backoff exponencial | Seguimiento de intentos de reintento |
| **Gestión de Timeouts** | Manejo de timeouts de request | Timeouts configurables | Monitoreo de ocurrencia de timeouts |

### Optimización de Rendimiento

| Optimización | Objetivo | Método | Medición |
|--------------|----------|--------|----------|
| **Pool de Conexiones** | Uso eficiente de recursos | Pool de cliente HTTP | Métricas de utilización del pool |
| **Cache de Respuestas** | Reducir carga del backend | Patrón cache-aside | Tasas de acierto de cache |
| **Compresión** | Optimización de ancho de banda | Compresión Gzip/Brotli | Ratios de compresión |
| **Keep-Alive** | Reutilización de conexiones | HTTP keep-alive | Métricas de conexión |

## 2.6 Restricciones de Seguridad

### Autenticación y Autorización

| Control | Requisito | Implementación | Validación |
|---------|-----------|----------------|------------|
| **Validación de Tokens** | Verificación de firma JWT | Validación de clave pública de Keycloak | Introspección de tokens, verificación de firma |
| **Limitación de Velocidad** | Límites por cliente y globales | Protección DDoS, uso justo | Contadores basados en Redis, ventanas deslizantes |
| **Lista de IPs Permitidas** | Restricciones de IP origen | Capa adicional de seguridad | Rangos de IP configurables por tenant |
| **Validación de Requests** | Sanitización de entrada | Endurecimiento de seguridad | Validación de esquemas, filtrado de entrada |

### Protección de Datos

| Aspecto | Requisito | Implementación | Monitoreo |
|---------|-----------|----------------|-----------|
| **Datos en Tránsito** | Cifrado TLS 1.3 | Terminación SSL/TLS | Monitoreo de expiración de certificados |
| **Headers Sensibles** | Filtrado de headers PII | Protección de privacidad de datos | Inspección de headers, reglas de filtrado |
| **Audit Logging** | Logging completo de requests | Requisitos de compliance | Logging estructurado, retención de logs |
| **Headers de Seguridad** | Headers de seguridad estándar | Cumplimiento OWASP | Inyección de headers, escaneo de seguridad |

### Seguridad de Red

| Control | Propósito | Implementación | Validación |
|---------|-----------|----------------|------------|
| **Aislamiento VPC** | Segmentación de red | VPC AWS, grupos de seguridad | Revisión de topología de red |
| **Integración WAF** | Web application firewall | Reglas AWS WAF | Detección de patrones de ataque |
| **Protección DDoS** | Mitigación de ataques | AWS Shield Advanced | Pruebas de simulación DDoS |
| **Network ACLs** | Filtrado de tráfico | Controles a nivel de subred | Análisis de tráfico |

## 2.7 Restricciones de Deployment

### Containerización

| Aspecto | Requisito | Implementación | Validación |
|---------|-----------|----------------|------------|
| **Imagen de Contenedor** | Imágenes base distroless | Endurecimiento de seguridad | Escaneo de vulnerabilidades |
| **Límites de Recursos** | Restricciones CPU/memoria | Límites de Kubernetes | Monitoreo de recursos |
| **Endpoints de Salud** | Probes de liveness/readiness | Health checks HTTP | Configuración de probes |
| **Cierre Elegante** | Terminación limpia | Manejo de SIGTERM | Pruebas de cierre |

### Orquestación

| Componente | Tecnología | Restricción | Configuración |
|-----------|------------|-------------|---------------|
| **Plataforma de Contenedores** | AWS ECS Fargate | Requisito serverless | Definiciones de tareas, configuración de servicios |
| **Load Balancer** | AWS Application Load Balancer | Alta disponibilidad | Despliegue multi-AZ |
| **Auto Scaling** | ECS Service Auto Scaling | Escalado dinámico | Basado en métricas de CloudWatch |
| **Service Discovery** | AWS Cloud Map | Registro de servicios | Descubrimiento basado en DNS |

### Pipeline CI/CD

| Etapa | Requisito | Implementación | Quality Gates |
|-------|-----------|----------------|---------------|
| **Build** | Compilación automatizada | GitHub Actions | Verificaciones de calidad de código |
| **Test** | Pruebas exhaustivas | Pruebas unitarias, integración, carga | Umbrales de cobertura |
| **Seguridad** | Escaneo de seguridad | SAST, DAST, verificación de dependencias | Evaluaciones de vulnerabilidades |
| **Deploy** | Despliegue blue-green | Actualizaciones rolling de ECS | Validación de health checks |

## 2.8 Restricciones de Monitoreo

### Observabilidad Mandatoria

| Componente | Herramienta | Propósito | Configuración |
|-----------|-------------|-----------|---------------|
| **Métricas** | CloudWatch + Prometheus | Monitoreo de rendimiento | Métricas personalizadas, dashboards |
| **Logging** | CloudWatch Logs | Logging centralizado | Logs JSON estructurados |
| **Tracing** | AWS X-Ray + OpenTelemetry | Trazado de requests | Correlación de trazas |
| **APM** | Monitoreo de aplicaciones | Perspectivas de rendimiento | Seguimiento de errores, profiling |

### Métricas Empresariales

| Métrica | Propósito | Implementación | Alertas |
|---------|-----------|----------------|---------|
| **Tasa de Requests** | Monitoreo de tráfico | Métricas de contador | Detección de picos de tráfico |
| **Tasa de Errores** | Salud del sistema | Cálculo de ratio de errores | Alertas de ruptura de SLA |
| **Tiempo de Respuesta** | Seguimiento de rendimiento | Métricas de histograma | Degradación de latencia |
| **Métricas por Tenant** | Monitoreo multi-tenant | Métricas específicas por tenant | Alertas por tenant |

### Monitoreo de SLA

| Métrica SLA | Objetivo | Medición | Acción |
|-------------|----------|----------|--------|
| **Disponibilidad** | 99.9% uptime | Agregación de health checks | Respuesta a incidentes |
| **Tiempo de Respuesta** | p95 < 200ms | Percentiles de latencia | Optimización de rendimiento |
| **Tasa de Errores** | < 0.1% | Monitoreo de ratio de errores | Análisis de causa raíz |
| **Capacidad de procesamiento** | 50k req/min | Seguimiento de tasa de requests | Planificación de capacidad |

## 2.9 Limitaciones Conocidas

### ⚠️ Técnicas

- **Actualizaciones de configuración**: Máximo cada 30 segundos (polling)
- **Circuit breaker**: Estado compartido entre instancias
- **Rate limiting**: Consistencia eventual en cluster

### 💰 Presupuestarias

- **Costo de infraestructura**: Optimización requerida
- **Límites de escalado**: Auto-scaling con límites definidos
- **Transferencia de datos**: Minimizar entre regiones

### 📅 Tiempo

- **Fase 1**: Características básicas (6 meses)
- **Fase 2**: Cache distribuido y características avanzadas
- **Ventana de migración**: Máximo 4 horas de downtime

## 2.10 Impacto en el Diseño

### Decisiones Arquitectónicas Derivadas

| Restricción | Decisión de Diseño | Trade-off | Mitigación |
|-------------|-------------------|-----------|------------|
| **Soporte Multi-tenant** | Middleware consciente de tenant | Sobrecarga de procesamiento de requests | Resolución eficiente de tenant |
| **Alta Disponibilidad** | Diseño sin estado | Complejidad de gestión de sesiones | Almacenamiento externo de sesiones |
| **Requisitos de Seguridad** | Validación exhaustiva | Latencia de procesamiento | Pipelines de validación optimizados |
| **Objetivos de Rendimiento** | Estrategias de caching | Desafíos de consistencia de datos | Estrategias de invalidación de cache |

## Referencias

### Microsoft YARP

- [YARP Documentation](https://microsoft.github.io/reverse-proxy/)
- [YARP Configuration](https://microsoft.github.io/reverse-proxy/articles/config-files.html)
- [YARP Balanceador de Carga](https://microsoft.github.io/reverse-proxy/articles/load-balancing.html)

### AWS Services

- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [AWS Application Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/)
- [AWS CloudWatch](https://docs.aws.amazon.com/cloudwatch/)

### Security Standards

- [OAuth 2.0 (RFC 6749)](https://tools.ietf.org/html/rfc6749)
- [OpenID Connect Core](https://openid.net/specs/openid-connect-core-1_0.html)
- [JWT (RFC 7519)](https://tools.ietf.org/html/rfc7519)

### Compliance

- [GDPR Regulation](https://gdpr-info.eu/)
- [PCI DSS Standards](https://www.pcisecuritystandards.org/)
- [OWASP API Security](https://owasp.org/www-project-api-security/)
