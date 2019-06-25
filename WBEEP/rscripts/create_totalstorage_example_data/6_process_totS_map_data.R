# Save just one day of data to use as an example

library(data.table)
library(jsonlite)
library(rjson) # writeLines

# This is the EXAMPLE DATA for water availability values
# They are %iles based on the last 5 years of "total storage"
# On 5/21, "total storage" was the sum of soil moisture + snowpack
# So, 0.20 = total storage that is greater than 20% of all total storage
# values for the last 5 years for that HRU

totS_percentiles_days <- readRDS("WBEEP/cache/totS_percentiles_days.rds")
totS_percentiles_hru_days <- readRDS("WBEEP/cache/totS_percentiles_hru_days.rds")
totS_perofmaxavg_days_conus <- readRDS("WBEEP/cache/totS_perofmaxavg_days_conus.rds")
totS_perofmaxavg_days_hru <- readRDS("WBEEP/cache/totS_perofmaxavg_days_hru.rds")

autumn <- as.Date("2016-11-01")
winter <- as.Date("2016-02-01")
spring <- as.Date("2016-05-01")
summer <- as.Date("2016-08-01")
dates <- c(winter = winter, spring = spring, summer = summer, autumn = autumn)

for(season in names(dates)) {
  
  date <- dates[season]
  totS_percentiles_1day <- totS_percentiles_days[Date ==  date]
  totS_percentiles_hru_1day <- totS_percentiles_hru_days[Date ==  date]
  totS_perofmaxavg_conus_1day <- totS_perofmaxavg_days_conus[Date ==  date]
  totS_perofmaxavg_hru_1day <- totS_perofmaxavg_days_hru[Date ==  date]
  
  determine_category <- function(totS, type=c("percentile", "perofavg", "perofmax")) {
    
    # Cfg
    totS_cat_nums <- switch(
      type,
      percentile = c(0, 0.25, 0.40, 0.60, 0.75, 1),
      perofavg = c(0, 0.25, 0.75, 1.25, 1.75, Inf),
      perofmax = c(0, 0.25, 0.50, 0.75, 1)
    )
    
    totS_cat <- switch(
      type,
      percentile = c("very low", "low", "average", "high", "very high"),
      perofavg = c("way below avg", "below avg", "average", "above avg", "way above avg"),
      perofmax = c("very low", "low", "high", "very high")
    )
    
    water_avail_cat <- cut(totS, totS_cat_nums, totS_cat)
    
    return(water_avail_cat)
  }
  
  # Use the function to determine the color for each HRU value
  map_data <- totS_percentiles_1day[, map_cat := determine_category(totS_per, "percentile")]
  # Turn df into list (HRUs are list element names, color is value)
  map_data_list <- setNames(as.list(as.character(map_data$map_cat)), map_data$HRU)
  # Then list into json
  map_data_json <- jsonlite::toJSON(map_data_list)
  # Write out JSON file and RDS in the end
  writeLines(map_data_json, sprintf("WBEEP/cache/totS_map_data_%s.json", season))
  saveRDS(map_data, sprintf("WBEEP/cache/totS_map_data_%s.rds", season))
  
  # Now do the same steps for others
  map_hru_data <- totS_percentiles_hru_1day[, map_cat := determine_category(totS_per, "percentile")]
  map_hru_data_list <- setNames(as.list(as.character(map_hru_data$map_cat)), map_hru_data$HRU)
  map_hru_data_json <- jsonlite::toJSON(map_hru_data_list)
  writeLines(map_hru_data_json, sprintf("WBEEP/cache/totS_map_hru_data_%s.json", season))
  saveRDS(map_hru_data, sprintf("WBEEP/cache/totS_map_hru_data_%s.rds", season))
  
  map_data_perofmax <- totS_perofmaxavg_conus_1day[, map_cat := determine_category(totS_perofmax, "perofmax")]
  map_data_perofmax_list <- setNames(as.list(as.character(map_data_perofmax$map_cat)), map_data_perofmax$HRU)
  map_data_perofmax_json <- jsonlite::toJSON(map_data_perofmax_list)
  writeLines(map_data_perofmax_json, sprintf("WBEEP/cache/totS_map_data_perofmax_%s.json", season))
  saveRDS(map_data_perofmax, sprintf("WBEEP/cache/totS_map_data_perofmax_%s.rds", season))
  
  map_data_perofmax_hru <- totS_perofmaxavg_hru_1day[, map_cat := determine_category(totS_perofmax, "perofmax")]
  map_data_perofmax_hru_list <- setNames(as.list(as.character(map_data_perofmax_hru$map_cat)), map_data_perofmax_hru$HRU)
  map_data_perofmax_hru_json <- jsonlite::toJSON(map_data_perofmax_hru_list)
  writeLines(map_data_perofmax_hru_json, sprintf("WBEEP/cache/totS_map_data_perofmax_hru_%s.json", season))
  saveRDS(map_data_perofmax_hru, sprintf("WBEEP/cache/totS_map_data_perofmax_hru_%s.rds", season))
  
  map_data_perofavg <- totS_perofmaxavg_conus_1day[, map_cat := determine_category(totS_perofavg, "perofavg")]
  map_data_perofavg_list <- setNames(as.list(as.character(map_data_perofavg$map_cat)), map_data_perofavg$HRU)
  map_data_perofavg_json <- jsonlite::toJSON(map_data_perofavg_list)
  writeLines(map_data_perofavg_json, sprintf("WBEEP/cache/totS_map_data_perofavg_%s.json", season))
  saveRDS(map_data_perofavg, sprintf("WBEEP/cache/totS_map_data_perofavg_%s.rds", season))
  
  map_data_perofavg_hru <- totS_perofmaxavg_hru_1day[, map_cat := determine_category(totS_perofavg, "perofavg")]
  map_data_perofavg_hru_list <- setNames(as.list(as.character(map_data_perofavg_hru$map_cat)), map_data_perofavg_hru$HRU)
  map_data_perofavg_hru_json <- jsonlite::toJSON(map_data_perofavg_hru_list)
  writeLines(map_data_perofavg_hru_json, sprintf("WBEEP/cache/totS_map_data_perofavg_hru_%s.json", season))
  saveRDS(map_data_perofavg_hru, sprintf("WBEEP/cache/totS_map_data_perofavg_hru_%s.rds", season))
  
  # Push to S3 
  # Not yet working due to dssecrets credential error. Likely due to binary file 
  #   issue thanks to differences in R 3.5 vs 3.6 (5/21)
  
  # aws.signature::use_credentials(profile='default', file=aws.signature::default_credentials_file())
  # 
  # s3_push <- aws.s3::put_object(file = sprintf("WBEEP/cache/totS_map_data_%s.json", date),
  #                               object = "totS_map_data.json",
  #                               bucket = "prod-owi-resources/resources/Application/wbeep/development")
  
}
