# 5. Vista de bloques de construcción

![API Gateway - Vista de Componentes](/diagrams/servicios-corporativos/api_gateway_yarp.png)

*Figura 5.1: Vista de componentes del API Gateway*

## 5.1 Componentes principales

| Componente | Responsabilidad | Tecnología |
|------------|-----------------|------------|
| **YARP Proxy** | Enrutamiento y proxy reverso | YARP |
| **Auth Middleware** | Validación de tokens JWT | .NET 8 |
| **Rate Limiter** | Control de velocidad | Redis |
| **Load Balancer** | Distribución de carga | YARP |
| **Circuit Breaker** | Patrón de resiliencia | Polly |
| **Logging** | Registro de eventos | Serilog |
| **Metrics** | Recolección de métricas | Prometheus |

## 5.2 Flujo de procesamiento

| Paso | Acción | Componente |
|------|--------|------------|
| **1** | Recepción de solicitud | YARP Proxy |
| **2** | Validación de autenticación | Auth Middleware |
| **3** | Verificación de límites | Rate Limiter |
| **4** | Enrutamiento a servicio | Load Balancer |
| **5** | Respuesta al cliente | YARP Proxy |
