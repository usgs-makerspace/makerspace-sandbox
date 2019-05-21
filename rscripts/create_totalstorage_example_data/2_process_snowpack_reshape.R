# Reshape data using data.table

library(data.table)

# Read in the RDS
# Transform them from wide (109K + columns) to long (3 columns)
#    The resulting columns will be Date, HRU, and Snwpk_va
#    Use data.table `melt` to reshape them since they are so big.

# lplatt had to close all other applications and restart RStudio before running the 
#   readRDS + melt lines below in order to allocate enough memory on her computer.

snwpk_data_15yrs <- readRDS("cache/nhru_snwpk_15yrs.rds")
snwpk_data_15yrs[, Year := NULL]
snwpk_data_15yrs_fix <- data.table::melt(
  snwpk_data_15yrs,
  id.vars = c("Date"),
  variable.name = "HRU",
  value.name = "Snwpk_va"
)

snwpk_data_1wk <- readRDS("cache/nhru_snwpk_1wk.rds")
snwpk_data_1wk[, Year := NULL]
snwpk_data_1wk_fix <- data.table::melt(
  snwpk_data_1wk,
  id.vars = c("Date"),
  variable.name = "HRU",
  value.name = "Snwpk_va"
)

# Saving these intermediate versions takes ~ 3 min
saveRDS(snwpk_data_15yrs_fix, "cache/nhru_snwpk_15yrs_reshape.rds")
saveRDS(snwpk_data_1wk_fix, "cache/nhru_snwpk_1wk_reshape.rds")
