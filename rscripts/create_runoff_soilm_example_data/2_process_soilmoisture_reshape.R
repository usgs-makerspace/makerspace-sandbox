# Calculate max soil moisture for each HRU & reshape 1 wk data using data.table

##### First, calculate max soil moisture for each HRU

# Read in the initial soil moisture data using fread since there are 109,952 columns
soilm_data <- fread("cache/nhru_soil_moist_tot.csv", header=TRUE)

# Calculate maximum soil moisture value for each HRU
soilm_data <- soilm_data[, Date := NULL] # Remove Date column
soilm_max <- soilm_data[, lapply(.SD, max, na.rm=TRUE)] # Calculate max for each column (HRU)
# Reshape to have HRU and Soilm_max columns
soilm_max_reshape <- data.table::melt(
  soilm_max,
  variable.name = "HRU",
  value.name = "Soilm_max"
)

##### Then, reshape soil moisture data with only one week

# Read in the RDS
# Transform them from wide (109K + columns) to long (3 columns)
#    The resulting columns will be Date, HRU, and Soilm_va
#    Use data.table `melt` to reshape them since they are so big.
soilm_data_1wk <- readRDS("cache/nhru_soilm_1wk.rds")
soilm_data_1wk_fix <- data.table::melt(
  soilm_data_1wk,
  id.vars = c("Date"),
  variable.name = "HRU",
  value.name = "Soilm_va"
)

# Saving the intermediate versions
saveRDS(soilm_max_reshape, "cache/nhru_soilm_max_reshape.rds")
saveRDS(soilm_data_1wk_fix, "cache/nhru_soilm_1wk_reshape.rds")
