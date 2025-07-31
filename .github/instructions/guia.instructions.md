---
applyTo: "**"
---

# ✅ Contexto general del proyecto

Este sistema implementa servicios corporativos distribuidos, multi-tenant y multi-país, desplegados en AWS, usando una arquitectura basada en microservicios y documentada con Arc42 y Structurizr DSL (modelo C4).
Las configuraciones son gestionadas por scripts, no APIs. La autenticación se realiza vía OAuth2 con JWT (`client_credentials`) y configuraciones específicas por aplicación y tenant.

# 📦 Stack técnico

- Lenguaje principal: C# (.NET 8)
- ORM: Entity Framework Core
- Validaciones: FluentValidation
- Logging estructurado: Serilog
- Mapeo de DTOs: Mapster
- Base de datos: PostgreSQL
- Contenedores: Docker + docker-compose
- Testing: xUnit
- Análisis de código: SonarQube
- Seguridad IaC: Checkov
- Arquitectura: Clean Architecture
- Documentación: Arc42 + Structurizr DSL
- Diagramación: Modelo C4 (Contexto, Contenedores, Componentes, Código)

# 📘 Reglas para generación de documentación con Copilot

## ➤ Para contenido de Structurizr DSL

- Utiliza archivos DSL organizados modularmente con `!include`.
- Define los niveles del modelo C4: Contexto, Contenedores, Componentes y Código.
- Usa `servicios-corporativos.dsl` como archivo raíz.
- Usa vistas consistentes con la estructura del sistema real.
- Utiliza etiquetas (`tags`) para reflejar tecnologías (por ejemplo: "PostgreSQL", "ASP.NET Core", "Lambda", "Kafka").
- Sigue buenas prácticas de diseño visual: orden lógico, separación de responsabilidades, nombres autoexplicativos.
- Incluye documentación inline cuando sea necesario (uso de `description`).
- Usa íconos personalizados desde carpetas como `/common/icons`.

## ➤ Para contenido de documentación Arc42

Cuando se generen secciones de la documentación:

- Sigue la estructura oficial de Arc42:

1.  Introducción y objetivos
2.  Restricciones de la arquitectura
3.  Contexto y alcance
4.  Estrategia de solución
5.  Vista de bloques de construcción
6.  Vista de tiempo de ejecución
7.  Vista de implementación
8.  Conceptos transversales
9.  Decisiones de arquitectura
10. Requisitos de calidad
11. Riesgos y deuda técnica
12. Glosario

- Para cada sección, usar estilo claro, estructurado y técnico.
- Referenciar vistas C4 generadas con Structurizr DSL.
- Evitar jerga innecesaria o repeticiones.
- Usar tablas o listas cuando sea útil para claridad.
- Documentar decisiones clave usando formato ADR si aplica.

## ➤ Para diagramas en Structurizr

Ejemplos que Copilot puede generar:

- Diagrama de contexto con actores como usuarios, sistemas externos (ERP, CRM).
- Diagrama de contenedores con API en .NET, base de datos PostgreSQL, conectores Kafka.
- Diagrama de componentes para los microservicios (controladores, servicios, repositorios).
- Diagrama de despliegue con AWS (EC2, RDS, Lambda, etc.).

# ✏️ Contribuciones esperadas de Copilot

- Sugerencias para archivos Structurizr DSL (`.dsl`) coherentes con Arc42 y C4.
- Generación de contenido técnico para cada sección de Arc42 (en español).
- Sugerencia de nombres, tags y descripciones para vistas C4.
- Generación de scripts de automatización para exportar diagramas (`puppeteer`, `structurizr-cli`).
- Fragmentos de documentación Markdown para adjuntar a los entregables de arquitectura.
- Plantillas para documentación de decisiones arquitectónicas (ADR).
- Ayuda para integrar la generación de documentación en pipelines CI/CD.
