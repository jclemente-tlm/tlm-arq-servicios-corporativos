container apiGateway "api_gateway" {
    include *
    exclude "* -> identity"
    exclude "* -> notification"
    exclude "* -> iataMessaging"
    exclude "* -> trackAndTrace"
    include "apiGateway.yarp -> *"
    title "[Diagrama de Contenedores] API Gateway"
}

component apiGateway.yarp "api_gateway_yarp" {
    include *
    exclude "* -> identity"
    exclude "* -> notification"
    exclude "* -> iataMessaging"
    exclude "* -> trackAndTrace"
    include "apiGateway.yarp.authorization -> *"
    title "[Diagrama de Contenedores] API Gateway - YARP API Gateway"
}