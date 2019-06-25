# Take example data values (1 week) and calculate their percentiles
#   using the 5 year quantiles.

library(dplyr)
library(tidyr)
library(data.table)

# Load necessary data files
quantile_df <- readRDS("WBEEP/cache/nhru_totS_percentiles_yrs.rds")
value_dt <- readRDS("WBEEP/cache/totS_days.rds")

stat_type_list <- c(-Inf, quantile_df$stat_type)
stat_value_list <- c(-Inf, quantile_df$stat_value)

# Add values for linear interp as column for the each stat_type
# Get rows for each stat_type that have the right x0,x1,y0,y1 to use for linear interpolation
# Do this with the fixed quantiles (no duplicates, Q00s as 0)

quantile_dt_interp_info <- data.table(quantile_df)[, 
                                                   c("stat_type0", "stat_type1", 
                                                     "stat_value0", "stat_value1") := 
                                                     list(shift(stat_type, 1, "lag"), 
                                                          stat_type, 
                                                          shift(stat_value, 1, "lag"), 
                                                          stat_value)]
# need chr in order to merge with stat_to_use col below
quantile_dt_interp_info[, stat_type := as.character(stat_type)]


# Figure out which stat category to use for linear interpolation from quantile_summary_dt
#   Since open on left, and closed on right, resulting values are the top of the category, so use 
#   preceding stat_type to interpolate
find_quantile_group <- function(value, breaks, labels) {
  cut(value, unique(breaks), unique(labels)[-1])
}

# Determine which is the highest percentile that would be appropriate to use for interpolation
value_dt_stat <- value_dt %>% 
  mutate(stat_to_use = find_quantile_group(totS, stat_value_list, stat_type_list)) %>%
  as.data.table()

# Now merge interp info with values and actually do linear interpolation to figure out the
# percentile that belongs to the value
per_dt <- merge(value_dt_stat, quantile_dt_interp_info, by.x = c("stat_to_use"), 
                by.y = c("stat_type"), all.x = TRUE)
per_dt[, totS_per := 
         # is.na(stat_type0) means that the stat_type being used is the lowest one
         ifelse(is.na(stat_type0), yes = as.numeric(stat_to_use), 
                no = (((stat_type1 - stat_type0) / (stat_value1 - stat_value0)) * (totS - stat_value0)) + stat_type0)]

# Both of these should be zero
stopifnot(length(which(is.na(per_dt$totS_per))) == 0)
stopifnot(length(which(per_dt$totS_per > 1)) == 0)

# Clean up to just be left with HRU, Date, Runoff_va, and Runoff_per
per_dt[, c("stat_to_use", "stat_name", "stat_value", "stat_type0", "stat_type1", "stat_value0", "stat_value1") := NULL]

saveRDS(per_dt, "WBEEP/cache/totS_percentiles_days.rds")

