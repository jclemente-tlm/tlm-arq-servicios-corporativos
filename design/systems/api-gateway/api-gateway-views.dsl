container apiGateway "api_gateway" {
    include *
    exclude "* -> identity"
    exclude "* -> notification"
    exclude "* -> sitaMessaging"
    exclude "* -> trackAndTrace"
    include "apiGateway.reverseProxyGateway -> *"
    title "[Diagrama de Contenedores] API Gateway"
}

component apiGateway.reverseProxyGateway "api_gateway_yarp" {
    include *
    exclude "* -> identity"
    exclude "* -> notification"
    exclude "* -> sitaMessaging"
    exclude "* -> trackAndTrace"
    include "apiGateway.reverseProxyGateway.authorizationMiddleware -> *"
    title "[Diagrama de Componentes] API Gateway - YARP Reverse Proxy"
}