# 2. Restricciones de la arquitectura

- **Lenguaje principal:** <span style="color:#1976d2"><b>C# (.NET 8)</b></span>
- **Base de datos:** <span style="color:#388e3c"><b>PostgreSQL</b></span>
- **Contenedores:** <span style="color:#ff9800"><b>Docker</b></span> + <span style="color:#ff9800"><b>docker-compose</b></span>
- **ORM:** <span style="color:#512da8"><b>Entity Framework Core</b></span>
- **Validaciones:** <span style="color:#c2185b"><b>FluentValidation</b></span>
- **Logging:** <span style="color:#607d8b"><b>Serilog</b></span>
- **Mapeo DTOs:** <span style="color:#0288d1"><b>Mapster</b></span>
- **Testing:** <span style="color:#0097a7"><b>xUnit</b></span>
- **Análisis de código:** <span style="color:#d32f2f"><b>SonarQube</b></span>
- **Seguridad IaC:** <span style="color:#388e3c"><b>Checkov</b></span>
- **Arquitectura:** <span style="color:#1976d2"><b>Clean Architecture</b></span>
- **Documentación:** <span style="color:#0288d1"><b>Arc42</b></span> + <span style="color:#0288d1"><b>Structurizr DSL</b></span>
- **Diagramación:** <span style="color:#0288d1"><b>Modelo C4</b></span>

> <span style="color:#d32f2f"><b>Nota:</b></span> Todas las configuraciones se gestionan por <code>scripts</code>, no por API. La autenticación es vía <code>OAuth2</code> con <code>JWT</code> (`client_credentials`).

## Restricciones técnicas

- Uso obligatorio de <b>contenedores</b> para todos los servicios.
- <b>Multi-tenant</b> y <b>multi-país</b> como requerimiento transversal.
- Cumplimiento de normativas locales de privacidad y mensajería.
- Integración con sistemas externos vía <code>API REST</code> y <code>Kafka</code>.
- Despliegue en <b>AWS</b> (EC2, RDS, Lambda, S3, etc.).
