# 8. Conceptos transversales

Esta sección describe los aspectos arquitectónicos que afectan múltiples bloques de construcción del **Sistema de Identidad**, proporcionando soluciones coherentes a preocupaciones recurrentes en todo el sistema.

*[INSERTAR AQUÍ: Diagrama C4 - Conceptos Transversales del Sistema de Identidad]*

## 8.1 Seguridad

### Modelo de Seguridad Defensa en Profundidad

El sistema implementa múltiples capas de seguridad siguiendo el principio de defensa en profundidad:

#### Capa de Red
```yaml
Seguridad de Red:
  Grupos_Seguridad_AWS:
    - Entrada: Solo puertos requeridos (80, 443, 5432, 6379)
    - Salida: Reglas restrictivas de salida
    - Origen: Grupos de seguridad específicos, no 0.0.0.0/0

  AWS_WAF:
    - Protección inyección SQL
    - Prevención cross-site scripting (XSS)
    - Limitación de velocidad por IP
    - Bloqueo geográfico si es necesario

  Configuración_VPC:
    - Subredes privadas para capa aplicación
    - Subredes base de datos aisladas
    - Gateway NAT para tráfico salida
    - Logs de flujo habilitados
```

#### Capa de Aplicación
```csharp
// Security middleware pipeline
public void Configure(IApplicationBuilder app)
{
    app.UseSecurityHeaders(); // HSTS, CSP, X-Frame-Options
    app.UseAuthentication();
    app.UseAuthorization();
    app.UseRateLimiting();
    app.UseAuditLogging();
}

// Security headers configuration
public class SecurityHeadersMiddleware
{
    public async Task InvokeAsync(HttpContext context, RequestDelegate next)
    {
        context.Response.Headers.Add("X-Content-Type-Options", "nosniff");
        context.Response.Headers.Add("X-Frame-Options", "DENY");
        context.Response.Headers.Add("X-XSS-Protection", "1; mode=block");
        context.Response.Headers.Add("Strict-Transport-Security", "max-age=31536000; includeSubDomains");
        context.Response.Headers.Add("Content-Security-Policy",
            "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'");

        await next(context);
    }
}
```

#### Gestión Avanzada de Secretos
```yaml
Estrategia_Gestión_Secretos:
  Administrador_Secretos_AWS:
    - Credenciales base datos con rotación automática
    - Claves API para servicios externos
    - Claves firma JWT con rotación 90 días
    - Secretos cliente para aplicaciones OAuth2

  Política_Rotación_Claves:
    - Claves JWT: 90 días automático
    - Contraseñas base datos: 60 días automático
    - Claves API: Manual en revisión seguridad
    - Certificados TLS: 90 días antes expiración

  Control_Acceso:
    - Roles IAM con menor privilegio
    - Políticas acceso específicas servicio
    - Rastro auditoría para todo acceso secreto
    - Procedimientos emergencia break-glass
```

#### Marco de Autenticación y Autorización
```csharp
// JWT Token validation with claims enrichment
public class JwtAuthenticationService
{
    public async Task<ClaimsPrincipal> ValidateTokenAsync(string token)
    {
        var tokenHandler = new JwtSecurityTokenHandler();
        var validationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = _configuration["Keycloak:Authority"],
            ValidAudience = _configuration["Keycloak:Audience"],
            IssuerSigningKeyResolver = ResolveSigningKey,
            ClockSkew = TimeSpan.FromMinutes(1) // Minimal clock skew
        };

        var principal = tokenHandler.ValidateToken(token, validationParameters, out var validatedToken);

        // Enrich with tenant-specific claims
        await EnrichWithTenantClaimsAsync(principal);

        return principal;
    }
}

// Attribute-based authorization
[Authorize(Policy = "RequireUserManagement")]
public class UserController : ControllerBase
{
    // Policy definition
    services.AddAuthorization(options =>
    {
        options.AddPolicy("RequireUserManagement", policy =>
            policy.RequireClaim("realm_access.roles", "user-manager")
                  .RequireClaim("tenant", context.User.GetTenantId())
                  .RequireAssertion(context =>
                      context.User.HasPermission("users:write")));
    });
}
```

