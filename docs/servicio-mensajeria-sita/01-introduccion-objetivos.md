# 1. Introducción y objetivos

El **Sistema de Mensajería SITA** es un servicio especializado diseñado para generar, procesar y entregar mensajes SITA (Société Internationale de Télécommunications Aéronautiques) para aerolíneas y partners del ecosistema aeronáutico. Proporciona integración confiable con la red SITA global y sistemas aeroportuarios.

## 1.1 Descripción general de los requisitos

### Propósito del Sistema

El sistema actúa como puente entre los eventos corporativos internos y la red SITA global, transformando eventos de negocio en mensajes SITA estandardizados y gestionando la entrega confiable a aerolíneas y sistemas de partners.

### Contexto del Dominio SITA

SITA es la red de comunicaciones más grande del mundo para la industria aérea, conectando aerolíneas, aeropuertos, agencias de viajes y otros actores del ecosistema aeronáutico. Los mensajes SITA siguen estándares internacionales (IATA, ICAO) para garantizar interoperabilidad global.

### Arquitectura del Sistema

| Componente | Propósito | Tecnología |
|------------|-----------|------------|
| **Event Processor** | Consume eventos del Track & Trace, aplica reglas de negocio | .NET 8 Background Services |
| **Message Generator** | Transforma eventos en mensajes SITA según templates | Template Engine (Liquid), Business Rules |
| **Delivery Engine** | Entrega confiable a partners SITA via múltiples protocolos | SFTP, HTTP/S, File Transfer |
| **Configuration Manager** | Gestión de templates, mappings y configuración por partner | Dynamic Configuration Platform |

### Requisitos Funcionales Principales

| ID | Requisito | Descripción Detallada |
|----|-----------|-----------------------|
| **RF-SITA-01** | **Message Generation** | Generación de mensajes SITA (MVTC, LDMC, etc.) desde eventos internos |
| **RF-SITA-02** | **Template Management** | Templates configurables por aerolínea y tipo de mensaje |
| **RF-SITA-03** | **Multi-Protocol Delivery** | Entrega via SFTP, HTTP/S, email según preferencias del partner |
| **RF-SITA-04** | **Partner Configuration** | Configuración específica por aerolínea (formatos, protocolos, schedules) |
| **RF-SITA-05** | **Delivery Scheduling** | Envío programado según horarios específicos del partner |
| **RF-SITA-06** | **Retry & Error Handling** | Reintentos inteligentes con escalación manual para fallos persistentes |
| **RF-SITA-07** | **Format Validation** | Validación de mensajes SITA según estándares IATA antes del envío |
| **RF-SITA-08** | **Audit & Compliance** | Tracking completo para auditorías y compliance regulatorio |
| **RF-SITA-09** | **Multi-tenant Support** | Soporte para múltiples aeropuertos/países con configuración independiente |
| **RF-SITA-10** | **Real-time Monitoring** | Dashboards para monitoreo de entregas y status de partners |

### Tipos de Mensajes SITA Soportados

| Tipo Mensaje | Estándar | Propósito | Frecuencia Típica |
|--------------|----------|-----------|-------------------|
| **MVTC** | IATA SSIM | Movement messages (vuelos) | Por movimiento |
| **LDMC** | IATA SSIM | Load messages (carga) | Por vuelo |
| **BSMC** | IATA RP 1745 | Baggage messages | Por pieza |
| **NOTAM** | ICAO Doc 8126 | Notice to Airmen | As needed |
| **METAR/TAF** | ICAO Annex 3 | Weather information | Hourly/scheduled |
| **Custom** | Partner-specific | Mensajes específicos por aerolínea | Variable |

### Requisitos No Funcionales

| Categoría | Requisito | Target | Medición |
|-----------|-----------|--------|----------|
| **Reliability** | Message delivery success rate | 99.9% | Delivery tracking |
| **Performance** | Message processing throughput | 1,000 messages/hour | Performance monitoring |
| **Availability** | System uptime | 99.9% | SLA monitoring |
| **Compliance** | SITA network compliance | 100% standard compliance | Format validation |
| **Security** | Secure transmission | Encryption in transit | Security audits |
| **Auditability** | Complete message audit trail | 100% messages tracked | Audit reports |

### Partners y Protocolos de Integración

| Partner Type | Integration Method | Protocol | Security |
|--------------|-------------------|----------|----------|
| **Major Airlines** | Direct SITA network | SITATEX, X.25 | SITA security standards |
| **Regional Airlines** | File transfer | SFTP, HTTPS | TLS 1.3, key-based auth |
| **Ground Handlers** | API integration | REST API, WebHooks | OAuth2 + JWT |
| **Cargo Operators** | Batch files | SFTP, scheduled delivery | Certificate-based auth |
| **Government Agencies** | Secure portal | HTTPS upload | Government PKI |

## 1.2 Objetivos de calidad

### Objetivos Primarios

