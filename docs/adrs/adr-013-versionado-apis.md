# ADR-013: Estrategia de versionado de `APIs`

## ✅ ESTADO

Aceptada – Julio 2025

---

## 🗺️ CONTEXTO

Para permitir la evolución controlada de los contratos de `APIs` y mantener la compatibilidad hacia atrás, se requiere una estrategia de versionado.

Las alternativas evaluadas fueron:

- Versionado en `path` (URL)
- Versionado en `header`
- Versionado en `query string`
- Sin versionado

### Comparativa de alternativas

| Criterio                                              | Path   | Header | Query String | Sin versionado |
|-------------------------------------------------------|--------|--------|--------------|----------------|
| Visibilidad y claridad para consumidores              | Muy alta (explícito en URL) | Baja (oculto en header) | Media (visible pero poco estándar) | N/A |
| Soporte por herramientas de documentación/gateways    | Muy alto (OpenAPI, gateways) | Medio (requiere configuración extra) | Bajo | N/A |
| Facilidad de automatización y DevOps                  | Alta (fácil de versionar en rutas) | Media | Baja | N/A |
| Impacto en caché y SEO                                | Positivo (versiona recursos) | Nulo | Negativo (puede confundir) | N/A |
| Compatibilidad con API management/version rollback    | Muy alta | Media | Baja | N/A |
| Riesgo de lock-in y portabilidad                      | Bajo (patrón estándar) | Medio (algunas herramientas propietarias) | Alto (poco soporte) | N/A |
| Facilidad de migración y coexistencia de versiones    | Muy alta | Media | Baja | N/A |
| Extensibilidad/Flexibilidad                          | Alta | Media | Baja | N/A |
| Costos                                               | Bajo | Bajo | Bajo | N/A |
| Licenciamiento                                       | OSS | OSS | OSS | N/A |

### Comparativa de costos estimados (2025)

| Solución                | Costo base*                  | Costos adicionales                | Infraestructura propia |
|------------------------|------------------------------|-----------------------------------|-----------------------|
| API Gateway gestionado | ~US$3.50/millón de llamadas  | Integración, tráfico              | No                    |
| API Gateway open source| Gratis (`open source`)         | ~US$20/mes (VM pequeña) + soporte | Sí                    |

*Precios aproximados, sujetos a variación según proveedor, volumen y configuración. El costo real depende del tráfico y la solución elegida.

### Agnosticismo, lock-in y mitigación

- **Lock-in:** El versionado en `path` es un patrón estándar y ampliamente soportado, minimiza lock-in. Algunas herramientas pueden tener implementaciones propietarias, pero el patrón es portable.
- **Mitigación:** Usar convenciones estándar y documentar los contratos de `API` facilita la migración entre plataformas y herramientas.

---

## ✔️ DECISIÓN

Se adopta el versionado en `path` (por ejemplo, `/v1/`) como estrategia estándar para todas las `APIs` públicas y privadas.

## Justificación

- Es la opción más explícita y ampliamente soportada.
- Facilita la coexistencia de múltiples versiones.
- Compatible con herramientas de documentación y `gateways`.
- Sencillo de implementar y mantener.

## Alternativas descartadas

- Header: Menos visible y menos soportado por herramientas, requiere gestión de la versión en el `header` de la petición.
- Query string: Poco común y menos claro, la versión se pasa como parámetro en la `query string`.
- Sin versionado: No permite evolución controlada ni coexistencia de versiones, dificulta la gestión de cambios en los contratos de `API`.

---

## ⚠️ CONSECUENCIAS

- Todas las `APIs` deben exponer la versión en el `path`.
- Se recomienda documentar claramente los cambios entre versiones.

---

## 📚 REFERENCIAS

- [REST API Versioning Best Practices](https://restfulapi.net/versioning/)
- [OpenAPI Specification – Versioning](https://swagger.io/docs/specification/api-host-and-base-path/)
- [ADR-004: API Gateway con YARP](./adr-004-api-gateway-yarp.md)
- [ADR-008: Autenticaciones](./adr-008-autenticaciones.md)
- [Arc42: Decisiones de arquitectura](https://arc42.org/decision/)
