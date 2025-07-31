# 5. Vista de bloques de construcción

- Diagrama de bloques disponible en `/diagrams/api-gateway-blocks.png`.

| Componente | Responsabilidad | Interfaces |
|------------|----------------|------------|
| YARP Proxy | Enrutamiento y balanceo | HTTP, HTTPS |
| Seguridad | Autenticación y autorización | OAuth2, JWT |
| Logging | Auditoría y monitoreo | Serilog, CloudWatch |
| Configuración | Multi-tenant/multipaís | Docker, IaC |
