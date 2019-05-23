# Reshape data using data.table

library(data.table)

# Read in the RDS
# Transform them from wide (109K + columns) to long (3 columns)
#    The resulting columns will be Date, HRU, and Soilm_va
#    Use data.table `melt` to reshape them since they are so big.

# lplatt had to close all other applications and restart RStudio before running the 
#   readRDS + melt lines below in order to allocate enough memory on her computer.

soilm_data_15yrs <- readRDS("WBEEP/cache/nhru_soilm_15yrs.rds")
soilm_data_15yrs[, Year := NULL]
soilm_data_15yrs_fix <- data.table::melt(
  soilm_data_15yrs,
  id.vars = c("Date"),
  variable.name = "HRU",
  value.name = "Soilm_va"
)

soilm_data_1wk <- readRDS("WBEEP/cache/nhru_soilm_1wk.rds")
soilm_data_1wk[, Year := NULL]
soilm_data_1wk_fix <- data.table::melt(
  soilm_data_1wk,
  id.vars = c("Date"),
  variable.name = "HRU",
  value.name = "Soilm_va"
)

# Saving these intermediate versions takes ~ 3 min
saveRDS(soilm_data_15yrs_fix, "WBEEP/cache/nhru_soilm_15yrs_reshape.rds")
saveRDS(soilm_data_1wk_fix, "WBEEP/cache/nhru_soilm_1wk_reshape.rds")
