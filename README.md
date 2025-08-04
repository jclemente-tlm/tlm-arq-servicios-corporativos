# Servicios Corporativos - Arquitectura Multi-Tenant

Sistema distribuido de microservicios para operaciones corporativas en Perú, Ecuador, Colombia y México.

## 🎯 ¿Qué es?

Plataforma de servicios corporativos diseñada con:

- **Multi-tenancy** para 4 países
- **Arquitectura agnóstica** de cloud provider
- **Stack .NET 8** moderno y escalable
- **Deployment en AWS ECS** con contenedores
- **Observabilidad completa** desde el día 1

## 🏗️ Servicios

### 🚪 API Gateway (YARP)
Punto de entrada único con autenticación, rate limiting y resiliencia.

**Stack**: .NET 8 + YARP + Polly + Serilog + Prometheus

### 🔐 Identity Service (Keycloak)
Autenticación y autorización multi-tenant con OAuth2/JWT.

**Stack**: Keycloak + PostgreSQL + Docker

### 📧 Notification System
Notificaciones multicanal (Email, SMS, WhatsApp, Push).

**Stack**: .NET 8 + PostgreSQL + Redis + AWS SES/SNS

### 📦 Track & Trace
Seguimiento de eventos con CQRS y trazabilidad completa.

**Stack**: .NET 8 + PostgreSQL + Event Sourcing

### ✈️ SITA Messaging
Generación y envío de archivos SITA para aerolíneas.

**Stack**: .NET 8 + PostgreSQL + SITA Format + SFTP

## 🔧 Stack Tecnológico

| Componente | Tecnología | Justificación |
|------------|------------|---------------|
| **Runtime** | .NET 8 LTS | Standard corporativo, soporte hasta 2026 |
| **Base de Datos** | PostgreSQL | ACID, escalabilidad, multi-tenancy |
| **Cache** | Redis | Performance, sesiones distribuidas |
| **Proxy** | YARP | Integración nativa .NET, alto rendimiento |
| **Auth** | Keycloak | Standard enterprise, multi-tenant |
| **Containers** | Docker + ECS | Portabilidad, escalabilidad |
| **Observability** | Prometheus + Grafana + Serilog | Monitoreo completo |

## 🌍 Multi-Tenancy

Cada país opera como tenant independiente:

- **Peru**: Aplicaciones peruanas
- **Ecuador**: Aplicaciones ecuatorianas
- **Colombia**: Aplicaciones colombianas
- **Mexico**: Aplicaciones mexicanas

### Aislamiento por Tenant

- **Datos**: Schemas separados en PostgreSQL
- **Configuración**: Por tenant en Configuration Platform
- **Rate Limiting**: Políticas específicas por país
- **Logging**: Segregado por tenant
- **Métricas**: Dashboards por país

## 🚀 Quick Start

### Prerequisitos

- .NET 8 SDK
- Docker & Docker Compose
- Node.js (para scripts de diagramas)

### Desarrollo Local

```bash
# Iniciar todos los servicios
docker-compose up -d

# Ver logs de un servicio específico
docker-compose logs -f api-gateway

# Parar servicios
docker-compose down
```

### Ver Arquitectura

```bash
# Generar diagramas C4
./export-diagrams.sh

# Iniciar Structurizr local
./start.sh

# Abrir http://localhost:8090
```

## 📊 Monitoreo

### URLs Importantes

- **API Gateway**: http://localhost:8080
- **Grafana**: http://localhost:3000
- **Prometheus**: http://localhost:9090
- **Keycloak**: http://localhost:8180

### Métricas Clave

- **Latencia P95**: < 100ms
- **Throughput**: > 5,000 RPS
- **Disponibilidad**: 99.9% SLA
- **Error Rate**: < 0.1%

## 📚 Documentación

### Por Servicio

- [API Gateway](docs/api-gateway/README.md) - Proxy reverso y routing
- [Identity Service](docs/servicio-identidad/) - Autenticación OAuth2
- [Notification System](docs/servicio-notificacion/) - Notificaciones multicanal
- [Track & Trace](docs/servicio-track-trace/) - Seguimiento de eventos
- [SITA Messaging](docs/servicio-mensajeria-sita/) - Mensajería aeroportuaria

### Documentación Arc42

Documentación completa siguiendo metodología Arc42:

