# Save just one day of data to use as an example

library(data.table)
library(jsonlite)
library(rjson) # writeLines

# This is the EXAMPLE DATA for water availability values
# They are %iles based on the last 5 years of "total storage"
# On 5/21, "total storage" was the sum of soil moisture + snowpack
# So, 0.20 = total storage that is greater than 20% of all total storage
# values for the last 5 years for that HRU

totS_percentiles_1wk <- readRDS("WBEEP/cache/totS_percentiles_1wk.rds")
totS_percentiles_1day <- totS_percentiles_1wk[Date == max(Date)]

# 2260 of these have invalid percentiles that Lindsay is still
# investigating.
length(unique(per_dt$HRU[which(per_dt$totS_per > 1)]))

determine_category <- function(totS) {
  
  # Cfg
  totS_cat_nums <- c(0, 0.25, 0.40, 0.60, 0.75, 1)
  totS_cat <- c("very low", "low", "average", "high", "very high")
  
  water_avail_cat <- cut(totS, totS_cat_nums, totS_cat)
  
  return(water_avail_cat)
}

# Use the function to determine the color for each HRU value
map_data <- totS_percentiles_1day[, map_cat := determine_category(totS_per)]

# Turn df into list (HRUs are list element names, color is value)
map_data_list <- setNames(as.list(as.character(map_data$map_cat)), map_data$HRU)

# Then list into json
map_data_json <- jsonlite::toJSON(map_data_list)

# Write out JSON file and RDS in the end
writeLines(map_data_json, "WBEEP/cache/totS_map_data.json")
saveRDS(map_data, "WBEEP/cache/totS_map_data.rds")

# Push to S3 
# Not yet working due to dssecrets credential error. Likely due to binary file 
#   issue thanks to differences in R 3.5 vs 3.6 (5/21)

# aws.signature::use_credentials(profile='default', file=aws.signature::default_credentials_file())
# 
# s3_push <- aws.s3::put_object(file = "WBEEP/cache/totS_map_data.json",
#                               object = "totS_map_data.json",
#                               bucket = "prod-owi-resources/resources/Application/wbeep/development")
