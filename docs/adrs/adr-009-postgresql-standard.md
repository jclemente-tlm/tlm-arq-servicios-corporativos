# ADR-009: Uso de [PostgreSQL](https://www.postgresql.org/) como base de datos estándar

## ✅ ESTADO

Aceptada – Julio 2025

---

## 🗺️ CONTEXTO

Se requiere una base de datos relacional robusta, escalable y de código abierto para los servicios corporativos, que soporte operaciones `multi-tenant`, replicación y alta disponibilidad.

Las alternativas evaluadas fueron:

- [PostgreSQL](https://www.postgresql.org/)
- [MySQL/MariaDB](https://mariadb.org/)
- [SQL Server](https://www.microsoft.com/en-us/sql-server)
- [Oracle](https://www.oracle.com/database/)

### Comparativa de alternativas

| Criterio                | PostgreSQL | MySQL/MariaDB | SQL Server | Oracle |
|------------------------|------------|--------------|------------|--------|
| Agnosticismo           | Alto (`open source`, `multi-cloud`) | Alto (`open source`, `multi-cloud`) | Bajo (licencia propietaria) | Bajo (licencia propietaria) |
| Licenciamiento         | Libre      | Libre        | Pago       | Pago   |
| Soporte cloud          | Excelente  | Excelente    | Bueno      | Bueno  |
| JSON/NoSQL             | Avanzado   | Limitado     | Limitado   | Limitado|
| Extensibilidad         | Alta       | Media        | Baja       | Baja   |
| Comunidad              | Muy alta   | Alta         | Media      | Media  |
| HA/Replicación         | Sí         | Sí           | Sí         | Sí     |

### Comparativa de costos estimados (2025)

| Solución        | Costo mensual base* | Licenciamiento | Infraestructura propia |
|-----------------|---------------------|----------------|-----------------------|
| `PostgreSQL`      | ~US$0 (`open source`) | No             | ~US$20/mes (VM pequeña) opcional |
| `MySQL/MariaDB`   | ~US$0 (`open source`) | No             | ~US$20/mes (VM pequeña) opcional |
| `SQL Server`      | ~US$200/mes         | Sí             | ~US$20/mes (VM pequeña) opcional |
| `Oracle`          | ~US$350/mes         | Sí             | ~US$20/mes (VM pequeña) opcional |

*Precios aproximados, sujetos a variación según proveedor, región y configuración. `SQL Server` y `Oracle` requieren licencias y pueden tener costos adicionales por soporte y HA.

### Agnosticismo, lock-in y mitigación

- **Lock-in:** `PostgreSQL` es `open source`, ampliamente soportado y portable entre proveedores cloud y `on-premises`, minimizando lock-in. Permite migración entre nubes y despliegue híbrido.
- **Mitigación:** Usar `SQL` estándar, evitar extensiones propietarias y mantener automatización de migraciones facilita la portabilidad y reduce riesgos de dependencia.

---

## ✔️ DECISIÓN

Se adopta [PostgreSQL](https://www.postgresql.org/) como base de datos relacional estándar para todos los servicios y `microservicios` corporativos.

## Justificación

- `Open source`, sin costos de licenciamiento.
- Soporte avanzado para `JSON`, índices, particionamiento y extensiones.
- Disponible en todos los principales proveedores cloud.
- Comunidad activa y abundante documentación.
- Replicación, alta disponibilidad y escalabilidad horizontal.
- Integración con herramientas de CI/CD y migraciones.
- Permite escenarios `multi-tenant` y `multi-país` mediante:
  - Esquemas por tenant (aislamiento lógico).
  - Row-Level Security (RLS) para control de acceso por tenant.
  - Particionamiento de tablas por tenant o país.
  - Flexibilidad para elegir el modelo `multi-tenant` según el caso de uso.

## Alternativas descartadas

- MySQL/MariaDB: Menor soporte para JSON y extensiones avanzadas.
- SQL Server/Oracle: Costos de licenciamiento y menor flexibilidad para modelos multi-tenant.

---

## ⚠️ CONSECUENCIAS

- Todos los servicios nuevos deben usar PostgreSQL salvo justificación técnica documentada.
- Se debe estandarizar la gestión de migraciones y backups.

---

## 📚 REFERENCIAS

- [PostgreSQL Docs](https://www.postgresql.org/docs/)
- [AWS RDS PostgreSQL](https://aws.amazon.com/rds/postgresql/)
- [Comparativa DB Engines](https://db-engines.com/en/ranking)
- [Arc42: Decisiones de arquitectura](https://arc42.org/decision/)
