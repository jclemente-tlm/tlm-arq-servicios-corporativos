# 7. Vista de implementación

![Diagrama de Despliegue](/diagrams/notification_system_deployment.png)

## Infraestructura por componente funcional

| Componente              | Tipo de despliegue         | Recursos DEV                | Recursos STG                | Recursos PROD               | Dependencias principales                | Escalado y alta disponibilidad |
|-------------------------|----------------------------|-----------------------------|-----------------------------|-----------------------------|-----------------------------------------|-------------------------------|
| Notification API        | ECS Fargate / Docker       | 1 vCPU, 2GB RAM, 1 tarea    | 2 vCPU, 4GB RAM, 1 tarea    | 4 vCPU, 8GB RAM, 2+ tareas, ALB | SQS, RDS, S3, YARP, IAM                | Autoescalado, ALB, multi-AZ   |
| Notification Processor  | ECS Fargate / Docker       | 1 vCPU, 2GB RAM, 1 tarea    | 2 vCPU, 4GB RAM, 2 tareas   | 4 vCPU, 8GB RAM, 4+ tareas         | SQS, SNS, RDS, S3, IAM                 | Autoescalado, multi-AZ        |
| Scheduler               | ECS Fargate / Docker       | 1 vCPU, 2GB RAM, 1 tarea    | 2 vCPU, 4GB RAM, 1 tarea    | 4 vCPU, 8GB RAM, 2+ tareas         | RDS, SQS, IAM                          | Autoescalado, multi-AZ        |
| Email Processor         | ECS Fargate / Docker       | 1 vCPU, 2GB RAM, 1 tarea    | 2 vCPU, 4GB RAM, 1 tarea    | 4 vCPU, 8GB RAM, 2+ tareas         | SQS, SNS, RDS, S3, Email Provider, IAM | Autoescalado, multi-AZ        |
| SMS Processor           | ECS Fargate / Docker       | 1 vCPU, 2GB RAM, 1 tarea    | 2 vCPU, 4GB RAM, 1 tarea    | 4 vCPU, 8GB RAM, 2+ tareas         | SQS, SNS, RDS, SMS Provider, IAM       | Autoescalado, multi-AZ        |
| WhatsApp Processor      | ECS Fargate / Docker       | 1 vCPU, 2GB RAM, 1 tarea    | 2 vCPU, 4GB RAM, 1 tarea    | 4 vCPU, 8GB RAM, 2+ tareas         | SQS, SNS, RDS, S3, WhatsApp Provider, IAM | Autoescalado, multi-AZ    |
| Push Processor          | ECS Fargate / Docker       | 1 vCPU, 2GB RAM, 1 tarea    | 2 vCPU, 4GB RAM, 1 tarea    | 4 vCPU, 8GB RAM, 2+ tareas         | SQS, SNS, RDS, S3, Push Provider, IAM  | Autoescalado, multi-AZ        |
| RDS PostgreSQL          | RDS (EC2)                  | t3.micro, 20GB, 1 AZ        | t3.small, 50GB, 2 AZ        | m5.large, 200GB, multi-AZ          | API, Processor, Scheduler, Canal Processors | Multi-AZ, backups automáticos |
| SQS (Colas de mensajes)     | AWS SQS (Serverless)         | 5 colas estándar/FIFO, DLQ, retención  | 5 colas estándar/FIFO, DLQ, retención  | 5 colas estándar/FIFO, DLQ, retención, colas por canal/tipo | IAM, integración con ECS, SNS, RDS | Autoescalado, alta disponibilidad, tolerancia a fallos |
| SNS (Notificaciones)        | AWS SNS (Serverless)         | 1 tópico, integración básica | 1 tópico, integración por canal | 1 tópico, integración avanzada | IAM, integración con SQS | Autoescalado, alta disponibilidad |
| Email/SMS/Push/WhatsApp Provider | Servicio externo           | Bajo volumen, test/dev      | Volumen medio, test/stg     | Alto volumen, productivo    | API canal correspondiente               | Según proveedor                        |
| IAM, CloudWatch, otros            | AWS (gestionado)           | IAM mínimo, logs básicos    | IAM mínimo, logs y métricas | IAM mínimo, logs, métricas, alertas | Todos los servicios                     | Alta disponibilidad AWS                 |

