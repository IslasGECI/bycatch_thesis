# ==========================================
# Título: Exporta el sitio potencial KBA como polígono único
#
# Contexto (Por qué):
# Las figuras del proyecto representan el sitio potencial KBA como un
# polígono púrpura que cada script deriva sobre la marcha. Exportarlo
# como GeoPackage independiente evita recalcularlo en cada consumo.
# Un artefacto único en data/processed/ habilita su uso en QGIS.
#
# Descripción (Qué / Cómo):
# Lee el GeoPackage de polígonos KBA de todas las colonias, filtra las
# celdas con potentialSite = TRUE y disuelve sus geometrías en un solo
# MULTIPOLYGON con summarise(). Exporta el resultado como GeoPackage
# para consumirlo desde sistemas externos o análisis posteriores.
#
# Entradas:
# data/processed/kba_polygons_all.gpkg
#
# Salida:
# data/processed/kba_potential_site_all.gpkg
#
# Dependencias:
# sf
# tidyverse
#
# Notas:
# - summarise() disuelve las 22 celdas del sitio potencial en un solo contorno
# - La salida solo contiene geometría, sin atributos
# ==========================================


# ==== CONFIGURACIÓN ====
library(sf) # Proporciona st_read para importar geometrías y st_write para exportarlas
library(tidyverse) # Proporciona el operador pipe |> y filter para filtrar filas

# Ruta del GeoPackage con los polígonos KBA de todas las colonias
input_kba_path <- "data/processed/kba_polygons_all.gpkg"
# Ruta del GeoPackage que almacenará el sitio potencial KBA disuelto
output_gpkg_path <- "data/processed/kba_potential_site_all.gpkg"


# ==== ENTRADAS ====
# Importa los polígonos KBA de todas las colonias desde el GeoPackage
# generado por bycatch::create_potential_kba()
kba_polygons_sf <- st_read(input_kba_path, quiet = TRUE)


# ==== PROCESAMIENTO / ANÁLISIS ====
# Desactiva la validación S2 para evitar errores por geometrías inválidas
# durante el filtrado y la disolución de los polígonos KBA
sf_use_s2(FALSE)
# Filtra los polígonos KBA para conservar solo las celdas identificadas
# como sitio potencial (potentialSite = TRUE) que corresponden al polígono
# morado que renderizan los mapas del proyecto
kba_potential_site_sf <- kba_polygons_sf |>
  filter(potentialSite == TRUE) |>
  # summarise() sin argumentos disuelve automáticamente las celdas del
  # sitio potencial en un solo MULTIPOLYGON con cero atributos
  summarise()


# ==== SALIDA ====
# Exporta el sitio potencial KBA como GeoPackage para consumirlo desde
# sistemas externos sin recalcular la disolución en cada script
st_write(
  obj = kba_potential_site_sf,
  dsn = output_gpkg_path,
  driver = "GPKG",
  delete_dsn = TRUE,
  quiet = TRUE
)
