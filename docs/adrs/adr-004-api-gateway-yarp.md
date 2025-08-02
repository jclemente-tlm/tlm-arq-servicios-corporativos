# ADR-004: API Gateway con [YARP](https://microsoft.github.io/reverse-proxy/)

## ✅ ESTADO

Aceptada – Julio 2025

---

## 🗺️ CONTEXTO

Se requiere una solución flexible y extensible para exponer `APIs` de `microservicios`, soportando enrutamiento dinámico, autenticación y balanceo de carga en sistemas distribuidos.

Las alternativas evaluadas fueron:

- **[YARP (Yet Another Reverse Proxy)](https://microsoft.github.io/reverse-proxy/)**
- **[AWS API Gateway](https://aws.amazon.com/api-gateway/)**
- **[NGINX](https://www.nginx.com/)/[Traefik](https://traefik.io/)**
- **[Ocelot](https://ocelot.readthedocs.io/en/latest/)**
- **[Kong](https://konghq.com/)**
- **[KrakenD](https://www.krakend.io/)**

### Comparativa de alternativas

| Criterio                | YARP (.NET)        | AWS API Gateway   | NGINX/Traefik    | Ocelot | Kong | KrakenD |
|------------------------|--------------------|-------------------|------------------|--------|------|---------|
| Agnosticismo           | ✅ Totalmente agnóstico (`open source`, multi-cloud) | ❌ Dependiente de proveedor (`AWS`) | ✅ Totalmente agnóstico (`open source`, multi-cloud) | ✅ Totalmente agnóstico (`open source`, multi-cloud) | ✅ Totalmente agnóstico (`open source`, multi-cloud) | ✅ Totalmente agnóstico (`open source`, multi-cloud) |
| Gestión operativa      | Gestionada por el equipo     | Gestionada por proveedor        | Gestionada por el equipo   | Gestionada por el equipo | Gestionada por el equipo | Gestionada por el equipo |
| Multi-tenant / Multi-país | Sí | Sí | Sí | Sí | Sí | Sí |
| Alta disponibilidad    | Requiere configuración | Garantizada      | Requiere configuración | Requiere configuración | Requiere configuración | Requiere configuración |
| Escalabilidad          | Alta               | Alta             | Alta             | Media | Alta | Alta |
| Latencia               | Baja               | Baja             | Baja             | Media | Baja | Baja |
| Seguridad/Compliance   | OAuth2/JWT, personalizable | IAM, OAuth2, JWT | SSL, plugins     | Media | Alta | Alta |
| Costos                 | Bajo (infra propia) | Alto (pago por uso) | Bajo (infra propia) | Bajo (infra propia) | Bajo (infra propia) | Bajo (infra propia) |
| Licenciamiento         | OSS                | Incluido en AWS   | OSS              | OSS | OSS | OSS |
| Extensibilidad/Flexibilidad | Alta           | Media             | Alta             | Media | Alta | Alta |
| Interoperabilidad      | Nativa con .NET    | APIs estándar     | APIs estándar     | Media | Alta | Alta |
| Trazabilidad/Auditoría | Integrable         | Integrada         | Integrable        | Media | Alta | Alta |

### Comparativa de costos estimados (2025)

| Solución        | Costo mensual base* | Costos adicionales | Infraestructura propia |
|-----------------|---------------------|--------------------|-----------------------|
| YARP (.NET)     | ~US$10 (VM/container pequeña) | Mantenimiento, soporte | Sí                    |
| AWS API Gateway | ~US$3.50/millón de llamadas | Pago por uso, integración | No                    |
| NGINX/Traefik   | ~US$10 (VM/container pequeña) | Mantenimiento, soporte | Sí                    |

*Precios aproximados, sujetos a variación según región, volumen y configuración. `AWS API Gateway` puede escalar costos rápidamente según tráfico.

### Agnosticismo, lock-in y mitigación

- **Lock-in:** `AWS API Gateway` implica dependencia de `AWS`, mientras que `YARP`, `NGINX`, `Ocelot`, `Kong` y `KrakenD` pueden desplegarse en cualquier infraestructura.
- **Mitigación:** El uso de proxies y gateways `open source` permite migrar entre nubes y `on-premises`, aunque requiere esfuerzo de integración y operación.

---

## ✔️ DECISIÓN

Se utilizará **[YARP (Yet Another Reverse Proxy)](https://microsoft.github.io/reverse-proxy/)** como `API Gateway` para los `microservicios` `.NET`, desplegado en `AWS ECS Fargate`, asegurando soporte para escenarios `multi-tenant` y `multi-país` mediante enrutamiento, autenticación y políticas segmentadas.

## Justificación

- Permite personalización avanzada de rutas y políticas, incluyendo segmentación por tenant y país.
- Facilita la integración con autenticación `OAuth2` y `JWT`, soportando control de acceso `multi-tenant`/`multi-país`.
- Simplifica el despliegue y mantenimiento.
- Integración nativa con `.NET` y ecosistema `C#`.
- Flexibilidad para definir reglas de enrutamiento, balanceo y autenticación personalizada.
- Despliegue sencillo en contenedores y compatibilidad con `ECS Fargate`.
- Menor costo operativo comparado con soluciones gestionadas (`AWS API Gateway`).
- Extensible y personalizable para necesidades futuras y requisitos de segmentación regional o de clientes.

## Alternativas descartadas

- **AWS API Gateway**: Solución gestionada, pero con mayor costo y menor flexibilidad para lógica personalizada.
- **NGINX/Traefik**: Requiere mayor esfuerzo de integración y personalización en entornos `.NET`, y aunque es robusto, no ofrece integración nativa con `C#`.
- **Ocelot**: Aunque es una buena opción para `.NET`, no ofrece tantas características avanzadas como `YARP`.
- **Kong**: Ofrece muchas funcionalidades, pero la versión Enterprise tiene un costo elevado y la versión OSS requiere más configuración.
- **KrakenD**: Gateway potente y flexible, pero requiere mayor configuración y no tiene integración nativa con `.NET`; su comunidad y soporte empresarial son menores comparados con Kong.

---

## ⚠️ CONSECUENCIAS

- El tráfico de entrada se canaliza y controla desde `YARP`.
- La seguridad y el monitoreo se centralizan en el gateway.

---

## 📚 REFERENCIAS

- [YARP](https://microsoft.github.io/reverse-proxy/)
- [AWS API Gateway](https://docs.aws.amazon.com/apigateway/latest/developerguide/welcome.html)
- [NGINX](https://www.nginx.com/resources/wiki/)
- [Traefik](https://doc.traefik.io/traefik/)
- [Ocelot](https://ocelot.readthedocs.io/en/latest/)
- [Kong](https://docs.konghq.com/)
- [KrakenD](https://www.krakend.io/docs/)
- [Arc42: Decisiones de arquitectura](https://arc42.org/decision/)
