
library(data.table)

# Calculate sum of all storage components

storage_vars <- c("pkwater_equiv", "soil_moist_tot", "hru_intcpstor",
                  "hru_impervstor", "gwres_stor", "dprst_stor_hru")
storage_cols <- c("Snwpk_va", "Soilm_va", "Intcp_va", 
                  "Imperv_va", "Gwres_va", "Dprst_va")

##### Read in storage components
# Lindsay's comp couldn't handle doing this for 5 years.
# She went to Yeti to run the `merge_data` function for "years"

combine_data_list <- function(storage_vars, type = c("yrs", "days")) {
  message(sprintf("Reading in reshaped RDS files for %s", type))
  data_list <- lapply(storage_vars, function(var_name, type) {
    readRDS(sprintf("WBEEP/cache/nhru_%s_%s_reshape.rds", var_name, type))
  }, type)
  saveRDS(data_list, sprintf("WBEEP/cache/nhru_totS_combined_%s_list.rds", type))
  return(sprintf("Completed combining %s files", type))
}


#### Try out a different solution for the future:
## https://stackoverflow.com/questions/34598139/left-join-using-data-table/34600831
merge_data <- function(type = c("yrs", "days"), dir = c("WBEEP/cache/")) {
  data_list <- readRDS(sprintf("%snhru_totS_combined_%s_list.rds", dir, type))
  message(sprintf("Merging into one data.table for %s", type))
  data <- data_list[[1]]
  # Tried to use Reduce() + merge() but that kept causing even Yeti to run out of room
  # This method used 81 GB, but the Reduce/merge method ran out of space with 120 GB
  for(i in 2:length(data_list)) {
    data <- dplyr::left_join(data, data_list[[i]], by = c("Date", "HRU"))
    print(sprintf("Completed %s of %s", i, length(data_list)))
  }
  message(sprintf("Saving into one RDS for %s", type))
  saveRDS(data, sprintf("%snhru_totS_combined_%s.rds", dir, type))
  return(sprintf("Completed merging %s files", type))
}

combine_data_list(storage_vars, "yrs")
# merge_data("yrs")
# went to Yeti for the merge_data command line instead since my comp couldn't handle
# WinSCP on Yeti: moved "WBEEP/cache/nhru_totS_combined_yrs_list.rds" to my user home dir
# Logged into Yeti on terminal
#   sinteractive -A iidd -n 1 -p normal -t 3:00:00 --mem=120GB
#   R
#   # didn't need to do: install.packages("data.table") # say yes to install on personal lib
#   ## copy & executed the merge_data function from this script ##
#   merge_data("yrs", "")
# WinSCP: moved "nhru_totS_combined_yrs.rds" from Yeti to local

# memory.limit(size=default_memory) # reset allocated memory
combine_data_list(storage_vars, "days")
merge_data("days")

#### Once you have the combined RDS files

data_days <- readRDS("WBEEP/cache/nhru_totS_combined_days.rds")

totS_data_days <- as.data.table(data_days)[, totS := rowSums(.SD), .SDcols = storage_cols]
totS_data_days[, (storage_cols) := NULL]

saveRDS(totS_data_days, "WBEEP/cache/totS_days.rds")

# Also had to do the following on Yeti because I didn't have room
# Follow same instructions above then run code below, except `local_fp <- ""`
# and make sure to `library(data.table)` and to load `storage_cols` from above
# Then sum into one new column and drop others

local_fp <- "WBEEP/cache/"
data_yrs <- readRDS(sprintf("%snhru_totS_combined_yrs.rds", local_fp))

totS_data_yrs <- as.data.table(data_yrs)[, totS := rowSums(.SD), .SDcols = storage_cols]
totS_data_yrs[, (storage_cols) := NULL]

# Save intermediate data
saveRDS(totS_data_yrs, sprintf("%stotS_yrs.rds", local_fp))
