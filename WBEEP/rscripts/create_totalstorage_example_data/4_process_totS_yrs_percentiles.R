# Calculate quantiles
# Hydrologic Response Units = HRUs

library(data.table)
library(dplyr)

totS_data_yrs <- readRDS("WBEEP/cache/totS_yrs.rds")

# A resulting value of 20% means that this value of stored water
#   is greater than 20% of the daily stored water values

# Calculate quantiles based on the last 5 years of total water storage.
totS_percentiles <- totS_data_yrs %>% 
  group_by(HRU) %>% 
  summarize(Q00 = quantile(totS, probs = 0.0),
            Q10 = quantile(totS, probs = 0.1),
            Q20 = quantile(totS, probs = 0.2),
            Q30 = quantile(totS, probs = 0.3),
            Q40 = quantile(totS, probs = 0.4),
            Q50 = quantile(totS, probs = 0.5),
            Q60 = quantile(totS, probs = 0.6),
            Q70 = quantile(totS, probs = 0.7),
            Q80 = quantile(totS, probs = 0.8),
            Q90 = quantile(totS, probs = 0.9),
            Q100 = quantile(totS, probs = 1.0))

# Reshape and format quantiles labels into decimal numbers
totS_percentiles_fix <- totS_percentiles %>%
  tidyr::gather(stat_name, stat_value, -HRU) %>%
  mutate(stat_value = as.numeric(stat_value),
         stat_type = as.numeric(gsub("Q", "", stat_name))/100) %>% 
  select(HRU, stat_name, stat_type, stat_value)

# Save quantiles
saveRDS(totS_percentiles_fix, "WBEEP/cache/nhru_totS_percentiles_yrs.rds")
