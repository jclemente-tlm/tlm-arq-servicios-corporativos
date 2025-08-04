identity = softwareSystem "Identity & Access Management System" {
    description "Sistema corporativo de gestión de identidad y acceso basado en Keycloak con contenedor Docker oficial para multi-tenancy, federación y administración centralizada."
    tags "Identity" "001 - Fase 1"

    // ========================================
    // KEYCLOAK - CONTENEDOR DOCKER OFICIAL
    // ========================================
    keycloakServer = container "Keycloak Server" {
        technology "Keycloak Docker Official, PostgreSQL"
        description "Servidor Keycloak oficial con soporte completo para multi-tenancy via tenants (realms), federación con IdPs externos, user management, delegated administration y observabilidad."
        tags "Keycloak" "Docker" "001 - Fase 1"
    }

    // ========================================
    // BASE DE DATOS
    // ========================================
    keycloakDatabase = store "Keycloak Database" {
        technology "PostgreSQL"
        description "Base de datos PostgreSQL para Keycloak con esquemas separados por tenant (realm) para completo aislamiento multi-tenant."
        tags "Database" "PostgreSQL" "001 - Fase 1"
    }

    // ========================================
    // RELACIONES INTERNAS
    // ========================================

    // Keycloak con su base de datos
    keycloakServer -> keycloakDatabase "Almacena configuración, usuarios, tenants (realms), tokens y sesiones" "PostgreSQL JDBC" "001 - Fase 1"

    // ========================================
    // RELACIONES EXTERNAS - ACTORES
    // ========================================

    // Administradores corporativos
    admin -> keycloakServer "Gestiona tenants, usuarios, federación via Admin Console" "HTTPS" "001 - Fase 1"

    // Administradores delegados por país (usando roles delegados de Keycloak)
    countryAdmin -> keycloakServer "Administra usuarios de su tenant específico" "HTTPS via API Gateway" "001 - Fase 1"

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