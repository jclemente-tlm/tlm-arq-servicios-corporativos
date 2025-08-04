# 5. Vista de bloques de construcción

## 5.1 Visión general del sistema

El API Gateway actúa como punto de entrada unificado para todos los servicios corporativos, implementando un patrón de fachada que oculta la complejidad de la arquitectura de microservicios a los clientes externos.

```
┌─────────────────────────────────────────────────────────────┐
│                    API Gateway (YARP)                       │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────────┐ │
│  │   Routing   │ │    Auth     │ │     Load Balancing      │ │
│  │   Engine    │ │  Middleware │ │     & Health Checks     │ │
│  └─────────────┘ └─────────────┘ └─────────────────────────┘ │
│                                                             │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────────┐ │
│  │ Rate Limit  │ │   Logging   │ │      Monitoring         │ │
│  │ & Throttle  │ │ & Tracing   │ │     & Metrics           │ │
│  └─────────────┘ └─────────────┘ └─────────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│                 Downstream Services                         │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────────┐ │
│  │   Identity  │ │Notification │ │     Track & Trace       │ │
│  │   Service   │ │   Service   │ │       Service           │ │
│  └─────────────┘ └─────────────┘ └─────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────┐ ┌─────────────────────────┐ │
│  │      SITA Messaging         │ │    External Services    │ │
│  │        Service              │ │     & Legacy Systems    │ │
│  └─────────────────────────────┘ └─────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## 5.2 Nivel 1: Contexto del API Gateway

### 5.2.1 Responsabilidades principales

| Responsabilidad | Descripción | Componente |
|-----------------|-------------|------------|
| **Request Routing** | Enrutamiento inteligente basado en URL, headers y tenant | YARP Routing Engine |
| **Authentication** | Validación de tokens JWT y gestión de autorización | Auth Middleware |
| **Load Balancing** | Distribución de carga entre instancias de servicios | YARP Load Balancer |
| **Rate Limiting** | Control de tráfico y prevención de abuse | Rate Limiting Middleware |
| **Observability** | Logging, métricas y distributed tracing | Telemetry Pipeline |

### 5.2.2 Interfaces externas

```csharp
// Interface principal del API Gateway
public interface IApiGateway
{
    Task<HttpResponseMessage> RouteAsync(HttpContext context);
    Task<bool> AuthenticateAsync(HttpContext context);
    Task<RateLimitResult> CheckRateLimitAsync(string clientId, string endpoint);
    Task<HealthCheckResult> GetHealthAsync();
}

// Interface para configuración de routing
public interface IRoutingConfiguration
{
    Task<RouteConfig[]> GetRoutesAsync();
    Task<ClusterConfig[]> GetClustersAsync();
    Task ReloadConfigurationAsync();
}
```

## 5.3 Nivel 2: Componentes principales

### 5.3.1 YARP Reverse Proxy Engine

**Responsabilidad**: Motor principal de proxy reverso que maneja el enrutamiento y load balancing.

```csharp
// Configuración de YARP
public class YarpConfiguration
{
    public RouteConfig[] Routes { get; set; }
    public ClusterConfig[] Clusters { get; set; }

