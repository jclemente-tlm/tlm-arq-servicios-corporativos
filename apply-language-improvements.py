#!/usr/bin/env python3
"""
Script para aplicar mejoras de homologación de idioma a toda la documentación
del proyecto de servicios corporativos.
"""

import os
import re
from pathlib import Path

# Diccionario de reemplazos para homologación de idioma
LANGUAGE_REPLACEMENTS = {
    # Términos técnicos que deben traducirse
    'Throughput': 'Capacidad de procesamiento',
    'throughput': 'capacidad de procesamiento',
    'Single Point of Entry': 'Punto Único de Entrada',
    'Multi-tenant Security': 'Seguridad Multi-tenant',
    'Intelligent Routing': 'Enrutamiento Inteligente',
    'Resilience Patterns': 'Patrones de Resiliencia',
    'Rate Limiting': 'Limitación de Velocidad',
    'rate limiting': 'limitación de velocidad',
    'Availability': 'Disponibilidad',
    'availability': 'disponibilidad',
    'Real-time Dashboards': 'Dashboards en Tiempo Real',
    'real-time dashboards': 'dashboards en tiempo real',
    'Event Correlation': 'Correlación de Eventos',
    'event correlation': 'correlación de eventos',
    'Audit Compliance': 'Cumplimiento de Auditoría',
    'audit compliance': 'cumplimiento de auditoría',
    'Historical Analysis': 'Análisis Histórico',
    'historical analysis': 'análisis histórico',
    'Alerting & Monitoring': 'Alertas y Monitoreo',
    'alerting & monitoring': 'alertas y monitoreo',
    'Federation Support': 'Soporte de Federación',
    'federation support': 'soporte de federación',
    'User Lifecycle Management': 'Gestión de Ciclo de Vida de Usuario',
    'user lifecycle management': 'gestión de ciclo de vida de usuario',
    'Session Management': 'Gestión de Sesiones',
    'session management': 'gestión de sesiones',
    'Multi-Factor Authentication': 'Autenticación Multi-Factor',
    'multi-factor authentication': 'autenticación multi-factor',
    'Self-Service Portal': 'Portal de Autoservicio',
    'self-service portal': 'portal de autoservicio',
    'Structured Logging': 'Registro Estructurado',
    'structured logging': 'registro estructurado',
    'Distributed Tracing': 'Trazado Distribuido',
    'distributed tracing': 'trazado distribuido',
    'Error Handling': 'Manejo de Errores',
    'error handling': 'manejo de errores',
    'Circuit Breaker Pattern': 'Patrón Circuit Breaker',
    'circuit breaker pattern': 'patrón circuit breaker',
    'Retry with Exponential Backoff': 'Reintentos con Backoff Exponencial',
    'retry with exponential backoff': 'reintentos con backoff exponencial',
    'Timeout Policies': 'Políticas de Timeout',
    'timeout policies': 'políticas de timeout',
    'Load Balancing': 'Balanceador de Carga',
    'load balancing': 'balanceador de carga',
    'Health Monitoring': 'Monitoreo de Salud',
    'health monitoring': 'monitoreo de salud',
    'Configuration Management': 'Gestión de Configuración',
    'configuration management': 'gestión de configuración',
    'Template Management': 'Gestión de Plantillas',
    'template management': 'gestión de plantillas',
    'Message Generation': 'Generación de Mensajes',
    'message generation': 'generación de mensajes',
    'Multi-Protocol Delivery': 'Entrega Multi-Protocolo',
    'multi-protocol delivery': 'entrega multi-protocolo',
    'Partner Configuration': 'Configuración de Partner',
    'partner configuration': 'configuración de partner',
    'Delivery Scheduling': 'Programación de Entrega',
    'delivery scheduling': 'programación de entrega',
    'Format Validation': 'Validación de Formato',
    'format validation': 'validación de formato',
    'Real-time Monitoring': 'Monitoreo en Tiempo Real',
    'real-time monitoring': 'monitoreo en tiempo real',
    
    # Títulos de secciones comunes
    'Building Blocks': 'Componentes de Construcción',
    'building blocks': 'componentes de construcción',
    'Whitebox': 'Caja Blanca',
    'whitebox': 'caja blanca',
    'Blackbox': 'Caja Negra',
    'blackbox': 'caja negra',
    'Cross-cutting Concerns': 'Conceptos Transversales',
    'cross-cutting concerns': 'conceptos transversales',
    'Quality Requirements': 'Requisitos de Calidad',
    'quality requirements': 'requisitos de calidad',
    'Technical Debt': 'Deuda Técnica',
    'technical debt': 'deuda técnica',
    'Architecture Decisions': 'Decisiones de Arquitectura',
    'architecture decisions': 'decisiones de arquitectura',
    
    # Términos de roles y equipos
    'Marketing Teams': 'Equipos de Marketing',
    'marketing teams': 'equipos de marketing',
    'Customer Support': 'Soporte al Cliente',
    'customer support': 'soporte al cliente',
    'Operations Teams': 'Equipos Operacionales',
    'operations teams': 'equipos operacionales',
    'DevOps Team': 'Equipo DevOps',
    'devops team': 'equipo devops',
    'Security Team': 'Equipo de Seguridad',
    'security team': 'equipo de seguridad',
    'Legal Team': 'Equipo Legal',
    'legal team': 'equipo legal',
    'Finance Team': 'Equipo de Finanzas',
    'finance team': 'equipo de finanzas',
    'External Providers': 'Proveedores Externos',
    'external providers': 'proveedores externos',
    'End Recipients': 'Destinatarios Finales',
    'end recipients': 'destinatarios finales',
    'Marketing Users': 'Usuarios de Marketing',
    'marketing users': 'usuarios de marketing',
    'API Developers': 'Desarrolladores API',
    'api developers': 'desarrolladores api',
    
    # Términos de procesos y operaciones
    'troubleshooting': 'resolución de problemas',
    'Troubleshooting': 'Resolución de problemas',
    'best practices': 'mejores prácticas',
    'Best Practices': 'Mejores Prácticas',
    'runbooks': 'runbooks',
    'Runbooks': 'Runbooks',
    'compliance reports': 'reportes de cumplimiento',
    'Compliance Reports': 'Reportes de Cumplimiento',
    'audit trails': 'trazas de auditoría',
    'Audit Trails': 'Trazas de Auditoría',
    'cost reporting': 'reportes de costos',
    'Cost Reporting': 'Reportes de Costos',
    'optimization metrics': 'métricas de optimización',
    'Optimization Metrics': 'Métricas de Optimización',
    
    # Términos de infraestructura y tecnología
    'REST clients': 'clientes REST',
    'REST Clients': 'Clientes REST',
    'email clients': 'clientes de email',
    'Email Clients': 'Clientes de Email',
    'mobile apps': 'aplicaciones móviles',
    'Mobile Apps': 'Aplicaciones Móviles',
    'admin UI': 'interfaz de administración',
    'Admin UI': 'Interfaz de Administración',
    'dashboards': 'dashboards',
    'Dashboards': 'Dashboards',
    'alerting': 'alertas',
    'Alerting': 'Alertas',
}

