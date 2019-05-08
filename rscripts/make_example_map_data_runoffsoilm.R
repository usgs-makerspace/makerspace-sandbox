# Test out using runoff & soil moisture

library(data.table)
library(jsonlite)
library(readr)

soilm <- readRDS("cache/soilm_example_data.rds")
runoff <- readRDS("cache/runoff_example_data.rds")

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

saveRDS(map_data, "cache/runoff_soilm_map_data.rds")

# Turn df into list (HRUs are list element names, color is value)
# Then list into json
map_data_json <- toJSON(map_data)

# Write out JSON file in the end
write_lines(map_data_json, "cache/runoff_soilm_map_data.json")
