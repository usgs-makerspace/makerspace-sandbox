# Fetch snowpack data in order to create example data
# Hydrologic Response Units = HRUs

library(data.table)
#library(sbtools)

### Example modeled data from Blodgett's code

# Get snowpack csv
# Downloaded from the following link because using sbtools was taking wayyyyyyyyyy
# too long. Took over an hour and a half and then I gave up.
# https://www.sciencebase.gov/catalog/item/5a4ea3bee4b0d05ee8c6647b

# IF science base download would work, I would use this code:
# authenticate_sb()
# nhm_prms_sbid <- "5a4ea3bee4b0d05ee8c6647b"
# nhm_prms_sbitem <- item_get(nhm_prms_sbid)
# nhm_prms_files <- item_list_files(nhm_prms_sbitem)
# snwpk_i <- grep("nhru_sroff", nhm_prms_files$fname)
# snwpk_data_fn <- nhm_prms_files$url[snwpk_i]

# URL: https://www.sciencebase.gov/catalog/item/5a4ea3bee4b0d05ee8c6647b
# Download and unzip: nhru_pkwater_equiv.zip
# Then save the nhru_pkwater_equiv.csv file to the `cache/` folder. 
# The line below will be used as the file path unless sbtools method works.
snwpk_data_fn <- "cache/nhru_pkwater_equiv.csv"

# Read in the initial snowpack data using fread since there are 109,952 columns
snwpk_data <- fread(snwpk_data_fn, header=TRUE)

# Filter out to get just the last 15 years & last week of data
#   Last 15 years will be used to calculate quantiles
#   Last 1 week will be used as the actual values for the example data
snwpk_data[, Date := as.Date(Date)]
snwpk_data[, Year := as.numeric(format(Date, "%Y"))] # use data table to add year column
max_date <- max(snwpk_data$Date) # get the max date in the dataset to use for filtering
max_year <- max(snwpk_data$Year) # get the max year in the dataset to use for filtering
snwpk_data_15yrs <- snwpk_data[Year >= max_year - 15]
snwpk_data_1wk <- snwpk_data_15yrs[max_date - Date <= 7]

# Saving these intermediate versions takes ~ 3 min
saveRDS(snwpk_data_15yrs, "cache/nhru_snwpk_15yrs.rds")
saveRDS(snwpk_data_1wk, "cache/nhru_snwpk_1wk.rds")
