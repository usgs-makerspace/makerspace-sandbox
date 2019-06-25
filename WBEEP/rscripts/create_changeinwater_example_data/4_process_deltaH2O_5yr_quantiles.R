# Calculate quantiles
# Hydrologic Response Units = HRUs

library(data.table)
library(dplyr)

deltaH2O_data_yrs <- readRDS("WBEEP/cache/deltaH2O_yrs.rds")

# Calculate quantiles based on the last 5 years of change in water (precip-ET).
deltaH2O_quantiles_hru <- deltaH2O_data_yrs %>% 
  group_by(HRU) %>% 
  summarize(Q00 = quantile(deltaH2O, probs = 0.0),
            Q10 = quantile(deltaH2O, probs = 0.1),
            Q20 = quantile(deltaH2O, probs = 0.2),
            Q30 = quantile(deltaH2O, probs = 0.3),
            Q40 = quantile(deltaH2O, probs = 0.4),
            Q50 = quantile(deltaH2O, probs = 0.5),
            Q60 = quantile(deltaH2O, probs = 0.6),
            Q70 = quantile(deltaH2O, probs = 0.7),
            Q80 = quantile(deltaH2O, probs = 0.8),
            Q90 = quantile(deltaH2O, probs = 0.9),
            Q100 = quantile(deltaH2O, probs = 1.0))

# Reshape and format quantiles labels into decimal numbers
deltaH2O_quantiles_hru_fix <- deltaH2O_quantiles_hru %>%
  tidyr::gather(stat_name, stat_value, -HRU) %>%
  mutate(stat_value = as.numeric(stat_value),
         stat_type = as.numeric(gsub("Q", "", stat_name))/100) %>% 
  select(HRU, stat_name, stat_type, stat_value)

# Save quantiles
saveRDS(deltaH2O_quantiles_hru_fix, "WBEEP/cache/nhru_deltaH2O_percentiles_hru_yrs.rds")

# Now calculate it so that all of CONUS uses the same set of percentiles 
# so that the results can be compared across space

# Calculate quantiles based on the last 5 years of change in water (precip-ET).
deltaH2O_quantiles <- deltaH2O_data_yrs %>% 
  summarize(Q00 = quantile(deltaH2O, probs = 0.0),
            Q10 = quantile(deltaH2O, probs = 0.1),
            Q20 = quantile(deltaH2O, probs = 0.2),
            Q30 = quantile(deltaH2O, probs = 0.3),
            Q40 = quantile(deltaH2O, probs = 0.4),
            Q50 = quantile(deltaH2O, probs = 0.5),
            Q60 = quantile(deltaH2O, probs = 0.6),
            Q70 = quantile(deltaH2O, probs = 0.7),
            Q80 = quantile(deltaH2O, probs = 0.8),
            Q90 = quantile(deltaH2O, probs = 0.9),
            Q100 = quantile(deltaH2O, probs = 1.0))

# Reshape and format quantiles labels into decimal numbers
deltaH2O_quantiles_fix <- deltaH2O_quantiles %>%
  tidyr::gather(stat_name, stat_value) %>%
  mutate(stat_value = as.numeric(stat_value),
         stat_type = as.numeric(gsub("Q", "", stat_name))/100) %>% 
  select(stat_name, stat_type, stat_value)

# Save quantiles
saveRDS(deltaH2O_quantiles_fix, "WBEEP/cache/nhru_deltaH2O_percentiles_yrs.rds")
