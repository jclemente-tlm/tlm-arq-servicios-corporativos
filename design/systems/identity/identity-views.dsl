container identity "identity_system" {
    include *

    // Incluir proveedores de identidad federados
    include microsoftAD googleWorkspace peruNationalIdP mexicoNationalIdP
    include configPlatform

    // Excluir sistemas que no interactúan directamente
    exclude apiGateway
    exclude notification sitaMessaging trackAndTrace

    title "[Diagrama de Contenedores] Identity Microservice"
}

component identity.keycloakServer "identity_system_keycloak" {
    include *

    // Incluir solo proveedores de identidad que se federan directamente
    include microsoftAD googleWorkspace peruNationalIdP mexicoNationalIdP
    include configPlatform

    // Excluir otros sistemas corporativos
    exclude apiGateway notification sitaMessaging trackAndTrace
    exclude emailProvider smsProvider whatsappProvider pushProvider
    exclude airlines descartes

    title "[Diagrama de Componentes] Identity System - Keycloak Server"
    description "Vista del servidor Keycloak con federación de identidades externas"
}