**Notas por componente:**

- Se implementan 5 colas SQS (una por canal principal: email, sms, push, whatsapp, scheduler) y 1 tópico SNS para fan-out y desacoplamiento. No se crea un tópico SNS por canal, ya que un solo tópico permite simplificar la integración y reducir costos; si en el futuro se requiere segmentación avanzada por canal, se puede escalar a múltiples tópicos.
- Los servicios desplegados en Fargate no requieren tipo de instancia EC2, solo vCPU/RAM por tarea.
- RDS PostgreSQL sí requiere tipo de instancia EC2, por eso se especifica (t3.micro, t3.small, m5.large).
- Notification API expone endpoints REST y gestiona autenticación/autorización vía YARP/API Gateway.
- Notification Processor consume SQS, publica en SNS y actualiza estados en RDS.
- Scheduler consulta notificaciones programadas en RDS y las encola en SQS.
- Los procesadores de canal (Email, SMS, WhatsApp, Push) consumen SQS, procesan y notifican vía proveedores externos, gestionando adjuntos desde S3 si aplica.
- Todos los workers tienen IAM mínimo necesario y monitoreo con CloudWatch/Prometheus/Grafana según ambiente.
- En producción, todos los servicios están distribuidos en múltiples zonas de disponibilidad (multi-AZ) y protegidos por grupos de seguridad y WAF donde aplica.

## Estimación de costos por ambiente (referencial)

| Componente                  | DEV (USD/mes) | STG (USD/mes) | PROD (USD/mes) | Características DEV | Características STG | Características PROD |
|-----------------------------|---------------|---------------|---------------|---------------------|---------------------|---------------------|
| Notification API (Fargate)  | 20            | 40            | 160           | 1 vCPU, 2GB RAM, 1 tarea | 2 vCPU, 4GB RAM, 1 tarea | 4 vCPU, 8GB RAM, 2+ tareas, ALB |
| Notification Processor      | 20            | 80            | 320           | 1 vCPU, 2GB RAM, 1 tarea | 2 vCPU, 4GB RAM, 2 tareas | 4 vCPU, 8GB RAM, 4+ tareas |
| Scheduler                   | 10            | 20            | 80            | 1 vCPU, 2GB RAM, 1 tarea | 2 vCPU, 4GB RAM, 1 tarea | 4 vCPU, 8GB RAM, 2+ tareas |
| Email Processor             | 10            | 20            | 80            | 1 vCPU, 2GB RAM, 1 tarea | 2 vCPU, 4GB RAM, 1 tarea | 4 vCPU, 8GB RAM, 2+ tareas |
| SMS Processor               | 10            | 20            | 80            | 1 vCPU, 2GB RAM, 1 tarea | 2 vCPU, 4GB RAM, 1 tarea | 4 vCPU, 8GB RAM, 2+ tareas |
| WhatsApp Processor          | 10            | 20            | 80            | 1 vCPU, 2GB RAM, 1 tarea | 2 vCPU, 4GB RAM, 1 tarea | 4 vCPU, 8GB RAM, 2+ tareas |
| Push Processor              | 10            | 20            | 80            | 1 vCPU, 2GB RAM, 1 tarea | 2 vCPU, 4GB RAM, 1 tarea | 4 vCPU, 8GB RAM, 2+ tareas |
| RDS PostgreSQL              | 30            | 80            | 400           | t3.micro, 20GB, 1 AZ | t3.small, 50GB, 2 AZ | m5.large, 200GB, multi-AZ |
| SQS (Colas de mensajes)     | 5             | 10            | 40            | 5 colas estándar/FIFO, DLQ, retención | 5 colas estándar/FIFO, DLQ, retención | 5 colas estándar/FIFO, DLQ, retención, por canal/tipo |
| SNS (Notificaciones)        | 1             | 2             | 8            | 1 tópico, integración básica | 1 tópico, integración por canal | 1 tópico, integración avanzada |
| Email/SMS/Push/WhatsApp Provider | 10        | 20            | 100           | Proveedor test/dev, bajo volumen | Proveedor test/stg, volumen medio | Proveedor productivo, alto volumen |
| IAM, CloudWatch, otros      | 5             | 10            | 30            | IAM mínimo, logs básicos | IAM mínimo, logs y métricas | IAM mínimo, logs, métricas, alertas |
| **Total estimado**          | **154**        | **375**        | **1590**      |                         |                         |                         |


