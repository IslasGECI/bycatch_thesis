#!/bin/bash
# ==========================================
# Título: Sync TODO.md to GitHub
# Contexto: Este script automatiza la sincronización de las tareas locales en TODO.md
# con el "Permanent Gold Store" en GitHub Issues.
# Descripción: Extrae el número del issue de la primera línea de TODO.md y
# actualiza el cuerpo del issue en GitHub usando la CLI 'gh'.
# Entradas: TODO.md
# Salidas: Actualización en GitHub Issue
# Dependencias: gh (GitHub CLI)
# ==========================================

# Verificación de existencia de TODO.md
if [ ! -f "TODO.md" ]; then
    echo "Error: TODO.md no encontrado."
    exit 1
fi

# Extraer el número del issue de la primera línea
# Soporta: "# Issue #46: ..."
ISSUE_NUM=$(grep -oP "(?<=#)\d+" TODO.md | head -n 1)

if [ -z "$ISSUE_NUM" ]; then
    echo "Error: No se encontró el número de issue en la primera línea de TODO.md."
    echo "Formato esperado: Issue #<número> en la primera línea."
    exit 1
fi

# Actualizar el issue en GitHub
echo "Sincronizando Issue #$ISSUE_NUM con TODO.md (sin encabezado)..."

# Crear un archivo temporal sin la primera línea (el encabezado) y sin líneas vacías iniciales
TEMP_BODY=$(mktemp)
# Elimina la primera línea y luego todas las líneas vacías al principio del archivo resultante
sed '1d' TODO.md | sed '/./,$!d' > "$TEMP_BODY"

gh issue edit "$ISSUE_NUM" --body-file "$TEMP_BODY"

# Limpieza
rm "$TEMP_BODY"

if [ $? -eq 0 ]; then
    echo "Sincronización exitosa: https://github.com/IslasGECI/bycatch_thesis/issues/$ISSUE_NUM"
else
    echo "Error al sincronizar con GitHub."
    exit 1
fi
