container identity "identity_system" {
    include *

    // // Excluir sistemas que no interactúan directamente
    exclude apiGateway
    exclude "admin -> observabilitySystem"
    // exclude notification sitaMessaging trackAndTrace

    title "[Diagrama de Contenedores] Identity Microservice"
}
