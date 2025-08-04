container apiGateway "api_gateway" {
    include *

    // Incluir sistemas que el gateway rutea
    include identity
    include notification
    include trackAndTrace
    exclude sitaMessaging

    // Incluir configuración y observabilidad
    include configPlatform

    title "[Diagrama de Contenedores] API Gateway"
}

component apiGateway.reverseProxyGateway "api_gateway_yarp" {
    include *

    // Incluir solo sistemas que interactúan directamente con el proxy
    include identity.keycloakServer
    include notification.api
    include trackAndTrace.trackingAPI
    include configPlatform

    // Excluir sistemas que no tienen interacción directa
    exclude sitaMessaging
    exclude emailProvider smsProvider whatsappProvider pushProvider
    exclude airlines descartes
    exclude microsoftAD googleWorkspace peruNationalIdP mexicoNationalIdP

    title "[Diagrama de Componentes] API Gateway - YARP Reverse Proxy"
    description "Vista enfocada en el proxy reverso y sus integraciones downstream directas"
}