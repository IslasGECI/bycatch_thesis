#!/usr/bin/env bash
# ==========================================
# Título: Verificador de ortografía de manuscritos
# Contexto (Por qué): Los manuscritos deben pasar verificación de
#   ortografía en español e inglés usando aspell para mantener calidad
#   profesional antes de publicación.
# Descripción (Qué / Cómo): Ejecuta verificación de ortografía aspell
#   para archivos de manuscrito español e inglés usando la configuración
#   y diccionario del proyecto. Reporta errores ortográficos encontrados.
# Entradas: Archivos markdown del proyecto, configuración spellcheck.yml,
#   diccionario personalizado .wordlist.txt
# Salidas: Mensajes de error a stdout; código de salida 0 si pasa, 1 si falla
# Dependencias: aspell, python3 (pyspelling)
# Notas:
#   - Requiere estar en el directorio raíz del proyecto
#   - Usa configuración en .github/config/.spellcheck.yml
#   - Diccionario personalizado en .github/config/.wordlist.txt
# ==========================================

# Variable para rastrear si hay errores
HAS_ERRORS=0

# ==========================================
# FUNCIÓN: Verificar ortografía con aspell
# ==========================================
check_spelling() {
    local lang="$1"
    local pattern="$2"
    local lang_name="$3"
    
    echo "Checking spelling in $lang_name..."
    
    # Obtener lista de archivos que coinciden con el patrón
    local files
    files=$(eval echo "$pattern")
    
    if [[ -z "$files" ]]; then
        echo "⚠️  No files matching pattern: $pattern"
        return 0
    fi
    
    # Contador para errores
    local error_count=0
    
    # Procesar cada archivo
    for file in $files; do
        if [[ -f "$file" ]]; then
            # Usar aspell en modo markdown para verificar
            local misspellings
            misspellings=$(aspell --lang="$lang" \
                                  --ignore-case \
                                  --mode=markdown \
                                  --personal=.github/config/.wordlist.txt \
                                  list < "$file" | sort -u)
            
            if [[ -n "$misspellings" ]]; then
                echo "❌ Spelling errors in $file:"
                echo "$misspellings" | while read -r word; do
                    echo "   → $word"
                done
                ((error_count++))
                HAS_ERRORS=1
            fi
        fi
    done
    
    if [[ $error_count -eq 0 ]]; then
        echo "✅ No spelling errors found in $lang_name files"
    fi
}

# ==========================================
# ENTRADA PRINCIPAL
# ==========================================
main() {
    echo "============================================"
    echo "Manuscript Spellcheck"
    echo "============================================"
    echo ""
    
    # Verificar español (0?_*.md)
    echo "─────────────────────────────────────────"
    check_spelling "es" "0?_*.md" "Spanish"
    echo "─────────────────────────────────────────"
    echo ""
    
    # Verificar inglés Paper 1 (1?_*.md)
    echo "─────────────────────────────────────────"
    check_spelling "en" "1?_*.md" "English (Paper 1)"
    echo "─────────────────────────────────────────"
    echo ""
    
    # Verificar inglés Paper 2 (2?_*.md)
    echo "─────────────────────────────────────────"
    check_spelling "en" "2?_*.md" "English (Paper 2)"
    echo "─────────────────────────────────────────"
    echo ""
    
    if [[ $HAS_ERRORS -eq 0 ]]; then
        echo "✅ All spelling checks passed!"
        return 0
    else
        echo "❌ Some spelling checks failed"
        return 1
    fi
}

main "$@"
