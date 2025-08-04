# 6. Vista de tiempo de ejecución

## 6.1 Escenarios principales de ejecución

### 6.1.1 Flujo de autenticación y enrutamiento

```mermaid
sequenceDiagram
    participant Client as Cliente Web/Mobile
    participant Gateway as API Gateway
    participant Auth as Identity Service
    participant Service as Target Service
    participant Redis as Redis Cache

    Client->>Gateway: 1. Request con JWT token
    Gateway->>Gateway: 2. Extract token from header
    Gateway->>Redis: 3. Check token cache

    alt Token en cache y válido
        Redis->>Gateway: 4a. Token válido
    else Token no en cache o expirado
        Gateway->>Auth: 4b. Validate token
        Auth->>Gateway: 5b. Token validation result
        Gateway->>Redis: 6b. Cache valid token
    end

    Gateway->>Gateway: 7. Resolve tenant context
    Gateway->>Gateway: 8. Apply rate limiting
    Gateway->>Gateway: 9. Route selection
    Gateway->>Service: 10. Forward request con headers
    Service->>Gateway: 11. Response
    Gateway->>Client: 12. Response con rate limit headers
```

**Descripción del flujo**:
1. Cliente envía request con JWT token en Authorization header
2. Gateway extrae token del header Authorization
3. Verifica si token está en cache de Redis
4-6. Validación de token (cache hit o validación contra Identity Service)
7. Resolución del contexto de tenant basado en claims del token
8. Aplicación de rate limiting basado en client ID y endpoint
9. Selección de ruta y cluster de destino
10. Forwarding de request con headers enriquecidos (X-Tenant-ID, X-User-ID)
11-12. Retorno de response con headers de rate limiting

### 6.1.2 Health check y circuit breaker

```mermaid
sequenceDiagram
    participant Monitor as Health Monitor
    participant Gateway as API Gateway
    participant Service1 as Service Instance 1
    participant Service2 as Service Instance 2
    participant LoadBalancer as Load Balancer
    participant Circuit as Circuit Breaker

    loop Cada 30 segundos
        Monitor->>Service1: Health check GET /health
        Monitor->>Service2: Health check GET /health

        alt Service healthy
            Service1->>Monitor: 200 OK
            Monitor->>LoadBalancer: Keep in rotation
        else Service unhealthy
            Service2->>Monitor: 500 Error / Timeout
            Monitor->>Circuit: Open circuit
            Monitor->>LoadBalancer: Remove from rotation
        end
    end

    Note over Gateway,Circuit: Durante circuit abierto
    Gateway->>Circuit: Check circuit state
    Circuit->>Gateway: Circuit OPEN
    Gateway->>Service1: Route only to healthy instances
```

**Timing de health checks**:
- **Intervalo**: 30 segundos
- **Timeout**: 5 segundos
- **Threshold**: 3 fallos consecutivos para abrir circuit
- **Recovery**: Intento cada 60 segundos cuando circuit está abierto

### 6.1.3 Rate limiting distribuido

```mermaid
sequenceDiagram
    participant Client as Cliente
    participant Gateway1 as Gateway Instance 1
    participant Gateway2 as Gateway Instance 2
    participant Redis as Redis Store

    Client->>Gateway1: Request 1 (client_id: ABC123)
    Gateway1->>Redis: INCR rate_limit:ABC123:/api/users
    Redis->>Gateway1: Counter: 1
    Gateway1->>Client: 200 OK (X-RateLimit-Remaining: 999)

    Client->>Gateway2: Request 2 (client_id: ABC123)
    Gateway2->>Redis: INCR rate_limit:ABC123:/api/users
    Redis->>Gateway2: Counter: 2
    Gateway2->>Client: 200 OK (X-RateLimit-Remaining: 998)

    Note over Gateway1,Redis: Después de 1000 requests
    Client->>Gateway1: Request 1001
    Gateway1->>Redis: INCR rate_limit:ABC123:/api/users
    Redis->>Gateway1: Counter: 1001
    Gateway1->>Client: 429 Too Many Requests
```

**Algoritmo de rate limiting**:
- **Sliding window**: Ventana deslizante de 1 minuto
- **Estado compartido**: Redis para sincronización entre instancias
- **Granularidad**: Por client_id + endpoint
- **Headers de respuesta**: X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset

## 6.2 Escenarios de failover y recovery

### 6.2.1 Failover automático de servicios

