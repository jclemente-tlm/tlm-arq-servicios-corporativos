# 1. Introducción y Objetivos

## 1.1 Descripción General de los Requisitos

### Propósito del Sistema

El **Enterprise API Gateway** es el punto de entrada centralizado para toda la plataforma de servicios corporativos de Talma. Actúa como un proxy reverso inteligente construido sobre **YARP** (Yet Another Reverse Proxy) de Microsoft, proporcionando una interfaz unificada para el acceso a microservicios distribuidos.

### Contexto Empresarial

Como empresa líder en servicios aeroportuarios multi-país, Talma requiere una arquitectura que permita:

- **Operaciones multi-tenant** para Perú, Ecuador, Colombia y México
- **Escalabilidad** para manejar el crecimiento del tráfico empresarial
- **Seguridad** robusta para proteger datos sensibles corporativos
- **Integración** con sistemas empresariales y regulatorios locales

### Capacidades Principales

| Capacidad | Descripción | Valor de Negocio |
|-----------|-------------|------------------|
| **Punto Único de Entrada** | Punto único de acceso a todos los servicios | Simplifica integración de clientes |
| **Seguridad Multi-tenant** | Aislamiento seguro por país/tenant | Cumplimiento regulatorio |
| **Enrutamiento Inteligente** | Enrutamiento dinámico basado en reglas | Flexibilidad operacional |
| **Patrones de Resiliencia** | Circuit breakers, reintentos, timeouts | Alta disponibilidad |
| **Observabilidad** | Métricas, registros y trazado distribuido | Operaciones proactivas |
| **Limitación de Velocidad** | Control de tráfico por tenant y API | Protección de recursos |

### Requisitos Funcionales Principales

| ID | Requisito | Descripción |
|----|-----------|-------------|
| **RF-GW-01** | **Proxy Reverso** | Enrutamiento transparente hacia servicios backend |
| **RF-GW-02** | **Autenticación Centralizada** | Validación OAuth2/JWT con Keycloak |
| **RF-GW-03** | **Multi-tenant Routing** | Enrutamiento basado en tenant (país) |
| **RF-GW-04** | **Limitación de Velocidad** | Límites configurables por tenant y endpoint |
| **RF-GW-05** | **Monitoreo de Salud** | Monitoreo de salud de servicios downstream |
| **RF-GW-06** | **Request/Response Transformation** | Modificación de headers y payloads |
| **RF-GW-07** | **Circuit Breaker** | Protección contra failures en cascada |
| **RF-GW-08** | **Balanceador de Carga** | Distribución de carga entre instancias |
| **RF-GW-09** | **Audit Logging** | Registro completo de requests y responses |
| **RF-GW-10** | **Gestión de Configuración** | Configuración dinámica sin downtime |

### Requisitos No Funcionales

| Categoría | Requisito | Target | Medición |
|-----------|-----------|--------|----------|
| **Rendimiento** | Latencia de proxy | p95 < 50ms | APM monitoring |
| **Rendimiento** | Capacidad de procesamiento | > 10,000 RPS por instancia | Pruebas de carga |
| **Disponibilidad** | Tiempo de actividad | 99.95% | Monitoreo de SLA |
| **Scalability** | Escalado horizontal | Escalado automático en < 2 min | Métricas de contenedores |
| **Security** | Validación de tokens | < 5ms por request | Métricas de seguridad |
| **Confiabilidad** | Tasa de errores | < 0.1% | Métricas empresariales |

## 1.2 Objetivos de Calidad

### Objetivos Primarios

| Prioridad | Objetivo | Escenario | Métrica Objetivo |
|-----------|----------|-----------|------------------|
| **1** | **Rendimiento** | Proxy transparente sin latencia significativa | p95 < 50ms sobrecarga |
| **2** | **Confiabilidad** | Alta disponibilidad para operaciones críticas | 99.95% disponibilidad |
| **3** | **Security** | Protección robusta contra amenazas | Cero incidentes de seguridad |

### Objetivos Secundarios

