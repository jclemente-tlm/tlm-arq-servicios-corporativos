// Vista general de la plataforma de almacenamiento
container storagePlatform "storage_platform_system" {
    include *

    // Incluir configuración externa
    include configPlatform

    // Excluir otros sistemas corporativos
    exclude apiGateway identity notification sitaMessaging trackAndTrace
    exclude emailProvider smsProvider whatsappProvider pushProvider
    exclude airlines descartes
    exclude microsoftAD googleWorkspace peruNationalIdP mexicoNationalIdP

    title "[Diagrama de Contenedores] File Storage Platform"
    description "Plataforma agnóstica de almacenamiento de archivos multi-cloud"
}

component storagePlatform.storageAPI "storage_platform_api" {
    include *

    // Incluir solo elementos directamente relacionados con el API
    include storagePlatform.objectStorage
    include storagePlatform.fileStorage
    include storagePlatform.metadataDB
    include configPlatform

    // Excluir otros sistemas
    exclude apiGateway identity notification sitaMessaging trackAndTrace
    exclude emailProvider smsProvider whatsappProvider pushProvider

    title "[Diagrama de Componentes] Storage Platform - API Gateway"
    description "Vista del API agnóstico de almacenamiento con abstracción de proveedores"
}
