---
title: Instrucciones Mejoradas para GitHub Copilot
---

# Instrucciones para GitHub Copilot en este proyecto

## Tabla de Contenido

1. Contexto General
2. Tecnologías y Prácticas Obligatorias
3. Identidad y Seguridad
4. Observabilidad y Monitoreo
5. Modelo Arquitectónico y DSL
6. Decisiones Arquitectónicas (ADRs)
7. Documentación de Servicios
8. Estilo y Guía de Redacción
9. Errores Comunes a Evitar
10. Preguntas Frecuentes (FAQ)

---

## 1. Contexto General

Proyecto en **C# con .NET 8**, arquitectura **Clean Architecture** y modelo **C4** (Structurizr DSL). Documentación generada con **Docusaurus** y plantilla **arc42**. Servicios corporativos multipaís (Perú, Ecuador, Colombia, México). Prioridad: simplicidad, escalabilidad y claridad técnica.

> **Nota:** Toda la documentación debe ser compatible y optimizada para su visualización en **Docusaurus**. Considerar los requisitos de formato, metadatos y estructura que exige Docusaurus al crear o editar cualquier archivo de documentación.

---

## 2. Tecnologías y Prácticas Obligatorias

A continuación se listan las tecnologías obligatorias que deben usarse en todo el código de ejemplo, implementación y documentación generada para este proyecto:

| Categoría        | Tecnología                 | Propósito principal                                                                                       |
| ---------------- | -------------------------- | --------------------------------------------------------------------------------------------------------- |
| Arquitectura     | Clean Architecture         | Estructura de capas, separación de responsabilidades                                                      |
| Arquitectura     | DDD (Domain-Driven Design) | Modelado de dominio complejo y reglas de negocio                                                          |
| Lenguaje         | C# (.NET 8)                | Desarrollo principal de servicios y lógica de negocio                                                     |
| Validación       | FluentValidation           | Validación de datos y reglas de negocio                                                                   |
| Mapeo de objetos | Mapster                    | Conversión entre DTOs, entidades y modelos (se evita AutoMapper por ser de pago)                          |
| ORM              | Entity Framework Core      | Acceso y persistencia de datos relacional                                                                 |
| CQRS             | CQRS (sin MediatR)         | Separación de comandos y queries directamente en la capa de aplicación (se evita MediatR por ser de pago) |
| Autenticación    | Keycloak                   | Gestión de identidad y autorización                                                                       |
| Observabilidad   | Prometheus                 | Métricas de servicios                                                                                     |
| Observabilidad   | Grafana                    | Visualización de métricas                                                                                 |
| Observabilidad   | Loki                       | Gestión centralizada de logs                                                                              |
| Observabilidad   | Serilog                    | Logs estructurados                                                                                        |
| Observabilidad   | OpenTelemetry              | Trazas distribuidas y exportación de logs/trazas                                                          |
| Observabilidad   | Jaeger                     | Visualización de trazas distribuidas                                                                      |

> **Nota:** Todo ejemplo de código, fragmento o referencia debe utilizar exclusivamente estas tecnologías y patrones. Para CQRS, se permite la implementación directa en la capa de aplicación siguiendo Clean Architecture, sin requerir MediatR. No se permite el uso de alternativas salvo que exista un ADR aprobado que lo justifique. Tecnologías como MediatR y AutoMapper quedan explícitamente excluidas por ser de pago.

- **Arquitectura:** Clean Architecture, DDD
- **Validación:** FluentValidation
- **Mapeo de objetos:** Mapster (no AutoMapper)
- **ORM:** Entity Framework Core (no Dapper)
- **CQRS:** Separación de comandos y queries directamente en la capa de aplicación (sin MediatR)
- **Separación de capas:** dominio, aplicación, infraestructura, presentación
- **Observabilidad:** Prometheus, Grafana, Loki (Serilog/OpenTelemetry), Jaeger (OpenTelemetry)
- **Instrumentación obligatoria** en cada nuevo servicio

---

## 3. Identidad y Seguridad

- Autenticación/autorización con **Keycloak**
- Validar JWTs emitidos por Keycloak
- Interpretar claims y roles correctamente
- Prohibido implementar lógica de autenticación personalizada
- En la empresa se maneja el concepto de `tenant` (o `tenants`), mientras que la herramienta Keycloak utiliza el término `realm` (o `realms`) para referirse a lo mismo. En la documentación y el código se debe emplear la notación `tenant (realm)` o `tenants (realms)` para mantener claridad y consistencia entre el lenguaje corporativo y la terminología de la herramienta.

---

## 4. Observabilidad y Monitoreo

| Función       | Tecnología                   |
| ------------- | ---------------------------- |
| Métricas      | Prometheus                   |
| Visualización | Grafana                      |
| Logs          | Loki (Serilog/OpenTelemetry) |
| Trazas        | Jaeger (OpenTelemetry)       |

- Logs estructurados con Serilog
- Métricas expuestas con Prometheus
- Trazas distribuidas con OpenTelemetry y Jaeger

---

