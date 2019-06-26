# Save just one day of data to use as an example

library(data.table)
library(jsonlite)
library(rjson) # writeLines

# This is the EXAMPLE DATA for water availability values
# They are %iles based on the last 5 years of "total storage"
# On 5/21, "total storage" was the sum of soil moisture + snowpack
# So, 0.20 = total storage that is greater than 20% of all total storage
# values for the last 5 years for that HRU

deltaH2O_percentiles_days <- readRDS("WBEEP/cache/deltaH2O_percentiles_days.rds")
deltaH2O_percentiles_hru_days <- readRDS("WBEEP/cache/deltaH2O_percentiles_hru_days.rds")

autumn <- as.Date("2016-11-01")
winter <- as.Date("2016-02-01")
spring <- as.Date("2016-05-01")
summer <- as.Date("2016-08-01")
dates <- c(winter = winter, spring = spring, summer = summer, autumn = autumn)

for(season in names(dates)) {
  
  date <- dates[season]
  deltaH2O_percentiles_1day <- deltaH2O_percentiles_days[Date ==  date]
  deltaH2O_percentiles_hru_1day <- deltaH2O_percentiles_days[Date ==  date]
  
  determine_category <- function(deltaH2O) {
    
    # Cfg
    deltaH2O_cat_nums <- c(0, 0.25, 0.40, 0.60, 0.75, 1)
    deltaH2O_cat <- c("very low", "low", "average", "high", "very high")
    
    water_avail_cat <- cut(deltaH2O, deltaH2O_cat_nums, deltaH2O_cat)
    
    return(water_avail_cat)
  }
  
  # Use the function to determine the color for each HRU value
  map_data <- deltaH2O_percentiles_1day[, map_cat := determine_category(deltaH2O_per)]
  map_hru_data <- deltaH2O_percentiles_hru_1day[, map_cat := determine_category(deltaH2O_per)]
  
  # Turn df into list (HRUs are list element names, color is value)
  map_data_list <- setNames(as.list(as.character(map_data$map_cat)), map_data$HRU)
  map_hru_data_list <- setNames(as.list(as.character(map_hru_data$map_cat)), map_hru_data$HRU)
  
  # Then list into json
  map_data_json <- jsonlite::toJSON(map_data_list)
  map_hru_data_json <- jsonlite::toJSON(map_hru_data_list)
  
  # Write out JSON file and RDS in the end
  writeLines(map_data_json, sprintf("WBEEP/cache/deltaH2O_map_data_%s.json", season))
  saveRDS(map_data, sprintf("WBEEP/cache/deltaH2O_map_data_%s.rds", season))
  
  writeLines(map_hru_data_json, sprintf("WBEEP/cache/deltaH2O_map_hru_data_%s.json", season))
  saveRDS(map_hru_data, sprintf("WBEEP/cache/deltaH2O_map_hru_data_%s.rds", season))
  
  # Push to S3 
  # Not yet working due to dssecrets credential error. Likely due to binary file 
  #   issue thanks to differences in R 3.5 vs 3.6 (5/21)
  
  # aws.signature::use_credentials(profile='default', file=aws.signature::default_credentials_file())
  # 
  # s3_push <- aws.s3::put_object(file = sprintf("WBEEP/cache/deltaH2O_map_data_%s.json", date),
  #                               object = "deltaH2O_map_data.json",
  #                               bucket = "prod-owi-resources/resources/Application/wbeep/development")
  
}
