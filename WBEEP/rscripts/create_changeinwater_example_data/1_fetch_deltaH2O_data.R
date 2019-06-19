# Downloaded "change in water" vars from ScienceBase
# hru_ppt - hru_actet data 

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
fetch_data("hru_ppt") # precipitation
fetch_data("hru_actet") # evapotranspiration
