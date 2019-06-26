# Take example data values (1 day each season) and calculate their % of max

library(dplyr)

# Load necessary data files
totS_yrs <- readRDS("WBEEP/cache/totS_yrs.rds")
totS_days <- readRDS("WBEEP/cache/totS_days.rds")

# Percent of max & avg for all of CONUS
totS_perofmaxavg_conus <- totS_days %>% 
  mutate(totS_perofmax = totS / max(totS_yrs$totS),
         totS_perofavg = totS / mean(totS_yrs$totS)) %>% 
  as.data.table()

# Percent of max for each HRU
totS_maxavg_hru <- totS_yrs %>% 
  group_by(HRU) %>% 
  summarize(totS_max = max(totS),
            totS_avg = mean(totS))

totS_perofmaxavg_hru <- totS_days %>% 
  left_join(totS_maxavg_hru, by = "HRU") %>% 
  mutate(totS_perofmax = totS / totS_max,
         totS_perofavg = totS / totS_avg) %>% 
  as.data.table()

saveRDS(totS_perofmaxavg_conus, "WBEEP/cache/totS_perofmaxavg_days_conus.rds")
saveRDS(totS_perofmaxavg_hru, "WBEEP/cache/totS_perofmaxavg_days_hru.rds")
