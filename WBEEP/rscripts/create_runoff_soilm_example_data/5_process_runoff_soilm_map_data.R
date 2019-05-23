# Test out using runoff & soil moisture

library(data.table)
library(jsonlite)
library(readr)

# This is the single day runoff percentiles to use for water availability values
# They are %iles based on the past 25 years of data
# So, 0.20 = runoff that is greater than 20% of 25 years of runoff
#   values, but less than 80% of runoff values. 50% equals the median runoff.
# NA means the runoff was 0
runoff_percentiles_1wk <- readRDS("WBEEP/cache/runoff_percentiles_1wk.rds")
runoff <- runoff_percentiles_1wk[Date == max(Date)]

# This is the single day soil moisture percentiles to use for water availability values
# They are %iles based on the maximum soil moisture
# So, 0.20 = soil moisture that is 20% of the max soil moisture for that HRU
# 0 means their was no soil moisture
soilm_percentiles_1wk <- readRDS("WBEEP/cache/soilm_percentiles_1wk.rds")
soilm <- soilm_percentiles_1wk[Date == max(Date)]

# Merge values with maxes in order to figure out color to use
all_data <- merge(runoff, soilm, by = c("HRU", "Date"), all=TRUE)

determine_category <- function(runoff, soilm) {
  
  # Cfg
  runoff_cat_nums <- c(0, 0.25, 0.50, 0.75, 1)
  runoff_cat <- c("very low runoff", "low runoff", "high runoff", "very high runoff")
  
  soilm_cat_nums <- c(0, 0.25, 0.50, 0.75, 1)
  soilm_cat <- c("very low soil m", "low soil m", "high soil m", "very high soil m")
  
  water_avail_cat <- 
    ifelse(
      test = !is.na(runoff), 
      # If runoff value exists (not 0), then figure out the color
      yes = as.character(cut(runoff, runoff_cat_nums, runoff_cat)),
      # Use soil moisture when there is no runoff
      no = ifelse(
        test = soilm != 0,
        yes = as.character(cut(soilm, soilm_cat_nums, soilm_cat)),
        # When soil moisture is also zero, color should be white
        no = "no water"
      ))
  
  return(water_avail_cat)
}

# Use the function to determine the color for each HRU value
all_data_col <- all_data[, map_cat := determine_category(Runoff_per, Soilm_per)]
map_data <- all_data_col[,c("HRU", "map_cat")]

saveRDS(map_data, "WBEEP/cache/runoff_soilm_map_data.rds")

# Turn df into list (HRUs are list element names, color is value)
# Then list into json
map_data_json <- toJSON(map_data)

# Write out JSON file in the end
write_lines(map_data_json, "WBEEP/cache/runoff_soilm_map_data.json")
