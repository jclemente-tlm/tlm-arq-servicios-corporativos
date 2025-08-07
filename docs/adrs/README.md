# Registros de Decisiones Arquitectónicas (ADRs)

Este directorio contiene los Registros de Decisiones Arquitectónicas (Architecture Decision Records - ADRs) para el proyecto de servicios corporativos.

## ¿Qué es un ADR?

Un ADR es un documento que captura una decisión arquitectónica importante junto con su contexto, alternativas evaluadas, criterios de decisión y consecuencias.

## Formato Estándar

Cada ADR sigue la estructura:
- **Estado**: Propuesta, Aceptada, Obsoleta, Supersedida
- **Contexto**: Situación que motiva la decisión y alternativas evaluadas
- **Comparativa**: Matriz de criterios con pesos y puntuaciones
- **Análisis de Costos**: TCO y consideraciones económicas
- **Decisión**: La decisión tomada con justificación
- **Consecuencias**: Resultados positivos, negativos y neutros
- **Referencias**: Enlaces y documentación relevante

## Clasificación de ADRs

### ADRs GLOBALES/COMUNES
*Decisiones que aplican a toda la arquitectura y todos los servicios*

| ADR | Título | Estado | Fecha | Descripción |
|-----|--------|--------|-------|-------------|
| [ADR-001](adr-001-gestion-secrets-manager.md) | Gestión de Secretos | Aceptada | 2024-03 | Estrategia para manejo seguro de secretos |
| [ADR-002](adr-002-estrategia-mensajeria-agnostica.md) | Estrategia de Mensajería Agnóstica | Aceptada | 2025-08 | Solución de mensajería portable (Kafka) |
| [ADR-003](adr-003-ecs-fargate.md) | Plataforma de Contenedores | Aceptada | 2024-03 | ECS Fargate para despliegue |
| [ADR-008](adr-008-autenticaciones.md) | Autenticación y Autorización | Aceptada | 2024-03 | Estrategia de seguridad transversal |
| [ADR-009](adr-009-postgresql-standard.md) | Base de Datos Estándar | Aceptada | 2024-03 | PostgreSQL como RDBMS principal |
| [ADR-010](adr-010-logging-serilog.md) | Logging Estructurado | Aceptada | 2024-03 | Serilog para logging transversal |
| [ADR-013](adr-013-versionado-apis.md) | Versionado de APIs | Aceptada | 2024-03 | Estrategia de versionado |
| [ADR-014](adr-014-ci-cd-github-actions.md) | Pipeline CI/CD | Aceptada | 2024-03 | GitHub Actions para CI/CD |
| [ADR-015](adr-015-iac-terraform.md) | Infraestructura como Código | Aceptada | 2024-03 | Terraform para IaC |
| [ADR-017](adr-017-event-store-agnostico.md) | Event Store Agnóstico | Aceptada | 2024-08 | Almacenamiento de eventos portable |
| [ADR-020](adr-020-storage-agnostico.md) | Storage Agnóstico | Aceptada | 2024-08 | Estrategia de almacenamiento portable |
| [ADR-022](adr-022-configuracion-agnostica.md) | Configuración Agnóstica | Aceptada | 2024-08 | Gestión de configuración portable |
| [ADR-023](adr-023-proveedor-identidad-keycloak.md) | Proveedor de Identidad | Aceptada | 2025-08 | Keycloak para gestión de identidades |
| [ADR-024](adr-024-estrategia-cache-redis.md) | Estrategia de Caché | Aceptada | 2025-08 | Redis para caché distribuido |
| [ADR-025](adr-025-estrategia-multi-tenancy.md) | Estrategia Multi-Tenancy | Aceptada | 2025-08 | Modelo híbrido por criticidad |
| [ADR-026](adr-026-estandares-diseno-apis.md) | Estándares de Diseño APIs | Aceptada | 2025-08 | REST + OpenAPI 3.0 estándar |

### ADRs ESPECÍFICOS DE SERVICIO
*Decisiones que aplican a servicios individuales*

| ADR | Título | Servicio | Estado | Fecha | Descripción |
|-----|--------|----------|--------|-------|-------------|
| [ADR-004](adr-004-api-gateway-yarp.md) | Selección YARP | API Gateway | Aceptada | 2024-03 | YARP como reverse proxy |
| [ADR-005](adr-005-dlq.md) | Dead Letter Queue | Notificaciones | Aceptada | 2024-03 | Manejo de mensajes fallidos |
| [ADR-006](adr-006-modularidad.md) | Modularidad de Servicios | General | Aceptada | 2024-03 | Estructura modular |
| [ADR-007](adr-007-configuracion-scripts.md) | Scripts de Configuración | General | Aceptada | 2024-03 | Automatización de configuración |

### ✅ ADRs CONSOLIDADOS/ELIMINADOS
*ADRs que han sido consolidados o eliminados del repositorio*

| ADR | Título | Estado | Acción Completada |
|-----|--------|--------|------------------|
| ADR-002 (original) | SNS + SQS | ❌ Eliminada | Supersedida por ADR-002 nueva (Kafka) |
| ADR-011 | Monitoreo y Observabilidad | ❌ Eliminada | Consolidado en estrategia global de observabilidad |
| ADR-012 | Tracing Distribuido | ❌ Eliminada | Consolidado en estrategia global de observabilidad |
| ADR-016 | Observabilidad Stack | ❌ Eliminada | Consolidado en estrategia global de observabilidad |
| ADR-019 | Configuración y Secrets | ❌ Eliminada | Consolidado con ADR-001 y ADR-022 |
| ADR-021 | Secrets Agnóstico | ❌ Eliminada | Consolidado con ADR-001 |

## Principios de Decisión

### Criterios de Evaluación Estándar
1. **Agnosticidad/Portabilidad** (25%) - Capacidad de migrar entre proveedores
2. **Escalabilidad** (20%) - Capacidad de crecimiento
3. **Facilidad Operacional** (15%) - Simplicidad de operación
4. **Rendimiento** (15%) - Características de performance
5. **Integración** (10%) - Facilidad de integración con stack .NET
6. **Costos** (10%) - TCO y consideraciones económicas
7. **Comunidad/Soporte** (5%) - Madurez y soporte disponible

### Enfoque Estratégico
- **Agnosticidad primera**: Preferir soluciones portables sobre servicios gestionados
- **Open source cuando sea posible**: Evitar lock-in comercial
- **Estándares de la industria**: Adoptar patrones y protocolos reconocidos
- **Multi-tenancy nativo**: Soporte para operaciones en múltiples países
- **Observabilidad integrada**: Monitoreo, logging y tracing por defecto

## Métricas de ADRs

- **Total ADRs activos**: 17 globales + 4 específicos = 21
- **ADRs por consolidar**: 4
- **Cobertura de decisiones críticas**: 95%
- **Última actualización**: Agosto 2025
