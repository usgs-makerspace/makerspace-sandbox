# Downloaded "other storage" vars from Yeti directory
# hru_intcpstor + hru_impervstor + gwres_stor + dprst_stor_hru data 

library(data.table)

fetch_data <- function(var_name, quantile_yrs = 5) {
  fn <- sprintf("WBEEP/cache/nhru_%s.csv", var_name)
  
  # Read in the initial data using fread since there are 109,952 columns
  message(sprintf("Reading in %s", fn))
  data <- fread(fn, header=TRUE)
  
  # Filter out to get just the last quantile_yrs & last week of data
  #   Last quantile_yrs will be used to calculate quantiles
  #   Get 1 day of data for Fall, Winter, Spring, Summer
  #   to use as the actual values for the example data
  message(sprintf("Filtering %s", var_name))
  data[, Date := as.Date(Date)]
  data[, Year := as.numeric(format(Date, "%Y"))] # use data table to add year column
  max_year <- max(data$Year) # get the max year in the dataset to use for filtering
  
  autumn <- as.Date(sprintf("%s-11-01", max_year))
  winter <- as.Date(sprintf("%s-02-01", max_year))
  spring <- as.Date(sprintf("%s-05-01", max_year))
  summer <- as.Date(sprintf("%s-08-01", max_year))
  
  data_yrs <- data[Year >= max_year - quantile_yrs]
  data_days <- data_yrs[Date %in% c(autumn, winter, spring, summer)]
  
  # Saving these intermediate versions takes ~ 3 min
  message(sprintf("Saving RDS for %s", var_name))
  saveRDS(data_yrs, sprintf("WBEEP/cache/nhru_%s_yrs.rds", var_name))
  saveRDS(data_days, sprintf("WBEEP/cache/nhru_%s_days.rds", var_name))
  
  return(sprintf("%s completed", var_name))
}

# Now do it for all the storage variables
fetch_data("pkwater_equiv") # snowpack
fetch_data("soil_moist_tot") # soil moisture
fetch_data("hru_intcpstor") # vegetative interception
fetch_data("hru_impervstor") # impervious surface storage?
fetch_data("gwres_stor") # groundwater reserve storage?
fetch_data("dprst_stor_hru") # not really sure what this one is
