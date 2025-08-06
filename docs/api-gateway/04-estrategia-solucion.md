# 4. Estrategia de solución

## 4.1 Decisiones Fundamentales

### Tecnología Central: YARP (Yet Another Reverse Proxy)

**Decisión:** Adoptar YARP de Microsoft como base del API Gateway

**Justificación:**

- **Integración Nativa .NET:** Aprovecha el ecosistema .NET 8 existente
- **Rendimiento Superior:** Optimizado para escenarios de alto rendimiento
- **Extensibilidad:** Arquitectura de middleware permite personalización completa
- **Comunidad:** Respaldado por Microsoft con hoja de ruta a largo plazo
- **Configuración Declarativa:** Configuración basada en JSON con recarga en caliente

**Alternativas Consideradas:**

- **Kong:** Funcionalidad rica pero sobrecarga de Lua y complejidad operacional
- **Envoy:** Rendimiento excelente pero curva de aprendizaje pronunciada
- **AWS ALB:** Limitado en personalización y bloqueo de proveedor
- **NGINX:** Requiere módulos personalizados y configuración compleja

### Arquitectura de Despliegue: ECS Fargate

**Decisión:** Desplegar como contenedores serverless en AWS ECS Fargate

**Beneficios:**

- **Escalabilidad Automática:** Escalado automático basado en métricas de CPU/memoria
- **Alta Disponibilidad:** Despliegue multi-AZ con verificaciones de estado
- **Operación Simplificada:** Sin gestión de servidores subyacentes
- **Optimización de Costos:** Modelo de pago por uso con capacidad reservada

## 4.2 Patrones Arquitectónicos Aplicados

### Patrón 1: Pipeline de Middleware

```
Request → Security → Tenant → RateLimit → Transform → CircuitBreaker → Downstream
```

**Implementación:**

- **Middleware de Seguridad:** Validación JWT, extracción de claims
- **Middleware de Tenant:** Resolución de contexto multi-tenant (realm)
- **Limitación de Velocidad:** Cuotas por tenant (realm), por usuario
- **Transformación:** Mapeo de datos de solicitud/respuesta
- **Circuit Breaker:** Aislamiento de fallas con Polly

### Patrón 2: Configuración como Código

```
Config Source → Validation → Hot Reload → Cache Invalidation → Apply Changes
```

**Características:**

- **Actualizaciones Dinámicas:** Cambios sin reinicio del servicio
- **Capa de Validación:** Validación de esquema antes de aplicar
- **Capacidad de Rollback:** Versionado de configuraciones
- **Multi-Ambiente:** Configuración específica por ambiente

### Patrón 3: Observabilidad Incorporada

```
Request → Correlation ID → Structured Logs → Metrics → Tracing → Dashboards
```

**Implementación:**

- **IDs de Correlación:** UUID propagado en headers
- **Registro Estructurado:** Formato JSON con Serilog
- **Métricas Personalizadas:** Métricas compatibles con Prometheus
- **Health Checks:** Health checks estilo Kubernetes

## 4.3 Enfoque Multi-Tenant (Multi-Realm)

### Contexto: Tenants vs Realms

**Equivalencia Conceptual:**

- **Tenant:** Concepto arquitectónico para aislamiento de datos y configuración por cliente
- **Realm:** Concepto de Keycloak que implementa físicamente el aislamiento de tenants
- **Relación:** 1 Tenant = 1 Realm de Keycloak

**Implementación Práctica:**

```csharp
// Tenant ID extraído del JWT viene del Realm de Keycloak
public class TenantContext
{
    public string TenantId { get; set; }        // ej: "talma-peru"
    public string RealmName { get; set; }       // ej: "talma-peru" (mismo valor)
    public string KeycloakRealm { get; set; }   // URL: /realms/talma-peru
}
```

### Estrategia de Aislamiento de Tenant (Realm)

| Nivel | Estrategia | Implementación |
|-------|------------|----------------|
| **Nivel de Solicitud** | Inyección de contexto tenant (realm) | Claims JWT, headers |
| **Configuración** | Configuraciones por tenant (realm) | Configuración dinámica por tenant/realm |
| **Limitación de Velocidad** | Cuotas aisladas | Buckets separados por tenant/realm |
| **Enrutamiento** | Enrutamiento consciente de tenant | Enrutamiento basado en reglas por realm |
| **Monitoreo** | Métricas separadas | Etiquetas por tenant/realm |

### Tenant (Realm) Context Flow

```
JWT Token → Claims Extraction → Tenant/Realm Resolution → Context Injection → Downstream
```

**Ejemplo práctico de extracción de contexto:**

```csharp
public class TenantResolutionMiddleware
{
    public async Task InvokeAsync(HttpContext context, RequestDelegate next)
    {
        var token = context.Request.Headers["Authorization"]
            .FirstOrDefault()?.Split(" ").Last();

        if (!string.IsNullOrEmpty(token))
        {
            var jwtToken = new JwtSecurityTokenHandler().ReadJwtToken(token);

            // Extraer realm de Keycloak (equivalente a tenant)
            var issuer = jwtToken.Issuer; // ej: "https://keycloak.talma.com/realms/talma-peru"
            var realmName = ExtractRealmFromIssuer(issuer); // "talma-peru"

            // Establecer contexto tenant/realm
            context.Items["TenantId"] = realmName;
            context.Items["RealmName"] = realmName;
            context.Items["KeycloakRealm"] = issuer;
        }

        await next(context);
    }

    private string ExtractRealmFromIssuer(string issuer)
    {
        // Extraer realm del formato: https://host/realms/{realm-name}
        return issuer.Split("/realms/").LastOrDefault();
    }
}
```