def apply_language_improvements(file_path):
    """Aplica mejoras de homologación de idioma a un archivo."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # Aplicar reemplazos
        for english_term, spanish_term in LANGUAGE_REPLACEMENTS.items():
            # Reemplazar términos completos (evitar reemplazos parciales)
            pattern = r'\b' + re.escape(english_term) + r'\b'
            content = re.sub(pattern, spanish_term, content)
        
        # Si hubo cambios, escribir el archivo
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            return True
        
        return False
    
    except Exception as e:
        print(f"Error procesando {file_path}: {e}")
        return False

def main():
    """Función principal para aplicar mejoras a toda la documentación."""
    docs_dir = Path('/mnt/d/dev/work/talma/tlm-arq-servicios-corporativos/docs')
    
    if not docs_dir.exists():
        print(f"Directorio de documentación no encontrado: {docs_dir}")
        return
    
    # Encontrar todos los archivos .md
    md_files = list(docs_dir.rglob('*.md'))
    
    print(f"Encontrados {len(md_files)} archivos de documentación")
    print("Aplicando mejoras de homologación de idioma...")
    
    processed_count = 0
    modified_count = 0
    
    for md_file in md_files:
        # Saltar el archivo de referencia arc42
        if 'Documentación de arc42.md' in str(md_file):
            continue
            
        processed_count += 1
        if apply_language_improvements(md_file):
            modified_count += 1
            print(f"✅ Modificado: {md_file.relative_to(docs_dir)}")
        else:
            print(f"⚪ Sin cambios: {md_file.relative_to(docs_dir)}")
    
    print(f"\n📊 Resumen:")
    print(f"   Archivos procesados: {processed_count}")
    print(f"   Archivos modificados: {modified_count}")
    print(f"   Mejoras aplicadas exitosamente ✅")

if __name__ == "__main__":
    main()
