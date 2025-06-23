# Proyecto de Arquitectura de Soluciones

Este proyecto contiene diagramas y recursos para la arquitectura de soluciones corporativas.

## Estructura

- **design/**: Contiene archivos DSL y recursos para los diagramas de arquitectura.
  - **common/**: Recursos comunes como iconos, estilos y logos.
  - **servicios-corporativos.dsl**: Archivo principal que define la arquitectura de servicios corporativos.

## Uso

Los archivos DSL en la carpeta `design` son utilizados para generar diagramas de arquitectura utilizando Structurizr Lite.

### Instrucciones de Uso

1. **Ejecución del Proyecto**:
   - Utiliza el script `start.sh` para iniciar Structurizr Lite. Asegúrate de proporcionar el nombre del archivo DSL como argumento:
     ```bash
     ./start.sh servicios-corporativos.dsl
     ```

2. **Acceso a Structurizr Lite**:
   - Abre tu navegador y ve a `http://localhost:8090` para acceder a la interfaz de Structurizr Lite.

## Mantenimiento

Asegúrate de mantener la estructura de carpetas y actualizar las referencias en los archivos DSL cuando se realicen cambios en los recursos.