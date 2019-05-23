# Fetch soil moisture data in order to create example data
# Hydrologic Response Units = HRUs

library(data.table)
#library(sbtools)

### Example modeled data from Blodgett's code

# Get soil moisture csv
# Downloaded from the following link because using sbtools was taking wayyyyyyyyyy
# too long. Took over an hour and a half and then I gave up.
# https://www.sciencebase.gov/catalog/item/5a4ea3bee4b0d05ee8c6647b

# IF science base download would work, I would use this code:
# authenticate_sb()
# nhm_prms_sbid <- "5a4ea3bee4b0d05ee8c6647b"
# nhm_prms_sbitem <- item_get(nhm_prms_sbid)
# nhm_prms_files <- item_list_files(nhm_prms_sbitem)
# soilm_i <- grep("nhru_sroff", nhm_prms_files$fname)
# soilm_data_fn <- nhm_prms_files$url[soilm_i]

# URL: https://www.sciencebase.gov/catalog/item/5a4ea3bee4b0d05ee8c6647b
# Download and unzip: nhru_sroff.zip
# Then save the nhru_sroff.csv file to the `WBEEP/cache/` folder. 
# The line below will be used as the file path unless sbtools method works.
soilm_data_fn <- "WBEEP/cache/nhru_soil_moist_tot.csv"

# Read in the initial soil moisture data using fread since there are 109,952 columns
soilm_data <- fread(soilm_data_fn, header=TRUE)

# Filter out to get just the last week of data to use as the actual values for the example data
soilm_data[, Date := as.Date(Date)]
max_date <- max(soilm_data$Date) # get the max date in the dataset to use for filtering
soilm_data_1wk <- soilm_data[max_date - Date <= 7]

# Saving the intermediate version
saveRDS(soilm_data_1wk, "WBEEP/cache/nhru_soilm_1wk.rds")
