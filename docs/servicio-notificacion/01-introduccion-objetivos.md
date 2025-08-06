# 1. Introducción y objetivos

El **Sistema de Notificaciones** es una plataforma distribuida multi-tenant y multi-país diseñada para el envío de mensajes por múltiples canales de comunicación. Forma parte de la arquitectura de servicios corporativos de Talma, operando en Perú, Ecuador, Colombia y México, y proporciona capacidades empresariales para notificaciones transaccionales, promocionales y de alerta con garantías de entrega y observabilidad completa.

## 1.1 Descripción general de los requisitos

### Propósito del Sistema

El sistema permite a las aplicaciones corporativas enviar notificaciones a usuarios finales a través de múltiples canales (Email, SMS, WhatsApp, Push, In-App) de manera agnóstica al proveedor, con soporte nativo para multi-tenancy y configuraciones específicas por país.

### Capacidades Principales

**Gestión de Notificaciones:**

- Recepción de solicitudes de notificación vía API REST
- Procesamiento asíncrono con garantías de entrega
- Soporte para scheduling y notificaciones diferidas
- Sistema de templates con internacionalización

**Multi-canal y Multi-tenant:**

- Envío por Email, SMS, WhatsApp, Push Notifications e In-App
- Aislamiento completo por tenant/país
- Configuraciones específicas por canal y región
- Preferencias de usuario personalizables

**Observabilidad y Confiabilidad:**

- Tracking completo del ciclo de vida
- Métricas de entrega en tiempo real
- Sistema de reintentos inteligentes
- Dead letter queue para fallos persistentes

### Requisitos Funcionales Principales

| ID | Requisito | Descripción |
|----|-----------|-----------------------|
| **RF-NOT-01** | **Envío Multicanal** | Soporte para Email, SMS, WhatsApp, Notificaciones Push e In-App |
| **RF-NOT-02** | **Plantillas Dinámicas** | Motor de plantillas Liquid con datos variables e internacionalización |
| **RF-NOT-03** | **Programación de Envíos** | Programación de notificaciones para envío futuro con soporte de zona horaria |
| **RF-NOT-04** | **Gestión de Adjuntos** | Carga, almacenamiento y entrega de archivos adjuntos via S3 |
| **RF-NOT-05** | **Preferencias de Usuario** | Opt-in/opt-out, horarios permitidos, límites de frecuencia |
| **RF-NOT-06** | **Reintentos Inteligentes** | Backoff exponencial con cola de mensajes fallidos para fallos persistentes |
| **RF-NOT-07** | **Aislamiento Multi-tenant** | Completa separación de datos y configuración por tenant/país |
| **RF-NOT-08** | **Trazabilidad de Auditoría** | Seguimiento completo del ciclo de vida de notificaciones |
| **RF-NOT-09** | **Control de Velocidad** | Limitación de velocidad de envío por canal y tipo de notificación |
| **RF-NOT-10** | **Integración Webhook** | Callbacks para estado de entrega y eventos del sistema |

### Requisitos No Funcionales

| Categoría | Requisito | Target | Medición |
|-----------|-----------|--------|----------|
| **Rendimiento** | Capacidad de procesamiento | 50,000 notificaciones/min | Pruebas de carga continuas |
| **Rendimiento** | Latencia de API | p95 < 200ms | Monitoreo APM |
| **Disponibilidad** | Tiempo de actividad del sistema | 99.9% | Monitoreo SLA |
| **Escalabilidad** | Escalado automático | Escalado horizontal en 2 min | Métricas de contenedores |
| **Confiabilidad** | Tasa de entrega | 99.9% entrega exitosa | Métricas empresariales |
| **Seguridad** | Cifrado de datos | AES-256 en reposo, TLS en tránsito | Auditorías de seguridad |

### Tipos de Notificaciones

| Tipo | Descripción | Canales Soportados | Prioridad | SLA |
|------|-------------|-------------------|-----------|-----|
| **Transaccional** | Confirmaciones, recibos, alertas críticas | Todos | Alta | < 30 segundos |
| **Promocional** | Marketing, ofertas, newsletters | Email, SMS, WhatsApp | Media | < 5 minutos |
| **Operacional** | Status updates, mantenimientos | Email, In-App, Push | Media | < 2 minutos |
| **Emergencia** | Alertas críticas, evacuaciones | Todos | Crítica | < 10 segundos |

## 1.2 Objetivos de calidad

### Objetivos Primarios

| Prioridad | Objetivo | Escenario | Métrica Objetivo |
|-----------|----------|-----------|------------------|
| **1** | **Confiabilidad** | Garantizar entrega de notificaciones críticas | 99.9% tasa de entrega |
| **2** | **Escalabilidad** | Manejar picos de tráfico sin degradación | Soporte 10x carga actual |
| **3** | **Rendimiento** | Respuesta rápida para APIs síncronas | p95 < 200ms respuesta API |

