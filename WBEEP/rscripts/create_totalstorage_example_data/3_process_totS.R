# Calculate sum of all storage components

# lplatt computer not good enough to handle 25 years of soil moisture + snowpack
# so had to go back and switch to 15 years each

library(data.table)

##### Read in storage components

# Cannot join 15 years (ran out of memory, also failed on 10, so did 5)
max_date <- as.Date("2016-12-31")

soilm_data_15yrs <- readRDS("WBEEP/cache/nhru_soilm_15yrs_reshape.rds")
soilm_data_5yrs <- soilm_data_15yrs[Date >= max_date - 5*365]
rm(soilm_data_15yrs)

snwpk_data_15yrs <- readRDS("WBEEP/cache/nhru_snwpk_15yrs_reshape.rds")
snwpk_data_5yrs <- snwpk_data_15yrs[Date >= max_date - 5*365]
rm(snwpk_data_15yrs)

# 1 week data
soilm_data_1wk <- readRDS("WBEEP/cache/nhru_soilm_1wk_reshape.rds")
snwpk_data_1wk <- readRDS("WBEEP/cache/nhru_snwpk_1wk_reshape.rds")

# First, join everything so there are columns Date, HRU, and one for each component
join_data_5yrs <- merge(snwpk_data_5yrs, soilm_data_5yrs, by = c("Date", "HRU"))
join_data_1wk <- merge(snwpk_data_1wk, soilm_data_1wk)

# Then sum into one new column and drop others
totS_data_5yrs <- join_data_5yrs[, totS := Snwpk_va + Soilm_va]
totS_data_5yrs[, c("Snwpk_va", "Soilm_va") := NULL]

totS_data_1wk <- join_data_1wk[, totS := Snwpk_va + Soilm_va]
totS_data_1wk[, c("Snwpk_va", "Soilm_va") := NULL]

# Save intermediate data
saveRDS(totS_data_5yrs, "WBEEP/cache/totS_5yrs.rds")
saveRDS(totS_data_1wk, "WBEEP/cache/totS_1wk.rds")
