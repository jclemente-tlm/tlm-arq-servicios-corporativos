# Servicios Corporativos - Arquitectura Multi-Tenant

Sistema distribuido de microservicios para operaciones corporativas en múltiples países de Latinoamérica.

## 📋 Documentación Principal

| Documento | Propósito | Audiencia |
|-----------|-----------|-----------|
| **[Resumen Ejecutivo](docs/executive-summary.md)** | Visión estratégica y beneficios empresariales | Ejecutivos, Product Owners |
| **[Documentación Arc42](docs/architecture-documentation-arc42.md)** | Arquitectura completa según metodología Arc42 | Arquitectos, Desarrolladores |
| **[Decisiones Arquitectónicas](docs/adrs/)** | ADRs detalladas con contexto y consecuencias | Equipo técnico |

## 🏗️ Arquitectura

### Servicios Principales
- **API Gateway (YARP):** Punto de entrada único con autenticación y resiliencia
- **Sistema de Notificaciones:** Envío multicanal (Email, SMS, WhatsApp, Push)
- **Track & Trace:** Seguimiento de eventos con CQRS y trazabilidad completa
- **SITA Messaging:** Generación y envío de archivos SITA para aerolíneas
- **Sistema de Identidad:** Autenticación multi-tenant con OAuth2/JWT

### Stack Tecnológico
- **Runtime:** .NET 8 LTS (soporte hasta 2026)
- **Base de Datos:** PostgreSQL con schemas multi-tenant
- **Cache:** Redis para sesiones y performance
- **Cloud:** AWS (ECS Fargate, RDS, ElastiCache, S3)
- **Observabilidad:** Prometheus, Grafana, Serilog

## 🚀 Inicio Rápido

### Prerequisitos
- .NET 8 SDK
- Docker & Docker Compose
- Node.js (para scripts de diagramas)

### Ejecutar Localmente
```bash
# Iniciar servicios de desarrollo
./start.sh

# Ver diagramas de arquitectura
./start.sh servicios-corporativos.dsl
# Luego abrir http://localhost:8090
```

### Generar Diagramas
```bash
# Exportar todos los diagramas
./export-diagrams.sh

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