    public static YarpConfiguration LoadConfiguration()
    {
        return new YarpConfiguration
        {
            Routes = new[]
            {
                new RouteConfig
                {
                    RouteId = "identity-route",
                    ClusterId = "identity-cluster",
                    Match = new RouteMatch
                    {
                        Path = "/api/identity/{**catch-all}"
                    }
                },
                new RouteConfig
                {
                    RouteId = "notification-route",
                    ClusterId = "notification-cluster",
                    Match = new RouteMatch
                    {
                        Path = "/api/notifications/{**catch-all}"
                    },
                    Transforms = new[]
                    {
                        new Dictionary<string, string>
                        {
                            ["RequestHeader"] = "X-Tenant-ID"
                        }
                    }
                }
            },
            Clusters = new[]
            {
                new ClusterConfig
                {
                    ClusterId = "identity-cluster",
                    LoadBalancingPolicy = LoadBalancingPolicies.RoundRobin,
                    HealthCheck = new HealthCheckConfig
                    {
                        Active = new ActiveHealthCheckConfig
                        {
                            Enabled = true,
                            Interval = TimeSpan.FromSeconds(30),
                            Path = "/health"
                        }
                    },
                    Destinations = new Dictionary<string, DestinationConfig>
                    {
                        ["identity-1"] = new() { Address = "https://identity-service:8080" },
                        ["identity-2"] = new() { Address = "https://identity-service-2:8080" }
                    }
                }
            }
        };
    }
}
```

**Interfaces**:
- Entrada: HTTP requests desde clientes externos
- Salida: HTTP requests hacia servicios downstream

### 5.3.2 Authentication & Authorization Middleware

**Responsabilidad**: Validación de tokens JWT, verificación de permisos y enriquecimiento de contexto.

```csharp
public class AuthenticationMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ITokenValidator _tokenValidator;
    private readonly ITenantResolver _tenantResolver;

    public async Task InvokeAsync(HttpContext context)
    {
        // 1. Extract JWT token
        var token = ExtractToken(context.Request);
        if (string.IsNullOrEmpty(token))
        {
            await HandleUnauthorized(context);
            return;
        }

        // 2. Validate token
        var validationResult = await _tokenValidator.ValidateAsync(token);
        if (!validationResult.IsValid)
        {
            await HandleUnauthorized(context);
            return;
        }

        // 3. Resolve tenant context
        var tenantId = validationResult.Claims.GetTenantId();
        var tenant = await _tenantResolver.GetTenantAsync(tenantId);

        // 4. Enrich request context
        context.Items["User"] = validationResult.User;
        context.Items["Tenant"] = tenant;
        context.Request.Headers.Add("X-Tenant-ID", tenantId);
        context.Request.Headers.Add("X-User-ID", validationResult.User.Id);

        await _next(context);
    }

    private string ExtractToken(HttpRequest request)
    {
        var authHeader = request.Headers["Authorization"].FirstOrDefault();
        return authHeader?.StartsWith("Bearer ") == true
            ? authHeader.Substring("Bearer ".Length).Trim()
            : null;
    }
}
```

### 5.3.3 Rate Limiting & Throttling

**Responsabilidad**: Control de tráfico para prevenir abuse y garantizar fair usage.

```csharp
public class RateLimitingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly IRateLimitStore _store;
    private readonly IRateLimitPolicy _policy;

    public async Task InvokeAsync(HttpContext context)
    {
        var clientId = GetClientIdentifier(context);
        var endpoint = GetEndpointKey(context);

        var result = await _policy.CheckAsync(clientId, endpoint);

        if (result.Exceeded)
        {
            await HandleRateLimitExceeded(context, result);
            return;
        }

        // Add rate limit headers
        context.Response.Headers.Add("X-RateLimit-Limit", result.Limit.ToString());
        context.Response.Headers.Add("X-RateLimit-Remaining", result.Remaining.ToString());
        context.Response.Headers.Add("X-RateLimit-Reset", result.ResetTime.ToString());

        await _next(context);
    }
}

// Rate limiting policies por tipo de cliente
public class TieredRateLimitPolicy : IRateLimitPolicy
{
    public async Task<RateLimitResult> CheckAsync(string clientId, string endpoint)
    {
        var tier = await GetClientTier(clientId);

        return tier switch
        {
            ClientTier.Premium => await CheckPremiumLimits(clientId, endpoint),
            ClientTier.Standard => await CheckStandardLimits(clientId, endpoint),
            ClientTier.Basic => await CheckBasicLimits(clientId, endpoint),
            _ => RateLimitResult.Exceeded()
        };
    }