| Objetivo | Descripción | Métrica |
|----------|-------------|---------|
| **Scalability** | Manejo de picos de tráfico sin degradación | Soporte de 10x la carga actual |
| **Maintainability** | Facilidad de configuración y despliegue | < 5 min actualizaciones de configuración |
| **Observability** | Visibilidad completa del tráfico de API | 100% requests trazados |
| **Cost Efficiency** | Optimización de recursos computacionales | < 2% sobrecarga de CPU |

## 1.3 Partes Interesadas

### Stakeholders Principales

| Rol | Contacto | Responsabilidades | Expectativas |
|-----|----------|-------------------|--------------|
| **Arquitecto de Plataforma** | jclemente-tlm | Decisiones arquitectónicas, patrones | Diseño escalable, rendimiento |
| **Equipo DevOps/SRE** | SRE Team | Deployment, monitoring, incidents | Despliegues confiables, observabilidad |
| **Equipo de Seguridad** | Equipo de Seguridad | Autenticación, autorización, compliance | Diseño seguro, capacidades de auditoría |
| **Equipos de Aplicación** | Dev Teams | Integración con servicios backend | APIs consistentes, documentación clara |

### Stakeholders Secundarios

| Rol | Contacto | Interés | Comunicación |
|-----|----------|---------|--------------|
| **Equipos de Operaciones** | Ops Teams | Monitoreo de servicios downstream | Dashboards, alertas |
| **Oficiales de Cumplimiento** | Equipo Legal | Cumplimiento regulatorio, trazas de auditoría | Reportes de cumplimiento |
| **Integradores Externos** | Partners | Acceso a APIs corporativas | Documentación de API, SLAs |
| **Usuarios Finales** | Various | Rendimiento y disponibilidad de aplicaciones | Operación transparente |

### Sistemas Cliente

| Sistema | Tipo | Descripción | Expectativas |
|---------|------|-------------|--------------|
| **Aplicaciones Web** | Frontend | Apps corporativas por país | Respuesta rápida, alta disponibilidad |
| **Aplicaciones Móviles** | Frontend | Apps móviles iOS/Android | Uso eficiente de API, soporte offline |
| **Sistemas de Terceros** | External | Sistemas de partners y proveedores | APIs estables, documentación clara |
| **Herramientas Internas** | Internal | Herramientas administrativas | Acceso seguro, trazas de auditoría |

## 1.4 Arquitectura de Referencia

### Stack Tecnológico

| Componente | Tecnología | Versión | Justificación |
|------------|------------|---------|---------------|
| **Tiempo de ejecución** | .NET 8 + ASP.NET Core | 8.0 LTS | Rendimiento, soporte a largo plazo |
| **Motor de Proxy** | YARP | Latest | Soporte de Microsoft, alto rendimiento |
| **Resilience** | Polly | 8.x | Estándar de la industria para .NET |
| **Logging** | Serilog | 3.x | Capacidades de logging estructurado |
| **Metrics** | Prometheus.NET | Latest | Estándar para colección de métricas |
| **Despliegue** | AWS ECS + Docker | Latest | Orquestación de contenedores |
| **Cache** | Redis | 7.x | Caché distribuido (Fase 2) |

### Principios Arquitectónicos

1. **Transparencia:** El gateway debe ser invisible para los clientes
2. **Resiliencia:** Fallo rápido con degradación elegante
3. **Observabilidad:** Todo debe ser medible y trazable
4. **Escalabilidad:** Diseño horizontal primero
5. **Seguridad:** Defensa en profundidad, zero trust
6. **Configurabilidad:** Configuración dinámica sin tiempo de inactividad

## 1.5 Alcance del Sistema

### Dentro del Alcance

- Proxy reverso para servicios corporativos
- Autenticación y autorización centralizada
- Rate limiting y throttling
- Circuit breakers y retry policies
- Health checks y service discovery
- Request/response logging y metrics
- Multi-tenant gestión de configuración

### Fuera del Alcance

- Lógica empresarial específica de servicios
- Almacenamiento de datos de negocio
- Procesamiento de eventos de dominio
- Integración directa con sistemas legacy
- Content delivery network (CDN)
- Versionado de API (Fase 2)

### Límites del Sistema

**Flujo ascendente:** Recibe requests de aplicaciones cliente
**Flujo descendente:** Enruta requests a servicios corporativos
**Este-Oeste:** Integración con sistemas de autenticación y monitoreo
