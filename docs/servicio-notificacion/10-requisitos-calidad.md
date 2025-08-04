# 10. Requisitos de calidad

## 10.1 Árbol de calidad

### 10.1.1 Disponibilidad
- **Definición**: Capacidad del sistema para estar operativo cuando se requiera
- **Objetivo**: 99.9% uptime (menos de 8.76 horas de inactividad por año)
- **Métricas**:
  - MTTR (Mean Time To Recovery): < 15 minutos
  - MTBF (Mean Time Between Failures): > 30 días
  - RTO (Recovery Time Objective): < 5 minutos
  - RPO (Recovery Point Objective): < 1 minuto

### 10.1.2 Performance
- **Latencia de API**: < 200ms (p95) para operaciones síncronas
- **Throughput**: 10,000 notificaciones/minuto por instancia
- **Procesamiento de colas**: < 30 segundos para emails, < 10 segundos para SMS/Push
- **Escalabilidad horizontal**: Auto-scaling basado en métricas de cola

### 10.1.3 Seguridad
- **Autenticación**: OAuth2 con JWT (client_credentials)
- **Autorización**: RBAC basado en tenant y permisos granulares
- **Cifrado**: TLS 1.3 en tránsito, AES-256 en reposo
- **Compliance**:
  - GDPR para datos personales
  - CAN-SPAM Act para emails
  - TCPA para SMS

### 10.1.4 Fiabilidad
- **Entrega garantizada**: At-least-once delivery con idempotencia
- **Retry policy**: Backoff exponencial con jitter
- **Dead letter queue**: Para mensajes fallidos después de 3 reintentos
- **Audit trail**: 100% de trazabilidad de eventos

### 10.1.5 Mantenibilidad
- **Code coverage**: > 80% en tests unitarios
- **Modularidad**: Clean Architecture con abstracciones por canal
- **Logging**: Structured logging con correlación de requests
- **Monitoring**: Métricas de negocio y técnicas con alertas

### 10.1.6 Usabilidad
- **API First**: RESTful API con OpenAPI 3.0
- **Documentación**: Swagger UI actualizada automáticamente
- **Templates**: Editor visual para plantillas de notificación
- **Multi-idioma**: Soporte i18n para contenido de notificaciones

## 10.2 Escenarios de calidad

### 10.2.1 Escenario de Disponibilidad
**Fuente**: Sistema de monitoreo
**Estímulo**: Falla de una instancia del API
**Artefacto**: Servicio de notificaciones
**Entorno**: Operación normal
**Respuesta**: Failover automático a otra instancia
**Medida**: Tiempo de recuperación < 30 segundos

### 10.2.2 Escenario de Performance
**Fuente**: Aplicación cliente
**Estímulo**: Pico de 50,000 notificaciones en 5 minutos
**Artefacto**: Sistema completo
**Entorno**: Carga alta
**Respuesta**: Auto-scaling de instancias
**Medida**: Todas las notificaciones procesadas en < 10 minutos

### 10.2.3 Escenario de Seguridad
**Fuente**: Atacante externo
**Estímulo**: Intento de acceso no autorizado
**Artefacto**: API endpoints
**Entorno**: Operación normal
**Respuesta**: Bloqueo de acceso y alertas
**Medida**: 0% de accesos no autorizados exitosos

### 10.2.4 Escenario de Multi-tenancy
**Fuente**: Tenant A
**Estímulo**: Consulta de datos de notificaciones
**Artefacto**: Base de datos
**Entorno**: Multi-tenant
**Respuesta**: Acceso solo a datos propios
**Medida**: 100% de aislamiento de datos

## 10.3 Matriz de calidad

| Atributo | Criticidad | Escenario Principal | Métrica Objetivo |
|----------|------------|-------------------|-----------------|
| Disponibilidad | Alta | Failover automático | 99.9% uptime |
| Performance | Alta | Procesamiento de picos | < 200ms API, 10K/min throughput |
| Seguridad | Crítica | Protección datos PII | 0 brechas, Compliance GDPR |
| Fiabilidad | Alta | Entrega garantizada | 99.99% delivery rate |
| Mantenibilidad | Media | Despliegues sin downtime | < 5 min deployment |
| Escalabilidad | Alta | Auto-scaling | Linear scaling hasta 100K/min |