## 5. Modelo Arquitectónico y DSL

- Modelo **C4** en `/design` con Structurizr DSL
- Los archivos DSL son la fuente de verdad
- No modificar archivos DSL, solo referenciar
- Usar los nombres definidos en DSL para describir contenedores/componentes
- Ejemplo de referencia:
  “Ver definición de contenedor en `/design/servicio-x.dsl`”

---

## 6. Decisiones Arquitectónicas (ADRs)

- Documentadas en `/docs/adrs`
- Formato estándar Markdown: título, estado, contexto, decisión, consecuencias
- Identificador único: ADR-001, ADR-002, etc.
- Enlazar a diagramas o documentos relevantes
- Antes de proponer cambios, revisar ADRs existentes
- Si se propone algo nuevo, sugerir crear un ADR

---

## 7. Documentación de Servicios

- Cada servicio documentado en `/docs/<servicio>/` siguiendo arc42:

  - 01-introduccion-objetivos.md
  - 02-restricciones-arquitectura.md
  - 03-contexto-alcance.md
  - 04-estrategia-solucion.md
  - 05-vista-bloques-construccion.md
  - 06-vista-tiempo-ejecucion.md
  - 07-vista-implementacion.md
  - 08-conceptos-transversales.md
  - 09-decisiones-arquitectura.md
  - 10-requisitos-calidad.md
  - 11-riesgos-deuda-tecnica.md
  - 12-glosario.md

- Los archivos DSL ubicados en `/design` y los ADRs globales en `/docs/adrs` son las únicas fuentes de verdad para la arquitectura y decisiones del sistema. Toda documentación, propuesta o ejemplo debe alinearse estrictamente a lo definido en estos archivos.
- No se debe contradecir, reinterpretar ni ignorar lo establecido en los DSL y ADRs. Si se requiere un cambio, debe actualizarse primero la fuente de verdad correspondiente.
- No incluir frases como “según el DSL” o “de acuerdo al ADR” ni indicar explícitamente de dónde se obtuvo la información; la documentación debe ser profesional, directa y sin justificaciones innecesarias.
- Evitar sobrejustificación, sobreinformación o explicaciones innecesarias sobre el origen de los datos o decisiones (por ejemplo, no mencionar fuentes de verdad al inicio de cada documento).
- Evitar repeticiones, información duplicada y lenguaje superfluo.
- Referenciar ADRs y DSL cuando corresponda.
- Revisar los archivos completos antes de finalizar para validar que estén completos y evitar dejar archivos con contenido corrupto o incompleto.

---

## 8. Estilo y Guía de Redacción

- Voz activa, español neutro
- Sin jerga técnica innecesaria ni adornos
- No usar pronombres personales (yo, tú, nosotros)
- Títulos y encabezados en Pascal Case
- Toda la documentación debe estar redactada en español neutro. El uso de inglés solo está permitido para terminología técnica, nombres propios de tecnologías, conceptos ampliamente reconocidos o fragmentos de código.
- Siempre que sea posible, se recomienda organizar la información en tablas para mayor claridad y orden, siguiendo la sugerencia de la plantilla **arc42**.
- Todo fragmento de código, comando, configuración o ejemplo técnico debe ir siempre en bloques de código (backticks triples ```), especificando el lenguaje si corresponde. Para código corto o referencias en línea, usar backticks simples (`codigo`).
  Ejemplo:

  ```csharp
  public class ServicioEjemplo {
      // Comentario claro y directo
  }
  ```

  Ejemplo en línea: `var resultado = servicio.Calcular();`

- Es válido resaltar tecnologías, términos clave o nombres de archivos usando backticks simples (`tecnología`), negritas o enlaces directos a la documentación oficial cuando aporte claridad o valor.
  Ejemplo: Utilizar `Keycloak` para autenticación o consultar [Documentación oficial de Mapster](https://github.com/MapsterMapper/Mapster).

- Diagramas de flujo, secuencia o arquitectura deben realizarse usando **Mermaid** en bloques de código con el tipo `mermaid`.
  Ejemplo:

  ```mermaid
  sequenceDiagram
      participant Usuario
      participant API
      participant ServicioInterno

      Usuario->>API: Solicita recurso
      API->>ServicioInterno: Procesa solicitud
      ServicioInterno-->>API: Respuesta
      API-->>Usuario: Resultado
  ```

---

## 9. Errores Comunes a Evitar

- Repetir información ya definida en ADRs o DSL
- Modificar archivos DSL
- Usar tecnologías no aprobadas sin ADR
- Redactar en primera persona
- Omitir instrumentación de observabilidad

---

## 10. Preguntas Frecuentes (FAQ)

**¿Cómo referencio un ADR?**
Incluye el identificador y, si es posible, un enlace:
“Ver ADR-001 para detalles de Clean Architecture.”

**¿Puedo proponer una nueva tecnología?**
Solo si sugieres crear un ADR y justificas la necesidad.

**¿Qué hago si hay conflicto entre DSL y ADR?**
Prioriza el DSL como fuente de verdad para arquitectura.

---