    private async Task<RateLimitResult> CheckPremiumLimits(string clientId, string endpoint)
    {
        // Premium: 10,000 requests per minute
        return await _store.CheckLimitAsync(clientId, endpoint, 10000, TimeSpan.FromMinutes(1));
    }
}
```

### 5.3.4 Health Monitoring & Circuit Breaker

**Responsabilidad**: Monitoreo de salud de servicios downstream y circuit breaking para resilience.

```csharp
public class HealthMonitoringService : IHostedService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly ICircuitBreakerService _circuitBreaker;
    private Timer _timer;

    public async Task StartAsync(CancellationToken cancellationToken)
    {
        _timer = new Timer(PerformHealthChecks, null, TimeSpan.Zero, TimeSpan.FromSeconds(30));
    }

    private async void PerformHealthChecks(object state)
    {
        using var scope = _serviceProvider.CreateScope();
        var clusters = scope.ServiceProvider.GetRequiredService<IClusterManager>().GetClusters();

        foreach (var cluster in clusters)
        {
            foreach (var destination in cluster.Destinations)
            {
                var healthResult = await CheckDestinationHealth(destination);

                if (!healthResult.IsHealthy)
                {
                    await _circuitBreaker.OpenCircuitAsync(destination.Id);
                    // Remove from load balancer rotation
                    await RemoveFromRotation(destination);
                }
                else
                {
                    await _circuitBreaker.CloseCircuitAsync(destination.Id);
                    await AddToRotation(destination);
                }
            }
        }
    }

    private async Task<HealthResult> CheckDestinationHealth(DestinationConfig destination)
    {
        try
        {
            using var client = new HttpClient();
            client.Timeout = TimeSpan.FromSeconds(5);

            var response = await client.GetAsync($"{destination.Address}/health");

            return new HealthResult
            {
                IsHealthy = response.IsSuccessStatusCode,
                ResponseTime = response.Headers.Date.HasValue
                    ? DateTime.UtcNow - response.Headers.Date.Value
                    : TimeSpan.Zero
            };
        }
        catch (Exception ex)
        {
            return new HealthResult { IsHealthy = false, Error = ex.Message };
        }
    }
}
```

### 5.3.5 Observability Pipeline

**Responsabilidad**: Logging estructurado, métricas y distributed tracing para monitoreo y troubleshooting.

```csharp
public class ObservabilityMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ObservabilityMiddleware> _logger;
    private readonly IMetrics _metrics;
    private readonly ActivitySource _activitySource;

    public async Task InvokeAsync(HttpContext context)
    {
        using var activity = _activitySource.StartActivity("gateway.request");
        var stopwatch = Stopwatch.StartNew();

        try
        {
            // Enrich activity with context
            activity?.SetTag("http.method", context.Request.Method);
            activity?.SetTag("http.url", context.Request.GetDisplayUrl());
            activity?.SetTag("tenant.id", context.Items["Tenant"]?.ToString());

            await _next(context);

            // Log successful request
            _logger.LogInformation("Request completed: {Method} {Path} -> {StatusCode} in {Duration}ms",
                context.Request.Method,
                context.Request.Path,
                context.Response.StatusCode,
                stopwatch.ElapsedMilliseconds);

            // Record metrics
            _metrics.Increment("gateway.requests.total",
                new KeyValuePair<string, object>("method", context.Request.Method),
                new KeyValuePair<string, object>("status", context.Response.StatusCode));

            _metrics.Record("gateway.request.duration", stopwatch.ElapsedMilliseconds,
                new KeyValuePair<string, object>("endpoint", GetEndpointName(context)));
        }
        catch (Exception ex)
        {
            activity?.SetStatus(ActivityStatusCode.Error, ex.Message);

            _logger.LogError(ex, "Request failed: {Method} {Path}",
                context.Request.Method, context.Request.Path);

            _metrics.Increment("gateway.requests.errors",
                new KeyValuePair<string, object>("error.type", ex.GetType().Name));

            throw;
        }
        finally
        {
            stopwatch.Stop();
        }
    }
}
```

## 5.4 Nivel 3: Componentes internos detallados

### 5.4.1 Multi-tenant Request Context

```csharp
public class TenantContext
{
    public string TenantId { get; init; }
    public string TenantName { get; init; }
    public TenantConfiguration Configuration { get; init; }
    public IReadOnlyDictionary<string, string> CustomHeaders { get; init; }
}

