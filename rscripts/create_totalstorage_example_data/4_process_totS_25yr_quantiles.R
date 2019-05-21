# Calculate quantiles
# Hydrologic Response Units = HRUs

library(data.table)
library(dplyr)

#totS_data_25yrs <- readRDS("cache/totS_25yrs.rds")
# Lindsay's comp could only handle merging 5 years of snowpack with 5 years of soil moisture.
totS_data_5yrs <- readRDS("cache/totS_5yrs.rds")

## >>> SHOULD WE INCLUDE 0s??? including for now <<< ##

# A resulting value of 20% means that this value of stored water
#   is greater than 20% of the daily stored water values

# Calculate quantiles based on the last 5 years of total water storage.
totS_quantiles <- totS_data_5yrs %>% 
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
totS_quantiles_fix <- totS_quantiles %>%
  tidyr::gather(stat_name, stat_value, -HRU) %>%
  mutate(stat_value = as.numeric(stat_value),
         stat_type = as.numeric(gsub("Q", "", stat_name))/100) %>% 
  select(HRU, stat_name, stat_type, stat_value)

# Save quantiles
saveRDS(totS_quantiles_fix, "cache/nhru_5yr_totS_quantiles.rds")
