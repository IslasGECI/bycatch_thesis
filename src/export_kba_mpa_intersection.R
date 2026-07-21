# ==========================================
# Título: Calcula la intersección entre los polígonos KBA y las AMP de México
#
# Contexto (Por qué):
# Los polígonos de Áreas Clave para la Biodiversidad (KBA) representan zonas
# de alimentación del albatros de Laysan. Las Áreas Marinas Protegidas (AMP)
# definen zonas marinas bajo protección legal. Su intersección identifica
# qué fracción del KBA está protegida dentro del sistema de AMP.
#
# Descripción (Qué / Cómo):
# Lee el GeoPackage de polígonos KBA de las colonias Guadalupe, Clarion y San
# Benedicto y el GeoPackage de Áreas Marinas Protegidas de México. Verifica que
# ambas capas compartan el mismo CRS. Calcula la intersección espacial con
# st_intersection(). Exporta el resultado como GeoPackage para graficarlo en el
# siguiente paso.
#
# Entradas:
# data/processed/kba_polygons_all.gpkg
# data/processed/mexico_mpa.gpkg
#
# Salida:
# data/processed/kba_mpa_intersection_all.gpkg
#
# Dependencias:
# sf
# tidyverse
#
# Notas:
# - st_make_valid() corrige geometrías inválidas antes de la intersección
# - st_intersection() recorta los polígonos KBA a la extensión de las AMP
# - Ambas capas están en WGS 84 (EPSG:4326), no requiere reproyección
# ==========================================


# ==== CONFIGURACIÓN ====
library(sf) # Proporciona st_read para importar geometrías y st_intersection para operaciones espaciales
library(tidyverse) # Proporciona el operador pipe |> para flujos de datos lineales

# Ruta del GeoPackage con los polígonos KBA de todas las colonias
input_kba_path <- "data/processed/kba_polygons_all.gpkg"
# Ruta del GeoPackage con las Áreas Marinas Protegidas de México
input_mpa_path <- "data/processed/mexico_mpa.gpkg"
# Ruta del GeoPackage que almacenará la intersección espacial KBA ∩ AMP
output_gpkg_path <- "data/processed/kba_mpa_intersection_all.gpkg"


# ==== ENTRADAS ====
# Importa los polígonos KBA de todas las colonias desde el GeoPackage
# generado por bycatch::create_potential_kba()
kba_polygons_sf <- st_read(input_kba_path, quiet = TRUE)
# Importa las Áreas Marinas Protegidas de México desde el GeoPackage
# generado por export_mexico_mpa_to_gpkg.R
mexico_mpa_sf <- st_read(input_mpa_path, quiet = TRUE)


# ==== PROCESAMIENTO / ANÁLISIS ====
# Verifica que ambas capas compartan el mismo CRS para evitar errores
# topológicos al calcular la intersección espacial
stopifnot(st_crs(kba_polygons_sf) == st_crs(mexico_mpa_sf))
# Desactiva la validación S2 para evitar errores por geometrías inválidas
# en los polígonos KBA durante el filtrado y la intersección espacial
sf_use_s2(FALSE)
# Filtra los polígonos KBA para conservar solo las celdas identificadas
# como sitio potencial (potentialSite = TRUE) que corresponden al polígono
# rojo que renderiza bycatch::render_potential_kba()
kba_polygons_sf <- kba_polygons_sf |>
  filter(potentialSite == TRUE)
# Valida y corrige geometrías potencialmente inválidas en ambas capas antes
# de la intersección para evitar errores por auto-intersecciones o vértices
# duplicados en los polígonos de las AMP
kba_polygons_valid_sf <- kba_polygons_sf |>
  st_make_valid()
mexico_mpa_valid_sf <- mexico_mpa_sf |>
  st_make_valid()
# Calcula la intersección espacial que recorta los polígonos KBA usando
# las AMP como máscara geográfica para identificar zonas protegidas
kba_mpa_intersection_sf <- st_intersection(kba_polygons_valid_sf, mexico_mpa_valid_sf)


# ==== SALIDA ====
# Exporta el resultado de la intersección como GeoPackage para consumirlo
# en el script de visualización plot_kba_mpa_intersection.R
st_write(
  obj = kba_mpa_intersection_sf,
  dsn = output_gpkg_path,
  driver = "GPKG",
  delete_dsn = TRUE,
  quiet = TRUE
)
