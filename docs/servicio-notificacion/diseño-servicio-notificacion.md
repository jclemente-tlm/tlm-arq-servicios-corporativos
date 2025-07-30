# Diseñar un servicio de notificación escalable - Entrevista de diseño de sistemas

Un servicio de notificación es un sistema responsable de entregar información oportuna y relevante a los usuarios a través de diversos canales, como SMS, correo electrónico, notificaciones push y mensajes en la aplicación.

Ejemplo: después de que un usuario realiza una compra en línea, el servicio de notificación podría enviarle un correo electrónico confirmando el pedido, un SMS cuando se procesa el pago y una notificación push cuando se envía el paquete.

Creado usando Multijugador
En este artículo, aprenderemos cómo diseñar un servicio de notificación escalable que pueda manejar millones de notificaciones por día y garantizar una alta disponibilidad.

## 1. Recopilación de requisitos

Antes de sumergirnos en el diseño, describamos los requisitos funcionales y no funcionales.

### 1.1 Requisitos funcionales

Soporte multicanal : el sistema debe admitir el envío de notificaciones a través de varios canales, incluidos correo electrónico, SMS, notificaciones push y mensajes en la aplicación.

Múltiples tipos de notificaciones : admite alertas transaccionales (por ejemplo, confirmación de pedido), promocionales (por ejemplo, ofertas de descuento) y generadas por el sistema (por ejemplo, restablecimiento de contraseña).

Entrega programada : admite la programación de notificaciones para entregas futuras.

Limitación de velocidad : garantiza que los usuarios reciban solo una cantidad limitada de mensajes promocionales en un día determinado para evitar el spam.

Mecanismo de reintento : maneja errores en la entrega de notificaciones y vuelve a intentarlo cuando sea necesario (por ejemplo, SMS o correo electrónico fallidos).

### 1.2 Requisitos no funcionales

Escalabilidad: el sistema debe manejar millones de notificaciones por minuto y soportar millones de usuarios simultáneos.

Alta disponibilidad: garantiza un tiempo de inactividad mínimo para que las notificaciones se envíen incluso en caso de fallas.

Confiabilidad: garantizar la entrega de notificaciones al menos una vez, con la posibilidad de semántica exactamente una vez para ciertos casos de uso.

Baja latencia: las notificaciones deben enviarse lo más rápido posible para garantizar una entrega oportuna.

## 2. Estimación de escala

Antes de sumergirnos en el diseño, calculemos la escala para tomar mejores decisiones de diseño.

Usuarios : Supongamos que el sistema atiende a 50 millones de usuarios diarios .

Notificaciones por usuario : En promedio, cada usuario recibe 5 notificaciones/día .

Carga máxima : supongamos que en el momento pico se reciben 1 millón de notificaciones en 1 minuto (un escenario común durante las ventas flash, por ejemplo).

Esto significa que el sistema debería gestionar:

Notificaciones por día: 50 millones x 5 = 250 millones de notificaciones/día

Notificaciones máximas por segundo: 1 millón / 60 = ~ 17 000 notificaciones/segundo

### Requisitos de almacenamiento

Suponiendo un tamaño promedio de notificación y datos de usuario de 1 KB.

Almacenamiento de datos de usuario: 50 millones * 1 KB = 50 GB

Almacenamiento diario para notificaciones: 50 millones *5* 1 KB = 250 GB

## 3. Diseño de alto nivel

A alto nivel, nuestro sistema constará de los siguientes componentes:

Esbozado usando Multijugador

### 1. Servicio de notificación

El Servicio de Notificaciones es el punto de entrada para todas las solicitudes de notificaciones, ya sean de aplicaciones externas o de sistemas internos. Expone API que varios clientes pueden llamar para activar notificaciones.

Estas podrían ser solicitudes para enviar notificaciones transaccionales (por ejemplo, correos electrónicos de restablecimiento de contraseña), notificaciones promocionales (por ejemplo, ofertas de descuento) o alertas del sistema (por ejemplo, advertencias de tiempo de inactividad).

Cada solicitud se valida para garantizar que contiene toda la información necesaria, como el ID del destinatario, el tipo de notificación, el contenido del mensaje y los canales a través de los cuales se debe enviar la notificación (correo electrónico, SMS, etc.).