### Objetivos Secundarios

| Objetivo | Descripción | Métrica |
|----------|-------------|---------|
| **Observabilidad** | Visibilidad completa del pipeline de notificaciones | 100% requests trazados |
| **Flexibilidad** | Fácil adición de nuevos canales y proveedores | < 1 día integración |
| **Eficiencia de Costo** | Optimización de costos de proveedores externos | < $0.05 por notificación |
| **Cumplimiento** | Cumplimiento GDPR, CAN-SPAM, regulaciones locales | Cero violaciones de cumplimiento |

## 1.3 Partes interesadas

### Stakeholders Principales

| Rol | Contacto | Responsabilidades | Expectativas |
|-----|----------|-------------------|--------------|
| **Product Owner** | Business Team | Definición de funcionalidades, roadmap | Funcionalidades entregadas a tiempo, satisfacción del usuario |
| **Arquitecto de Software** | jclemente-tlm | Decisiones técnicas, patrones, ADRs | Diseño escalable, arquitectura mantenible |
| **Equipo de Desarrollo** | Dev Team | Implementación, testing, debugging | Requisitos claros, documentación técnica |
| **DevOps/SRE** | SRE Team | Despliegue, monitoreo, respuesta a incidentes | Despliegues confiables, alertas accionables |
| **Equipo de Seguridad** | Equipo de Seguridad | Cumplimiento, auditoría, evaluación de vulnerabilidades | Seguridad por diseño, rastros de auditoría |

### Stakeholders Secundarios

| Rol | Contacto | Interés | Comunicación |
|-----|----------|---------|--------------|
| **Equipos de Marketing** | Departamentos de Marketing | Campañas promocionales, segmentación | Documentación de API, mejores prácticas |
| **Soporte al Cliente** | Equipos de Soporte | Resolución de problemas de entrega | Runbooks operacionales, dashboards |
| **Legal/Cumplimiento** | Equipo Legal | Cumplimiento regulatorio, privacidad de datos | Reportes de cumplimiento, trazas de auditoría |
| **Finanzas** | Equipo de Finanzas | Control de costos, planificación presupuestaria | Reportes de costos, métricas de optimización |
| **Proveedores Externos** | Proveedores Email/SMS/WhatsApp | Integración, SLAs, facturación | Especificaciones técnicas, monitoreo de SLA |

### Usuarios Finales

| Tipo de Usuario | Descripción | Herramientas | Expectativas |
|-----------------|-------------|--------------|--------------|
| **Desarrolladores API** | Integran con Notification API | Clientes REST, SDKs | Integración simple, documentación completa |
| **Usuarios de Marketing** | Configuran campañas promocionales | Interfaz de administración, dashboards | Configuración fácil de campañas, insights de entrega |
| **Equipos Operacionales** | Monitorean sistema de notificaciones | Grafana, alertas | Visibilidad en tiempo real, alertas accionables |
| **Destinatarios Finales** | Reciben notificaciones en dispositivos | Clientes de email, aplicaciones móviles | Entrega oportuna, gestión de preferencias |

### Matriz de Comunicación

| Stakeholder | Frecuencia | Canal | Contenido |
|-------------|------------|-------|-----------|
| **Product Owner** | Semanal | Revisiones de sprint, Jira | Funcionalidades completadas, bloqueos, próximas prioridades |
| **Arquitecto** | Bi-semanal | Revisiones de ADR, charlas técnicas | Decisiones de arquitectura, deuda técnica |
| **DevOps** | Diario | Dashboards, alertas Slack | Salud del sistema, métricas de rendimiento |
| **Seguridad** | Mensual | Reportes de seguridad | Evaluaciones de vulnerabilidades, estado de cumplimiento |
| **Legal** | Trimestral | Reportes de cumplimiento | Cumplimiento GDPR, hallazgos de auditoría |

## 1.4 Resumen Ejecutivo

El Sistema de Notificaciones constituye un componente crítico de la plataforma de servicios corporativos, proporcionando capacidades de comunicación escalables y confiables para las operaciones multi-país de Talma. Su diseño modular y agnóstico permite adaptarse a diferentes proveedores y regulaciones regionales mientras mantiene la consistencia operacional y la separación segura por tenant.

**Valores Arquitectónicos Clave:**

- **Fiabilidad:** Entrega garantizada y trazabilidad completa
- **Mantenibilidad:** Modularidad y facilidad de evolución
- **Multi-tenant:** Separación lógica y segura de datos por cliente
- **Multipaís:** Adaptabilidad a normativas y configuraciones regionales
