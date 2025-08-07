# ADR-005: Estrategia de Gestión de Configuración Agnóstica

## ✅ ESTADO

Aceptada – Agosto 2025

---

## 🗺️ CONTEXTO

Los servicios corporativos distribuidos requieren una estrategia de gestión de configuración que soporte:

- **Multi-tenancy** con configuraciones específicas por país/tenant
- **Multi-cloud portabilidad** sin vendor lock-in entre AWS, Azure, GCP
- **Configuración dinámica** con hot-reload sin reiniciar servicios
- **Versionado y rollback** para cambios seguros de configuración
- **Segregación por entorno** (dev, staging, prod) con herencia
- **Feature flags** para deployment progresivo y A/B testing
- **Auditoría completa** de cambios de configuración
- **Encriptación** para configuraciones sensibles (no secretos)
- **API centralizada** para gestión programática
- **Disaster recovery** con backup y replicación cross-region

La intención estratégica es **priorizar agnosticidad vs simplicidad operacional** para gestión de configuración empresarial.

Las alternativas evaluadas fueron:

- **HashiCorp Consul** (KV store, service discovery, multi-cloud)
- **AWS Parameter Store** (Managed service, AWS nativo)
- **Azure App Configuration** (Managed service, Azure nativo)
- **Google Cloud Runtime Config** (Managed service, GCP nativo)
- **etcd** (Distributed KV store, Kubernetes nativo)
- **Apache Zookeeper** (Coordination service, configuration)

## 🔍 COMPARATIVA DE ALTERNATIVAS

### Comparativa Cualitativa

| Criterio | Consul | Parameter Store | Azure App Config | etcd | Zookeeper | GCP Runtime |
|----------|--------|-----------------|------------------|------|-----------|-------------|
| **Agnosticidad** | ✅ Totalmente agnóstico | ❌ Lock-in AWS | ❌ Lock-in Azure | ✅ Agnóstico K8s | ✅ Agnóstico | ❌ Lock-in GCP |
| **Feature Flags** | ✅ KV dinámico | 🟡 Básico | ✅ Nativo, completo | 🟡 Manual | 🟡 Muy básico | 🟡 Básico |
| **Multi-tenancy** | ✅ Namespaces nativos | 🟡 Por parámetros | ✅ Labels y filtros | 🟡 Por prefijos | 🟡 Manual | 🟡 Por proyectos |
| **Operación** | 🟡 Requiere cluster | ✅ Totalmente gestionado | ✅ Totalmente gestionado | 🟡 Gestión manual | 🟡 Complejo | ✅ Gestionado |
| **Versionado** | ✅ Transacciones | ✅ Historial | ✅ Snapshots | 🟡 Manual | 🟡 No nativo | ✅ Versionado |
| **Ecosistema .NET** | ✅ Cliente oficial | ✅ SDK nativo | ✅ SDK nativo | 🟡 Terceros | 🟡 Limitado | 🟡 Básico |
| **Costos** | ✅ Gratuito OSS | ✅ Muy económico | 🟡 Por transacción | ✅ Gratuito | ✅ Gratuito | 🟡 Por uso |

### Matriz de Decisión

| Solución | Agnosticidad | Feature Flags | Multi-tenancy | Operación | Recomendación |
|----------|--------------|---------------|---------------|-----------|---------------|
| **HashiCorp Consul** | Excelente | Buena | Excelente | Manual | ✅ **Seleccionada** |
| **Azure App Configuration** | Mala | Excelente | Excelente | Gestionada | 🟡 Alternativa |
| **AWS Parameter Store** | Mala | Básica | Moderada | Gestionada | 🟡 Considerada |
| **etcd** | Excelente | Manual | Moderada | Manual | 🟡 Considerada |
| **GCP Runtime Config** | Mala | Básica | Moderada | Gestionada | ❌ Descartada |
| **Apache Zookeeper** | Excelente | Muy básica | Manual | Compleja | ❌ Descartada |

### Comparativa de costos estimados (2025)