| Prioridad | Objetivo | Escenario | Métrica Objetivo |
|-----------|----------|-----------|------------------|
| **1** | **Compliance** | Mensajes cumplen estándares SITA/IATA al 100% | Zero compliance violations |
| **2** | **Reliability** | Entrega garantizada de mensajes críticos | 99.9% delivery success |
| **3** | **Timeliness** | Entrega dentro de ventanas de tiempo requeridas | 95% on-time delivery |

### Objetivos Secundarios

| Objetivo | Descripción | Métrica |
|----------|-------------|---------|
| **Flexibility** | Fácil adición de nuevos partners y formatos | < 1 semana integration |
| **Observability** | Visibilidad completa del pipeline de mensajes | 100% messages traced |
| **Cost Efficiency** | Optimización de costos de transmisión | < $0.10 per message |
| **Maintainability** | Gestión simple de templates y configuraciones | Self-service configuration |

### Atributos de Calidad Específicos

| Atributo | Definición | Implementación | Verificación |
|----------|------------|----------------|--------------|
| **Message Integrity** | Mensajes entregados sin corrupción | Checksums, digital signatures | Automated validation |
| **Delivery Assurance** | Confirmación de entrega exitosa | Acknowledgment tracking | Receipt verification |
| **Format Compliance** | Adherencia a estándares SITA/IATA | Schema validation, format checking | Compliance testing |
| **Partner SLA** | Cumplimiento de SLAs específicos por partner | SLA monitoring, alerting | SLA reporting |

## 1.3 Partes interesadas

### Stakeholders Principales

| Rol | Contacto | Responsabilidades | Expectativas |
|-----|----------|-------------------|--------------|
| **Airport Operations** | Ops Management | Definición de mensajes críticos, SLAs | Reliable delivery, real-time status |
| **Airline Relations** | Partner Management | Relaciones con aerolíneas, onboarding | Smooth partner integration |
| **IT Integration** | Dev Teams | Integración técnica, troubleshooting | Clear APIs, comprehensive documentation |
| **Compliance Officer** | Legal/Compliance | Regulatory compliance, audits | Full audit trails, compliance reporting |
| **SITA Technical** | SITA Representatives | Technical standards, certification | Standards compliance, certification |

### Partners Externos (Consumidores)

| Partner | Relationship | Messages Consumed | Technical Contact |
|---------|--------------|-------------------|-------------------|
| **LATAM Airlines** | Major partner | MVTC, LDMC, BSMC | LATAM IT Team |
| **Copa Airlines** | Regional partner | MVTC, Custom messages | Copa Operations |
| **Avianca** | Strategic partner | Full message suite | Avianca Technical |
| **Local Ground Handlers** | Service providers | Ground operation messages | Ops teams |
| **Cargo Companies** | Logistics partners | Cargo-specific messages | Cargo IT teams |

### Sistemas Proveedores (Upstream)

| Sistema | Data Provided | Integration Type | SLA |
|---------|---------------|------------------|-----|
| **Track & Trace** | Flight events, operational events | Event streaming | < 30 sec |
| **Flight Information** | Schedule changes, delays | Real-time API | < 5 sec |
| **Ground Operations** | Baggage, cargo, services | Batch + real-time | < 1 min |
| **Weather Systems** | METAR, TAF data | Scheduled updates | Hourly |
| **Configuration Platform** | Templates, partner settings | Polling | 30 sec intervals |

### Autoridades Regulatorias

| Authority | Jurisdiction | Compliance Requirements | Reporting |
|-----------|--------------|------------------------|-----------|
| **DGAC Peru** | Peru aviation authority | Flight movement reporting | Daily |
| **DGAC Ecuador** | Ecuador aviation authority | Operational compliance | Weekly |
| **Aerocivil Colombia** | Colombia aviation authority | Safety reporting | As required |
| **AFAC Mexico** | Mexico aviation authority | Movement tracking | Real-time |
| **IATA** | International standards | Message format compliance | Periodic audits |

### Matriz de Comunicación

| Stakeholder | Frecuencia | Canal | Contenido |
|-------------|------------|-------|-----------|
| **Airport Operations** | Real-time | Dashboards, alerts | Message delivery status, partner status |
| **Airline Relations** | Weekly | Status reports | Partner SLA compliance, issues |
| **IT Integration** | Daily | Monitoring, logs | System health, error rates |
| **Compliance** | Monthly | Formal reports | Audit trails, compliance metrics |
| **SITA Technical** | Quarterly | Technical reviews | Standards compliance, certification status |

### Escalation Matrix

| Issue Type | L1 Support | L2 Support | L3 Support | External |
|------------|------------|------------|------------|----------|
| **Delivery Failures** | DevOps Team | Development Team | System Architect | Partner Technical |
| **Format Issues** | Operations | SITA Specialist | Technical Lead | SITA Certification |
| **Partner Problems** | Account Manager | Technical Support | Solution Architect | Partner Management |
| **Compliance Issues** | Compliance Officer | Legal Team | Executive Leadership | Regulatory Authority |
