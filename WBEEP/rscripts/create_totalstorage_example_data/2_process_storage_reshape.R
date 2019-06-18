# Reshape data using data.table

library(data.table)

# Read in the RDS
# Transform them from wide (109K + columns) to long (3 columns)
#    The resulting columns will be Date, HRU, and Snwpk_va
#    Use data.table `melt` to reshape them since they are so big.

# lplatt had to close all other applications and restart RStudio before running the 
#   readRDS + melt lines below in order to allocate enough memory on her computer.

reshape_data <- function(var_name, col_name) {
  
  message(sprintf("Reading in YRS data for %s", var_name))
  data_yrs <- readRDS(sprintf("WBEEP/cache/nhru_%s_yrs.rds", var_name))
  
  message(sprintf("Reshaping YRS for %s", var_name))
  data_yrs[, Year := NULL]
  data_yrs_fix <- data.table::melt(
    data_yrs,
    id.vars = c("Date"),
    variable.name = "HRU",
    value.name = col_name
  )
  
  message(sprintf("Reading in DAYS data for %s", var_name))
  data_days <- readRDS(sprintf("WBEEP/cache/nhru_%s_days.rds", var_name))
  
  message(sprintf("Reshaping DAYS for %s", var_name))
  data_days[, Year := NULL]
  data_days_fix <- data.table::melt(
    data_days,
    id.vars = c("Date"),
    variable.name = "HRU",
    value.name = col_name
  )
  
  # Saving these intermediate versions takes ~ 3 min
  message(sprintf("Saving RDS for %s", var_name))
  saveRDS(data_yrs_fix, sprintf("WBEEP/cache/nhru_%s_yrs_reshape.rds", var_name))
  saveRDS(data_days_fix, sprintf("WBEEP/cache/nhru_%s_days_reshape.rds", var_name))
  
  return(sprintf("%s completed", var_name))
}

# Now do it for all the storage variables
reshape_data("pkwater_equiv", "Snwpk_va")
reshape_data("soil_moist_tot", "Soilm_va")
reshape_data("hru_intcpstor", "Intcp_va") # vegetative interception
reshape_data("hru_impervstor", "Imperv_va") # impervious surface storage?
reshape_data("gwres_stor", "Gwres_va") # groundwater reserve storage?
reshape_data("dprst_stor_hru", "Dprst_va") # not really sure what this one is
