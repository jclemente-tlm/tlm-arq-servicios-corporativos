container apiGateway "api_gateway" {
    include *

    // Incluir sistemas que el gateway rutea
    // include identity
    // include notification
    // include trackAndTrace
    // exclude sitaMessaging

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

    // exclude "configPlatform -> *"
    // exclude "* -> configPlatform"

    // exclude "configPlatform -> identity"
    // exclude "configPlatform -> notification"
    // exclude "configPlatform -> trackAndTrace"
    // exclude "identity -> configPlatform"
    // exclude "notification -> configPlatform"
    // exclude "trackAndTrace -> configPlatform"

    exclude "observabilitySystem -> notification"
    exclude "observabilitySystem -> trackAndTrace"
    exclude "observabilitySystem -> identity"

    exclude "notification -> configPlatform"
    exclude "trackAndTrace -> configPlatform"

    exclude "admin -> identity"

    // Incluir configuración y observabilidad
    // include configPlatform

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

    exclude "observabilitySystem -> notification"
    exclude "observabilitySystem -> trackAndTrace"
    exclude "observabilitySystem -> identity"

    exclude "configPlatform -> identity"
    exclude "configPlatform -> notification"
    exclude "configPlatform -> trackAndTrace"
    exclude "identity -> configPlatform"
    exclude "notification -> configPlatform"
    exclude "trackAndTrace -> configPlatform"

    title "[Diagrama de Componentes] API Gateway - YARP Reverse Proxy"
    description "Vista enfocada en el proxy reverso y sus integraciones downstream directas"
}