## 8.2 Multi-Tenancy y Aislamiento

### Estrategia de Aislamiento Multi-Nivel

#### Realm-Level Isolation (Keycloak)
```yaml
Tenant Isolation Strategy:
  Keycloak_Realms:
    peru-realm:
      users: peru_users_only
      roles: peru_specific_roles
      clients: peru_applications
      themes: peru_branding
      configuration: peru_settings

    ecuador-realm:
      users: ecuador_users_only
      roles: ecuador_specific_roles
      clients: ecuador_applications
      themes: ecuador_branding
      configuration: ecuador_settings

  Benefits:
    - Complete data isolation
    - Independent configuration
    - Separate authentication flows
    - Isolated user management
    - Per-tenant customization
```

#### Application-Level Tenant Context
```csharp
// Tenant context middleware
public class TenantContextMiddleware
{
    public async Task InvokeAsync(HttpContext context, RequestDelegate next)
    {
        var tenantId = ResolveTenantId(context);
        var tenantContext = await _tenantService.GetTenantContextAsync(tenantId);

        if (tenantContext == null || !tenantContext.IsActive)
        {
            context.Response.StatusCode = 404;
            await context.Response.WriteAsync("Tenant not found or inactive");
            return;
        }

        context.Items["TenantContext"] = tenantContext;
        context.Items["TenantId"] = tenantId;

        await next(context);
    }

    private string ResolveTenantId(HttpContext context)
    {
        // Priority: JWT claim > Header > Subdomain > Default
        var jwtTenant = context.User?.FindFirst("tenant")?.Value;
        if (!string.IsNullOrEmpty(jwtTenant)) return jwtTenant;

        var headerTenant = context.Request.Headers["X-Tenant-ID"].FirstOrDefault();
        if (!string.IsNullOrEmpty(headerTenant)) return headerTenant;

        var host = context.Request.Host.Host;
        if (host.Contains("."))
        {
            var subdomain = host.Split('.')[0];
            if (IsValidTenant(subdomain)) return subdomain;
        }

        return "default";
    }
}

// Tenant-aware data access
public class TenantAwareRepository<T> : IRepository<T> where T : ITenantEntity
{
    private readonly ITenantContext _tenantContext;
    private readonly DbContext _dbContext;

    public IQueryable<T> GetQueryable()
    {
        return _dbContext.Set<T>()
            .Where(entity => entity.TenantId == _tenantContext.TenantId);
    }

    public async Task<T> CreateAsync(T entity)
    {
        entity.TenantId = _tenantContext.TenantId;
        entity.CreatedAt = DateTime.UtcNow;
        entity.CreatedBy = _tenantContext.CurrentUserId;

        _dbContext.Set<T>().Add(entity);
        await _dbContext.SaveChangesAsync();

        return entity;
    }
}
```

#### Dynamic Configuration per Tenant
```csharp
// Tenant-specific configuration
public class TenantConfigurationService
{
    private readonly IMemoryCache _cache;
    private readonly IKeycloakAdminClient _keycloakClient;

    public async Task<TenantConfiguration> GetConfigurationAsync(string tenantId)
    {
        var cacheKey = $"tenant_config:{tenantId}";

        if (_cache.TryGetValue(cacheKey, out TenantConfiguration cachedConfig))
        {
            return cachedConfig;
        }

        var realm = await _keycloakClient.GetRealmAsync(tenantId);
        var config = new TenantConfiguration
        {
            TenantId = tenantId,
            DisplayName = realm.DisplayName,
            DefaultLocale = realm.DefaultLocale,
            PasswordPolicy = realm.PasswordPolicy,
            SessionTimeout = realm.SsoSessionIdleTimeout,
            MfaRequired = realm.OtpPolicyType != null,
            BrandingTheme = realm.LoginTheme,
            CustomAttributes = realm.Attributes
        };

        _cache.Set(cacheKey, config, TimeSpan.FromMinutes(30));
        return config;
    }
}
```

## 8.3 Observabilidad y Telemetría