Para las notificaciones que deben enviarse en una fecha u hora futura, el Servicio de notificaciones se integra con el Servicio de programación .

Después de procesar la solicitud, el Servicio de notificaciones envía las notificaciones a una cola de notificaciones (por ejemplo, Kafka o RabbitMQ).

### 2. Servicio de preferencias del usuario

El Servicio de preferencias del usuario permite a los usuarios controlar cómo reciben las notificaciones.

Almacena y recupera las preferencias individuales del usuario para recibir notificaciones en diferentes canales.

El servicio rastrea qué tipos de notificaciones han aceptado o rechazado explícitamente los usuarios.

Ejemplo: Los usuarios pueden optar por no recibir contenido de marketing o promocional.

Para evitar que los usuarios se vean abrumados por las notificaciones, el Servicio de preferencias del usuario aplica límites de frecuencia para ciertos tipos de notificaciones, especialmente los mensajes promocionales.

Ejemplo: Un usuario solo puede recibir 2 notificaciones promocionales por día

### 3. Servicio de programación

El servicio Programador es responsable de almacenar y rastrear las notificaciones programadas (notificaciones que deben enviarse en un momento futuro específico).

Estos pueden incluir recordatorios, campañas promocionales u otras notificaciones urgentes que no se envían de inmediato sino que deben activarse según un cronograma predefinido.

Ejemplo: Es posible programar un mensaje promocional para su entrega la próxima semana.

Una vez que llega la hora programada, el Servicio Programador extrae la notificación de su almacenamiento y la envía a la Cola de Notificaciones .

### 4. Cola de notificaciones

La cola de notificaciones actúa como un búfer entre el servicio de notificaciones y los procesadores de canal .

Al disociar el envío de solicitudes de notificación de la entrega de notificaciones, la cola permite que el sistema se escale de manera mucho más efectiva, particularmente durante períodos de alto tráfico.

El sistema de colas proporciona garantías en torno a la entrega de mensajes.

Dependiendo del caso de uso, se puede configurar para:

Entrega al menos una vez : garantiza que cada notificación se enviará al menos una vez, incluso si esto genera mensajes duplicados en casos excepcionales.

Entrega exactamente una vez : garantiza que cada notificación se entregue exactamente una vez, lo que evita duplicados y mantiene la confiabilidad.

### 5. Procesadores de canal

Los procesadores de canal son responsables de extraer notificaciones de la cola de notificaciones y entregarlas a los usuarios a través de canales específicos, como correo electrónico , SMS , notificaciones push y notificaciones en la aplicación .

Al disociar el servicio de notificación de la entrega real, los procesadores de canal permiten el escalamiento independiente y el procesamiento asincrónico de las notificaciones.

Esta configuración permite que cada procesador se concentre en su canal designado, lo que garantiza una entrega confiable con mecanismos de reintento integrados y un manejo eficiente de fallas.

### 6. Base de datos/Almacenamiento

La capa de base de datos/almacenamiento administra grandes volúmenes de datos, incluido el contenido de las notificaciones, las preferencias del usuario, las notificaciones programadas, los registros de entrega y los metadatos.

El sistema requiere una combinación de soluciones de almacenamiento para satisfacer diversas necesidades:

Datos transaccionales : una base de datos relacional como PostgreSQL o MySQL almacena datos estructurados, como registros de notificaciones y estados de entrega.

Preferencias del usuario : las bases de datos NoSQL (por ejemplo, DynamoDB, MongoDB) almacenan grandes volúmenes de datos específicos del usuario, como preferencias y límites de velocidad.

Almacenamiento de blobs : para las notificaciones que contienen archivos adjuntos grandes (por ejemplo, correos electrónicos con imágenes o archivos PDF), Amazon S3 o servicios similares pueden almacenarlos.

Compartir

## 4. Diseño detallado

### Paso 1: Creación de la solicitud de notificación

Un sistema externo (por ejemplo, una plataforma de comercio electrónico, un generador de alertas del sistema o un sistema de marketing) genera una solicitud de notificación.

