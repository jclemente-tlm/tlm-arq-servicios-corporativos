// ========================================
// OBSERVABILITY SYSTEM - VIEWS
// ========================================

// Vista general del sistema de observabilidad
systemContext observabilitySystem "observability_system_overview" {
    include observabilitySystem
    include notification identity trackAndTrace sitaMessaging apiGateway
    include admin operationalUser countryAdmin
    title "[Sistema] Observability Platform"
    description "Stack empresarial de observabilidad para monitoreo transversal."
}

// Vista de contenedores del sistema de observabilidad
container observabilitySystem "observability_system_containers" {
    include observabilitySystem.dashboardEngine
    include observabilitySystem.metricsCollector
    include observabilitySystem.logAggregator
    include observabilitySystem.tracingPlatform
    title "[Contenedores] Stack de Observabilidad"
    description "Contenedores principales del stack de observabilidad empresarial."
}

// ========================================
// NOTA: VISTAS DE COMPONENTES ELIMINADAS
// ========================================
// Las vistas de componentes internos fueron eliminadas porque el sistema
// de observabilidad se documenta como externo sin detalles de implementación

// ========================================
// DEPLOYMENT VIEW
// ========================================

// NOTA: Las vistas de deployment requieren un deploymentEnvironment definido
// Por ahora comentamos esta vista hasta que se defina la infraestructura de deployment
// para el sistema de observabilidad

// deployment observabilitySystem "observabilityEnvironment" "observability_deployment" {
//     include *
//     title "[Deployment] Observability System - AWS ECS"
//     description "Vista de deployment del sistema de observabilidad en AWS ECS con contenedores y almacenamiento."
// }
