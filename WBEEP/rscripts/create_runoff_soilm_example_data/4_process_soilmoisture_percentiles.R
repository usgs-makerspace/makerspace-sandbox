# Take example data values (1 week) and calculate their based on the max soil moisture for the HRU.

library(data.table)

# Load necessary data files
max_dt <- readRDS("WBEEP/cache/nhru_soilm_max_reshape.rds")
value_dt <- readRDS("WBEEP/cache/nhru_soilm_1wk_reshape.rds")

value_max_dt <- merge(value_dt, max_dt, all.x = TRUE)
per_dt <- value_max_dt[, Soilm_per := Soilm_va / Soilm_max ]

saveRDS(per_dt, "WBEEP/cache/soilm_percentiles_1wk.rds")
