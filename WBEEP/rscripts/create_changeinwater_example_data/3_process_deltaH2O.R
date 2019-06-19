# Calculate difference between precip & ET

# lplatt computer not good enough to handle 25 years of soil moisture + snowpack
# so had to go back and switch to 15 years each

library(data.table)

##### Read in storage components

# Calculate sum of all storage components

storage_vars <- c("hru_ppt", "hru_actet")
storage_cols <- c("Precip_va", "ET_va")

##### Read in availability components
# Lindsay's comp couldn't handle doing this for 5 years.
# She went to Yeti to run the `merge_data` function for "years"

combine_data_list <- function(storage_vars, type = c("yrs", "days")) {
  message(sprintf("Reading in reshaped RDS files for %s", type))
  data_list <- lapply(storage_vars, function(var_name, type) {
    readRDS(sprintf("WBEEP/cache/nhru_%s_%s_reshape.rds", var_name, type))
  }, type)
  saveRDS(data_list, sprintf("WBEEP/cache/nhru_deltaH2O_combined_%s_list.rds", type))
  return(sprintf("Completed combining %s files", type))
}


# Merge components into one dataset with different columns for each
#### Try out a different solution for the future:
## https://stackoverflow.com/questions/34598139/left-join-using-data-table/34600831
merge_data <- function(type = c("yrs", "days"), dir = c("WBEEP/cache/")) {
  data_list <- readRDS(sprintf("%snhru_deltaH2O_combined_%s_list.rds", dir, type))
  message(sprintf("Merging into one data.table for %s", type))
  data <- data_list[[1]]
  # Tried to use Reduce() + merge() but that kept causing even Yeti to run out of room
  # This method used 81 GB, but the Reduce/merge method ran out of space with 120 GB
  for(i in 2:length(data_list)) {
    data <- dplyr::left_join(data, data_list[[i]], by = c("Date", "HRU"))
    print(sprintf("Completed %s of %s", i, length(data_list)))
  }
  message(sprintf("Saving into one RDS for %s", type))
  saveRDS(data, sprintf("%snhru_deltaH2O_combined_%s.rds", dir, type))
  return(sprintf("Completed merging %s files", type))
}

combine_data_list(storage_vars, "yrs")
merge_data("yrs")

combine_data_list(storage_vars, "days")
merge_data("days")

#### Once you have the combined RDS files
# Calculate the deltaH2O by subtracting ET from precip.
# Negative values = more water lost via ET than returned from precip.
# Positive values = more water added via precip than lost from ET.

data_days <- readRDS("WBEEP/cache/nhru_deltaH2O_combined_days.rds")
deltaH2O_data_days <- as.data.table(data_days)[, deltaH2O := Precip_va - ET_va]
deltaH2O_data_days[, (storage_cols) := NULL]
saveRDS(deltaH2O_data_days, "WBEEP/cache/deltaH2O_days.rds")

data_yrs <- readRDS("WBEEP/cache/nhru_deltaH2O_combined_yrs.rds")
totS_data_yrs <- as.data.table(data_yrs)[, deltaH2O := Precip_va - ET_va]
totS_data_yrs[, (storage_cols) := NULL]
saveRDS(totS_data_yrs, "WBEEP/cache/deltaH2O_yrs.rds")
