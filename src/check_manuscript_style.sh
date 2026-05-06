#!/usr/bin/env bash
# ==========================================
# Título: Validador de estilo de manuscritos
# Contexto (Por qué): Los manuscritos (1?_*.md y 2?_*.md) deben cumplir
#   con restricciones de legibilidad: ≤25 palabras por oración,
#   ≤200 palabras por párrafo, y puntuación adecuada.
# Descripción (Qué / Cómo): Valida que cada línea termine con
#   puntuación adecuada y que todas las oraciones sean ≤25 palabras.
#   Itera sobre archivos de manuscrito y reporta violaciones.
# Entradas: Archivos markdown (1?_*.md o 2?_*.md en directorio actual)
# Salidas: Mensajes de error a stdout; código de salida 0 si pasa, 1 si falla
# Dependencias: grep, egrep, wc, bash
# Notas:
#   - Requiere estar en el directorio raíz del proyecto
#   - Se puede llamar con patrón: check_manuscript_style.sh "1?_*.md"
#   - Usa expresiones regulares extendidas para coincidencia
# ==========================================

# Obtener el patrón de archivos (por defecto: Paper 1)
PATTERN="${1:-1?_*.md}"

# Rastrear si hay errores
HAS_ERRORS=0

# ==========================================
# VERIFICACIÓN 1: Las líneas terminan con puntuación adecuada
# ==========================================
check_line_endings() {
    local file="$1"

    echo "Checking line endings in: $file"

    # Encontrar líneas que NO terminan con puntuación válida
    # Excluir líneas que terminan con: : . ? o comienzan con "1. " o caracteres no-palabra
    local lines_without_period
    lines_without_period=$(egrep -v ":$" "$file" | \
                          egrep -v "\.$" | \
                          egrep -v "\?$" | \
                          egrep -v "^1\. " | \
                          egrep -v "^\W" || true)

    if [[ -n "$lines_without_period" ]]; then
        echo "❌ Lines without proper punctuation:"
        echo "$lines_without_period"
        HAS_ERRORS=1
    fi
}

# ==========================================
# VERIFICACIÓN 2: Las oraciones tienen ≤25 palabras
# ==========================================
check_sentence_length() {
    local file="$1"

    echo "Checking sentence length in: $file"

    local max_words=25
    local line_count=0
    local violations=0

    # Procesar líneas que terminan con : . ? o comienzan con "1. " o caracteres no-palabra
    for pattern in ":$" "\.$" "\?$" "^1\. " "^\W"; do
        IFS=$'\n' read -d '' -r -a lines < <(egrep "$pattern" "$file" || true) || true

        for line in "${lines[@]}"; do
            ((line_count++))
            local word_count
            word_count=$(echo "$line" | wc -w)

            if [[ $word_count -gt $max_words ]]; then
                echo "❌ Line $line_count exceeds $max_words words ($word_count words):"
                echo "   $line"
                ((violations++))
                HAS_ERRORS=1
            fi
        done
    done

    if [[ $violations -eq 0 ]]; then
        echo "✅ All sentences are ≤$max_words words"
    fi
}

# ==========================================
# VERIFICACIÓN 3: Los párrafos tienen ≤200 palabras
# ==========================================
check_paragraph_length() {
    local file="$1"

    echo "Checking paragraph length in: $file"

    awk '
      BEGIN {
        RS = "";
        max = 200;
        para_num = 0;
        fail = 0;
      }
      {
        para_num++;
        words = NF;
        if (words > max) {
          split($0, lines, "\n");
          printf "❌ Paragraph %d too long (%d words)\n→ %s\n\n",
                 para_num, words, lines[1];
          fail = 1;
        }
      }
      END {
        if (fail) exit 1;
        else printf "✅ All paragraphs are ≤%d words\n", max;
      }
    ' "$file" || HAS_ERRORS=1
}

# ==========================================
# ENTRADA PRINCIPAL
# ==========================================
main() {
    echo "============================================"
    echo "Manuscript Style Checker"
    echo "Pattern: $PATTERN"
    echo "============================================"
    echo ""

    local file_count=0

    for file in $PATTERN; do
        if [[ -f "$file" ]]; then
            ((file_count++))
            echo ""
            echo "─────────────────────────────────────────"
            check_line_endings "$file"
            echo ""
            check_sentence_length "$file"
            echo ""
            check_paragraph_length "$file"
            echo "─────────────────────────────────────────"
        fi
    done

    if [[ $file_count -eq 0 ]]; then
        echo "⚠️  No files matching pattern: $PATTERN"
        HAS_ERRORS=1
    fi

    echo ""
    if [[ $HAS_ERRORS -eq 0 ]]; then
        echo "✅ All checks passed!"
        return 0
    else
        echo "❌ Some checks failed"
        return 1
    fi
}

main "$@"
