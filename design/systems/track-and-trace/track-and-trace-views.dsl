// Vista general del sistema Track & Trace
container trackAndTrace "track_and_trace_system" {
    include *

    // Incluir los sistemas externos relacionados
    // include notification
    // include sitaMessaging

    // Excluir sistemas y sus relaciones que no queremos ver
    exclude apiGateway
    // exclude identity
    // exclude "appPeru -> notification"
    // exclude "appEcuador -> notification"
    // exclude "appColombia -> notification"
    // exclude "appMexico -> notification"
    // exclude "appPeru -> sitaMessaging"
    // exclude "appEcuador -> sitaMessaging"
    // exclude "appColombia -> sitaMessaging"
    // exclude "appMexico -> sitaMessaging"

    // // Excluir comunicaciones del admin con notification e sitaMessaging
    // exclude "admin -> notification"
    // exclude "admin -> sitaMessaging"

    // exclude "observabilitySystem -> notification"
    // exclude "observabilitySystem -> trackAndTrace"
    // exclude "observabilitySystem -> identity"
    exclude "observabilitySystem -> sitaMessaging"
    exclude "sitaMessaging -> configPlatform"
    exclude "sitaMessaging -> observabilitySystem"

    title "[Diagrama de Contenedores] Track and Trace"
}

// container trackAndTrace "track_and_trace_system_fase_1" {
//     include *

//     // Incluir los sistemas externos relacionados
//     include sitaMessaging

//     // Excluir sistemas y sus relaciones que no queremos ver
//     exclude apiGateway
//     exclude appColombia
//     exclude appMexico
//     exclude trackAndTrace.trackingDashboard
//     exclude operationalUser

//     title "[Diagrama de Contenedores] Track and Trace - Fase 1"
// }

component trackAndTrace.trackingIngestAPI "track_and_trace_tracking_api" {
    include *

    // Exclusión inteligente de componentes de observabilidad para diagrama limpio
    exclude observabilitySystem
    exclude apiGateway
    exclude trackAndTrace.trackingIngestAPI.healthCheck
    exclude trackAndTrace.trackingIngestAPI.metricsCollector
    exclude trackAndTrace.trackingIngestAPI.structuredLogger

    title "[Diagrama de Componentes] Track & Trace - Tracking API"
}

component trackAndTrace.trackingEventProcessor "track_and_trace_event_processor" {
    include *

    // Exclusión inteligente de componentes de observabilidad para diagrama limpio
    exclude observabilitySystem
    exclude apiGateway
    exclude trackAndTrace.trackingEventProcessor.healthCheck
    exclude trackAndTrace.trackingEventProcessor.metricsCollector
    exclude trackAndTrace.trackingEventProcessor.structuredLogger

    // Exclusión de relaciones externas innecesarias
    exclude "sitaMessaging -> configPlatform"
    exclude "sitaMessaging -> observabilitySystem"
    exclude "observabilitySystem -> sitaMessaging"

    title "[Diagrama de Componentes] Track & Trace - Event Processor"
}
