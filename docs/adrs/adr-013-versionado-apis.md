# ADR-013: Estrategia de versionado de APIs

## Estado

Aceptada – Julio 2025

## Contexto

Para permitir la evolución controlada de los contratos de APIs y mantener la compatibilidad hacia atrás, se requiere una estrategia de versionado. Las alternativas evaluadas fueron:

- Versionado en path (URL)
- Versionado en header
- Versionado en query string
- Sin versionado

## Decisión

Se adopta el **versionado en path** (por ejemplo, `/v1/`) como estrategia estándar para todas las APIs públicas y privadas.

## Justificación
- Es la opción más explícita y ampliamente soportada.
- Facilita la coexistencia de múltiples versiones.
- Compatible con herramientas de documentación y gateways.
- Sencillo de implementar y mantener.

### Comparativa de alternativas

| Criterio                | Path   | Header | Query String | Sin versionado |
|------------------------|--------|--------|--------------|----------------|
| Agnosticismo           | Alto (estándar abierto, multi-plataforma) | Medio (algunas herramientas propietarias) | Bajo (poco usado, menor soporte) | N/A |
| Claridad               | Alta   | Media  | Baja         | Baja           |
| Compatibilidad         | Alta   | Media  | Baja         | Baja           |
| Soporte herramientas   | Alta   | Media  | Baja         | Baja           |
| Facilidad de testing   | Alta   | Media  | Baja         | Alta           |


### Comparativa de costos estimados (2025)

| Solución                | Costo base*                  | Costos adicionales                | Infraestructura propia |
|------------------------|------------------------------|-----------------------------------|-----------------------|
| API Gateway gestionado | ~US$3.50/millón de llamadas  | Integración, tráfico              | No                    |
| API Gateway open source| Gratis (open source)         | ~US$20/mes (VM pequeña) + soporte | Sí                    |

*Precios aproximados, sujetos a variación según proveedor, volumen y configuración. El costo real depende del tráfico y la solución elegida.

### Agnosticismo, lock-in y mitigación

- **Lock-in:** El versionado en path es un patrón estándar y ampliamente soportado, minimiza lock-in. Algunas herramientas pueden tener implementaciones propietarias, pero el patrón es portable.
- **Mitigación:** Usar convenciones estándar y documentar los contratos de API facilita la migración entre plataformas y herramientas.


## Alternativas descartadas
- Header: Menos visible y menos soportado por herramientas.
- Query string: Poco común y menos claro.
- Sin versionado: No permite evolución controlada ni coexistencia de versiones.

## Implicaciones
- Todas las APIs deben exponer la versión en el path.
- Se recomienda documentar claramente los cambios entre versiones.

## Referencias
- [REST API Versioning Best Practices](https://restfulapi.net/versioning/)
- [OpenAPI Specification – Versioning](https://swagger.io/docs/specification/api-host-and-base-path/)
- [ADR-004: API Gateway con YARP](./adr-004-api-gateway-yarp.md)
- [ADR-008: Autenticaciones](./adr-008-autenticaciones.md)
- [Arc42: Decisiones de arquitectura](https://arc42.org/decision/)
