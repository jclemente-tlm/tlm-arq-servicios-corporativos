# ADR-007: Configuración gestionada por scripts

## Estado

Aceptada – Julio 2025

## Contexto

Se requiere una gestión de configuración auditable, reproducible y controlada por código para los entornos de los servicios corporativos. Las alternativas evaluadas fueron:

- **Scripts (SQL, CLI, etc.)**
- **API de configuración**

## Decisión

La configuración de los servicios se gestionará mediante scripts versionados en el repositorio, evitando la gestión manual o vía API.

## Justificación

- Facilita la trazabilidad y control de cambios.
- Permite reproducibilidad de entornos y rollback sencillo.
- Mayor control y trazabilidad de cambios.
- Reducción de superficie de ataque y riesgos de seguridad.
- Adecuado para escenarios con baja frecuencia de cambios.
- Si la frecuencia de cambios aumenta, se puede reconsiderar exponer una API.

### Comparativa de alternativas

| Criterio                | Scripts/CLI         | API de configuración |
|-------------------------|---------------------|----------------------|
| Costo operativo         | Bajo                | Alto                 |
| Seguridad               | Alta (acceso controlado) | Media (mayor superficie de ataque) |
| Trazabilidad            | Alta (auditoría por cambios en scripts) | Media (requiere logging adicional) |
| Flexibilidad            | Media (requiere intervención técnica) | Alta (cambios vía API) |
| Mantenimiento           | Bajo                | Alto                 |
| Riesgo de errores       | Bajo (procedimientos controlados) | Medio/Alto (exposición pública) |
| Ejemplos en la industria| Mercado Libre, Nubank, AWS, Google | Salesforce, Twilio, Auth0         |

### Agnosticismo y lock-in

- **Scripts/CLI:** Agnóstico respecto a proveedor cloud o plataforma, ya que los scripts pueden ejecutarse en cualquier entorno compatible (on-premises, AWS, Azure, GCP, etc.). No genera lock-in tecnológico.
- **API de configuración:** Puede generar lock-in si depende de APIs propietarias de un proveedor cloud o plataforma específica.

### Comparativa de costos

- **Scripts/CLI:** Costos operativos bajos, sin costos adicionales por licenciamiento o uso de APIs. El principal costo es el tiempo técnico para mantenimiento y ejecución.
- **API de configuración:** Puede implicar costos adicionales por uso de APIs, infraestructura y licenciamiento, además de mayor esfuerzo de desarrollo y mantenimiento.

## Alternativas descartadas

- Gestión manual vía consola o UI.
- Configuración vía API.

## Implicaciones

- Los cambios de configuración requieren acceso controlado y personal técnico.
- Se documentan los procedimientos y scripts utilizados.

## Referencias

- [Gestión de configuración por scripts](https://12factor.net/config)
- [Arc42: Decisiones de arquitectura](https://arc42.org/decision/)
