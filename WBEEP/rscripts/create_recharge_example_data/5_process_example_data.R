# Save just one day of data to use as an example

library(data.table)

# This is the EXAMPLE DATA for water availability values
# They are %iles based on the past 25 years of data
# So, 0.20 = recharge that is greater than 20% of 25 years of recharge
#   values, but less than 80% of recharge values. 50% equals the median recharge.
# NA means the recharge was 0

recharge_percentiles_1wk <- readRDS("WBEEP/cache/recharge_percentiles_1wk.rds")
recharge_percentiles_1day <- recharge_percentiles_1wk[Date == max(Date)]

saveRDS(recharge_percentiles_1day, "WBEEP/cache/recharge_example_data.rds")

# Might need to make it wide format again if we want to save it as
#   a NetCDF file. See below for example.

# recharge_data <- read.csv("WBEEP/cache/nhru_recharge.csv")
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

