# 9. Decisiones de arquitectura

## 9.1 ADR-001: Selección de YARP como proxy reverso

**Estado**: Aceptado
**Fecha**: 2024-01-15
**Decisores**: Equipo de Arquitectura, Equipo DevOps

### Contexto y problema

Necesitamos un proxy reverso de alto rendimiento para el API Gateway que pueda:
- Manejar routing dinámico a múltiples servicios
- Soportar configuración en tiempo real
- Integrarse nativamente con .NET 8
- Proporcionar capacidades de balanceo de carga
- Ser extensible para funcionalidades personalizadas

### Alternativas consideradas

1. **NGINX**
   - ✅ Muy maduro y ampliamente usado
   - ✅ Excelente rendimiento
   - ❌ Configuración estática mediante archivos
   - ❌ Requiere recargas para cambios de configuración
   - ❌ No integrado con .NET ecosystem

2. **Envoy Proxy**
   - ✅ Arquitectura cloud-native
   - ✅ Configuración dinámica via xDS APIs
   - ✅ Excelentes capacidades de observabilidad
   - ❌ Curva de aprendizaje empinada
   - ❌ Overhead adicional para servicios simples

3. **YARP (Yet Another Reverse Proxy)**
   - ✅ Integración nativa con .NET
   - ✅ Configuración dinámica
   - ✅ Extensibilidad mediante middleware
   - ✅ Soporte oficial de Microsoft
   - ❌ Relativamente nuevo (menor ecosistema)

### Decisión

Seleccionamos **YARP** como solución de proxy reverso por las siguientes razones:

```csharp
// Ejemplo de configuración dinámica con YARP
public class DynamicRouteConfigProvider : IProxyConfigProvider
{
    public IProxyConfig GetConfig() => _config;

    public void UpdateRoutes(IEnumerable<RouteConfig> routes)
    {
        var newConfig = new MemoryConfigProvider(routes, clusters);
        Interlocked.Exchange(ref _config, newConfig.GetConfig());

        // Notificar cambios
        _changeToken.OnReload();
    }
}
```

### Consecuencias

**Positivas**:
- Desarrollo e integración más rápidos
- Configuración dinámica sin downtime
- Mejor debugging y resolución de problemas
- Reutilización de middleware existente de ASP.NET Core

**Negativas**:
- Menor madurez comparado con NGINX
- Dependencia del ecosistema Microsoft
- Potencial overhead por estar basado en .NET

## 9.2 ADR-002: Implementación de limitación de velocidad distribuido

**Estado**: Aceptado
**Fecha**: 2024-01-20
**Decisores**: Equipo de Arquitectura

### Contexto y problema

El API Gateway debe proteger los servicios backend contra abuso y garantizar QoS mediante limitación de velocidad. En un entorno distribuido con múltiples instancias del gateway, necesitamos:
- Rate limiting consistente entre instancias
- Baja latencia en la verificación de límites
- Capacidad de configuración por cliente/tenant
- Resistencia a fallos del sistema de limitación de velocidad

### Alternativas consideradas

1. **Rate limiting local (in-memory)**
   - ✅ Latencia mínima
   - ❌ Inconsistente entre instancias
   - ❌ Escalabilidad limitada

2. **Rate limiting centralizado con base de datos**
   - ✅ Consistencia perfecta
   - ❌ Latencia alta
   - ❌ Punto único de falla

3. **Rate limiting distribuido con Redis**
   - ✅ Buena consistencia
   - ✅ Latencia aceptable
   - ✅ Capacidades de clustering
   - ❌ Dependencia externa adicional

### Decisión

Implementamos **limitación de velocidad distribuido con Redis** usando algoritmo sliding window con fallback local:

```csharp
public class DistributedRateLimiter : IRateLimiter
{
    private readonly IConnectionMultiplexer _redis;
    private readonly IMemoryCache _localCache;

    public async Task<RateLimitResult> CheckAsync(string key, int limit, TimeSpan window)
    {
        try
        {
            // Intentar Redis primero
            return await CheckRedisAsync(key, limit, window);
        }
        catch (RedisException)
        {
            // Fallback a cache local
            return CheckLocal(key, limit, window);
        }
    }

    private async Task<RateLimitResult> CheckRedisAsync(string key, int limit, TimeSpan window)
    {
        var script = @"
            local key = KEYS[1]
            local window = tonumber(ARGV[1])
            local limit = tonumber(ARGV[2])
            local now = tonumber(ARGV[3])

            redis.call('zremrangebyscore', key, '-inf', now - window)
            local current = redis.call('zcard', key)

            if current < limit then
                redis.call('zadd', key, now, now)
                redis.call('expire', key, window)
                return {1, limit - current - 1}
            else
                return {0, 0}
            end
        ";

        var database = _redis.GetDatabase();
        var result = await database.ScriptEvaluateAsync(script,
            new RedisKey[] { key },
            new RedisValue[] { window.TotalSeconds, limit, DateTimeOffset.UtcNow.ToUnixTimeSeconds() });

        var values = (RedisValue[])result;
        return new RateLimitResult
        {
            IsAllowed = values[0] == 1,
            Remaining = values[1]
        };
    }
}
```

### Consecuencias

**Positivas**:
- Consistencia entre instancias del gateway
- Degradación graceful ante fallos de Redis
- Configuración flexible por cliente
- Implementación sliding window más precisa

**Negativas**:
- Latencia adicional por llamadas a Redis
- Complejidad operacional adicional
- Posible inconsistencia durante fallos

## 9.3 ADR-003: Estrategia de circuit breaker por servicio

**Estado**: Aceptado
**Fecha**: 2024-01-25
**Decisores**: Equipo de Arquitectura, SRE Team

### Contexto y problema

El API Gateway debe protegerse contra fallos en cascada cuando los servicios backend experimentan problemas. Necesitamos:
- Detección rápida de servicios no saludables
- Prevención de sobrecarga en servicios degradados
- Recuperación automática cuando los servicios se estabilizan
- Métricas detalladas para observabilidad

### Decisión

Implementamos circuit breakers independientes por servicio backend con configuración adaptativa:

```csharp
public class AdaptiveCircuitBreaker : ICircuitBreaker
{
    private readonly CircuitBreakerConfig _config;
    private readonly IMetrics _metrics;
    private CircuitState _state = CircuitState.Closed;
    private int _failureCount;
    private DateTime _lastFailureTime;
    private DateTime _nextAttemptTime;

    public async Task<T> ExecuteAsync<T>(Func<Task<T>> operation, string operationName)
    {
        if (_state == CircuitState.Open)
        {
            if (DateTime.UtcNow < _nextAttemptTime)
            {
                _metrics.Counter("circuit_breaker_blocked_total")
                    .WithTag("service", _config.ServiceName)
                    .WithTag("operation", operationName)
                    .Increment();

                throw new CircuitBreakerOpenException();
            }

            _state = CircuitState.HalfOpen;
        }

        var stopwatch = Stopwatch.StartNew();
        try
        {
            var result = await operation();
            OnSuccess(stopwatch.Elapsed);
            return result;
        }
        catch (Exception ex)
        {
            OnFailure(ex, stopwatch.Elapsed);
            throw;
        }
    }

    private void OnSuccess(TimeSpan duration)
    {
        if (_state == CircuitState.HalfOpen)
        {
            _state = CircuitState.Closed;
            _failureCount = 0;

            _metrics.Counter("circuit_breaker_state_change_total")
                .WithTag("service", _config.ServiceName)
                .WithTag("from", "half_open")
                .WithTag("to", "closed")
                .Increment();
        }

        _metrics.Histogram("circuit_breaker_operation_duration_seconds")
            .WithTag("service", _config.ServiceName)
            .WithTag("result", "success")
            .Record(duration.TotalSeconds);
    }

    private void OnFailure(Exception ex, TimeSpan duration)
    {
        _failureCount++;
        _lastFailureTime = DateTime.UtcNow;

        // Configuración adaptativa basada en tipo de error
        var threshold = GetAdaptiveThreshold(ex);

        if (_failureCount >= threshold)
        {
            _state = CircuitState.Open;
            _nextAttemptTime = DateTime.UtcNow.Add(GetBackoffDuration());

            _metrics.Counter("circuit_breaker_state_change_total")
                .WithTag("service", _config.ServiceName)
                .WithTag("from", _state == CircuitState.HalfOpen ? "half_open" : "closed")
                .WithTag("to", "open")
                .Increment();
        }

        _metrics.Histogram("circuit_breaker_operation_duration_seconds")
            .WithTag("service", _config.ServiceName)
            .WithTag("result", "failure")
            .WithTag("exception_type", ex.GetType().Name)
            .Record(duration.TotalSeconds);
    }

    private int GetAdaptiveThreshold(Exception ex)
    {
        return ex switch
        {
            TimeoutException => _config.TimeoutFailureThreshold,
            HttpRequestException httpEx when IsServerError(httpEx) => _config.ServerErrorThreshold,
            _ => _config.DefaultFailureThreshold
        };
    }
}
```