### Registro Estructurado con Contexto Completo
```csharp
// Rich logging with structured data
public class IdentityAuditLogger
{
    private readonly ILogger<IdentityAuditLogger> _logger;
    private readonly ITenantContext _tenantContext;

    public void LogAuthenticationAttempt(string userId, string clientIp, bool successful, string failureReason = null)
    {
        var logEvent = new
        {
            EventType = "AUTHENTICATION_ATTEMPT",
            Timestamp = DateTime.UtcNow,
            TenantId = _tenantContext.TenantId,
            UserId = userId,
            ClientIP = clientIp,
            UserAgent = _httpContext.Request.Headers["User-Agent"].ToString(),
            Successful = successful,
            FailureReason = failureReason,
            SessionId = _httpContext.Session.Id,
            TraceId = Activity.Current?.TraceId.ToString(),
            SpanId = Activity.Current?.SpanId.ToString()
        };

        if (successful)
        {
            _logger.LogInformation("User authentication successful {@AuthEvent}", logEvent);
        }
        else
        {
            _logger.LogWarning("User authentication failed {@AuthEvent}", logEvent);
        }
    }

    public void LogPrivilegedOperation(string operation, string targetUserId, object oldValues, object newValues)
    {
        _logger.LogInformation("Privileged operation executed {Operation} by {UserId} on {TargetUserId} {@Changes}",
            operation,
            _tenantContext.CurrentUserId,
            targetUserId,
            new { OldValues = oldValues, NewValues = newValues, TenantId = _tenantContext.TenantId });
    }
}
```

### Métricas de Negocio y Técnicas
```csharp
// Custom metrics collection
public class IdentityMetricsCollector
{
    private readonly IMetricsLogger _metricsLogger;
    private readonly Counter _authenticationAttempts;
    private readonly Histogram _authenticationLatency;
    private readonly Gauge _activeSessions;

    public IdentityMetricsCollector(IMetricsRoot metrics)
    {
        var tags = new MetricTags("service", "identity-system");

        _authenticationAttempts = metrics.Measure.Counter.WithTags(tags).Instance("authentication_attempts_total");
        _authenticationLatency = metrics.Measure.Histogram.WithTags(tags).Instance("authentication_duration_ms");
        _activeSessions = metrics.Measure.Gauge.WithTags(tags).Instance("active_sessions_count");
    }

    public void RecordAuthenticationAttempt(string tenantId, string method, bool successful)
    {
        var tags = new MetricTags(
            "tenant", tenantId,
            "method", method,
            "result", successful ? "success" : "failure"
        );

        _authenticationAttempts.Increment(tags);
    }

    public void RecordAuthenticationLatency(string tenantId, TimeSpan duration)
    {
        var tags = new MetricTags("tenant", tenantId);
        _authenticationLatency.Update(duration.TotalMilliseconds, tags);
    }

    public async Task UpdateActiveSessionsAsync()
    {
        foreach (var tenant in await _tenantService.GetActivTenantsAsync())
        {
            var sessionCount = await _sessionService.GetActiveSessionCountAsync(tenant.Id);
            var tags = new MetricTags("tenant", tenant.Id);
            _activeSessions.SetValue(sessionCount, tags);
        }
    }
}
```

### Trazado Distribuido con OpenTelemetry
```csharp
// OpenTelemetry configuration
public void ConfigureServices(IServiceCollection services)
{
    services.AddOpenTelemetryTracing(builder =>
    {
        builder
            .SetSampler(new AlwaysOnSampler())
            .AddAspNetCoreInstrumentation(options =>
            {
                options.RecordException = true;
                options.EnrichWithHttpRequest = (activity, request) =>
                {
                    activity.SetTag("tenant.id", request.HttpContext.Items["TenantId"]?.ToString());
                    activity.SetTag("user.id", request.HttpContext.User?.GetUserId());
                };
            })
            .AddHttpClientInstrumentation()
            .AddEntityFrameworkCoreInstrumentation()
            .AddJaegerExporter();
    });
}

// Manual span creation for business logic
public class UserProvisioningService
{
    private static readonly ActivitySource ActivitySource = new("Identity.UserProvisioning");

    public async Task<ProvisioningResult> ProvisionUserAsync(ProvisionUserRequest request)
    {
        using var activity = ActivitySource.StartActivity("ProvisionUser");
        activity?.SetTag("tenant.id", request.TenantId);
        activity?.SetTag("user.email", request.Email);

        try
        {
            // Step 1: Create in Keycloak
            using var keycloakActivity = ActivitySource.StartActivity("CreateKeycloakUser");
            var keycloakUser = await _keycloakClient.CreateUserAsync(request);
            keycloakActivity?.SetTag("keycloak.user.id", keycloakUser.Id);

            // Step 2: Assign roles
            using var rolesActivity = ActivitySource.StartActivity("AssignDefaultRoles");
            await AssignDefaultRolesAsync(keycloakUser.Id, request.TenantId);

            // Step 3: Send notification
            using var notificationActivity = ActivitySource.StartActivity("SendWelcomeNotification");
            await _notificationService.SendWelcomeEmailAsync(keycloakUser.Email);

            activity?.SetStatus(ActivityStatusCode.Ok, "User provisioned successfully");
            return ProvisioningResult.Success(keycloakUser.Id);
        }
        catch (Exception ex)
        {
            activity?.SetStatus(ActivityStatusCode.Error, ex.Message);
            activity?.RecordException(ex);
            throw;
        }
    }
}
```

