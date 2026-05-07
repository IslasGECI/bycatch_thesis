#!/bin/bash
# ==========================================
# Título: Pull GitHub Issue to TODO.md
# Contexto: Este script automatiza la carga de un "Gold" (GitHub Issue)
# al espacio de trabajo activo (TODO.md).
# Descripción: Obtiene el título y el cuerpo de un issue de GitHub usando 'gh'
# y sobreescribe TODO.md con el formato del proyecto.
# Entradas: Número de issue (Argumento 1)
# Salidas: TODO.md actualizado
# Dependencias: gh (GitHub CLI)
# ==========================================

ISSUE_NUM=$1

if [ -z "$ISSUE_NUM" ]; then
    echo "Error: Debes proporcionar un número de issue."
    echo "Uso: $0 <número_de_issue>"
    exit 1
fi

echo "Obteniendo Issue #$ISSUE_NUM desde GitHub..."

# Obtener título y cuerpo en formato JSON
ISSUE_DATA=$(gh issue view "$ISSUE_NUM" --json title,body)

if [ $? -ne 0 ]; then
    echo "Error: No se pudo encontrar el Issue #$ISSUE_NUM."
    exit 1
fi

# Extraer campos usando python (ya que está disponible en el entorno y es robusto para JSON)
TITLE=$(echo "$ISSUE_DATA" | python3 -c "import sys, json; print(json.load(sys.stdin)['title'])")
BODY=$(echo "$ISSUE_DATA" | python3 -c "import sys, json; print(json.load(sys.stdin)['body'])")

# Escribir a TODO.md con el encabezado estándar
echo "# Issue #$ISSUE_NUM: $TITLE" > TODO.md
echo "" >> TODO.md
echo "$BODY" >> TODO.md

echo "Éxito: TODO.md actualizado con el Issue #$ISSUE_NUM."
