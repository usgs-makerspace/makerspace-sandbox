# Reshape data

library(data.table)

# Read in the RDS
# Transform them from wide (109K + columns) to long (3 columns)
#    The resulting columns will be Date, HRU, and Recharge_va
#    Use data.table `melt` to reshape them since they are so big.

# lplatt had to close all other applications and restart RStudio before running the 
#   readRDS + melt lines below in order to allocate enough memory on her computer.

recharge_data_25yrs <- readRDS("cache/nhru_recharge_25yrs.rds")
recharge_data_25yrs_fix <- melt(
  recharge_data_25yrs,
  id.vars = c("Date"),
  variable.name = "HRU",
  value.name = "Recharge_va"
)

recharge_data_1wk <- readRDS("cache/nhru_recharge_1wk.rds")
recharge_data_1wk_fix <- melt(
  recharge_data_1wk,
  id.vars = c("Date"),
  variable.name = "HRU",
  value.name = "Recharge_va"
)

# Saving these intermediate versions takes ~ 3 min
saveRDS(recharge_data_25yrs_fix, "cache/nhru_recharge_25yrs_reshape.rds")
saveRDS(recharge_data_1wk_fix, "cache/nhru_recharge_1wk_reshape.rds")