## 8.4 Resilencia y Manejo de Errores

### Patrón Circuit Breaker para External Services
```csharp
// Resilient Keycloak client
public class ResilientKeycloakClient
{
    private readonly HttpClient _httpClient;
    private readonly AsyncCircuitBreakerPolicy _circuitBreaker;
    private readonly AsyncRetryPolicy _retryPolicy;

    public ResilientKeycloakClient(HttpClient httpClient)
    {
        _httpClient = httpClient;

        _circuitBreaker = Policy
            .Handle<HttpRequestException>()
            .Or<TaskCanceledException>()
            .CircuitBreakerAsync(
                exceptionsAllowedBeforeBreaking: 5,
                durationOfBreak: TimeSpan.FromSeconds(30),
                onBreak: (exception, duration) =>
                {
                    Log.Warning("Circuit breaker opened for {Duration}s due to {Exception}",
                        duration.TotalSeconds, exception.Message);
                },
                onReset: () =>
                {
                    Log.Information("Circuit breaker reset - service recovered");
                });

        _retryPolicy = Policy
            .Handle<HttpRequestException>()
            .WaitAndRetryAsync(
                retryCount: 3,
                sleepDurationProvider: retryAttempt => TimeSpan.FromSeconds(Math.Pow(2, retryAttempt)),
                onRetry: (outcome, timespan, retryCount, context) =>
                {
                    Log.Warning("Retry {RetryCount} after {Delay}s for {Operation}",
                        retryCount, timespan.TotalSeconds, context.OperationKey);
                });
    }

    public async Task<User> GetUserAsync(string userId)
    {
        var policy = Policy.WrapAsync(_retryPolicy, _circuitBreaker);

        return await policy.ExecuteAsync(async () =>
        {
            var response = await _httpClient.GetAsync($"/admin/realms/master/users/{userId}");
            response.EnsureSuccessStatusCode();

            var content = await response.Content.ReadAsStringAsync();
            return JsonSerializer.Deserialize<User>(content);
        });
    }
}
```

### Timeout y Bulkhead Patterns
```csharp
// Resource isolation with dedicated thread pools
public class BulkheadService
{
    private readonly TaskScheduler _authenticationScheduler;
    private readonly TaskScheduler _administrationScheduler;
    private readonly TaskScheduler _reportingScheduler;

    public BulkheadService()
    {
        // Separate thread pools for different operation types
        _authenticationScheduler = new LimitedConcurrencyLevelTaskScheduler(50);  // High priority
        _administrationScheduler = new LimitedConcurrencyLevelTaskScheduler(10);  // Medium priority
        _reportingScheduler = new LimitedConcurrencyLevelTaskScheduler(5);        // Low priority
    }

    public Task<AuthResult> AuthenticateAsync(AuthRequest request)
    {
        return Task.Factory.StartNew(
            () => _authenticationService.AuthenticateAsync(request),
            CancellationToken.None,
            TaskCreationOptions.DenyChildAttach,
            _authenticationScheduler).Unwrap();
    }
}

// Timeout policies
public class TimeoutPolicyService
{
    public static readonly AsyncTimeoutPolicy FastOperationTimeout =
        Policy.TimeoutAsync(TimeSpan.FromSeconds(5));

    public static readonly AsyncTimeoutPolicy StandardOperationTimeout =
        Policy.TimeoutAsync(TimeSpan.FromSeconds(30));

    public static readonly AsyncTimeoutPolicy LongRunningOperationTimeout =
        Policy.TimeoutAsync(TimeSpan.FromMinutes(5));
}
```

