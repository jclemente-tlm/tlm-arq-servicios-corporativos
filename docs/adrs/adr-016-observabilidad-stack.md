# ADR-016: Implementación de Stack de Observabilidad para Microservicios Corporativos

## ✅ ESTADO

Propuesta – Agosto 2025

---

## 🗺️ CONTEXTO

Con la arquitectura distribuida de 5 microservicios corporativos (API Gateway, Identity, Notification, Track & Trace, SITA Messaging), se necesita implementar un stack completo de observabilidad para:

- **Monitoring**: Visibilidad del rendimiento y disponibilidad de servicios
- **Alerting**: Notificación proactiva de problemas y degradación
- **Troubleshooting**: Capacidad de diagnosticar problemas rápidamente
- **Capacity Planning**: Datos para decisiones de escalamiento

### Problemas Actuales

- **Falta de visibilidad**: No hay métricas centralizadas de rendimiento
- **Debugging difícil**: Sin logs correlacionados entre servicios
- **Alertas reactivas**: Solo se detectan problemas cuando usuarios reportan
- **SLA sin medición**: No hay datos objetivos de disponibilidad

---

## ✔️ DECISIÓN

Se implementará un stack de observabilidad con las siguientes tecnologías:

### 1. Stack de Métricas
- **Prometheus**: Recolección y almacenamiento de métricas
- **Grafana**: Visualización y dashboards
- **AlertManager**: Gestión de alertas

### 2. Stack de Logging
- **Loki**: Agregación centralizada de logs
- **Promtail**: Agente de recolección de logs
- **Serilog**: Structured logging en aplicaciones .NET

### 3. Health Checks
- **ASP.NET Core Health Checks**: En todos los servicios
- **Prometheus scraping**: Monitoreo automático de salud

### 4. Tracing Distribuido (Fase 2)
- **Jaeger**: Tracing de requests entre servicios
- **OpenTelemetry**: Instrumentación estándar

---

## 🏗️ IMPLEMENTACIÓN

### Fase 1: Métricas y Health Checks (2-3 semanas)

#### Métricas por Servicio
```csharp
// Métricas básicas para todos los servicios
- http_requests_total (counter)
- http_request_duration_seconds (histogram)
- database_connections_active (gauge)
- queue_messages_processed_total (counter)
- error_rate_percentage (gauge)
```

#### Health Checks
```csharp
// Endpoints estándar
- /health (liveness probe)
- /health/ready (readiness probe)
- /health/live (startup probe)
- /metrics (prometheus metrics)
```

#### Métricas Específicas por Servicio

**Notification System:**
- `notification_requests_total`
- `notification_processing_duration_seconds`
- `notification_channel_success_rate`
- `notification_queue_depth`

**Track & Trace:**
- `events_ingested_total`
- `events_processed_total`
- `query_response_time_seconds`
- `event_enrichment_duration_seconds`

**SITA Messaging:**
- `sita_messages_generated_total`
- `sita_file_generation_duration_seconds`
- `sita_transmission_success_rate`

**API Gateway:**
- `gateway_requests_total`
- `gateway_circuit_breaker_state`
- `gateway_rate_limit_hits`
- `downstream_service_health`

### Fase 2: Logging Centralizado (1-2 semanas)

#### Structured Logging
```csharp
// Formato estándar con Serilog
{
  "timestamp": "2025-08-02T10:30:00Z",
  "level": "Information",
  "messageTemplate": "Processing notification {NotificationId} for tenant {TenantId}",
  "properties": {
    "NotificationId": "notif-123",
    "TenantId": "tenant-peru",
    "CorrelationId": "req-456",
    "UserId": "user-789",
    "Service": "notification-api"
  }
}
```

#### Log Aggregation
- **Promtail** en cada contenedor/VM
- **Loki** como agregador central
- **Grafana** para consultas LogQL

### Fase 3: Dashboards y Alertas (1-2 semanas)

#### Dashboards Grafana
1. **Overview Dashboard**: Salud general de todos los servicios
2. **Service-specific Dashboards**: Métricas detalladas por servicio
3. **Infrastructure Dashboard**: Recursos (CPU, memoria, disco, red)
4. **Business Metrics Dashboard**: KPIs específicos del negocio

#### Alertas Críticas
```yaml
# Ejemplos de alertas
- Service Down (health check failed > 2 min)
- High Error Rate (>5% errors > 5 min)
- High Latency (P95 > 2s > 10 min)
- Queue Depth High (>1000 messages > 15 min)
- Database Connections Low (<10% available)
```

---

## 📊 MÉTRICAS OBJETIVO

### SLIs (Service Level Indicators)
- **Availability**: 99.9% uptime por servicio
- **Latency**: P95 < 500ms para APIs críticas
- **Error Rate**: < 1% error rate en condiciones normales
- **Throughput**: Capacidad de procesar cargas pico

### KPIs de Negocio
- **Notification Delivery Rate**: >95% entrega exitosa
- **Track & Trace Processing Time**: <30 segundos promedio
- **SITA Message Generation**: <2 minutos tiempo promedio
- **API Gateway Response Time**: P99 < 1 segundo

---

## 🚀 BENEFICIOS ESPERADOS

### Técnicos
✅ **Detección proactiva** de problemas antes que afecten usuarios
✅ **MTTR reducido** de 60 minutos a <15 minutos
✅ **Troubleshooting eficiente** con logs correlacionados
✅ **Capacity planning** basado en datos reales

### Operacionales
✅ **SLA medible** con datos objetivos
✅ **Alertas inteligentes** que reducen noise
✅ **Dashboards ejecutivos** para visibilidad del negocio
✅ **Compliance** con requerimientos de auditoría

---

## 💰 COSTOS ESTIMADOS

### Infraestructura (mensual)
- **Prometheus/Grafana**: $200-400 (dependiendo de retención)
- **Loki storage**: $100-300 (logs por 30 días)
- **Compute**: $150-250 (instancias adicionales)
- **Total**: ~$450-950/mes

### Desarrollo
- **Instrumentación**: 2-3 semanas desarrollo
- **Dashboards**: 1 semana configuración
- **Alertas**: 1 semana setup y tuning

---

## ⚠️ RIESGOS Y MITIGACIONES

| Riesgo | Impacto | Mitigación |
|--------|---------|------------|
| Overhead de métricas | Performance degradation | Sampling, async collection |
| Alert fatigue | Equipos ignoran alertas | Tuning cuidadoso de thresholds |
| Storage costs | Budget overrun | Retention policies, compression |
| Learning curve | Slow adoption | Training, documentation |

---

## 📋 PLAN DE ROLLOUT

### Semana 1-2: Health Checks
- Implementar health checks en todos los servicios
- Setup básico de Prometheus
- Dashboards simples de disponibilidad

### Semana 3-4: Métricas
- Instrumentación completa con prometheus-net
- Dashboards detallados por servicio
- Alertas básicas (uptime, error rate)

### Semana 5-6: Logging
- Setup de Loki y Promtail
- Structured logging con Serilog
- Correlación de logs con métricas

### Semana 7-8: Refinamiento
- Tuning de alertas
- Optimización de dashboards
- Training al equipo

---

## 🔗 REFERENCIAS

- [Prometheus Best Practices](https://prometheus.io/docs/practices/)
- [Grafana Dashboard Design](https://grafana.com/docs/grafana/latest/best-practices/)
- [The Four Golden Signals](https://sre.google/sre-book/monitoring-distributed-systems/)
- [.NET Observability Guide](https://docs.microsoft.com/en-us/dotnet/core/diagnostics/)
