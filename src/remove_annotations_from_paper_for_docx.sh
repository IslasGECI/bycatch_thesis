#!/usr/bin/env bash
# ==========================================
# Título: Elimina las anotaciones del manuscrito para el DOCX
# Contexto (Por qué): El PDF conserva las anotaciones [[ ]] como
#   recordatorios de edición, pero el DOCX debe presentarse sin ellas.
#   Se necesita una versión intermedia del manuscrito sin anotaciones.
# Descripción (Qué / Cómo): Lee reports/first_paper.md y escribe
#   reports/first_paper_no_annotations.md. Con awk descarta las líneas que
#   son solo una anotación y, en el resto, quita cada anotación junto con
#   un espacio adyacente. Verifica que no quede ninguna anotación y que
#   solo se hayan eliminado esas líneas.
# Entradas:
# reports/first_paper.md
# Salida:
# reports/first_paper_no_annotations.md
# Dependencias:
# awk
# grep
# wc
# Notas:
#   - Solo reconoce anotaciones de una línea
#   - No divide ni une párrafos
#   - Falla si sobran anotaciones o si se eliminó una línea de más
# ==========================================

# ==== CONFIGURACIÓN ====
# Ruta del manuscrito renderizado que contiene las anotaciones de edición
input_markdown_path="reports/first_paper.md"
# Ruta del manuscrito intermedio que alimentará al DOCX
output_markdown_path="reports/first_paper_no_annotations.md"

# ==== ENTRADAS ====
# Verifica que el manuscrito renderizado exista antes de intentar limpiarlo
if [[ ! -f "$input_markdown_path" ]]; then
    echo "❌ Error: no existe $input_markdown_path" >&2
    exit 1
fi

# ==== PROCESAMIENTO / ANÁLISIS ====
# Cuenta las anotaciones que ocupan una línea completa, porque cada una de
# esas líneas debe desaparecer del archivo de salida
whole_line_annotations=$(awk '/^[[:space:]]*\[\[[^]]*\]\][[:space:]]*$/ { total++ } END { print total + 0 }' "$input_markdown_path")
# Cuenta las líneas de entrada con NR para no depender del salto final
input_lines=$(awk 'END { print NR }' "$input_markdown_path")
# Escribe la salida descartando las líneas de anotación completa y
# quitando en las demás la anotación junto con un espacio adyacente
awk '
    /^[[:space:]]*\[\[[^]]*\]\][[:space:]]*$/ { next }
    {
        gsub(/[[:space:]]*\[\[[^]]*\]\][[:space:]]*/, " ")
        gsub(/^[[:space:]]+|[[:space:]]+$/, "")
        print
    }
' "$input_markdown_path" > "$output_markdown_path"
# Cuenta las líneas de salida para compararlas con las de entrada
output_lines=$(awk 'END { print NR }' "$output_markdown_path")
# Cuenta las anotaciones que sobrevivieron en la salida, que deben ser cero
remaining_annotations=$(grep -o '\[\[' "$output_markdown_path" | wc -l)
# Calcula cuántas líneas se eliminaron en total
removed_lines=$((input_lines - output_lines))

# ==== SALIDA ====
# Falla si alguna anotación sobrevivió al proceso de limpieza
if [[ "$remaining_annotations" -ne 0 ]]; then
    echo "❌ Error: quedan $remaining_annotations anotaciones en $output_markdown_path" >&2
    exit 1
fi
# Falla si se eliminó una cantidad de líneas distinta a las anotaciones
# completas, lo que indicaría que se borró una línea de más o de menos
if [[ "$removed_lines" -ne "$whole_line_annotations" ]]; then
    echo "❌ Error: se eliminaron $removed_lines líneas y se esperaban $whole_line_annotations" >&2
    exit 1
fi