Solicitud de muestra:
{
  "requestId": "abc123",
  "timestamp": "2024-09-17T14:00:00Z",
  "notificationType": "transactional",
  "channels": ["email", "sms", "push"],
  "recipient": {
    "userId": "user789",
    "email": "<user@example.com>"
  },
  "message": {
    "subject": "Order Confirmation",
    "body": "Thank you for your order! Your order #123456 has been confirmed.",
    "attachments": ["https://example.com/invoice123456.pdf"],
    "smsText": "Thank you for your order! Order #123456 confirmed.",
    "pushNotification": {
      "title": "Order Confirmed",
      "body": "Your order #123456 has been confirmed. Check your email for details.",
      "icon": "<https://example.com/icon.png>",
      "action": {
        "type": "viewOrder",
        "url": "<https://example.com/order/123456>"
      }
    }
  },
  "schedule": {
    "sendAt": "2024-09-17T15:00:00Z"
  },
  "metadata": {
    "priority": "high",
    "retries": 3
  }
}

### Paso 2: Ingestión del servicio de notificación

El servicio de notificación (a través de un API Gateway o un balanceador de carga ) recibe la solicitud de notificación.

La solicitud se autentica y valida para garantizar que proviene de una fuente autorizada y que toda la información necesaria (destinatario, mensaje, canales, etc.) está presente y es correcta.

### Paso 3: Obtener las preferencias del usuario

El Servicio de notificación consulta al Servicio de preferencias del usuario para recuperar:

Canales de notificación preferidos (por ejemplo, algunos usuarios pueden preferir el correo electrónico para mensajes promocionales pero SMS para alertas críticas).

Preferencias de inclusión/exclusión voluntaria : garantiza el cumplimiento de las preferencias del usuario, como no enviar correos electrónicos de marketing si el usuario ha optado por no participar.

Límites de velocidad : garantiza que el usuario no exceda los límites de notificación configurados (por ejemplo, máximo 3 mensajes SMS promocionales por día).

Ejemplo de respuesta del Servicio de preferencias del usuario:
{
  "userId": "user789",
  "preferences": {
    "channels": {
      "transactional": ["email", "push"],
      "promotional": ["sms"],
      "systemAlert": ["push", "sms"]
    },
    "doNotDisturb": {
      "enabled": true,
      "startTime": "22:00",
      "endTime": "08:00",
      "timezone": "America/New_York"
    },
    "dailyLimits": {
      "promotionalLimit": 2,
      "promotionalSentToday": 1
    },
    "optOut": {
      "email": false,
      "sms": false,
      "push": false
    },
    "preferredTimeForDelivery": {
      "enabled": true,
      "startTime": "09:00",
      "endTime": "21:00",
      "timezone": "America/New_York"
    }
  }
}

### Paso 4: Programación (si es necesario)

Si la notificación está programada para una entrega futura (por ejemplo, un recordatorio para mañana o un correo electrónico de marketing la próxima semana), el Servicio de notificación envía la notificación al Servicio de programación , que almacena la notificación junto con su tiempo de entrega programado en una base de datos basada en tiempo o una base de datos NoSQL que permite una consulta eficiente en función del tiempo.

Creado usando Multijugador
La scheduled_notifications tabla está particionada scheduled_time para que el sistema pueda recuperar de manera eficiente solo las notificaciones que caen dentro del rango de tiempo relevante, en lugar de escanear toda la tabla.

El servicio del programador consulta continuamente el almacenamiento en busca de notificaciones cuya entrega está prevista .

Ejemplo: cada minuto (o según un intervalo más granular), el servicio consulta las notificaciones que deben entregarse en la siguiente ventana de tiempo (por ejemplo, los próximos 1 a 5 minutos).

Cuando llega la hora programada, el Servicio Programador toma la notificación y la envía a la Cola de Notificaciones .

### Paso 5: Creación y formato del mensaje

En función de las preferencias del usuario y la solicitud, el Servicio de Notificación utiliza plantillas (si es necesario) para generar y formatear dinámicamente el mensaje para cada canal:

