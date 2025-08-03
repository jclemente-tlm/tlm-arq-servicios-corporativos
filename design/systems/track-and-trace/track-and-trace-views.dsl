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
//     exclude trackAndTrace.trackingQueryAPI
//     exclude trackAndTrace.trackingDashboard
//     exclude operationalUser

//     title "[Diagrama de Contenedores] Track and Trace - Fase 1"
// }

component trackAndTrace.trackingIngestAPI "track_and_trace_ingest_api" {
    include *
    exclude apiGateway
    title "[Diagrama de Contenedores] Track & Trace - Ingest API"
}

component trackAndTrace.trackingQueryAPI "track_and_trace_query_api" {
    include *
    exclude apiGateway
    title "[Diagrama de Contenedores] Track & Trace - Query API"
}

component trackAndTrace.trackingEventProcessor "track_and_trace_event_processor" {
    include *
    exclude apiGateway
    title "[Diagrama de Contenedores] Track & Trace - Event Processor"
}