public class TenantContextEnricher
{
    public async Task<TenantContext> EnrichRequestAsync(HttpContext context, ClaimsPrincipal user)
    {
        var tenantId = user.FindFirst("tenant_id")?.Value;
        var tenant = await _tenantRepository.GetAsync(tenantId);

        return new TenantContext
        {
            TenantId = tenantId,
            TenantName = tenant.Name,
            Configuration = tenant.Configuration,
            CustomHeaders = tenant.CustomHeaders ?? new Dictionary<string, string>()
        };
    }
}
```

### 5.4.2 Configuration Management

```csharp
public class DynamicConfigurationProvider : IConfigurationProvider
{
    private readonly IConfigurationRepository _repository;
    private readonly IMemoryCache _cache;

    public async Task<T> GetConfigurationAsync<T>(string key) where T : class
    {
        var cacheKey = $"config:{key}";

        if (_cache.TryGetValue(cacheKey, out T cachedValue))
        {
            return cachedValue;
        }

        var configuration = await _repository.GetAsync<T>(key);
        _cache.Set(cacheKey, configuration, TimeSpan.FromMinutes(5));

        return configuration;
    }

    public async Task ReloadAsync()
    {
        _cache.Clear();
        // Trigger YARP configuration reload
        var routeConfig = await GetConfigurationAsync<RouteConfig[]>("routes");
        var clusterConfig = await GetConfigurationAsync<ClusterConfig[]>("clusters");

        await _proxyConfigProvider.UpdateAsync(routeConfig, clusterConfig);
    }
}
```

## 5.5 Patrón de despliegue

### 5.5.1 Arquitectura de deployment

```yaml
# API Gateway deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-gateway
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api-gateway
  template:
    metadata:
      labels:
        app: api-gateway
    spec:
      containers:
      - name: gateway
        image: api-gateway:latest
        ports:
        - containerPort: 8080
        - containerPort: 8443
        env:
        - name: ASPNETCORE_ENVIRONMENT
          value: "Production"
        - name: CONNECTIONSTRINGS__REDIS
          value: "redis:6379"
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health/live
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
```

## 5.6 Decisiones de diseño

### 5.6.1 YARP vs Ocelot vs Envoy

**Decisión**: YARP (Yet Another Reverse Proxy)

**Justificación**:
- **Native .NET**: Mejor integración con ecosystem .NET
- **Performance**: Alto rendimiento y baja latencia
- **Flexibility**: Configuración dinámica y extensibilidad
- **Microsoft Support**: Soporte oficial y roadmap claro

### 5.6.2 Estrategia de caching

- **Configuration**: Memory cache con TTL de 5 minutos
- **Rate limiting**: Redis para estado distribuido
- **Health checks**: In-memory con refresh cada 30 segundos

### 5.6.3 Security headers

```csharp
public class SecurityHeadersMiddleware
{
    public async Task InvokeAsync(HttpContext context)
    {
        context.Response.Headers.Add("X-Content-Type-Options", "nosniff");
        context.Response.Headers.Add("X-Frame-Options", "DENY");
        context.Response.Headers.Add("X-XSS-Protection", "1; mode=block");
        context.Response.Headers.Add("Referrer-Policy", "strict-origin-when-cross-origin");
        context.Response.Headers.Add("Content-Security-Policy",
            "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'");

        await _next(context);
    }
}
```
