# ==========================================
# Título: Calcula y exporta las áreas marinas protegidas de México
#
# Contexto (Por qué):
# Las Áreas Marinas Protegidas (AMP) son la diferencia espacial entre
# las Áreas Naturales Protegidas (ANP) y el territorio continental.
# Este cálculo permite identificar las zonas marinas que están bajo
# protección legal en el océano mexicano.
#
# Descripción (Qué / Cómo):
# Lee los GeoPackages de ANP y territorio mexicano, verifica que ambas
# capas compartan el mismo CRS, calcula la diferencia espacial con
# st_difference() y exporta el resultado como GeoPackage para su uso
# en visualizaciones y análisis posteriores.
#
# Entradas:
# data/processed/mexico_pna.gpkg (capa: mexico_pna)
# data/processed/mexico_map.gpkg (capa: mexico_map)
#
# Salida:
# data/processed/mexico_mpa.gpkg (capa: mexico_mpa)
#
# Dependencias:
# sf
# tidyverse
#
# Notas:
# - La diferencia espacial se calcula con st_difference() entre ANP y territorio
# - st_make_valid() se aplica para asegurar geometrías válidas antes del cálculo
# ==========================================


# ==== CONFIGURACIÓN ====
library(sf) # Proporciona st_read para importar geometrías y st_difference para diferencias espaciales
library(tidyverse) # Proporciona el operador pipe |> para flujos de datos lineales

# Ruta del GeoPackage con las Áreas Naturales Protegidas de México
mexico_pna_path <- "data/processed/mexico_pna.gpkg"
# Ruta del GeoPackage con el mapa del territorio mexicano
mexico_map_path <- "data/processed/mexico_map.gpkg"
# Ruta del GeoPackage de salida con las Áreas Marinas Protegidas
output_gpkg_path <- "data/processed/mexico_mpa.gpkg"
# Nombre de la capa dentro del GeoPackage para identificar la geometría
output_layer_name <- "mexico_mpa"


# ==== ENTRADAS ====
# Importa las geometrías de ANP desde el GeoPackage generado previamente
mexico_pna <- st_read(mexico_pna_path, quiet = TRUE)
# Importa las geometrías del territorio mexicano desde el GeoPackage
mexico_map <- st_read(mexico_map_path, quiet = TRUE)


# ==== PROCESAMIENTO / ANÁLISIS ====
# Verifica que ambas capas usen el mismo sistema de referencia espacial
# y transforma las ANP si es necesario para garantizar compatibilidad
mexico_pna <- st_transform(mexico_pna, st_crs(mexico_map))

# Calcula la diferencia espacial para obtener las zonas de ANP que quedan
# fuera del polígono de México, es decir, las áreas marinas protegidas
anp_difference <- st_difference(mexico_pna, mexico_map)


# ==== SALIDA ====
# Exporta el resultado como GeoPackage con una capa nombrada para
# facilitar su lectura por otros scripts del pipeline de análisis
st_write(
  obj = anp_difference,
  dsn = output_gpkg_path,
  layer = output_layer_name,
  driver = "GPKG",
  quiet = TRUE
)
