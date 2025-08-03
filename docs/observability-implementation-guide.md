# 🔍 Guía de Implementación de Observabilidad

## Stack de Tecnologías Seleccionado

### Métricas y Monitoring
- **Prometheus**: Recolección y almacenamiento de métricas
- **Grafana**: Dashboards y visualización
- **AlertManager**: Gestión de alertas

### Logging
- **Serilog**: Structured logging en .NET
- **Loki**: Agregación centralizada de logs
- **Promtail**: Agente de recolección

### Health Checks
- **ASP.NET Core Health Checks**: Endpoints estándar
- **Prometheus Health Check Publisher**: Exporta health como métricas

## Componentes Agregados por Servicio

### ✅ Notification System
- Health Check endpoints (/health, /health/ready, /health/live)
- Metrics Collector (prometheus-net)
- Structured Logger (Serilog)
- Métricas específicas: notifications/sec, processing time, channel success rate

### ✅ Track & Trace
- Health Check endpoints en Ingest API y Query API
- Metrics Collector en Event Processor
- Structured Logger con correlationId
- Métricas específicas: events/sec, query response time, enrichment duration

### ✅ SITA Messaging
- Health Check endpoints en API y Event Processor
- Metrics Collector para generación SITA
- Structured Logger para auditoría
- Métricas específicas: SITA messages/sec, generation time, transmission rate

### ✅ Identity System (Keycloak)
- Health Check de Keycloak
- Metrics Collector para autenticación
- Structured Logger para eventos de seguridad
- Métricas específicas: logins/sec, token validation rate, failed auth

### ✅ API Gateway (YARP)
- Health Check Aggregator (ya implementado)
- Circuit Breaker, Retry, Timeout (ya implementado)
- Metrics para gateway performance
- Métricas específicas: requests/sec, downstream health, rate limit hits

## Próximos Pasos Sugeridos

### 1. Implementar Health Checks (Semana 1)
```csharp
// En cada API .NET
services.AddHealthChecks()
    .AddDbContext<ApplicationDbContext>()
    .AddSqlServer(connectionString)
    .AddRedis(redisConnection)
    .AddAWSServiceCheck<IAmazonSQS>("SQS");
```

### 2. Agregar Prometheus Metrics (Semana 2)
```csharp
// En cada servicio
services.AddSingleton<IMetricsServer>(new MetricServer(port: 9090));
// Custom metrics per service
Counter.WithLabels("service", "notification").Inc();
```

### 3. Configurar Structured Logging (Semana 3)
```csharp
// Serilog configuration
Log.Logger = new LoggerConfiguration()
    .WriteTo.Console()
    .WriteTo.File("logs/app-.log", rollingInterval: RollingInterval.Day)
    .CreateLogger();
```

### 4. Setup Grafana Dashboards (Semana 4)
- Dashboard general de salud de servicios
- Dashboards específicos por microservicio
- Dashboard de métricas de negocio

## Métricas Clave a Monitorear

### Golden Signals
- **Latency**: Tiempo de respuesta P50, P95, P99
- **Traffic**: Requests per second por servicio
- **Errors**: Error rate y tipos de errores
- **Saturation**: CPU, memoria, conexiones DB, queue depth

### Métricas de Negocio
- **Notification Delivery Rate**: % entrega exitosa por canal
- **Track & Trace Processing Time**: Tiempo promedio de procesamiento
- **SITA Generation Success**: % generación exitosa de archivos
- **Authentication Success Rate**: % autenticaciones exitosas

## Alertas Críticas Recomendadas

### Nivel Crítico (P0)
- Servicio down > 2 minutos
- Error rate > 10% > 5 minutos
- Database connections < 10% disponible
- Queue depth > 10,000 mensajes

### Nivel Alto (P1)
- Latency P95 > 2 segundos > 10 minutos
- Error rate > 5% > 10 minutos
- Disk usage > 85%
- Memory usage > 90%

### Nivel Medio (P2)
- Latency P95 > 1 segundo > 15 minutos
- Error rate > 2% > 15 minutos
- CPU usage > 80% > 20 minutos

¿Te parece bien este plan? ¿Quieres que profundicemos en algún aspecto específico o prefieres que empecemos a implementar alguna parte?