```mermaid
sequenceDiagram
    participant Client as Cliente
    participant Gateway as API Gateway
    participant Primary as Service Primary
    participant Secondary as Service Secondary
    participant Monitor as Health Monitor

    Client->>Gateway: Normal request
    Gateway->>Primary: Forward request
    Primary->>Gateway: Response
    Gateway->>Client: Response

    Note over Primary: Service becomes unhealthy
    Monitor->>Primary: Health check
    Primary-->>Monitor: Timeout/Error
    Monitor->>Gateway: Mark primary unhealthy

    Client->>Gateway: Subsequent request
    Gateway->>Secondary: Forward to secondary
    Secondary->>Gateway: Response
    Gateway->>Client: Response

    Note over Primary: Service recovers
    Monitor->>Primary: Health check
    Primary->>Monitor: 200 OK
    Monitor->>Gateway: Mark primary healthy

    Client->>Gateway: Next request
    Gateway->>Primary: Back to primary (load balanced)
```

**Características del failover**:
- **Detección**: 3 health checks fallidos consecutivos
- **Switchover time**: < 30 segundos
- **Load balancing**: Round-robin entre instancias sanas
- **Recovery**: Gradual re-introduction con circuit breaker

### 6.2.2 Degradación graceful durante sobrecarga

```mermaid
sequenceDiagram
    participant Client as Cliente
    participant Gateway as API Gateway
    participant Monitor as Resource Monitor
    participant Queue as Request Queue

    Note over Gateway: Sistema bajo carga normal
    Client->>Gateway: Request
    Gateway->>Gateway: Process immediately
    Gateway->>Client: Response

    Note over Gateway: Carga alta detectada
    Monitor->>Monitor: CPU > 80%, Memory > 85%
    Monitor->>Gateway: Enable throttling mode

    Client->>Gateway: Request
    Gateway->>Gateway: Check priority (tenant tier)

    alt High priority client
        Gateway->>Gateway: Process immediately
        Gateway->>Client: Response
    else Standard priority client
        Gateway->>Queue: Queue request
        Queue->>Gateway: Process when capacity available
        Gateway->>Client: 503 Service Temporarily Unavailable
    end
```

## 6.3 Scenarios de multi-tenancy

### 6.3.1 Resolución de contexto de tenant

```mermaid
sequenceDiagram
    participant Client as Cliente Tenant A
    participant Gateway as API Gateway
    participant TenantResolver as Tenant Resolver
    participant IdentityDB as Identity Database
    participant Service as Target Service

    Client->>Gateway: Request con JWT (tenant_id: TENANT_A)
    Gateway->>Gateway: Extract tenant_id from JWT claims
    Gateway->>TenantResolver: Resolve tenant context

    alt Tenant en cache
        TenantResolver->>Gateway: Tenant config from cache
    else Tenant no en cache
        TenantResolver->>IdentityDB: Query tenant configuration
        IdentityDB->>TenantResolver: Tenant config
        TenantResolver->>TenantResolver: Cache tenant config (TTL: 5 min)
        TenantResolver->>Gateway: Tenant config
    end

    Gateway->>Gateway: Enrich request headers
    Note over Gateway: Add X-Tenant-ID, X-Tenant-Region, X-Tenant-Tier
    Gateway->>Service: Forward con tenant context
    Service->>Gateway: Response
    Gateway->>Client: Response
```

### 6.3.2 Routing inteligente por tenant

```mermaid
sequenceDiagram
    participant ClientA as Cliente Tenant A (Premium)
    participant ClientB as Cliente Tenant B (Standard)
    participant Gateway as API Gateway
    participant PremiumService as Premium Service Instance
    participant StandardService as Standard Service Instance

    ClientA->>Gateway: Request (tenant_tier: premium)
    Gateway->>Gateway: Check tenant tier from context
    Gateway->>PremiumService: Route to dedicated premium instance
    PremiumService->>Gateway: Response (low latency)
    Gateway->>ClientA: Response

    ClientB->>Gateway: Request (tenant_tier: standard)
    Gateway->>Gateway: Check tenant tier from context
    Gateway->>StandardService: Route to shared standard instance
    StandardService->>Gateway: Response
    Gateway->>ClientB: Response
```

## 6.4 Monitoring y observability en tiempo de ejecución

### 6.4.1 Distributed tracing flow

```mermaid
sequenceDiagram
    participant Client as Cliente
    participant Gateway as API Gateway
    participant Service1 as Identity Service
    participant Service2 as Notification Service
    participant Jaeger as Jaeger Tracing

    Client->>Gateway: Request (trace-id: 12345)
    Note over Gateway: Start root span
    Gateway->>Jaeger: Span: gateway.request (trace-id: 12345)

    Gateway->>Service1: Request con trace headers
    Note over Service1: Create child span
    Service1->>Jaeger: Span: identity.validate (parent: gateway.request)
    Service1->>Gateway: Response

    Gateway->>Service2: Request con trace headers
    Note over Service2: Create child span
    Service2->>Jaeger: Span: notification.send (parent: gateway.request)
    Service2->>Gateway: Response

    Gateway->>Client: Final response
    Note over Gateway: Complete root span
    Gateway->>Jaeger: Complete span: gateway.request
```

