# 1. Introducción y objetivos

Punto de entrada unificado para todos los servicios corporativos basado en YARP.

## 1.1 Propósito y funcionalidades

| Funcionalidad | Descripción |
|---------------|-------------|
| **Enrutamiento** | Proxy reverso para servicios downstream |
| **Autenticación** | Validación de tokens JWT |
| **Rate Limiting** | Control de velocidad por tenant |
| **Load Balancing** | Distribución de carga |
| **Observabilidad** | Logging, métricas y tracing |
| **Resiliencia** | Circuit breakers y retry policies |

## 1.2 Objetivos de calidad

| Atributo | Objetivo | Métrica |
|----------|----------|--------|
| **Disponibilidad** | Alta disponibilidad | 99.9% uptime |
| **Rendimiento** | Baja latencia | < 100ms P95 |
| **Throughput** | Alto rendimiento | > 5,000 RPS |
| **Seguridad** | Zero trust | Autenticación obligatoria |