## 8.5 Compliance y Governance

### Audit Trail Comprehensivo
```csharp
// Comprehensive audit logging
public class ComplianceAuditService
{
    public async Task LogDataAccessAsync(string userId, string dataType, string dataId, string operation)
    {
        var auditEvent = new AuditEvent
        {
            EventId = Guid.NewGuid(),
            Timestamp = DateTime.UtcNow,
            EventType = "DATA_ACCESS",
            UserId = userId,
            TenantId = _tenantContext.TenantId,
            ResourceType = dataType,
            ResourceId = dataId,
            Operation = operation,
            ClientIP = _httpContext.Connection.RemoteIpAddress?.ToString(),
            UserAgent = _httpContext.Request.Headers["User-Agent"],
            SessionId = _httpContext.Session.Id,
            CorrelationId = _httpContext.TraceIdentifier
        };

        await _auditRepository.CreateAsync(auditEvent);
        await _eventBus.PublishAsync(auditEvent);
    }

    public async Task<GdprDataExport> GenerateGdprExportAsync(string userId)
    {
        var export = new GdprDataExport
        {
            RequestId = Guid.NewGuid(),
            UserId = userId,
            GeneratedAt = DateTime.UtcNow,
            DataController = "Talma Corporation"
        };

        // Collect identity data
        export.IdentityData = await _identityService.GetUserDataAsync(userId);

        // Collect audit logs
        export.ActivityHistory = await _auditService.GetUserActivityAsync(userId);

        // Collect consent history
        export.ConsentHistory = await _consentService.GetConsentHistoryAsync(userId);

        await LogDataAccessAsync(userId, "GDPR_EXPORT", export.RequestId.ToString(), "EXPORT");

        return export;
    }
}
```

### Data Retention y Anonymization
```csharp
// Automated data retention policies
public class DataRetentionService
{
    public async Task ApplyRetentionPoliciesAsync()
    {
        var policies = await _policyRepository.GetActiveRetentionPoliciesAsync();

        foreach (var policy in policies)
        {
            switch (policy.Action)
            {
                case RetentionAction.Delete:
                    await DeleteExpiredDataAsync(policy);
                    break;

                case RetentionAction.Anonymize:
                    await AnonymizeExpiredDataAsync(policy);
                    break;

                case RetentionAction.Archive:
                    await ArchiveExpiredDataAsync(policy);
                    break;
            }
        }
    }

    private async Task AnonymizeExpiredDataAsync(RetentionPolicy policy)
    {
        var expiredRecords = await _auditRepository.GetExpiredRecordsAsync(
            policy.DataType,
            DateTime.UtcNow.Subtract(policy.RetentionPeriod));

        foreach (var record in expiredRecords)
        {
            record.UserId = AnonymizeUserId(record.UserId);
            record.ClientIP = AnonymizeIpAddress(record.ClientIP);
            record.UserAgent = "ANONYMIZED";
            record.AnonymizedAt = DateTime.UtcNow;
        }

        await _auditRepository.UpdateRangeAsync(expiredRecords);
    }
}
```

*[INSERTAR AQUÍ: Diagrama C4 - Conceptos Transversales Implementation]*

## 8.6 Performance y Caching

