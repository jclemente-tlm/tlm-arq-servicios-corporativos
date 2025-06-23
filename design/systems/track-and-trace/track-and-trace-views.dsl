// Vista general del sistema Track & Trace
container trackAndTrace "track_and_trace_system" {
    include *

    // Incluir los sistemas externos relacionados
    // include notification
    include iataMessaging

    // Excluir sistemas y sus relaciones que no queremos ver
    exclude apiGateway
    exclude identity
    exclude "appPeru -> notification"
    exclude "appEcuador -> notification"
    exclude "appColombia -> notification"
    exclude "appMexico -> notification"
    exclude "appPeru -> iataMessaging"
    exclude "appEcuador -> iataMessaging"
    exclude "appColombia -> iataMessaging"
    exclude "appMexico -> iataMessaging"

    // Excluir comunicaciones del admin con notification e iataMessaging
    exclude "admin -> notification"
    exclude "admin -> iataMessaging"

    title "[Diagrama de Contenedores] Track and Trace"
}