Creado usando Multijugador
Mensaje de muestra (correo electrónico):
{
  "messageId": "msg12345",
  "timestamp": "2024-09-17T14:00:00Z",
  "notificationType": "transactional",
  "channel": "email",
  "recipient": {
    "userId": "user789",
    "email": "<user@example.com>"
  },
  "messageContent": {
    "subject": "Order Confirmation - Order #123456",
    "body": {
      "html": "<html><body><h1>Thank you for your order!</h1><p>Your order #123456 has been confirmed. You can track your order <a href='https://example.com/track'>here</a>.</p></body></html>",
      "plainText": "Thank you for your order! Your order #123456 has been confirmed. Track your order here: <https://example.com/track>"
    },
    "attachments": [
      {
        "url": "https://example.com/invoice123456.pdf",
        "fileName": "invoice123456.pdf",
        "mimeType": "application/pdf"
      }
    ]
  },
  "metadata": {
    "priority": "high",
    "retries": 3,
    "sentBy": "OrderService",
    "templateId": "orderConfirmationTemplate",
    "requestId": "req9876"
  }
}

### Paso 6: Poner en cola la notificación

Una vez que el Servicio de notificación ha creado y formateado los mensajes para los canales requeridos, coloca cada mensaje en el tema respectivo en el Sistema de cola de notificaciones (por ejemplo, Kafka , RabbitMQ , AWS SQS ).

Cada canal (correo electrónico, SMS, push, etc.) tiene su propio tema dedicado , lo que garantiza que los mensajes sean procesados ​​independientemente por los procesadores de canal correspondientes .

Ejemplo: si la notificación debe enviarse por correo electrónico, SMS y push, el Servicio de Notificación genera tres mensajes , cada uno adaptado al canal respectivo.

El mensaje de correo electrónico se coloca en el tema del correo electrónico .

El mensaje SMS se coloca en el tema SMS .

El mensaje de notificación push se coloca en el tema push .

Estos temas permiten que cada procesador de canal se centre en consumir mensajes relevantes para su canal, reduciendo la complejidad y mejorando la eficiencia del procesamiento.

Cada mensaje contiene la carga útil de notificación , información específica del canal y metadatos (como prioridad y número de reintentos).

### Paso 7: Procesamiento de mensajes específicos del canal

La cola de notificaciones almacena los mensajes hasta que los procesadores de canal correspondientes los extraen para su procesamiento.

Cada procesador de canal actúa como consumidor de la cola y es responsable de consumir sus propios mensajes:

El procesador de correo electrónico extrae información del tema del correo electrónico .

El procesador de SMS extrae información del tema de SMS .

El procesador Push extrae del tema Push .

El procesador en la aplicación extrae información del tema en la aplicación .

### Paso 8: Envío de la notificación

Cada procesador de canal gestiona la entrega de la notificación a través del canal especificado:

Procesador de correo electrónico :
Se conecta al proveedor de correo electrónico (por ejemplo, SendGrid , Mailgun , Amazon SES ).

Envía el correo electrónico, garantizando que siga las preferencias del usuario (por ejemplo, HTML frente a texto sin formato).

Maneja errores como rebotes o direcciones de correo electrónico no válidas.

Procesador de SMS :
Se conecta al proveedor de SMS (por ejemplo, Twilio , Nexmo ).

Envía el SMS con cualquier ajuste de formato para cumplir con los límites de caracteres o requisitos regionales.

Maneja problemas como números de teléfono no válidos o errores de red.

Procesador de notificaciones push :
Utiliza servicios como Firebase Cloud Messaging (FCM) para Android o Apple Push Notification Service (APNs) para iOS.

Envía la notificación push, incluidos todos los metadatos (por ejemplo, acciones o íconos específicos de la aplicación).

Maneja fallas como tokens de dispositivos vencidos o dispositivos fuera de línea.

Procesador de notificaciones en la aplicación :
Envía la notificación en la aplicación a través de WebSockets o sondeo largo a la sesión activa del usuario.

Formatea el mensaje para mostrarlo en la interfaz de usuario de la aplicación, cumpliendo con las reglas de visualización específicas de la aplicación.

### Paso 9: Seguimiento y confirmación de entrega

Cada procesador de canal espera un acuse de recibo del proveedor externo:

Éxito : el mensaje ha sido entregado.

Error : la entrega del mensaje falló (por ejemplo, problemas de red, direcciones no válidas).

Los procesadores de canal registran el estado de cada notificación en la notification_logstabla para futuras referencias, auditorías e informes.

Creado usando Multijugador

## 5. Abordar los cuellos de botella

### 5.1 Manejo de fallos y reintentos