### Multi-Level Caching Strategy
```csharp
// Hierarchical caching implementation
public class HierarchicalCacheService
{
    private readonly IMemoryCache _l1Cache;           // Local in-memory
    private readonly IDistributedCache _l2Cache;      // Redis cluster
    private readonly ICacheWarming _cacheWarming;

    public async Task<T> GetAsync<T>(string key, Func<Task<T>> factory, TimeSpan? ttl = null) where T : class
    {
        // L1 Cache (Memory)
        if (_l1Cache.TryGetValue(key, out T cachedValue))
        {
            return cachedValue;
        }

        // L2 Cache (Redis)
        var serializedValue = await _l2Cache.GetStringAsync(key);
        if (serializedValue != null)
        {
            var deserializedValue = JsonSerializer.Deserialize<T>(serializedValue);

            // Populate L1 cache
            _l1Cache.Set(key, deserializedValue, TimeSpan.FromMinutes(5));

            return deserializedValue;
        }

        // Cache miss - call factory
        var freshValue = await factory();
        if (freshValue != null)
        {
            var serialized = JsonSerializer.Serialize(freshValue);

            // Set in both levels
            await _l2Cache.SetStringAsync(key, serialized, new DistributedCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = ttl ?? TimeSpan.FromHours(1)
            });

            _l1Cache.Set(key, freshValue, TimeSpan.FromMinutes(5));
        }

        return freshValue;
    }
}
```

### Connection Pooling y Resource Management
```csharp
// Optimized connection management
public class OptimizedDbContext : DbContext
{
    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        optionsBuilder.UseNpgsql(connectionString, options =>
        {
            options.SetPostgresVersion(15, 0);
            options.EnableRetryOnFailure(maxRetryCount: 3, maxRetryDelay: TimeSpan.FromSeconds(30), null);
        });

        // Connection pooling optimization
        optionsBuilder.EnableServiceProviderCaching();
        optionsBuilder.EnableSensitiveDataLogging(false);
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // Optimized indexing strategy
        modelBuilder.Entity<AuditEvent>()
            .HasIndex(e => new { e.TenantId, e.Timestamp, e.EventType })
            .HasDatabaseName("IX_AuditEvent_Tenant_Timestamp_Type");

        modelBuilder.Entity<User>()
            .HasIndex(e => new { e.TenantId, e.Email })
            .IsUnique()
            .HasDatabaseName("IX_User_Tenant_Email_Unique");
    }
}
```

## Referencias

### Security Standards

