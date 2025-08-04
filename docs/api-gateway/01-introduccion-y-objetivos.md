# 1. Introducción y Objetivos

## ¿Qué es el API Gateway?

El **Enterprise API Gateway** es el punto de entrada único para todos los servicios corporativos. Funciona como un proxy reverso inteligente que gestiona el tráfico hacia nuestros microservicios usando **YARP** (Yet Another Reverse Proxy) de Microsoft.

## Funcionalidades Principales

- 🛡️ **Seguridad centralizada** - Autenticación OAuth2/JWT con Keycloak
- 🔀 **Routing inteligente** - Enruta requests a servicios backend
- ⚡ **Rate limiting** - Control de tráfico por tenant
- 🔄 **Resiliencia** - Circuit breakers y retry policies
- 📊 **Observabilidad** - Métricas, logs y tracing distribuido

## Stack Tecnológico

| Componente | Tecnología | Propósito |
|------------|------------|-----------|
| **Runtime** | .NET 8 + ASP.NET Core | Plataforma base |
| **Proxy** | YARP | Reverse proxy y load balancing |
| **Resiliencia** | Polly | Circuit breakers y retry policies |
| **Logging** | Serilog | Logging estructurado |
| **Métricas** | Prometheus.NET | Recolección de métricas |
| **Cache** | Redis | Cache distribuido (Fase 2) |
| **Deployment** | AWS ECS | Contenedores Docker |

## Objetivos del Sistema

### 🎯 Objetivos de Negocio
1. **Punto único de acceso** a todos los servicios corporativos
2. **Seguridad consistente** across all microservices
3. **Multi-tenancy** para Peru, Ecuador, Colombia y México
4. **Alta disponibilidad** 99.9% SLA
5. **Escalabilidad horizontal** para crecimiento futuro

### 🔧 Objetivos Técnicos
- **Performance**: < 100ms latencia P95
- **Throughput**: > 5,000 RPS por instancia
- **Configuración dinámica** sin downtime
- **Portabilidad cloud** - agnóstico de proveedor

## Stakeholders

| Stakeholder | Responsabilidad |
|-------------|-----------------|
| **Desarrollo** | APIs consistentes y documentación |
| **Operaciones** | Monitoreo y alertas |
| **Seguridad** | Autenticación y autorización |
| **Aplicaciones Cliente** | Acceso unificado a servicios |

## Scope y Limitaciones

### ✅ En Scope
- Proxy reverso con YARP
- Autenticación/Autorización
- Rate limiting por tenant
- Health checks y métricas
- Logging estructurado

### ❌ Fuera de Scope
- Transformación compleja de datos
- Business logic
- Persistencia de datos de negocio
- Direct database access

## Fases de Implementación

### 📋 Fase 1 (Actual)
- Security middleware
- Tenant resolution
- Rate limiting básico
- Health checks
- Métricas básicas

### 📋 Fase 2 (Futuro)
- Cache distribuido con Redis
- Advanced routing rules
- WebSocket support
- API versioning avanzado