Si la entrega de una notificación falla debido a un problema temporal (por ejemplo, tiempo de inactividad de un proveedor externo), el Procesador de canal intentará reenviar la notificación.

Normalmente, se utiliza una estrategia de retroceso exponencial , donde cada reintento se retrasa por intervalos progresivamente más largos.

Si la notificación permanece sin entregarse después de una cantidad determinada de reintentos, se mueve a la cola de mensajes no entregados (DLQ) para su posterior procesamiento.

Los administradores pueden luego revisar y reprocesar manualmente los mensajes en el DLQ según sea necesario.

### 5.2 Escalabilidad

#### Escalabilidad horizontal

El sistema debe estar diseñado para escalabilidad horizontal , lo que significa que los componentes pueden escalar agregando más instancias a medida que aumenta la carga.

Servicio de notificación : a medida que aumentan los volúmenes de solicitudes, se pueden implementar instancias adicionales para administrar la mayor carga de notificaciones entrantes.

Cola de notificaciones : los sistemas de colas distribuidas, como Kafka o RabbitMQ , son naturalmente escalables y pueden manejar cargas de trabajo más grandes al distribuir la cola entre múltiples nodos.

Procesadores de canal : cada procesador (correo electrónico, SMS, etc.) debe ser escalable horizontalmente para manejar grandes volúmenes de notificaciones.

#### Fragmentación y partición

Para gestionar de manera eficiente grandes conjuntos de datos, en particular datos de usuario y registros de notificaciones, la fragmentación y la partición distribuyen la carga entre múltiples bases de datos o regiones geográficas:

Fragmentación basada en usuarios : distribuya a los usuarios entre diferentes bases de datos o regiones según la ubicación geográfica o la ID de usuario para equilibrar la carga.

Particiones basadas en tiempo : organice los registros de notificaciones en particiones basadas en tiempo (por ejemplo, diarias o mensuales) para mejorar el rendimiento de las consultas y administrar grandes volúmenes de datos históricos.

#### Almacenamiento en caché

Implemente el almacenamiento en caché con soluciones como Redis o Memcached para almacenar datos a los que se accede con frecuencia, como las preferencias del usuario.

El almacenamiento en caché reduce la carga en la base de datos y mejora los tiempos de respuesta para las notificaciones en tiempo real al evitar búsquedas repetidas en la base de datos.

### 5.3 Confiabilidad

Para lograr una alta disponibilidad, los datos (p. ej., preferencias de usuario, registros) deben replicarse en múltiples centros de datos o regiones. Esto garantiza que, incluso si una región falla, los datos estén disponibles en otras regiones.

Replicación Multi-AZ : almacene datos en múltiples zonas de disponibilidad para proporcionar redundancia.

Se debe utilizar un equilibrador de carga para distribuir el tráfico entrante de manera uniforme entre las instancias del Servicio de notificación, garantizando así que ninguna instancia se convierta en un cuello de botella.

### 5.4 Monitoreo y registro

Para garantizar un funcionamiento fluido a gran escala, el sistema debe tener:

Registro centralizado : utilice herramientas como ELK Stack o Prometheus/Grafana para recopilar registros de varios componentes y monitorear el estado del sistema.

Alertas : configure alertas para fallas (por ejemplo, cuando las tasas de fallas en la entrega de notificaciones exceden un umbral).

Métricas : realice un seguimiento de métricas como la tasa de éxito, la tasa de fallas, la latencia de entrega y el rendimiento de cada canal.

### 5.5 Seguridad

Implemente una autenticación robusta (p. ej., OAuth 2.0) para todas las solicitudes entrantes al servicio de notificaciones. Utilice el control de acceso basado en roles (RBAC) para limitar el acceso a servicios críticos.

Proteja el servicio contra abusos implementando una limitación de velocidad en la puerta de enlace API para evitar ataques DoS.

### 5.6 Archivado de datos antiguos

Como un sistema de notificación maneja grandes volúmenes de datos a lo largo del tiempo, es importante implementar una estrategia para archivar los datos antiguos .

El archivado implica trasladar datos obsoletos o a los que se accede con menos frecuencia (por ejemplo, registros de entrega antiguos, contenido de notificaciones e historial de usuarios) del almacenamiento principal a una solución de almacenamiento de menor costo y a más largo plazo.
