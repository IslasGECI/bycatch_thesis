library(fs)
library(purrr)
library(tidyverse)


csv_file_list <- dir_ls("/workdir/data/raw/conapesca/", recurse = TRUE, regexp = "[.]csv$")
df_list <- map(
  csv_file_list,
  read_csv,
  na = c("", "NULL"),
  col_types = cols(
    FechaRecepcionUnitrac = col_datetime(format = "%d/%m/%Y %H:%M"),
    RNP = col_character(),
    RNPA = col_character(),
    Rumbo = col_character(),
    Velocidad = col_character()
  )
)
bind_rows(df_list) |>
  write_csv("/workdir/data/processed/fisheries_gps_points_ascii.csv")
