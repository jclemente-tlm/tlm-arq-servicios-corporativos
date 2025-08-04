// ========================================
// STORAGE PLATFORM - Abstracción agnóstica de almacenamiento
// ========================================

storagePlatform = softwareSystem "File Storage Platform" {
    description "Plataforma centralizada agnóstica de almacenamiento de archivos y objetos"
    tags "External, Storage, Cloud Agnostic, 001 - Fase 1"

    // Servicio de almacenamiento de objetos (S3-compatible)
    objectStorage = container "Object Storage Service" {
        technology "AWS S3 / Azure Blob / GCP Cloud Storage"
        description "Servicio de almacenamiento de objetos compatible con S3 API. Implementación intercambiable entre proveedores cloud."
        tags "Storage, S3-Compatible, Multi-Cloud, 001 - Fase 1"
    }

    // Servicio de almacenamiento de archivos (file system)
    fileStorage = container "File Storage Service" {
        technology "AWS EFS / Azure Files / NFS"
        description "Servicio de almacenamiento de archivos compartido. Implementación intercambiable entre proveedores."
        tags "Storage, FileSystem, Multi-Cloud, 001 - Fase 1"
    }

    // API Gateway para operaciones de almacenamiento
    storageAPI = container "Storage API Gateway" {
        technology "ASP.NET Core / Storage Abstraction Library"
        description "API agnóstica que abstrae operaciones de almacenamiento independiente del proveedor subyacente"
        tags "API, Storage Abstraction, .NET, 001 - Fase 1"

        // Componentes del API de almacenamiento
        storageController = component "Storage Controller" {
            technology "ASP.NET Core Web API"
            description "Controlador REST para operaciones de archivos: upload, download, delete, list"
            tags "Controller, REST API, 001 - Fase 1"
        }

        storageService = component "Storage Service" {
            technology "C# Service Layer"
            description "Lógica de negocio para gestión de archivos con validaciones y políticas"
            tags "Service, Business Logic, 001 - Fase 1"
        }

        // Abstracción del almacenamiento
        storageProvider = component "Storage Provider" {
            technology "Storage Abstraction Pattern"
            description "Interfaz agnóstica que encapsula operaciones de almacenamiento. Implementaciones: S3Provider, AzureBlobProvider, GCPProvider"
            tags "Abstraction, Provider Pattern, 001 - Fase 1"
        }

        metadataRepository = component "Metadata Repository" {
            technology "Entity Framework Core"
            description "Repositorio para metadatos de archivos: nombre, tamaño, tipo, path, permisos, tenant"
            tags "Repository, Metadata, EF Core, 001 - Fase 1"
        }

        configurationProvider = component "Configuration Provider" {
            technology "Configuration Pattern"
            description "Proveedor de configuración específica del tenant y proveedor de almacenamiento"
            tags "Configuration, Multi-Tenant, 001 - Fase 1"
        }
    }

    // Base de datos de metadatos
    metadataDB = container "Metadata Database" {
        technology "PostgreSQL"
        description "Base de datos para metadatos de archivos, permisos y configuración por tenant"
        tags "Database, PostgreSQL, Metadata, 001 - Fase 1"
    }
}

// ========================================
// RELACIONES INTERNAS - STORAGE PLATFORM
// ========================================

// API to Services
storagePlatform.storageAPI.storageController -> storagePlatform.storageAPI.storageService "Delega operaciones de almacenamiento" "C#" "001 - Fase 1"
storagePlatform.storageAPI.storageService -> storagePlatform.storageAPI.storageProvider "Utiliza abstracción de almacenamiento" "Interface" "001 - Fase 1"
storagePlatform.storageAPI.storageService -> storagePlatform.storageAPI.metadataRepository "Gestiona metadatos de archivos" "EF Core" "001 - Fase 1"

// Provider to Storage
storagePlatform.storageAPI.storageProvider -> storagePlatform.objectStorage "Almacena/recupera objetos" "S3-Compatible API" "001 - Fase 1"
storagePlatform.storageAPI.storageProvider -> storagePlatform.fileStorage "Almacena/recupera archivos" "File System API" "001 - Fase 1"

// Configuration
storagePlatform.storageAPI.configurationProvider -> configPlatform.configService "Lee configuraciones de almacenamiento por tenant" "HTTPS" "001 - Fase 1"

// Metadata persistence
storagePlatform.storageAPI.metadataRepository -> storagePlatform.metadataDB "Persiste metadatos de archivos" "PostgreSQL" "001 - Fase 1"