| Solución             | Costo mensual base* | Costos adicionales         | Infra propia |
|----------------------|---------------------|---------------------------|--------------|
| Parameter Store      | Pago por uso        | Parámetros, operaciones   | No           |
| Azure App Config     | Pago por uso        | Configs, operaciones      | No           |
| Consul               | ~US$30/mes (VM)     | Discos, backup            | Sí           |
| Google Runtime Config| Pago por uso        | Configs, operaciones      | No           |

*Precios aproximados, sujetos a variación según proveedor y volumen.

---

## 💰 ANÁLISIS DE COSTOS (TCO 3 años)

### Escenario Base: 1000 parámetros, 10K requests/mes, 4 entornos

| Solución | Licenciamiento | Infraestructura | Operación | TCO 3 años |
|----------|----------------|-----------------|-----------|------------|
| **Consul** | US$0 (OSS) | US$2,160/año | US$24,000/año | **US$78,480** |
| **Azure App Config** | Pago por uso | US$0 | US$0 | **US$1,800/año** |
| **Parameter Store** | Pago por uso | US$0 | US$0 | **US$1,440/año** |
| **etcd** | US$0 (OSS) | US$1,800/año | US$18,000/año | **US$59,400** |
| **GCP Runtime Config** | Pago por uso | US$0 | US$0 | **US$1,680/año** |
| **Zookeeper** | US$0 (OSS) | US$2,400/año | US$30,000/año | **US$97,200** |

### Escenario Alto Volumen: 10K parámetros, 1M requests/mes

| Solución | TCO 3 años | Hot Reload | Multi-tenant |
|----------|------------|------------|---------------|
| **Consul** | **US$180,000** | Sí | Nativo |
| **Azure App Config** | **US$180,000** | Sí | Nativo |
| **Parameter Store** | **US$144,000** | No | Manual |
| **etcd** | **US$120,000** | Sí | Manual |
| **GCP Runtime Config** | **US$168,000** | No | Manual |
| **Zookeeper** | **US$240,000** | Sí | Manual |

### Factores de Costo Adicionales

```yaml
Consideraciones Consul:
  Clustering: 3 nodos vs 1 nodo (3x infra vs 99.9% availability)
  Storage: SSD vs HDD (2x costo vs 5x performance)
  Backup: Snapshots automáticos vs manual (US$500/mes vs downtime)
  Monitoring: Prometheus + Grafana vs CloudWatch (US$200/mes vs US$50/mes)
  Migración: US$0 entre clouds vs US$50K vendor migration
  Capacitación: US$5K Consul vs US$2K managed services
  Downtime evitado: US$100K/año vs US$200K/año self-hosted
```

---

## ✔️ DECISIÓN

Se recomienda desacoplar la gestión de configuración mediante interfaces y adaptadores. Inicialmente se usará AWS Parameter Store, pero la arquitectura soporta migración a Consul o soluciones cloud equivalentes según necesidades de portabilidad o despliegue híbrido.

## Justificación

- Permite gestión centralizada, segura y versionada de la configuración.
- Facilita la portabilidad y despliegue multi-cloud.
- El desacoplamiento del backend permite cambiar de tecnología sin impacto en la lógica de negocio.
- Consul es una opción madura y ampliamente soportada para escenarios on-premises o híbridos.

## Limitaciones

- Parameter Store, Azure App Config y Google Runtime Config implican lock-in y costos variables.
- Consul requiere operación y monitoreo propio.

## Alternativas descartadas

- Azure App Config y Google Runtime Config: lock-in cloud, menor portabilidad.

---

## ⚠️ CONSECUENCIAS

- El código debe desacoplarse del proveedor concreto mediante interfaces.
- Se facilita la portabilidad y despliegue híbrido.
- Se requiere mantener adaptadores y pruebas para cada backend soportado.

---

## 📚 REFERENCIAS

- [AWS Parameter Store](https://aws.amazon.com/systems-manager/features/#Parameter_Store)
- [Azure App Configuration](https://azure.microsoft.com/en-us/services/app-configuration/)
- [Consul](https://www.consul.io/)
- [Google Runtime Config](https://cloud.google.com/deployment-manager/runtime-configurator)

