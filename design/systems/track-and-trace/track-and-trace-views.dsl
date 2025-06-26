// Vista general del sistema Track & Trace
container trackAndTrace "track_and_trace_system" {
    include *

    // Incluir los sistemas externos relacionados
    // include notification
    // include iataMessaging

    // Excluir sistemas y sus relaciones que no queremos ver
    exclude apiGateway
    // exclude identity
    // exclude "appPeru -> notification"
    // exclude "appEcuador -> notification"
    // exclude "appColombia -> notification"
    // exclude "appMexico -> notification"
    // exclude "appPeru -> iataMessaging"
    // exclude "appEcuador -> iataMessaging"
    // exclude "appColombia -> iataMessaging"
    // exclude "appMexico -> iataMessaging"

    // // Excluir comunicaciones del admin con notification e iataMessaging
    // exclude "admin -> notification"
    // exclude "admin -> iataMessaging"

    title "[Diagrama de Contenedores] Track and Trace"
}

container trackAndTrace "track_and_trace_system_fase_1" {
    include *

    // Incluir los sistemas externos relacionados
    include iataMessaging

    // Excluir sistemas y sus relaciones que no queremos ver
    exclude apiGateway
    exclude appColombia
    exclude appMexico
    exclude trackAndTrace.queryApi
    exclude trackAndTrace.dashboard
    exclude operationalUser

    title "[Diagrama de Contenedores] Track and Trace - Fase 1"
}

component trackAndTrace.ingestApi "track_and_trace_ingest_api" {
    include *
    exclude apiGateway
    title "[Diagrama de Contenedores] Track & Trace - Ingest API"
}

component trackAndTrace.queryApi "track_and_trace_query_api" {
    include *
    exclude apiGateway
    title "[Diagrama de Contenedores] Track & Trace - Query API"
}

component trackAndTrace.eventProcessor "track_and_trace_event_processor" {
    include *
    exclude apiGateway
    title "[Diagrama de Contenedores] Track & Trace - Event Processor"
}