- [OWASP Application Security Verification Standard](https://owasp.org/www-project-application-security-verification-standard/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
- [OAuth 2.0 Security Mejores Prácticas](https://tools.ietf.org/html/draft-ietf-oauth-security-topics)

### Observability

- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)
- [Registro Estructurado Mejores Prácticas](https://stackify.com/what-is-structured-logging-and-why-developers-need-it/)
- [Trazado Distribuido in .NET](https://docs.microsoft.com/en-us/dotnet/core/diagnostics/distributed-tracing)

### Patrones de Resiliencia

- [Polly Library Documentation](https://github.com/App-vNext/Polly)
- [Patrón Circuit Breaker](https://martinfowler.com/bliki/CircuitBreaker.html)
- [Bulkhead Pattern](https://docs.microsoft.com/en-us/azure/architecture/patterns/bulkhead)

### Architecture References

- [Arc42 Conceptos Transversales Template](https://docs.arc42.org/section-8/)
- [Microsoft .NET Application Architecture Guides](https://docs.microsoft.com/en-us/dotnet/architecture/)
- **Jitter:** Randomización para evitar thundering herd
- **Circuit Breaker:** Fail-fast ante servicios degradados
- **Bulkhead Pattern:** Aislamiento de recursos críticos

### Health Checks
```csharp
public class KeycloakHealthCheck : IHealthCheck
{
    public async Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context,
        CancellationToken cancellationToken = default)
    {
        // Verify Keycloak connectivity
        // Check database connection
        // Validate JWT signing keys
        // Test LDAP connectivity
    }
}
```

## 8.5 Performance y Escalabilidad

### Caching Strategy
- **Token Cache:** Redis para validación rápida de JWT
- **User Profile Cache:** Datos frecuentemente accedidos
- **Configuration Cache:** Settings de tenant y aplicación
- **Session Cache:** Estado de sesiones distribuidas

### Connection Pooling
```yaml
Database Connections:
  MinPoolSize: 5
  MaxPoolSize: 100
  ConnectionTimeout: 30s
  CommandTimeout: 60s
  IdleTimeout: 300s
```

### Balanceador de Carga
- **Round Robin:** Distribución equitativa
- **Health-based:** Exclusión de nodos degradados
- **Geographic:** Routing por proximidad
- **Session Affinity:** Para operaciones stateful

## 8.6 Compliance y Auditoría

### GDPR Compliance
- **Data Minimization:** Solo datos necesarios
- **Purpose Limitation:** Uso específico declarado
- **Storage Limitation:** Retención automática
- **Right to Erasure:** Anonimización automatizada
- **Data Portability:** Export en formatos estándar

### SOX Compliance
- **Change Management:** Todas las modificaciones auditadas
- **Segregation of Duties:** Separación de roles críticos
- **Access Reviews:** Certificación trimestral
- **Financial Controls:** Acceso especial para datos financieros

### Audit Trail
```json
{
  "timestamp": "2024-08-04T10:30:00Z",
  "eventType": "USER_LOGIN",
  "userId": "user123",
  "tenantId": "tenant456",
  "details": {
    "sourceIp": "192.168.1.100",
    "userAgent": "Mozilla/5.0...",
    "mfaMethod": "TOTP",
    "result": "SUCCESS"
  },
  "correlationId": "req-789",
  "signature": "SHA256:abcd1234..."
}
```

## 8.7 Gestión de Configuración

### Environment-based Configuration
```yaml
Development:
  Keycloak:
    Realm: dev-realm
    ClientSecret: dev-secret
    LogLevel: DEBUG

Production:
  Keycloak:
    Realm: prod-realm
    ClientSecret: ${KC_CLIENT_SECRET}
    LogLevel: INFO
```

### Feature Flags
```csharp
public class FeatureFlags
{
    public bool EnableMFA { get; set; }
    public bool EnablePasswordPolicy { get; set; }
    public bool EnableAuditLogging { get; set; }
    public bool EnableRateLimiting { get; set; }
}
```

### Configuration Validation
- **Schema Validation:** JSON Schema para configuraciones
- **Runtime Checks:** Validación durante startup
- **Hot Reload:** Cambios sin reinicio de servicio
- **Rollback Capability:** Reversión automática ante errores

## 8.8 Internacionalización y Localización

### Multi-language Support
```yaml
Supported Languages:
  - es-ES: Español (España)
  - es-PE: Español (Perú)
  - es-MX: Español (México)
  - en-US: English (US)
  - pt-BR: Português (Brasil)
```

### Cultural Considerations
- **Date/Time Formats:** Por región
- **Number Formats:** Separadores decimales
- **Currency Display:** Símbolos locales
- **Timezone Handling:** UTC + conversión local

### Content Localization
- **Error Messages:** Traducidos por idioma
- **Email Templates:** Contenido localizado
- **UI Text:** Resource bundles
- **Legal Terms:** Compliance por jurisdicción

## 8.9 Testing Strategy

### Unit Testing
```csharp
[Test]
public async Task AuthenticateUser_ValidCredentials_ReturnsJwtToken()
{
    // Arrange
    var userService = new Mock<IUserService>();
    var authService = new AuthenticationService(userService.Object);

    // Act
    var result = await authService.AuthenticateAsync("user", "password");

    // Assert
    Assert.IsNotNull(result.Token);
    Assert.IsTrue(result.IsValid);
}
```

### Integration Testing
- **Database Integration:** Testcontainers para PostgreSQL
- **Keycloak Integration:** Testcontainers para Keycloak
- **External APIs:** WireMock para simulación
- **End-to-End:** Selenium para flujos completos

### Performance Testing
- **Load Testing:** JMeter/k6 para carga normal
- **Stress Testing:** Límites de capacidad
- **Spike Testing:** Picos de tráfico
- **Endurance Testing:** Estabilidad a largo plazo

## Referencias
- [OAuth2 Security Mejores Prácticas](https://tools.ietf.org/html/draft-ietf-oauth-security-topics)
- [Multi-Tenant SaaS Architecture](https://aws.amazon.com/blogs/apn/building-a-multi-tenant-saas-solution-using-aws-serverless-services/)
- [Observability Patterns](https://microservices.io/patterns/observability/)
- [Arc42 Cross-cutting Concepts](https://docs.arc42.org/section-8/)