### Consecuencias

**Positivas**:
- Prevención efectiva de fallos en cascada
- Recuperación automática de servicios
- Métricas detalladas para resolución de problemas
- Configuración adaptativa por tipo de error

**Negativas**:
- Complejidad adicional en debugging
- Posibles falsos positivos durante picos de tráfico
- Configuración requiere tuning inicial

## 9.4 ADR-004: Autenticación descentralizada con validación local

**Estado**: Aceptado
**Fecha**: 2024-02-01
**Decisores**: Equipo de Seguridad, Arquitectura

### Contexto y problema

El API Gateway debe validar JWT tokens en cada request. Con alta concurrencia, esto puede generar:
- Latencia alta por validación remota constante
- Sobrecarga en el servicio de identidad
- Punto único de falla crítico

### Alternativas consideradas

1. **Validación remota siempre**
   - ✅ Revocación inmediata
   - ❌ Latencia alta
   - ❌ Dependencia crítica

2. **Validación local con cache**
   - ✅ Latencia baja
   - ❌ Revocación diferida
   - ✅ Resistencia a fallos

### Decisión

Implementamos validación local con cache inteligente y revocación diferida:

```csharp
public class HybridTokenValidator : ITokenValidator
{
    private readonly IJwtSecurityTokenHandler _tokenHandler;
    private readonly ITokenCache _cache;
    private readonly IIdentityServiceClient _identityService;

    public async Task<ClaimsPrincipal> ValidateAsync(string token)
    {
        // 1. Validación criptográfica local
        var validationResult = await ValidateTokenStructureAsync(token);
        if (!validationResult.IsValid)
            throw new SecurityTokenValidationException();

        var jwtToken = validationResult.SecurityToken as JwtSecurityToken;
        var tokenId = jwtToken.Claims.FirstOrDefault(c => c.Type == "jti")?.Value;

        // 2. Verificar cache de revocación
        if (await _cache.IsRevokedAsync(tokenId))
            throw new SecurityTokenValidationException("Token revoked");

        // 3. Validación periódica con servicio de identidad
        if (ShouldVerifyWithIdentityService(jwtToken))
        {
            try
            {
                var isValid = await _identityService.ValidateTokenAsync(tokenId);
                if (!isValid)
                {
                    await _cache.MarkAsRevokedAsync(tokenId);
                    throw new SecurityTokenValidationException("Token validation failed");
                }

                await _cache.MarkAsVerifiedAsync(tokenId);
            }
            catch (Exception ex)
            {
                // Log pero no fallar - degradación graceful
                _logger.LogWarning(ex, "Failed to verify token with identity service");
            }
        }

        return new ClaimsPrincipal(new ClaimsIdentity(jwtToken.Claims, "jwt"));
    }

    private bool ShouldVerifyWithIdentityService(JwtSecurityToken token)
    {
        // Verificar cada 5 minutos o si el token es nuevo
        var lastVerified = _cache.GetLastVerificationTime(token.Claims.First(c => c.Type == "jti").Value);
        return lastVerified == null || DateTime.UtcNow - lastVerified > TimeSpan.FromMinutes(5);
    }
}
```

