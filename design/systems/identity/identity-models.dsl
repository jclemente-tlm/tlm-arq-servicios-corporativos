identity = softwareSystem "Identity & Access Management System" {
    description "Sistema de gestión de identidad basado en Keycloak"
    tags "Identity" "001 - Fase 1"

    // ========================================
    // KEYCLOAK - CONTENEDOR DOCKER OFICIAL
    // ========================================
    keycloakServer = container "Keycloak Server" {
        technology "Keycloak Docker Official, PostgreSQL"
        description "Servidor Keycloak con multi-tenancy y federación"
        tags "Keycloak" "Docker" "001 - Fase 1"
    }

    // ========================================
    // BASE DE DATOS
    // ========================================
    keycloakDatabase = store "Keycloak Database" {
        technology "PostgreSQL"
        description "Base de datos PostgreSQL con esquemas por tenant"
        tags "Database" "PostgreSQL" "001 - Fase 1"
    }

    // ========================================
    // RELACIONES INTERNAS
    // ========================================

    // Keycloak con su base de datos
    keycloakServer -> keycloakDatabase "Almacena configuración y usuarios" "PostgreSQL JDBC" "001 - Fase 1"

    // ========================================
    // RELACIONES EXTERNAS - ACTORES
    // ========================================

    // Administradores corporativos
    admin -> keycloakServer "Gestiona tenants y usuarios" "HTTPS" "001 - Fase 1"

    // Administradores delegados por país (usando roles delegados de Keycloak)
    countryAdmin -> keycloakServer "Administra usuarios de su tenant" "HTTPS via API Gateway" "001 - Fase 1"

    // Aplicaciones por país - Autenticación OAuth2/OIDC
    appPeru -> keycloakServer "Autenticación OAuth2/OIDC tenant Peru" "HTTPS via API Gateway" "001 - Fase 1"
    appEcuador -> keycloakServer "Autenticación OAuth2/OIDC tenant Ecuador" "HTTPS via API Gateway" "001 - Fase 1"
    appColombia -> keycloakServer "Autenticación OAuth2/OIDC tenant Colombia" "HTTPS via API Gateway" "001 - Fase 1"
    appMexico -> keycloakServer "Autenticación OAuth2/OIDC tenant Mexico" "HTTPS via API Gateway" "001 - Fase 1"

    // ========================================
    // RELACIONES EXTERNAS - SISTEMAS
    // ========================================

    // Configuración externa (para automatización de setup)
    // keycloakServer -> configPlatform.configService "Configuración inicial de tenants via Admin API" "Keycloak Admin REST API" "001 - Fase 1"
}