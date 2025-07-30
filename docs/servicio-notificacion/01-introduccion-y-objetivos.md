# 1. Introducción y objetivos

El Servicio de Notificaciones es una plataforma multi-tenant y multipaís para el envío de mensajes por múltiples canales (email, SMS, WhatsApp, push, in-app), gestionando adjuntos y programación de envíos. Permite operar para varios clientes/empresas y países, adaptándose a configuraciones regionales y normativas locales.

## 1.1 Descripción general de los requisitos

| Requisito | Descripción |
|-----------|-------------|
| Multicanal | Envío por email, SMS, WhatsApp, push, in-app |
| Adjuntos | Soporte para archivos adjuntos |
| Programación | Agendar envíos futuros |
| Preferencias | Opt-in/opt-out, límites diarios, horarios |
| Reintentos | Automáticos ante fallos |
| Extensibilidad | Integración de nuevos canales/proveedores |
| Multi-tenant | Múltiples clientes/empresas con aislamiento de datos |
| Multipaís | Operación en varios países con configuración regional |
| Tipos de notificación | Transaccionales, promocionales, alertas |
| Limitación de velocidad | Control de mensajes promocionales por usuario/día |
| Escalabilidad | Millones de notificaciones por minuto |
| Alta disponibilidad y confiabilidad | Entrega garantizada, tolerancia a fallos |
| Baja latencia | Entrega oportuna |
| Almacenamiento eficiente | Bases relacionales, NoSQL y blobs para adjuntos |

## 1.2 Objetivos de calidad

| Objetivo | Descripción |
|----------|-------------|
| Escalabilidad | Manejo de picos y crecimiento horizontal |
| Disponibilidad | Alta disponibilidad y tolerancia a fallos |
| Seguridad | Autenticación, autorización y privacidad |
| Fiabilidad | Entrega garantizada y trazabilidad |
| Mantenibilidad | Modularidad y facilidad de evolución |
| Multi-tenant | Separación lógica y segura de datos por cliente |
| Multipaís | Adaptabilidad a normativas y configuraciones regionales |

## 1.3 Partes interesadas

| Rol/Nombre | Contacto | Expectativas |
|------------|---------|--------------|
| Product Owner | <product@talma.com> | Plataforma robusta, flexible, multi-tenant y multipaís |
| Equipo Dev | <dev@talma.com> | Facilidad de mantenimiento y evolución |
| Operaciones | <ops@talma.com> | Monitoreo, alertas y recuperación |
| Usuarios finales | - | Recepción confiable y segura de notificaciones |
| Clientes corporativos | - | Aislamiento de datos y configuración personalizada |
| Administradores regionales | - | Cumplimiento de normativas locales |
