
deployment trackAndTrace "Track & Trace" "track_and_trace_deployment" {
    include *

    // autoLayout lr
    // exclude "notificationSystem.aws.region.ecsNotificationProcessor -> notificationSystem.aws.region.sqsEmailNode"
    exclude "relationship.tag==Messaging"

    title "[Diagrama de Implementación] Track & Trace"
}
