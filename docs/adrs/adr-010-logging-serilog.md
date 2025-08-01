# ADR-010: Logging estructurado con [Serilog](https://serilog.net/)

## ✅ ESTADO

Aceptada – Julio 2025

---

## 🗺️ CONTEXTO

Se requiere un mecanismo de logging estructurado, flexible y compatible con múltiples `sinks` para todos los servicios `.NET`, que permita trazabilidad, auditoría y análisis centralizado.

Las alternativas evaluadas fueron:

- [Serilog](https://serilog.net/)
- [NLog](https://nlog-project.org/)
- [log4net](https://logging.apache.org/log4net/)

### Comparativa de alternativas

| Criterio                | Serilog | NLog | log4net |
|------------------------|---------|------|---------|
| Agnosticismo           | Alto (`open source`, multi-plataforma) | Alto (`open source`, multi-plataforma) | Alto (`open source`, multi-plataforma) |
| Estructurado/JSON      | Sí      | Parcial | Parcial |
| Sinks soportados       | Muchos  | Muchos | Menos   |
| Integración .NET Core  | Excelente | Buena | Media   |
| Comunidad              | Alta    | Alta  | Media   |
| Enriquecimiento        | Sí      | Parcial | Parcial |

### Agnosticismo, lock-in y mitigación

- **Lock-in:** `Serilog`, `NLog` y `log4net` son `open source` y portables entre plataformas `.NET`, minimizando lock-in. Sin embargo, el uso de `sinks` propietarios (Seq, Datadog, etc.) puede generar dependencia.
- **Mitigación:** Usar formatos estándar (`JSON`, `GELF`) y `sinks` open source facilita la migración entre soluciones de logging y observabilidad.

### Comparativa de costos estimados (2025)

| Solución        | Costo mensual base* | Costos adicionales | Infraestructura propia |
|-----------------|---------------------|--------------------|-----------------------|
| `Serilog`         | Gratis (`open source`)| ~US$20/mes (VM pequeña) si se usa `Seq`/`Elasticsearch` | Opcional              |
| `NLog`            | Gratis (`open source`)| ~US$20/mes (VM pequeña) si se usa `Seq`/`Elasticsearch` | Opcional              |
| `log4net`         | Gratis (`open source`)| ~US$20/mes (VM pequeña) si se usa `Seq`/`Elasticsearch` | Opcional              |
| `Seq`             | Gratis hasta 5M eventos/mes | ~US$15/mes por 10M eventos extra | Sí         |
| [Datadog](https://www.datadoghq.com/)         | ~US$1.27/GB de logs | Pago por logs      | No                    |

*Precios aproximados, sujetos a variación según proveedor, volumen y configuración. El costo real depende del destino de los logs y la retención.

---

## ✔️ DECISIÓN

Se adopta `Serilog` como librería estándar de logging estructurado para todos los servicios `.NET` del ecosistema corporativo.

## Justificación

- Soporte nativo para `sinks` como consola, archivos, `Seq`, `Elasticsearch`, etc.
- Permite logging estructurado (`JSON`) y enriquecimiento de logs.
- Integración sencilla con `ASP.NET Core` y otros frameworks `.NET`.
- Amplia comunidad y documentación.
- Facilita la integración con sistemas de monitoreo y observabilidad.
- Permite incluir información de `tenant` y `país` en los logs, facilitando la trazabilidad y auditoría en entornos `multi-tenant` y `multi-país`.

## Alternativas descartadas

- NLog/log4net: Menor soporte para logging estructurado y sinks modernos.

---

## ⚠️ CONSECUENCIAS

- Todos los servicios .NET deben implementar Serilog para logging estructurado.
- Se debe estandarizar el formato y la gestión de logs.

---

## 📚 REFERENCIAS

- [Serilog Docs](https://serilog.net/)
- [Serilog Sinks](https://github.com/serilog/serilog/wiki/Provided-Sinks)
- [Arc42: Decisiones de arquitectura](https://arc42.org/decision/)
