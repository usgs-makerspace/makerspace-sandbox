# Take example data values (1 week) and calculate their percentiles
#   using the 25 year quantiles.

library(data.table)
library(dplyr)

# Load necessary data files
quantile_df <- readRDS("cache/nhru_25yr_recharge_quantiles.rds")
value_dt <- readRDS("cache/nhru_recharge_1wk_reshape.rds")

# Remove duplicate breaks/quantiles
#   Needed for handling multiple zeros quantiles for breaks
quantile_nodups <- quantile_df %>% 
  group_by(HRU) %>% 
  # Keep row if it is not equal to the following one
  # `default` returns TRUE so that it keeps the last row
  filter(lead(stat_value, default=TRUE) != stat_value)

# Format quantiles to be used in `cut`
#   Don't know how to do this using data.table, so used dplyr
quantile_summary_df <- quantile_nodups %>% 
  group_by(HRU) %>% 
  # Adding -Inf as lowest category for everything
  # Allows cut to work properly if the value is 0 (without it, you get NA) 
  #   e.g. cut(c(0, 0.5), c(0, 0.2, 0.5), c("low", "high")) gives NA for the first one
  # takes care of HRUs where all values are the same so the only unique quantile is 1
  summarize(stat_type_list = list(c(0, stat_type)), 
            stat_value_list = list(c(-Inf, stat_value)))
quantile_summary_dt <- as.data.table(quantile_summary_df) # needs to be a dt to merge

# Figure out which stat category to use for linear interpolation from quantile_summary_dt
#   Since open on left, and closed on right, resulting values are the top of the category, so use 
#   preceding stat_type to interpolate
find_quantile_group <- function(value, breaks, labels) {
  cut(value, unlist(unique(breaks)), unlist(unique(labels))[-1])
}
value_dt_stat <- merge(value_dt, quantile_summary_dt, all=TRUE)
value_dt_stat[, stat_to_use := find_quantile_group(Recharge_va, stat_value_list, stat_type_list),
              by = list(HRU)]
value_dt_stat[,c("stat_type_list", "stat_value_list") := NULL] # Clean up and delete unneeded columns

# Add values for linear interp as column for the each stat_type
# Get rows for each stat_type that have the right x0,x1,y0,y1 to use for linear interpolation
quantile_dt_interp_info <- data.table(quantile_df)[, 
                                                   c("stat_type0", "stat_type1", 
                                                     "stat_value0", "stat_value1") := 
                                                     list(shift(stat_type, 1, "lag"), 
                                                          stat_type, 
                                                          shift(stat_value, 1, "lag"), 
                                                          stat_value),
                                                   by=list(HRU)]
# need chr in order to merge with stat_to_use col below
quantile_dt_interp_info[, stat_type := as.character(stat_type)] 

# Now merge interp info with values and actually do linear interpolation to figure out the
# Recharge percentile that belongs to the recharge value
per_dt <- merge(value_dt_stat, quantile_dt_interp_info, by.x = c("HRU", "stat_to_use"), by.y = c("HRU", "stat_type"))
per_dt[, Recharge_per := 
         (((stat_type1 - stat_type0) / (stat_value1 - stat_value0)) * (Recharge_va - stat_value0)) + stat_type0]

# Despite quantiles, values of 0 should be "NA" since there is no water use
per_dt[, Recharge_per := ifelse(Recharge_va == 0, NA, Recharge_per)]

# Clean up to just be left with HRU, Date, Recharge_va, and Recharge_per
per_dt[, c("stat_to_use", "stat_name", "stat_value", "stat_type0", "stat_type1", "stat_value0", "stat_value1") := NULL]


saveRDS(per_dt, "cache/recharge_percentiles_1wk.rds")

