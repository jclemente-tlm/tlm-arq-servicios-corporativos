# 📍 Track & Trace - Mejoras de Configuración

## Feature Flags Específicos

### Por Funcionalidad y País
```bash
# Event enrichment por país
/corporativo/feature-flags/peru/track-trace-enrichment = "enabled"
/corporativo/feature-flags/ecuador/track-trace-enrichment = "enabled"
/corporativo/feature-flags/colombia/track-trace-enrichment = "beta"
/corporativo/feature-flags/mexico/track-trace-enrichment = "enabled"

# Real-time tracking
/corporativo/feature-flags/peru/track-trace-realtime = "enabled"
/corporativo/feature-flags/ecuador/track-trace-realtime = "disabled"
/corporativo/feature-flags/colombia/track-trace-realtime = "enabled"
/corporativo/feature-flags/mexico/track-trace-realtime = "enabled"

# Advanced analytics
/corporativo/feature-flags/global/track-trace-analytics = "beta"
```

### Configuraciones Dinámicas
```bash
# Batch sizes por país
/corporativo/config/peru/track-trace-batch-size = "100"
/corporativo/config/ecuador/track-trace-batch-size = "500"
/corporativo/config/colombia/track-trace-batch-size = "300"
/corporativo/config/mexico/track-trace-batch-size = "200"

# Retention policies
/corporativo/config/peru/track-trace-retention-days = "90"
/corporativo/config/ecuador/track-trace-retention-days = "120"
/corporativo/config/colombia/track-trace-retention-days = "60"
/corporativo/config/mexico/track-trace-retention-days = "180"
```

## Implementación en C#

```csharp
// En EventProcessor
public class EventProcessor : IEventProcessor
{
    private readonly IFeatureFlagService _featureFlags;

    public async Task<bool> ProcessEventAsync(TrackingEvent eventData)
    {
        // Verificar si enrichment está habilitado
        var enrichmentEnabled = await _featureFlags.IsEnabledAsync(
            "track-trace-enrichment",
            eventData.TenantId,
            eventData.Country
        );

        if (enrichmentEnabled)
        {
            await EnrichEventAsync(eventData);
        }

        // Verificar si real-time está habilitado
        var realtimeEnabled = await _featureFlags.IsEnabledAsync(
            "track-trace-realtime",
            eventData.TenantId,
            eventData.Country
        );

        if (realtimeEnabled)
        {
            await PublishRealtimeEventAsync(eventData);
        }

        return await StoreEventAsync(eventData);
    }
}
```

## Casos de Uso Específicos

### 1. Enriquecimiento de Eventos
- Control granular por país y tenant
- Diferentes niveles de enriquecimiento
- Optimización de recursos por región

### 2. Políticas de Retención
- Cumplimiento de regulaciones locales
- Optimización de storage por país
- Configuración dinámica sin restart

### 3. Real-time vs Batch Processing
- Real-time para países con alta demanda
- Batch processing para optimizar costos
- Configuración híbrida por tenant
