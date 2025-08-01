# 7. Vista de implementación

## 7.1 Estructura de carpetas

```text
servicio-notificacion/
├── src/
│   ├── Api/
│   ├── Application/
│   ├── Domain/
│   ├── Infrastructure/
│   └── Worker/
├── tests/
│   ├── Api.Tests/
│   └── Worker.Tests/
├── docker/
└── README.md
```

## 7.2 Consideraciones de despliegue

- Despliegue en <span style="color:#1976d2"><b>AWS</b></span> usando <b>Docker</b> y <b>docker-compose</b>
- Uso de <b>pipelines CI/CD</b> para automatización
- Variables sensibles gestionadas por <code>secrets</code> y <code>Parameter Store</code>
- Versionado semántico (`semver`)
- Integración con <b>monitorización</b> y <b>logging centralizado</b>
