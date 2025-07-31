# ADR-007: Configuración gestionada por scripts en vez de API

## Estado

Aceptada – Julio 2025

## Contexto

La configuración de tenants, canales y plantillas tiene baja frecuencia de cambio y es gestionada por personal técnico. Las alternativas evaluadas fueron:

- **Scripts (SQL, CLI, etc.)**
- **API de configuración**

## Decisión

Se gestiona la configuración mediante scripts y herramientas de línea de comandos, evitando exponer una API pública.

## Justificación

- Menor costo y mantenimiento operativo.
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

**Evidencia:**

- Empresas como Mercado Libre, Nubank, AWS y Google gestionan configuraciones críticas mediante scripts y herramientas CLI para mayor seguridad y control.
- Plataformas SaaS con alta frecuencia de cambios (Salesforce, Twilio, Auth0) suelen exponer APIs de configuración, pero requieren mayores controles de seguridad y auditoría.

## Alternativas descartadas

- **API de configuración**: Mayor complejidad, costo y riesgos de seguridad innecesarios para el contexto actual.

## Implicaciones

- Los cambios de configuración requieren acceso controlado y personal técnico.
- Se documentan los procedimientos y scripts utilizados.

## Referencias

- [Gestión de configuración por scripts](https://12factor.net/config)
- [Arc42: Decisiones de arquitectura](https://arc42.org/decision/)
