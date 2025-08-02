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

| Criterio                                    | PostgreSQL | MySQL/MariaDB | SQL Server | Oracle |
|---------------------------------------------|------------|--------------|------------|--------|
| Agnosticismo/Portabilidad                   | ✅ Totalmente agnóstico (`open source`, multi-cloud) | ✅ Totalmente agnóstico (`open source`, multi-cloud) | ❌ Dependiente de proveedor (licencia propietaria) | ❌ Dependiente de proveedor (licencia propietaria) |
| Gestión operativa                           | Gestionada por el equipo o proveedor cloud | Gestionada por el equipo o proveedor cloud | Gestionada por proveedor | Gestionada por proveedor |
| Multi-tenant / Multi-país                   | Sí (esquemas, RLS, particionamiento) | Sí (limitado) | Sí (limitado) | Sí (limitado) |
| Alta disponibilidad y replicación           | Sí (nativo, streaming, logical, multi-región) | Sí (nativo, menos flexible) | Sí (AlwaysOn, licencias) | Sí (RAC, DataGuard, licencias) |
| Recuperación ante desastres                 | Avanzada (herramientas OSS y cloud) | Media | Alta (con licencias) | Alta (con licencias) |
| Escalabilidad (horizontal/vertical)         | Alta (sharding, particionamiento, extensiones) | Media | Media | Media |
| Performance OLTP/OLAP                       | Alta (índices, JSONB, extensiones) | Media | Alta (OLTP), Media (OLAP) | Alta (OLTP), Media (OLAP) |
| Latencia                                    | Baja | Baja | Baja | Baja |
| Seguridad/Compliance                        | Alta (RLS, cifrado, auditoría, certificaciones cloud) | Media | Alta | Alta |
| Cumplimiento normativo (GDPR, PCI, etc.)    | Depende de despliegue | Depende de despliegue | Certificaciones enterprise | Certificaciones enterprise |
| Costos totales (licencia, soporte, HA)      | Bajo (`open source`) + operación | Bajo (`open source`) + operación | Alto (licencia, soporte, HA) | Muy alto (licencia, soporte, HA) |
| Licenciamiento                              | OSS | OSS | Propietario | Propietario |
| Extensibilidad/Flexibilidad                 | Muy alta (PostGIS, TimescaleDB, extensiones) | Media | Baja | Media |
| Interoperabilidad y conectores              | Muy alta (drivers, ORMs, cloud, ETL) | Alta | Alta | Alta |
| Automatización y DevOps (migraciones, IaC)  | Alta (herramientas OSS, CI/CD, IaC) | Media | Media | Media |
| Comunidad y soporte                         | Muy alta (global, activa) | Alta | Muy alta (enterprise) | Alta |
| Portabilidad de datos y migración           | Alta (formatos estándar, herramientas) | Media | Baja | Baja |
| Soporte para extensiones avanzadas          | Muy alto (PostGIS, TimescaleDB, Citus, etc.) | Bajo | Bajo | Bajo |
| Trazabilidad/Auditoría                      | Alta (nativo y extensiones) | Media | Alta | Alta |
| Riesgo de lock-in                           | Bajo | Bajo | Alto | Muy alto |

### Comparativa de costos estimados (2025)

| Solución        | Costo mensual base* | Licenciamiento | Infraestructura propia |
|-----------------|---------------------|----------------|-----------------------|
| `PostgreSQL`      | ~US$0 (`open source`) | No             | ~US$20/mes (VM pequeña) opcional |
| `MySQL/MariaDB`   | ~US$0 (`open source`) | No             | ~US$20/mes (VM pequeña) opcional |
| `SQL Server`      | ~US$200/mes         | Sí             | ~US$20/mes (VM pequeña) opcional |
| `Oracle`          | ~US$350/mes         | Sí             | ~US$20/mes (VM pequeña) opcional |

*Precios aproximados, sujetos a variación según proveedor, región y configuración. `SQL Server` y `Oracle` requieren licencias y pueden tener costos adicionales por soporte, alta disponibilidad y backup.

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