## 4.4 Estrategia de Resiliencia

### Patrón Circuit Breaker

- **Implementación:** Integración con librería Polly
- **Umbrales:** Tasas de falla y timeouts configurables
- **Estados:** Cerrado → Abierto → Semi-Abierto → Cerrado
- **Respaldo:** Respuestas de degradación elegante

### Estrategia de Reintentos

- **Política:** Backoff exponencial con jitter
- **Máximos Intentos:** Configurable por endpoint
- **Condiciones de Reintento:** Códigos de estado HTTP, timeouts, excepciones
- **Integración con Circuit:** Respeta el estado del circuit breaker

### Gestión de Timeouts

- **Timeout de Solicitud:** 30s por defecto, configurable por ruta
- **Timeout de Circuit:** 60s para recuperación de circuit
- **Timeout de Health Check:** 5s para salud de downstream
- **Timeout de Configuración:** 10s para actualizaciones de configuración

## 4.5 Estrategia de Seguridad

### Defensa en Profundidad

| Capa | Medida | Implementación |
|------|--------|----------------|
| **Transporte** | Cifrado TLS 1.3 | Terminación ALB + TLS interno |
| **Autenticación** | OAuth2 + JWT | Validación de tokens, verificación de expiración |
| **Autorización** | RBAC + Claims | Control de acceso basado en roles por realm |
| **Validación de Entrada** | Validación de esquema | Validación de especificación OpenAPI |
| **Limitación de Velocidad** | Gestión de cuotas | Algoritmo token bucket por tenant/realm |
| **Auditoría** | Registro de acceso | Logs estructurados con correlación + contexto tenant |

### Cabeceras de Seguridad

```
Strict-Transport-Security: max-age=31536000; includeSubDomains
X-Frame-Options: DENY
X-Content-Type-Options: nosniff
X-XSS-Protection: 1; mode=block
Content-Security-Policy: default-src 'self'
```

## 4.6 Estrategia de Rendimiento

### Técnicas de Optimización

| Técnica | Propósito | Implementación |
|---------|-----------|----------------|
| **Pooling de Conexiones** | Reducir latencia | Pooling de clientes HTTP |
| **Compresión de Respuesta** | Reducir ancho de banda | Codificación gzip/brotli |
| **HTTP/2** | Multiplexación | Soporte nativo en .NET |
| **Caching** | Reducir carga | Headers de caché de respuesta |
| **Balanceo de Carga** | Distribuir carga | Round-robin ponderado |

### Objetivos de Rendimiento

| Métrica | Objetivo | Medición |
|---------|----------|----------|
| **Sobrecarga de Latencia** | < 10ms p95 | Monitoreo APM |
| **Rendimiento** | 10K req/s | Pruebas de carga |
| **Uso de Memoria** | < 2GB por instancia | Métricas de contenedor |
| **Uso de CPU** | < 70% promedio | Métricas CloudWatch |
| **Tasa de Error** | < 0.1% | Seguimiento de errores |

## 4.7 Estrategia de Configuración Dinámica

### Fuentes de Configuración

- **AWS Systems Manager:** Parameter Store para configuraciones
- **AWS Secrets Manager:** Claves API y certificados
- **Variables de Entorno:** Overrides a nivel de contenedor
- **Archivos Locales:** Configuración de respaldo

### Jerarquía de Configuración

```
Variables de Entorno > AWS SSM > Archivos Locales > Valores por Defecto
```

### Proceso de Recarga en Caliente

1. **Sondeo:** Verificar cambios cada 30 segundos
2. **Validación:** Validación de esquema de nueva configuración
3. **Despliegue Gradual:** Aplicar cambios incrementalmente
4. **Verificación de Salud:** Verificar salud del sistema post-cambio
5. **Rollback:** Auto-rollback si las verificaciones de salud fallan

## 4.8 Estrategia de Testing

### Pirámide de Testing

| Nivel | Tipo | Cobertura | Herramientas |
|-------|------|-----------|--------------|
| **Unitario** | Testing de componentes | 80%+ | xUnit, Moq |
| **Integración** | Testing de API | 70%+ | TestServer, WebApplicationFactory |
| **Contrato** | Contrato de API | 100% | Pact, validación OpenAPI |
| **Carga** | Testing de rendimiento | Escenarios clave | NBomber, Artillery |
| **Seguridad** | Testing de seguridad | OWASP Top 10 | OWASP ZAP, SonarQube |

### Estrategia de Testing

- **Desplazamiento hacia la Izquierda:** Testing temprano en el ciclo de desarrollo
- **Automatizado:** 100% testing automatizado en CI/CD
- **Paridad de Ambiente:** Testing en ambientes similares a producción
- **Continuo:** Testing continuo con ciclos de retroalimentación
- **Testing Multi-Tenant:** Validación de aislamiento entre tenants/realms
- **Integración Keycloak:** Testing con múltiples realms configurados
