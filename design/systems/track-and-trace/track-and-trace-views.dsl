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

component trackAndTrace.trackingAPI "track_and_trace_tracking_api" {
    include *

    // // Incluir solo sistemas que interactúan directamente con este API
    // include configPlatform
    // include sitaMessaging.eventProcessor

    // // Excluir sistemas que no tienen relación directa con este componente
    // exclude apiGateway
    // exclude identity
    // exclude notification

    title "[Diagrama de Componentes] Track & Trace - API Unificada con CQRS"
    description "Vista detallada del API unificado con separación lógica de comandos (ingest) y consultas (query). Solo muestra relaciones directas del API."
}

component trackAndTrace.trackingEventProcessor "track_and_trace_event_processor" {
    include *

    // // Incluir solo sistemas que interactúan directamente con este processor
    // include configPlatform
    // include sitaMessaging.eventProcessor

    // // Excluir sistemas que no tienen relación directa con este componente
    // exclude apiGateway
    // exclude identity
    // exclude notification

    exclude "sitaMessaging -> configPlatform"
    exclude "sitaMessaging -> observabilitySystem"
    exclude "observabilitySystem -> sitaMessaging"
    // exclude "observabilitySystem -> trackAndTrace"

    title "[Diagrama de Componentes] Track & Trace - Event Processor"
    description "Vista enfocada en el procesador de eventos y sus interacciones directas únicamente"
}
