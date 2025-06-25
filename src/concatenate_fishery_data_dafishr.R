library(fs)
library(purrr)
library(tidyverse)


csv_file_list <- dir_ls("/workdir/data/raw/VMS-data/", recurse = T, regexp = "[.]csv$")
df_list <- map(csv_file_list, read_csv, na = c("", "NULL"), col_types = list(FechaRecepcionUnitrac = col_datetime(format = "%d/%m/%Y %H:%M")))
bind_rows(df_list) |>
  drop_na(Latitud, any_of("Longitud")) |>
  write_csv("/workdir/data/processed/fisheries_gps_points_ascii.csv")