### Consecuencias

**Positivas**:
- Latencia de validación muy baja
- Resistencia a fallos del servicio de identidad
- Balance entre seguridad y rendimiento

**Negativas**:
- Ventana de tiempo para tokens revocados
- Complejidad adicional en gestión de cache
- Posible inconsistencia temporal

## 9.5 ADR-005: Verificaciones de salud multinivel

**Estado**: Aceptado
**Fecha**: 2024-02-05
**Decisores**: SRE Team, DevOps

### Contexión y problema

Necesitamos verificaciones de salud que proporcionen información granular sobre el estado del API Gateway y sus dependencias para:
- Load balancer routing decisions
- Alertas automáticas específicas
- Debugging de problemas de conectividad

### Decisión

Implementamos verificaciones de salud multinivel con endpoints especializados:

```csharp
public class CompositeHealthCheck : IHealthCheck
{
    private readonly IEnumerable<IHealthCheck> _healthChecks;
    private readonly ILogger<CompositeHealthCheck> _logger;

    public async Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context,
        CancellationToken cancellationToken = default)
    {
        var results = new Dictionary<string, HealthCheckResult>();
        var overallStatus = HealthStatus.Healthy;

        var tasks = _healthChecks.Select(async hc =>
        {
            try
            {
                var result = await hc.CheckHealthAsync(context, cancellationToken);
                return (hc.GetType().Name, result);
            }
            catch (Exception ex)
            {
                return (hc.GetType().Name, HealthCheckResult.Unhealthy(ex.Message, ex));
            }
        });

        var completedResults = await Task.WhenAll(tasks);

        foreach (var (name, result) in completedResults)
        {
            results[name] = result;

            if (result.Status == HealthStatus.Unhealthy)
                overallStatus = HealthStatus.Unhealthy;
            else if (result.Status == HealthStatus.Degraded && overallStatus == HealthStatus.Healthy)
                overallStatus = HealthStatus.Degraded;
        }

        return new HealthCheckResult(overallStatus, data: results);
    }
}

// Startup configuration
public void ConfigureServices(IServiceCollection services)
{
    services.AddHealthChecks()
        // Básico - usado por load balancer
        .AddCheck("self", () => HealthCheckResult.Healthy())

        // Dependencias críticas
        .AddCheck<RedisHealthCheck>("redis", tags: new[] { "critical" })
        .AddCheck<IdentityServiceHealthCheck>("identity", tags: new[] { "critical" })

        // Servicios backend
        .AddCheck<NotificationServiceHealthCheck>("notification", tags: new[] { "backend" })
        .AddCheck<TrackTraceServiceHealthCheck>("track-trace", tags: new[] { "backend" })

        // Recursos locales
        .AddCheck<MemoryHealthCheck>("memory", tags: new[] { "resource" })
        .AddCheck<DiskSpaceHealthCheck>("disk", tags: new[] { "resource" });
}

public void Configure(IApplicationBuilder app)
{
    app.UseHealthChecks("/health/live", new HealthCheckOptions
    {
        Predicate = _ => false // Solo self-check
    });

    app.UseHealthChecks("/health/ready", new HealthCheckOptions
    {
        Predicate = hc => hc.Tags.Contains("critical")
    });

    app.UseHealthChecks("/health/detailed", new HealthCheckOptions
    {
        ResponseWriter = WriteDetailedResponse
    });
}
```

### Consecuencias

**Positivas**:
- Información granular del estado del sistema
- Endpoints especializados para diferentes propósitos
- Mejor integration con herramientas de monitoreo

**Negativas**:
- Mayor complejidad en configuración
- Más endpoints que mantener
- Posible overhead en health checks frecuentes