- [Introducción y Objetivos](docs/)
- [Restricciones](docs/)
- [Decisiones Arquitectónicas](docs/adrs/)

## 🔄 CI/CD

### AWS ECS Deployment

```bash
# Build y push de imágenes
docker build -t api-gateway .
docker tag api-gateway:latest <ecr-repo>/api-gateway:latest
docker push <ecr-repo>/api-gateway:latest

# Deploy via ECS Task Definition
aws ecs update-service --cluster corporate-services --service api-gateway
```

### Infrastructure as Code

- **Terraform**: Infrastructure provisioning
- **Docker Compose**: Local development
- **ECS Task Definitions**: Production deployment

## 🔐 Seguridad

- **OAuth2 + OIDC** para autenticación
- **JWT (RS256)** para tokens
- **TLS 1.3** mínimo para transporte
- **Multi-factor auth** para admins
- **Audit logging** completo
- **Rate limiting** por tenant

## 🎯 Roadmap

### ✅ Fase 1 (6 meses)
- Servicios core funcionales
- Multi-tenancy básico
- Deployment en ECS
- Observabilidad básica

### 🔄 Fase 2 (3 meses)
- Cache distribuido
- Advanced monitoring
- Performance optimization
- Advanced security features

### 🚀 Fase 3 (3 meses)
- Multi-cloud support
- Advanced automation
- ML-based monitoring
- Advanced analytics

---

**Principios**: Simplicidad, Portabilidad, Observabilidad, Multi-tenancy

# Ver diagramas generados
ls diagrams/
```

## 📁 Estructura del Proyecto

```
├── design/                          # Arquitectura C4 en Structurizr DSL
│   ├── servicios-corporativos.dsl   # Archivo principal de arquitectura
│   ├── common/                      # Recursos compartidos (iconos, estilos)
│   └── systems/                     # Modelos por sistema
├── docs/                            # Documentación completa
│   ├── architecture-documentation-arc42.md  # Documentación principal Arc42
│   ├── executive-summary.md         # Resumen ejecutivo
│   └── adrs/                        # Decisiones arquitectónicas
├── diagrams/                        # Diagramas exportados (PNG)
├── infrastructure/                  # IaC y configuración AWS
└── scripts/                         # Scripts de automatización
```

## 🛡️ Características Clave

### Multi-Tenancy
- **Aislamiento:** PostgreSQL schemas por tenant
- **Configuración:** Dinámica por país/cliente
- **Datos:** Completa separación y auditoría

### Resiliencia
- **Circuit Breakers:** Polly para prevenir cascadas de fallos
- **Rate Limiting:** Por tenant y endpoint
- **Auto-Scaling:** ECS Fargate basado en métricas

### Observabilidad
- **Logs Estructurados:** Serilog con correlation IDs
- **Métricas:** Prometheus con dashboards Grafana
- **Tracing:** OpenTelemetry (roadmap Q4 2025)

### Configuración Dinámica
- **Providers:** AWS SSM, Azure App Config, Consul, K8s
- **Polling:** Inteligente con validación y cache
- **Zero Downtime:** Cambios sin reinicio de servicios

## 📊 Métricas de Calidad

| Objetivo | Target | Estado |
|----------|--------|--------|
| **Disponibilidad** | 99.9% | 🎯 En progreso |
| **Latencia p95** | < 200ms | 🎯 En progreso |
| **Escalabilidad** | 10x carga actual | ✅ Implementado |
| **Test Coverage** | 80% | 🔄 70% actual |

## 🤝 Contribución

### Desarrollo
1. Fork el repositorio
2. Crear branch feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit cambios (`git commit -m 'Añadir nueva funcionalidad'`)
4. Push branch (`git push origin feature/nueva-funcionalidad`)
5. Crear Pull Request

### Documentación
- Seguir metodología Arc42 para cambios arquitectónicos
- Actualizar diagramas C4 en Structurizr DSL
- Crear ADRs para decisiones técnicas importantes

## 📞 Contacto

**Equipo de Arquitectura**
- Arquitecto Principal: jclemente-tlm
- Email: arquitectura@talma.com.pe
- Slack: #arquitectura-servicios-corporativos

---

**Última actualización:** Agosto 2025
**Versión:** 1.0
**Estado:** En Desarrollo - Fase 1