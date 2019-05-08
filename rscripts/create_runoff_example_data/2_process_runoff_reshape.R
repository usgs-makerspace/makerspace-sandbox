# Reshape data using data.table

# Read in the RDS
# Transform them from wide (109K + columns) to long (3 columns)
#    The resulting columns will be Date, HRU, and Runoff_va
#    Use data.table `melt` to reshape them since they are so big.

# lplatt had to close all other applications and restart RStudio before running the 
#   readRDS + melt lines below in order to allocate enough memory on her computer.

runoff_data_25yrs <- readRDS("cache/nhru_runoff_25yrs.rds")
runoff_data_25yrs[, Year := NULL]
runoff_data_25yrs_fix <- data.table::melt(
  runoff_data_25yrs,
  id.vars = c("Date"),
  variable.name = "HRU",
  value.name = "Runoff_va"
)

runoff_data_1wk <- readRDS("cache/nhru_runoff_1wk.rds")
runoff_data_1wk[, Year := NULL]
runoff_data_1wk_fix <- data.table::melt(
  runoff_data_1wk,
  id.vars = c("Date"),
  variable.name = "HRU",
  value.name = "Runoff_va"
)

# Saving these intermediate versions takes ~ 3 min
saveRDS(runoff_data_25yrs_fix, "cache/nhru_runoff_25yrs_reshape.rds")
saveRDS(runoff_data_1wk_fix, "cache/nhru_runoff_1wk_reshape.rds")
