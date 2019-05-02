# Calculate quantiles
# Hydrologic Response Units = HRUs

library(dplyr)

recharge_data_25yrs <- readRDS("cache/nhru_recharge_25yrs_reshape.rds")

# Calculate quantiles based on the last 25 years of data.
recharge_quantiles <- recharge_data_25yrs %>% 
  group_by(HRU) %>% 
  summarize(Q00 = quantile(Recharge_va, probs = 0.0),
            Q10 = quantile(Recharge_va, probs = 0.1),
            Q20 = quantile(Recharge_va, probs = 0.2),
            Q30 = quantile(Recharge_va, probs = 0.3),
            Q40 = quantile(Recharge_va, probs = 0.4),
            Q50 = quantile(Recharge_va, probs = 0.5),
            Q60 = quantile(Recharge_va, probs = 0.6),
            Q70 = quantile(Recharge_va, probs = 0.7),
            Q80 = quantile(Recharge_va, probs = 0.8),
            Q90 = quantile(Recharge_va, probs = 0.9),
            Q100 = quantile(Recharge_va, probs = 1.0))

# Reshape and format quantiles labels into decimal numbers
recharge_quantiles_fix <- recharge_quantiles %>%
  tidyr::gather(stat_name, stat_value, -HRU) %>%
  mutate(stat_value = as.numeric(stat_value),
         stat_type = as.numeric(gsub("Q", "", stat_name))/100) %>% 
  select(HRU, stat_name, stat_type, stat_value)

# Save quantiles and remove 25 year data & original quantiles
saveRDS(recharge_quantiles_fix, "cache/nhru_25yr_recharge_quantiles.rds")
