# Calculate quantiles
# Hydrologic Response Units = HRUs

library(data.table)
library(dplyr)

runoff_data_25yrs <- readRDS("WBEEP/cache/nhru_runoff_25yrs_reshape.rds")


# Removing data that has a value of zero since there is not any runoff.
# So, quantiles will be based on non-zero runoff.
# So, a resulting value of 20% means that when there was runoff ocurring, 
#   this value is greater than 20% of the runoff.
runoff_data_25yrs_nozeros <- runoff_data_25yrs[Runoff_va != 0]
rm(runoff_data_25yrs)

# Calculate quantiles based on the last 25 years of nonzero runoff data.
runoff_quantiles <- runoff_data_25yrs_nozeros %>% 
  group_by(HRU) %>% 
  summarize(Q00 = quantile(Runoff_va, probs = 0.0),
            Q10 = quantile(Runoff_va, probs = 0.1),
            Q20 = quantile(Runoff_va, probs = 0.2),
            Q30 = quantile(Runoff_va, probs = 0.3),
            Q40 = quantile(Runoff_va, probs = 0.4),
            Q50 = quantile(Runoff_va, probs = 0.5),
            Q60 = quantile(Runoff_va, probs = 0.6),
            Q70 = quantile(Runoff_va, probs = 0.7),
            Q80 = quantile(Runoff_va, probs = 0.8),
            Q90 = quantile(Runoff_va, probs = 0.9),
            Q100 = quantile(Runoff_va, probs = 1.0))

# The resulting `runoff_quantiles` df only has 109,795 observations
# Which means there are 156 HUCs that had only nonzero runoff for 
# the 25 year dataset.

# Reshape and format quantiles labels into decimal numbers
runoff_quantiles_fix <- runoff_quantiles %>%
  tidyr::gather(stat_name, stat_value, -HRU) %>%
  mutate(stat_value = as.numeric(stat_value),
         stat_type = as.numeric(gsub("Q", "", stat_name))/100) %>% 
  select(HRU, stat_name, stat_type, stat_value)

# Save quantiles and remove 25 year data & original quantiles
saveRDS(runoff_quantiles_fix, "WBEEP/cache/nhru_25yr_runoff_quantiles.rds")
