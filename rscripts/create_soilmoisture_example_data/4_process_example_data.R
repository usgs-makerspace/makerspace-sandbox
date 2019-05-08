# Save just one day of data to use as an example

library(data.table)

# This is the EXAMPLE DATA for water availability values
# They are %iles based on the maximum soil moisture
# So, 0.20 = soil moisture that is 20% of the max soil moisture for that HRU
# 0 means their was no soil moisture

soilm_percentiles_1wk <- readRDS("cache/soilm_percentiles_1wk.rds")
soilm_percentiles_1day <- soilm_percentiles_1wk[Date == max(Date)]

saveRDS(runoff_percentiles_1day, "cache/runoff_example_data.rds")

# Might need to make it wide format again if we want to save it as
#   a NetCDF file. See below for example.
# Below is a recharge example
# recharge_data <- read.csv("cache/nhru_recharge.csv")
# write_netcdf(recharge_data, coords, "out/nhm_recharge.nc", 
#              "recharge", "Modeled Daily Recharge to Groundwater", 
#              "inches", list(title = "National Hydrologic Model Recharge per HUC12", 
#                             institution = "U.S. Geological Survey Water Mission Area",
#                             source = "Hay, L.E., 2019, Application of the National Hydrologic Model Infrastructure with the Precipitation-Runoff Modeling System (NHM-PRMS), by HRU Calibrated Version: U.S. Geological Survey data release, https://doi.org/10.5066/P9NM8K8W.",
#                             summary = "Initial calibration of the conterminous United States (CONUS) application of the Precipitation-Runoff Modeling System (PRMS) as implemented in the National Hydrologic Model (NHM) infrastructure converted to HUC12 watershed units with area-weighted mean.", 
#                             date_created = "2019-04-15", 
#                             creator_name = "David L. Blodgett",
#                             creator_email = "dblodgett@usgs.gov", 
#                             project = "U.S. Geological Survey Water Budget Estimation and Evaluation Project of the National Water Census.",
#                            processing_level = "Post processed calibrated model retrospective."))