### 6.4.2 Métricas en tiempo real

```mermaid
sequenceDiagram
    participant Gateway as API Gateway
    participant Metrics as Metrics Collector
    participant Prometheus as Prometheus
    participant Grafana as Grafana Dashboard
    participant AlertManager as Alert Manager

    loop Cada request
        Gateway->>Metrics: Record request metrics
        Note over Metrics: - Request count<br/>- Response time<br/>- Status codes<br/>- Tenant ID
    end

    loop Cada 15 segundos
        Metrics->>Prometheus: Scrape metrics endpoint
        Prometheus->>Prometheus: Store time series data
    end

    loop Cada 30 segundos
        Grafana->>Prometheus: Query for dashboard
        Prometheus->>Grafana: Metrics data
    end

    alt Threshold exceeded
        Prometheus->>AlertManager: Trigger alert
        AlertManager->>AlertManager: Send notification (Slack/PagerDuty)
    end
```

## 6.5 Patrones de performance

### 6.5.1 Request pooling y connection reuse

```mermaid
sequenceDiagram
    participant Client as Multiple Clients
    participant Gateway as API Gateway
    participant Pool as HTTP Connection Pool
    participant Service as Backend Service

    Note over Pool: Initial state: 0 connections

    Client->>Gateway: Request 1
    Gateway->>Pool: Get connection
    Pool->>Service: Create new connection
    Pool->>Gateway: Return connection
    Gateway->>Service: Send request
    Service->>Gateway: Response
    Gateway->>Pool: Return connection to pool
    Gateway->>Client: Response

    Client->>Gateway: Request 2 (concurrent)
    Gateway->>Pool: Get connection
    Pool->>Gateway: Reuse existing connection
    Gateway->>Service: Send request (reused connection)
    Service->>Gateway: Response
    Gateway->>Client: Response

    Note over Pool: Pool maintains 5-50 connections per service
```

**Configuración del pool**:
- **Min connections**: 5 por service cluster
- **Max connections**: 50 por service cluster
- **Idle timeout**: 30 segundos
- **Connection lifetime**: 2 minutos

### 6.5.2 Caching strategy en tiempo de ejecución

```mermaid
sequenceDiagram
    participant Client as Cliente
    participant Gateway as API Gateway
    participant L1Cache as L1 Cache (Memory)
    participant L2Cache as L2 Cache (Redis)
    participant Service as Backend Service

    Client->>Gateway: GET /api/config/tenant/ABC
    Gateway->>L1Cache: Check L1 cache

    alt L1 Cache hit
        L1Cache->>Gateway: Return cached data
        Gateway->>Client: Response (X-Cache: L1-HIT)
    else L1 Cache miss
        Gateway->>L2Cache: Check L2 cache

        alt L2 Cache hit
            L2Cache->>Gateway: Return cached data
            Gateway->>L1Cache: Store in L1 cache
            Gateway->>Client: Response (X-Cache: L2-HIT)
        else L2 Cache miss
            Gateway->>Service: Forward request
            Service->>Gateway: Response
            Gateway->>L2Cache: Store in L2 cache
            Gateway->>L1Cache: Store in L1 cache
            Gateway->>Client: Response (X-Cache: MISS)
        end
    end
```

**TTL Configuration**:
- **L1 Cache (Memory)**: 2 minutos
- **L2 Cache (Redis)**: 10 minutos
- **Cache invalidation**: Event-driven para configuration changes

## 6.6 Timing y performance targets

| Operación | Target | Timeout | SLA |
|-----------|--------|---------|-----|
| Token validation (cached) | < 10ms | 100ms | 99.9% |
| Token validation (fresh) | < 100ms | 500ms | 99.5% |
| Request routing | < 5ms | 50ms | 99.9% |
| Health check | < 200ms | 5s | 95% |
| Rate limit check | < 5ms | 100ms | 99.9% |
| Configuration reload | < 1s | 30s | 99% |
| Circuit breaker activation | < 100ms | 500ms | 99% |

## 6.7 Error handling scenarios

### 6.7.1 Downstream service timeout

- **Timeout threshold**: 30 segundos
- **Retry policy**: 3 intentos con exponential backoff
- **Circuit breaker**: Abre después de 5 timeouts consecutivos
- **Response**: 504 Gateway Timeout con retry-after header

### 6.7.2 Authentication service unavailable

- **Fallback**: Cache de tokens válidos extendido a 1 hora
- **Degraded mode**: Permitir requests con tokens cached válidos únicamente
- **Response**: 503 Service Unavailable para nuevas autenticaciones
