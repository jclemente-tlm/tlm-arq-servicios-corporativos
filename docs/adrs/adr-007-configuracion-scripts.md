# ADR-007: Configuración gestionada por scripts

## ✅ ESTADO

Aceptada – Julio 2025

---

## 🗺️ CONTEXTO

Se requiere una gestión de configuración auditable, reproducible y controlada por código para los entornos de los servicios corporativos.

Las alternativas evaluadas fueron:

- **Scripts (`SQL`, `CLI`, etc.)**
- **API de configuración**

### Comparativa de alternativas

| Criterio                        | Scripts/CLI         | API de configuración |
|---------------------------------|---------------------|----------------------|
| Agnosticismo (portabilidad)     | ✅ Totalmente agnóstico (multi-cloud, portable) | ✅ Totalmente agnóstico (si es desarrollada internamente) |
| Gestión operativa (mantenimiento y esfuerzo) | Requiere conocimiento técnico, bajo mantenimiento | Requiere desarrollo y mantenimiento propio |
| Auditabilidad/trazabilidad de cambios | Alta (versionado, control de cambios) | Media/Alta (según implementación de logging) |
| Facilidad de automatización     | Alta (integrable en CI/CD) | Alta (vía API) |
| Riesgo de errores humanos       | Bajo (procedimientos controlados) | Medio/Alto (exposición pública) |
| Flexibilidad/extensibilidad     | Media | Alta |
| Seguridad (acceso y superficie de ataque) | Alta (acceso controlado) | Media (mayor superficie de ataque) |
| Costos operativos               | Bajo | Medio/Alto (desarrollo y soporte) |
| Integración con CI/CD           | Nativa (scripts como código) | Alta (API) |
| Time-to-market para cambios     | Medio | Alto (si la API está bien diseñada) |

### Agnosticismo, lock-in y mitigación

- **Scripts/CLI:** Agnóstico respecto a proveedor cloud o plataforma, ya que los scripts pueden ejecutarse en cualquier entorno compatible (`on-premises`, `AWS`, `Azure`, `GCP`, etc.). No genera lock-in tecnológico.
- **API de configuración:** Si es desarrollada internamente, es agnóstica y portable; solo genera lock-in si depende de APIs propietarias de un proveedor cloud o plataforma específica.

### Comparativa de costos

- **Scripts/CLI:** Costos operativos bajos, sin costos adicionales por licenciamiento o uso de `APIs`. El principal costo es el tiempo técnico para mantenimiento y ejecución.
- **API de configuración:** Puede implicar costos adicionales por desarrollo, soporte, infraestructura y licenciamiento, además de mayor esfuerzo de mantenimiento.

---

## ✔️ DECISIÓN

La configuración de los servicios se gestionará mediante scripts versionados en el repositorio, evitando la gestión manual o vía `API`.

## Justificación

- Facilita la trazabilidad y control de cambios.
- Permite reproducibilidad de entornos y rollback sencillo.
- Mayor control y trazabilidad de cambios.
- Reducción de superficie de ataque y riesgos de seguridad.
- Adecuado para escenarios con baja frecuencia de cambios.
- Si la frecuencia de cambios aumenta, se puede reconsiderar exponer una `API`.

## Alternativas descartadas

- Gestión manual vía consola o UI.
- Configuración vía `API`.

---

## ⚠️ CONSECUENCIAS

- Los cambios de configuración requieren acceso controlado y personal técnico.
- Se documentan los procedimientos y scripts utilizados.

---

## 📚 REFERENCIAS

- [Gestión de configuración por scripts](https://12factor.net/config)
- [Arc42: Decisiones de arquitectura](https://arc42.org/decision/)
