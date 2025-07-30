
deployment notification "Notification System" "notification_system_deployment" {
    include *
    // autoLayout lr
    // exclude "notificationSystem.aws.region.ecsNotificationProcessor -> notificationSystem.aws.region.sqsEmailNode"
    exclude "relationship.tag==SNS"
    title "[Diagrama de Implementación] Notification System"
}
