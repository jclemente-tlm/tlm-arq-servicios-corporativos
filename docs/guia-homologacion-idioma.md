# 📖 Guía de Estilo: Homologación de Idioma en Documentación Arc42

## 🎯 Objetivo

Esta guía establece las pautas para mantener consistencia en el idioma español en toda la documentación Arc42, especificando cuándo usar español vs inglés según el contexto técnico.

## 📋 Principios Generales

### ✅ Usar ESPAÑOL para:

#### Estructuras de Documentación
- **Títulos de secciones**: "Beneficios de Rendimiento", "Consecuencias", "Mitigaciones"
- **Descripciones explicativas**: Texto que explica conceptos o decisiones
- **Justificaciones de negocio**: Razones empresariales y operacionales
- **Análisis de impacto**: Positivas, negativas, riesgos

#### Términos Técnicos Traducibles
- **Benefits** → **Beneficios**
- **Performance** → **Rendimiento**
- **Reliability** → **Confiabilidad**
- **Business** → **Empresarial/Negocio**
- **Technical** → **Técnico**
- **Operational** → **Operacional**
- **Primary/Secondary** → **Primario/Secundario**
- **Load distribution** → **Distribución de carga**
- **Health monitoring** → **Monitoreo de salud**
- **Quality routing** → **Enrutamiento de calidad**
- **Cost optimization** → **Optimización de costos**
- **Failover** → **Conmutación por error**
- **Cloud Agnostic** → **Agnóstico de nube**
- **Vendor Lock-in** → **Bloqueo de proveedor**
- **Container Ready** → **Listo para contenedores**

### 🔧 Mantener INGLÉS para:

#### Términos Técnicos Estándar
- **Protocolos**: JWT, OAuth2, OIDC, SAML, REST, GraphQL
- **Tecnologías**: Docker, Kubernetes, PostgreSQL, Redis
- **Proveedores**: AWS, Azure, GCP, SendGrid, Twilio
- **Patrones**: ACID, CRUD, API Gateway, Load Balancer
- **Métricas**: SLA, TTL, QPS, RPM
- **Algoritmos**: RS256, SHA-256, AES

#### Código y Configuraciones
- **Nombres de variables**: `primaryProvider`, `fallbackProvider`
- **Configuraciones YAML/JSON**: Mantener keys en inglés
- **URLs y endpoints**: `/health/ready`, `/api/v1/notifications`
- **Nombres de clases**: `IConfigurationProvider`, `DatabaseMessageQueue`

## 📝 Ejemplos de Homologación

### ❌ Antes (Mixto)
```markdown
#### Performance Benefits
- **Load distribution:** Carga distribuida reduce latencia
- **Health monitoring:** Monitoreo proactivo de provider status

#### Business Benefits
- **Cost optimization:** Reducción de costos
```

### ✅ Después (Homologado)
```markdown
#### Beneficios de Rendimiento
- **Distribución de carga:** Carga distribuida reduce latencia
- **Monitoreo de salud:** Monitoreo proactivo del estado del proveedor

#### Beneficios Empresariales
- **Optimización de costos:** Reducción de costos
```

## 🏗️ Estructura de Secciones Estandarizada

### ADR (Architecture Decision Record)
```markdown
## ADR-XXX: [Título en Español] para [Propósito]

### Contexto
[Descripción en español del problema/necesidad]

### Alternativas Consideradas
[Tabla con opciones evaluadas]

### Decisión
[Decisión tomada en español]

### Justificación

#### Beneficios de [Categoría]
- **[Beneficio]:** [Explicación en español]

#### Beneficios Técnicos
- **[Beneficio]:** [Explicación en español]

#### Beneficios Operacionales
- **[Beneficio]:** [Explicación en español]

### Consecuencias

#### Positivas
- ✅ **[Aspecto]:** [Descripción en español]

#### Negativas
- ❌ **[Aspecto]:** [Descripción en español]

#### Mitigaciones
- 🔧 **[Estrategia]:** [Descripción en español]
```

## 🔍 Proceso de Verificación

### 1. Script de Verificación
```bash
# Ejecutar script para detectar contenido en inglés
./check-english-content.sh
```

### 2. Revisión Manual
- Verificar que títulos de sección estén en español
- Confirmar que explicaciones de negocio estén en español
- Validar que términos técnicos sigan las reglas establecidas

### 3. Casos Especiales
- **Acrónimos técnicos**: Mantener en inglés con explicación en español
  - "JWT (JSON Web Token) para autenticación"
- **Nombres propios**: Mantener original
  - "SendGrid", "Twilio", "Keycloak"
- **Conceptos establecidos**: Usar término más conocido
  - "Failover" vs "Conmutación por error" (preferir "failover" si es más usado)

## 📊 Métricas de Calidad

### Indicadores de Consistencia
- **Títulos homologados**: 100% en español
- **Beneficios traducidos**: 100% estructura en español
- **Términos técnicos**: Según reglas establecidas
- **Código/configuración**: 100% en inglés apropiado

### Herramientas de Validación
- Script automatizado de detección
- Revisión por pares en PRs
- Checklist de homologación

## 🎯 Checklist de Homologación

### Para Cada Archivo .md:
- [ ] Títulos de sección en español
- [ ] "Benefits" → "Beneficios"
- [ ] "Performance" → "Rendimiento"
- [ ] "Business" → "Empresarial/Negocio"
- [ ] "Technical" → "Técnico"
- [ ] "Operational" → "Operacional"
- [ ] "Positivas", "Negativas", "Mitigaciones" en español
- [ ] Términos técnicos según reglas establecidas
- [ ] Código y configuraciones apropiadamente en inglés

### Para Nuevos Documentos:
- [ ] Seguir estructura estandarizada
- [ ] Aplicar reglas de idioma desde el inicio
- [ ] Validar con script de verificación
- [ ] Revisión por al menos un compañero

## 🔄 Proceso de Actualización

1. **Detección**: Usar script automatizado
2. **Priorización**: Documentos principales primero
3. **Traducción**: Seguir guías establecidas
4. **Validación**: Script + revisión manual
5. **Documentación**: Actualizar esta guía si es necesario

---

**Nota**: Esta guía es un documento vivo que debe actualizarse conforme evolucionen las necesidades del proyecto y se identifiquen nuevos patrones de uso.
