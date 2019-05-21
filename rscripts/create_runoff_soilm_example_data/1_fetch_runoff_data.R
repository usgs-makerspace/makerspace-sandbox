# Fetch runoff data in order to create example data
# Hydrologic Response Units = HRUs

library(data.table)
#library(sbtools)

### Example modeled data from Blodgett's code

# Get runoff csv
# Downloaded from the following link because using sbtools was taking wayyyyyyyyyy
# too long. Took over an hour and a half and then I gave up.
# https://www.sciencebase.gov/catalog/item/5a4ea3bee4b0d05ee8c6647b

# IF science base download would work, I would use this code:
# authenticate_sb()
# nhm_prms_sbid <- "5a4ea3bee4b0d05ee8c6647b"
# nhm_prms_sbitem <- item_get(nhm_prms_sbid)
# nhm_prms_files <- item_list_files(nhm_prms_sbitem)
# runoff_i <- grep("nhru_sroff", nhm_prms_files$fname)
# runoff_data_fn <- nhm_prms_files$url[runoff_i]

# URL: https://www.sciencebase.gov/catalog/item/5a4ea3bee4b0d05ee8c6647b
# Download and unzip: nhru_sroff.zip
# Then save the nhru_sroff.csv file to the `cache/` folder. 
# The line below will be used as the file path unless sbtools method works.
runoff_data_fn <- "cache/nhru_sroff.csv"

# Read in the initial runoff data using fread since there are 109,952 columns
runoff_data <- fread(runoff_data_fn, header=TRUE)

# Filter out to get just the last 25 years & last week of data
#   Last 25 years will be used to calculate quantiles
#   Last 1 week will be used as the actual values for the example data
runoff_data[, Date := as.Date(Date)]
runoff_data[, Year := as.numeric(format(Date, "%Y"))] # use data table to add year column
max_date <- max(runoff_data$Date) # get the max date in the dataset to use for filtering
max_year <- max(runoff_data$Year) # get the max year in the dataset to use for filtering
runoff_data_25yrs <- runoff_data[Year >= max_year - 25]
runoff_data_1wk <- runoff_data_25yrs[max_date - Date <= 7]

# Saving these intermediate versions takes ~ 3 min
saveRDS(runoff_data_25yrs, "cache/nhru_runoff_25yrs.rds")
saveRDS(runoff_data_1wk, "cache/nhru_runoff_1wk.rds")
