
# 8. Conceptos transversales

> Nota: Las decisiones arquitectónicas clave están documentadas en los [ADRs comunes](../../adrs/README.md).

## 8.1 Seguridad

La seguridad es un pilar fundamental del sistema y afecta a todos los componentes expuestos (APIs, colas, bases de datos). Se implementa mediante:

- **Autenticación OAuth2**: Todos los servicios expuestos requieren tokens JWT válidos, gestionados por un proveedor central (ver ADR-008).
- **Control de acceso basado en roles (RBAC)**: Cada endpoint define permisos explícitos según el rol del usuario o sistema llamante.
- **Rate limiting**: Se aplican límites de peticiones por cliente para prevenir abusos y ataques de denegación de servicio.
- **Cifrado**: Toda la información sensible se cifra en tránsito (TLS) y en reposo (AES-256 en base de datos y backups).

**Ejemplo de tabla de roles y permisos:**

| Rol         | Permisos principales                |
|-------------|-------------------------------------|
| admin       | Gestión total de recursos           |
| operador    | Consulta y operación limitada       |
| sistema     | Acceso técnico a colas/eventos      |
| auditor     | Solo lectura y trazabilidad         |

Estas medidas garantizan la protección de la información y el cumplimiento de normativas, minimizando riesgos de acceso no autorizado o fuga de datos.

## 8.2 Observabilidad

La observabilidad permite monitorear y entender el comportamiento del sistema en tiempo real, abarcando desde APIs hasta procesadores y colas. Se implementa mediante:

- **Logs centralizados**: Todos los servicios envían logs estructurados a un sistema central (ej. ELK, CloudWatch), siguiendo un formato común.
- **Métricas**: Se exponen métricas técnicas y de negocio (ej. latencia, throughput, errores) vía endpoints Prometheus.
- **Alertas**: Se configuran alertas automáticas ante umbrales críticos (ej. caídas, errores, saturación).
- **Trazabilidad**: Cada evento relevante incluye un traceId propagado entre servicios para facilitar el análisis de flujos distribuidos.

**Ejemplo de fragmento de log estructurado:**

```json
{
  "timestamp": "2025-07-31T10:00:00Z",
  "level": "Error",
  "service": "notificacion-api",
  "traceId": "abc123",
  "tenant": "cliente-x",
  "mensaje": "Error al enviar correo",
  "detalle": { "email": "user@dominio.com" }
}
```

Esto facilita la detección proactiva de incidentes, el análisis de causa raíz y la mejora continua de la operación.

## 8.3 Escalabilidad

El sistema está diseñado para escalar horizontalmente, permitiendo manejar incrementos de carga sin degradar el servicio. Los principales mecanismos son:

- **Desacoplamiento**: Uso de colas y procesadores desacoplados para distribuir la carga y evitar cuellos de botella.
- **Fan-out SNS/SQS**: Distribución de eventos a múltiples consumidores de forma eficiente.
- **Particionado y sharding**: División de datos y procesamiento por tenant, país o tipo de evento, permitiendo crecimiento lineal.

Esto asegura capacidad de crecimiento y alta disponibilidad en todos los bloques críticos.

## 8.4 Fiabilidad

La fiabilidad se garantiza mediante estrategias como:

- **Reintentos automáticos**: Ante fallos temporales en APIs o colas, los servicios reintentan operaciones según políticas configurables.
- **DLQ (Dead Letter Queue)**: Los mensajes no procesados tras varios intentos se almacenan en colas especiales para análisis posterior.
- **Backups y replicación multi-AZ**: Los datos críticos se respaldan periódicamente y se replican en varias zonas de disponibilidad para tolerancia a fallos.

Estas prácticas minimizan la pérdida de información y aseguran la continuidad operativa ante incidentes en cualquier componente.

## 8.5 Mantenibilidad

La mantenibilidad se logra mediante:

- **Arquitectura modular y DDD**: Separación clara de dominios y responsabilidades, facilitando la comprensión y evolución.
- **Documentación y pruebas automatizadas**: Cada módulo incluye documentación técnica y pruebas unitarias/integración, lo que reduce el costo de cambios y errores.

Esto permite incorporar nuevas funcionalidades o corregir errores de forma ágil y segura en todos los bloques de construcción.

## 8.6 Multi-tenant

El soporte multi-tenant permite que múltiples clientes o empresas utilicen el sistema de forma aislada y segura. Se implementa mediante:

- **Separación lógica de datos y recursos**: Cada tenant tiene su propio espacio lógico en la base de datos y recursos asociados.
- **Configuración y personalización por tenant**: Permite adaptar reglas, canales y notificaciones a cada cliente.
- **Aislamiento de datos**: Mecanismos técnicos y lógicos previenen accesos cruzados entre tenants.

Esto garantiza privacidad, personalización y cumplimiento de acuerdos contractuales.

## 8.7 Multipaís

El sistema está preparado para operar en múltiples países, adaptándose a normativas, idiomas, formatos y requisitos legales locales. Se implementa mediante:

- **Localización y formatos regionales**: Soporte de idiomas, monedas, zonas horarias y formatos de fecha/hora.
- **Configuración de canales y reglas por país**: Permite definir lógicas y flujos específicos según la región.
- **Cumplimiento legal**: Adaptación a regulaciones locales (protección de datos, retención, notificaciones legales).

Esto asegura cumplimiento regulatorio y una experiencia adecuada para cada región donde opera el sistema.
