#!/bin/bash

# Script para buscar y reportar contenido en inglés en archivos de documentación Arc42
# Este script ayuda a identificar términos que pueden necesitar traducción al español

echo "🔍 Buscando contenido en inglés en documentación Arc42..."
echo "=================================================="

# Términos técnicos que típicamente aparecen en inglés y pueden traducirse
english_terms=(
    "Benefits"
    "Performance"
    "Reliability"
    "Business"
    "Technical"
    "Operational"
    "Primary"
    "Secondary"
    "Tertiary"
    "Load distribution"
    "Health monitoring"
    "Rate negotiation"
    "Quality routing"
    "Cost optimization"
    "Geographic redundancy"
    "Failover"
    "Waste reduction"
    "Volume optimization"
    "Dynamic routing"
    "Regional optimization"
    "Capacity scaling"
    "Testing complexity"
    "Configuration drift"
    "Operational overhead"
    "Abstraction layer"
    "Automated testing"
    "Configuration management"
    "Monitoring dashboard"
    "Cloud Agnostic"
    "Vendor Lock-in"
    "Container Ready"
    "Cost Predictable"
    "ACID Transactions"
    "Batch Processing"
    "Connection Pooling"
    "Future Path"
    "Adapter Pattern"
    "Risk Mitigation"
    "Migration Benefits"
    "Portability Benefits"
    "Read replicas"
    "Table partitioning"
    "Queue depth"
    "Processing time"
    "Performance testing"
    "Load testing"
    "Migration planning"
)

# Buscar en archivos de documentación
find docs/ -name "*.md" -type f | while read file; do
    echo ""
    echo "📄 Analizando: $file"
    echo "----------------------------------------"

    found_terms=()

    for term in "${english_terms[@]}"; do
        if grep -q "$term" "$file"; then
            line_numbers=$(grep -n "$term" "$file" | head -3)
            found_terms+=("$term")
            echo "  ⚠️  '$term' encontrado en líneas:"
            echo "$line_numbers" | sed 's/^/      /'
        fi
    done

    if [ ${#found_terms[@]} -eq 0 ]; then
        echo "  ✅ Sin términos en inglés detectados"
    else
        echo ""
        echo "  📊 Resumen: ${#found_terms[@]} términos en inglés encontrados"
        echo "     Términos: ${found_terms[*]}"
    fi
done

echo ""
echo "📋 RECOMENDACIONES DE TRADUCCIÓN:"
echo "================================="
echo ""
echo "Secciones comunes a traducir:"
echo "- Benefits → Beneficios"
echo "- Performance Benefits → Beneficios de Rendimiento"
echo "- Reliability Benefits → Beneficios de Confiabilidad"
echo "- Business Benefits → Beneficios Empresariales"
echo "- Technical Benefits → Beneficios Técnicos"
echo "- Operational Benefits → Beneficios Operacionales"
echo "- Positivas → mantener en español"
echo "- Negativas → mantener en español"
echo "- Mitigaciones → mantener en español"
echo ""
echo "Términos técnicos a mantener en inglés cuando sea apropiado:"
echo "- JWT, OAuth2, OIDC, SAML"
echo "- API, REST, GraphQL"
echo "- Docker, Kubernetes"
echo "- PostgreSQL, Redis"
echo "- AWS, Azure, GCP"
echo "- Load balancer, CDN"
echo ""
echo "✨ Proceso completado!"