---

### Comparativa de proveedores de notificaciones (ejemplo)

La siguiente tabla muestra ejemplos de costos reales para envío de mensajes por canal y proveedor. Los valores son aproximados y pueden variar según país, volumen y acuerdos comerciales. Se recomienda consultar las calculadoras oficiales de cada proveedor para estimaciones precisas.

| Proveedor   | Canal     | Costo por mensaje (USD) | Ejemplo: 10,000 mensajes | Observaciones |
|-------------|-----------|------------------------|--------------------------|--------------|
| Amazon SES  | Email     | 0.0001                 | 1.00                     | Primeros 62,000 emails enviados cada mes desde EC2, ECS Fargate, Lambda u otros servicios dentro de AWS son gratis. Luego, se cobra el precio estándar mensual. Si envías desde fuera de AWS, el costo es mayor y no aplica el beneficio. [Calculadora SES](https://calculator.aws.amazon.com/calculator/home?nc2=h_ql_prod_awscalc)
| Amazon SES  | Email con adjunto (1 MB) | 0.0001 + S3/transferencia | ~13.00-15.00                | El costo de envío por email no cambia por adjunto, pero hay costos adicionales por almacenamiento y transferencia si se usan enlaces o si el mensaje es muy grande. [Calculadora S3](https://calculator.aws.amazon.com/calculator/home?nc2=h_ql_prod_awscalc&service=s3)
| Twilio      | SMS (MX)  | 0.045                  | 450.00                   | Varía por país. [Precios Twilio](https://www.twilio.com/sms/pricing/mx)
| Infobip     | WhatsApp  | 0.045-0.075            | 450-750                  | Depende de tipo de mensaje y país. [Precios Infobip](https://www.infobip.com/pricing)
| SendGrid    | Email     | 0.0009-0.001            | 9-10                     | Planes escalables. [Precios SendGrid](https://sendgrid.com/pricing/)
| Firebase    | Push      | Gratis                  | 0.00                     | Solo costo de backend propio. [Firebase Cloud Messaging](https://firebase.google.com/pricing)

---

### Comparativa de proveedores multicanal ("todo en uno")

Algunos proveedores ofrecen servicios integrados para múltiples canales de notificación (email, SMS, push, WhatsApp, etc.) en una sola plataforma. La siguiente tabla muestra ejemplos de costos y características de estos proveedores multicanal. Los valores son aproximados y pueden variar según país, canal, volumen y acuerdos comerciales. Consultar siempre la calculadora oficial del proveedor para estimaciones precisas.

| Proveedor    | Canales soportados                | Costo por canal (ejemplo)                                                                 | Ejemplo: 10,000 mensajes | Moneda | Observaciones |
|--------------|------------------------------------|------------------------------------------------------------------------------------------|--------------------------|--------|--------------|
| Twilio       | Email, SMS, WhatsApp, Voice, Push | Email: desde $0.0008<br>SMS (MX): $0.045<br>WhatsApp: $0.045-0.075<br>Push: Gratis     | Email: $8<br>SMS: $450<br>WhatsApp: $450-750<br>Push: $0 | USD    | Plataforma global, API unificada, precios varían por país y canal. [Precios Twilio](https://www.twilio.com/pricing) |
| Infobip      | Email, SMS, WhatsApp, Push        | Email: desde $0.0006<br>SMS (MX): $0.040<br>WhatsApp: $0.045-0.075<br>Push: Gratis     | Email: $6<br>SMS: $400<br>WhatsApp: $450-750<br>Push: $0 | USD    | API multicanal, soporte local, precios negociables. [Precios Infobip](https://www.infobip.com/pricing) |
| MessageBird  | Email, SMS, WhatsApp, Voice, Push | Email: desde $0.001<br>SMS (MX): $0.045<br>WhatsApp: $0.050-0.080<br>Push: Gratis     | Email: $10<br>SMS: $450<br>WhatsApp: $500-800<br>Push: $0 | USD    | Plataforma europea, API unificada, precios varían por canal/país. [Precios MessageBird](https://www.messagebird.com/pricing/) |



**Aclaración sobre emails con adjuntos:**

- El costo base por envío de email (por mensaje) es el mismo con o sin adjunto, siempre que no se supere el tamaño máximo permitido por el proveedor.
- Los costos adicionales provienen del almacenamiento y transferencia de los archivos adjuntos (por ejemplo, si se alojan en S3 y se envía un enlace), o si el mensaje es muy grande y genera cargos por transferencia de datos.

**Ejemplo de cálculo de adjuntos:**

- Para 10,000 emails con un adjunto de 1 MB cada uno:
  - Almacenamiento S3: 10,000 MB ≈ 10 GB (costo mensual de almacenamiento estándar S3: ~0.23 USD/GB/mes)
  - Transferencia de salida S3: 10 GB x ~0.09 USD/GB ≈ 0.90 USD (primer GB suele ser gratis)
  - Total estimado adicional por adjuntos: ~2-4 USD por 10,000 mensajes (puede variar según región y descargas repetidas)
  - El costo total del email con adjunto es la suma del envío (SES) + almacenamiento + transferencia.

**Notas sobre proveedores multicanal:**

- Los precios pueden variar significativamente según el país, tipo de mensaje y volumen mensual.
- Todos los proveedores ofrecen APIs unificadas, panel de control y reportes centralizados.
- Algunos proveedores permiten negociar precios para grandes volúmenes o acuerdos empresariales.
- Es recomendable evaluar integraciones, soporte y SLA además del costo unitario.



**Notas generales:**

- La arquitectura actual utiliza 5 colas SQS y 1 tópico SNS en todos los ambientes, lo que reduce el costo de SNS respecto a una arquitectura con múltiples tópicos por canal. La estimación refleja este ahorro y la lógica de simplificación. Si se requiere mayor granularidad por canal, se puede escalar a más tópicos SNS en el futuro, lo que incrementaría el costo.
- Los valores son referenciales y deben ajustarse según uso real, región y acuerdos con proveedores.
- El beneficio de los 62,000 emails gratis de SES es mensual y aplica para envíos desde EC2, ECS Fargate, Lambda y otros servicios dentro de AWS. Si se envía desde fuera de AWS, el costo por email es mayor y no aplica el beneficio gratuito.
- Los costos de SQS y S3 dependen del volumen de mensajes y almacenamiento, así como de la configuración (DLQ, versionado, ciclo de vida).
- Los costos de Fargate y RDS dependen de la cantidad de tareas, vCPU/RAM y tipo de instancia.
- Los proveedores externos (Email, SMS, WhatsApp, Push) pueden variar significativamente según el volumen, país y tipo de mensaje. Consultar siempre la calculadora oficial del proveedor.

- No se incluyen costos de transferencia de datos entre zonas/regiones ni backups adicionales.

---

**Referencias:**
- [Twilio Pricing](https://www.twilio.com/pricing)
- [Infobip Pricing](https://www.infobip.com/pricing)
- [MessageBird Pricing](https://www.messagebird.com/pricing/)
