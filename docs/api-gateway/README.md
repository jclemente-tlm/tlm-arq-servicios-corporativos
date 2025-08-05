# API Gateway - Documentación Simplificada

## 🎯 ¿Qué es?

El **Enterprise API Gateway** es el punto de entrada único para todos nuestros servicios corporativos. Funciona como un proxy reverso inteligente usando **YARP** (Yet Another Reverse Proxy) de Microsoft.

## 🔧 Stack Tecnológico

- **Runtime**: .NET 8 + ASP.NET Core
- **Proxy**: YARP (Yet Another Reverse Proxy)
- **Resiliencia**: Polly (Circuit breakers, Retry policies)
- **Logging**: Serilog (Structured logging)
- **Métricas**: Prometheus.NET
- **Deployment**: AWS ECS (Docker containers)
- **Cache**: Redis (Fase 2)

## 🏗️ Arquitectura

```
Cliente ──▶ Security ──▶ Tenant ──▶ Rate Limit ──▶ Resilience ──▶ Service
          Middleware   Resolution   Middleware     Handler      Backend
```

### Componentes Principales

| Componente | Tecnología | Propósito |
|------------|------------|-----------|
| **Security Middleware** | ASP.NET Core | Autenticación JWT/OAuth2 |
| **Tenant Resolution** | ASP.NET Core | Identifica tenant (país) |
| **Rate Limiting** | ASP.NET Core | Control de tráfico |
| **Resilience Handler** | Polly | Circuit breakers, retries |
| **Health Checks** | ASP.NET Core | Monitoreo de salud |
| **Metrics Collector** | Prometheus.NET | Recolección de métricas |

## 🌍 Multi-tenancy

Soportamos 4 tenants:

- **Peru** - Aplicaciones peruanas
- **Ecuador** - Aplicaciones ecuatorianas
- **Colombia** - Aplicaciones colombianas
- **Mexico** - Aplicaciones mexicanas

Cada tenant tiene:

- Configuración independiente
- Rate limits específicos
- Logging segregado
- Políticas de seguridad propias

## 🔗 Servicios Downstream

| Servicio | URL Pattern | Propósito |
|----------|-------------|-----------|
| **Identity** | `/auth/*` | Autenticación (Keycloak) |
| **Notifications** | `/notifications/*` | Sistema de notificaciones |
| **Track & Trace** | `/tracking/*` | Seguimiento de envíos |
| **SITA Messaging** | `/sita/*` | Mensajería aeroportuaria |

## 📊 Métricas y Monitoreo

### Métricas Clave

- **Latencia P95**: < 100ms
- **Throughput**: > 5,000 RPS por instancia
- **Disponibilidad**: 99.9% SLA
- **Error Rate**: < 0.1%

### Observabilidad

- **Logs estructurados** con Serilog
- **Métricas** con Prometheus + Grafana
- **Distributed tracing** con OpenTelemetry
- **Health checks** automáticos

## 🔐 Seguridad

- **OAuth2 + OIDC** con Keycloak
- **JWT tokens** (RS256)
- **TLS 1.3** mínimo
- **Rate limiting** por tenant
- **Audit logging** completo

## 🚀 Deployment

### AWS ECS

- **Containers**: Docker con .NET 8
- **Load Balancer**: Application Load Balancer
- **Auto-scaling**: Basado en CPU y latencia
- **Health checks**: Endpoint `/health`

### Configuration

- **External config**: Polling cada 30s
- **Secrets**: AWS Secrets Manager
- **Feature flags**: Configuration Platform

## 🔄 Resiliencia

### Polly Policies

- **Circuit breaker**: 5 fallos → Open por 60s
- **Retry**: 3 intentos con backoff exponencial
- **Timeout**: 30s por request
- **Bulkhead**: Aislamiento por servicio

### Failover

- **Multi-AZ deployment**
- **Health check** cada 30s
- **Graceful degradation**
- **Automatic failover** < 60s

## 📋 Roadmap

### ✅ Fase 1 (Actual)

- Security middleware
- Tenant resolution
- Rate limiting básico
- Health checks
- Métricas básicas
- Deployment en ECS

### 🔄 Fase 2 (Futuro)

- Cache distribuido (Redis)
- Advanced routing rules
- WebSocket support
- API versioning
- Advanced monitoring

## 🔧 Configuración Local

```bash
# Clone repo
git clone <repo-url>

# Run with Docker Compose
docker-compose up -d

# Gateway disponible en:
# http://localhost:8080
```

## 📚 Documentación Detallada

Para documentación Arc42 completa, ver:

- [01. Introducción y Objetivos](./01-introduccion-y-objetivos.md)
- [02. Restricciones](./02-restricciones-de-la-arquitectura.md)
- [05. Bloques de Construcción](./05-vista-bloques-construccion.md)
- [09. Decisiones Arquitectónicas](./09-decisiones-arquitectura.md)

---

**Principio**: Mantenemos la documentación simple, práctica y alineada con la implementación real.
