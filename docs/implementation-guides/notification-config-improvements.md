# 🔔 Notification System - Mejoras de Configuración

## Feature Flags Específicos

### Por Canal y País
```bash
# Email por país
/corporativo/feature-flags/peru/notification-email = "enabled"
/corporativo/feature-flags/ecuador/notification-email = "enabled"
/corporativo/feature-flags/colombia/notification-email = "enabled"
/corporativo/feature-flags/mexico/notification-email = "enabled"

# SMS por país
/corporativo/feature-flags/peru/notification-sms = "disabled"
/corporativo/feature-flags/ecuador/notification-sms = "enabled"
/corporativo/feature-flags/colombia/notification-sms = "enabled"
/corporativo/feature-flags/mexico/notification-sms = "enabled"

# WhatsApp por país
/corporativo/feature-flags/peru/notification-whatsapp = "beta"
/corporativo/feature-flags/ecuador/notification-whatsapp = "enabled"
/corporativo/feature-flags/colombia/notification-whatsapp = "enabled"
/corporativo/feature-flags/mexico/notification-whatsapp = "enabled"

# Push por país
/corporativo/feature-flags/peru/notification-push = "enabled"
/corporativo/feature-flags/ecuador/notification-push = "enabled"
/corporativo/feature-flags/colombia/notification-push = "enabled"
/corporativo/feature-flags/mexico/notification-push = "enabled"
```

### Configuraciones Dinámicas
```bash
# Rate limiting por país
/corporativo/config/peru/notification-rate-limit = "1000"
/corporativo/config/ecuador/notification-rate-limit = "800"
/corporativo/config/colombia/notification-rate-limit = "1200"
/corporativo/config/mexico/notification-rate-limit = "1500"

# Batch sizes por canal
/corporativo/config/global/email-batch-size = "100"
/corporativo/config/global/sms-batch-size = "50"
/corporativo/config/global/whatsapp-batch-size = "200"
/corporativo/config/global/push-batch-size = "500"
```

## Implementación en C#

```csharp
// En NotificationService
public class NotificationService : INotificationService
{
    private readonly IFeatureFlagService _featureFlags;

    public async Task<bool> ProcessNotificationAsync(NotificationRequest request)
    {
        // Verificar si el canal está habilitado para este país
        var channelEnabled = await _featureFlags.IsEnabledAsync(
            $"notification-{request.Channel.ToLower()}",
            request.TenantId,
            request.Country
        );

        if (!channelEnabled)
        {
            _logger.LogInformation("Channel {Channel} disabled for {Country}",
                request.Channel, request.Country);
            return false;
        }

        // Obtener configuración específica
        var rateLimit = await _featureFlags.GetFeatureConfigAsync<int>(
            "notification-rate-limit",
            request.TenantId,
            request.Country,
            defaultValue: 1000
        );

        // Procesar con configuración dinámica...
        return await ProcessWithRateLimitAsync(request, rateLimit);
    }
}
```

## Casos de Uso Específicos

### 1. Rollout Gradual de WhatsApp
- Perú: `beta` (solo algunos tenants)
- Ecuador: `enabled` (todos los tenants)
- Colombia: `enabled`
- México: `enabled`

### 2. Rate Limiting por País
- Perú: 1000 msg/min (regulaciones estrictas)
- Ecuador: 800 msg/min
- Colombia: 1200 msg/min
- México: 1500 msg/min (mayor volumen)

### 3. Configuración de Templates
- Templates específicas por país y cultura
- Feature flags para A/B testing de templates
- Cache inteligente para templates frecuentes
