container apiGateway "api_gateway" {
    include *

    exclude "appPeru -> notification"
    exclude "appEcuador -> notification"
    exclude "appColombia -> notification"
    exclude "appMexico -> notification"
    exclude "appPeru -> trackAndTrace"
    exclude "appEcuador -> trackAndTrace"
    exclude "appColombia -> trackAndTrace"
    exclude "appMexico -> trackAndTrace"
    exclude "appPeru -> identity"
    exclude "appEcuador -> identity"
    exclude "appColombia -> identity"
    exclude "appMexico -> identity"

    exclude "identity -> configPlatform"
    exclude "notification -> configPlatform"
    exclude "trackAndTrace -> configPlatform"
    exclude "sitaMessaging -> configPlatform"

    exclude "notification -> observabilitySystem"
    exclude "trackAndTrace -> observabilitySystem"
    exclude "identity -> observabilitySystem"
    exclude "sitaMessaging -> observabilitySystem"

    title "[Diagrama de Contenedores] API Gateway"
}

component apiGateway.reverseProxyGateway "api_gateway_yarp" {
    include *

    exclude "appPeru -> notification"
    exclude "appEcuador -> notification"
    exclude "appColombia -> notification"
    exclude "appMexico -> notification"
    exclude "appPeru -> trackAndTrace"
    exclude "appEcuador -> trackAndTrace"
    exclude "appColombia -> trackAndTrace"
    exclude "appMexico -> trackAndTrace"
    exclude "appPeru -> identity"
    exclude "appEcuador -> identity"
    exclude "appColombia -> identity"
    exclude "appMexico -> identity"

    exclude "identity -> configPlatform"
    exclude "notification -> configPlatform"
    exclude "trackAndTrace -> configPlatform"
    exclude "sitaMessaging -> configPlatform"

    exclude "notification -> observabilitySystem"
    exclude "trackAndTrace -> observabilitySystem"
    exclude "identity -> observabilitySystem"
    exclude "sitaMessaging -> observabilitySystem"

    title "[Diagrama de Componentes] API Gateway - YARP Reverse Proxy"
    description "Vista enfocada en el proxy reverso y sus integraciones downstream directas"
}