# Get SC data for salt propogation in DRB viz prototypes

library(dataRetrieval)
library(dplyr)
library(ggplot2)
library(plotly)
library(noncensus)

##### Get sites with SC data #####

# See Page 15 of this paper (https://pubs.usgs.gov/sir/2015/5142/sir20155142.pdf) for a view of HUC8 watersheds in the DRB
huc8s_drb <- c(
  "02040101", "02040102", "02040103", "02040104", "02040105", "02040106", # Upper Delaware HUC8s
  "02040201", "02040202", "02040203", "02040204", "02040205", "02040206", "02040207" # Lower Delaware HUC8s
)

sc_parameters <- parameterCdFile %>% filter(grepl("conductance", parameter_nm, ignore.case = T),
                                            grepl("Physical", parameter_group_nm),
                                            grepl("water", parameter_nm, ignore.case = T))

# CAN ONLY DO UP TO 10 HUC8s. Will need a second call.
# Figure out groups of 10
remainder <- length(huc8s_drb) %% 10
n_calls <- floor(length(huc8s_drb)/10)
n_calls <- ifelse(remainder == 0, n_calls, n_calls + 1)
last_huc_i <- seq_len(n_calls)*10
last_huc_i <- c(head(last_huc_i, -1), tail(last_huc_i, 1) - (10-remainder))

# Make calls to get sites using HUCs in max groups of 10
sc_sites <- c()
start_huc_i <- 1
for(i in last_huc_i) {
  sc_sites_i <- whatNWISsites(huc = huc8s_drb[start_huc_i:i],
                              parameterCd = sc_parameters$parameter_cd,
                              startDate = "2019-12-05")
  sc_sites <- c(sc_sites, sc_sites_i$site_no)
  start_huc_i <- i + 1
}

##### Get data & plot for rain storm #####

# Found info about a "bomb cyclone" in the NE from https://www.ncdc.noaa.gov/sotc/national/201910
# Actual storm: Oct 16-17
rain_storm_dates <- list(
  start = as.Date("2019-10-16"),
  end = as.Date("2019-10-17")
)

# Now pull data (start with dv, may switch to iv)
rain_sc_data <- readNWISdata(siteNumbers = sc_sites, 
                             parameterCd = sc_parameters$parameter_cd,
                             startDate = rain_storm_dates$start, 
                             endDate = rain_storm_dates$end + 3,
                             service = "uv") %>% 
  renameNWISColumns()

# rain_sc_plot <- ggplot(rain_sc_data, aes(x=dateTime, y=SpecCond_Inst)) +
#   geom_point(aes(color = site_no)) +
#   scale_y_log10() 
# ggplotly(rain_sc_plot)

##### Get data for snow storm #####

# Found info about snowfall here: https://www.ncdc.noaa.gov/snow-and-ice/daily-snow/PA/7d-snowfall/20191201
# Actual storm: Nov 30 - Dec 1
snow_storm_dates <- list(
  start = as.Date("2019-12-01"),
  end = as.Date("2019-12-02")
)

# Now pull data (start with dv, may switch to iv)
snow_sc_data <- readNWISdata(siteNumbers = sc_sites, 
                             parameterCd = sc_parameters$parameter_cd,
                             startDate = snow_storm_dates$start, 
                             endDate = snow_storm_dates$end + 1,
                             service = "uv") %>% 
  renameNWISColumns()

# snow_sc_plot <- ggplot(snow_sc_data, aes(x=dateTime, y=SpecCond_Inst)) +
#   geom_point(aes(color = site_no)) +
#   scale_y_log10() 
# ggplotly(snow_sc_plot)

# Want to find which are urban vs rural
# Want to figure out why some spike and some get low
# Want to show a summer storm to compare how road salt might change the 

##### Merge storm data into one dataset #####

cyclic_sites <- c("01484272", "01484080", "01482800", "01483177",
                  "01480065", "01477050", "01474703", "01467024")

# Merge snow & rain storm data and only keep sites from both
rain_start <- min(rain_sc_data$dateTime)
rain_sc_data_clean <- rain_sc_data %>% 
  select(site_no, dateTime, SC = SpecCond_Inst) %>% 
  mutate(storm = "rain",
         storm_elapse_hrs = as.numeric(dateTime - rain_start)/3600) %>% 
  filter(!is.na(SC)) %>% 
  filter(!site_no %in% cyclic_sites)

snow_start <- min(snow_sc_data$dateTime)
snow_sc_data_clean <- snow_sc_data %>% 
  select(site_no, dateTime, SC = SpecCond_Inst) %>% 
  mutate(storm = "snow",
         storm_elapse_hrs = as.numeric(dateTime - snow_start)/3600) %>% 
  filter(!is.na(SC)) %>% 
  filter(!site_no %in% cyclic_sites)

# Figure out shared sites:
rain_sites <- unique(rain_sc_data_clean$site_no)
snow_sites <- unique(snow_sc_data_clean$site_no)
shared_sites <- intersect(rain_sites, snow_sites)

storm_sc_data <- bind_rows(rain_sc_data_clean, snow_sc_data_clean) %>% 
  filter(site_no %in% shared_sites) %>%
  # Some sites don't have much data
  filter(!site_no %in% c("01463500", "01473900", "01474500", "01438500"))

# This plot shows SC from a snow storm as foreground
# and SC from a rain storm as background.
# Expect snow SC to be higher due to road salt?
comparison_plot <- ggplot(storm_sc_data, aes(x = storm_elapse_hrs, y = SC)) +
  geom_point(aes(color = site_no, alpha=storm), shape=16, stroke = 0) +
  scale_y_log10() + 
  facet_grid(rows = vars(site_no), scales = "free_y")

ggplotly(comparison_plot)

print(unique(storm_sc_data$site_no))

##### Filter plot to get rid of weird sites #####

# Sites that show the snow SC higher than rain
sites_showing_expected <- c(
  "01414500", "01423000", "01427207", "01446500",
  "01451500", "01451650", "01467087", "01473169"
)

# Sites that show the reverse ...
sites_showing_unexpected <- c(
  "01432160", "01433500", "01434000", "0143400680", "01434021",
  "01466500", "014670261", "01467200", "01473500", "01484100"
)

# Sites doing things that I don't understand
sites_storm <- unique(storm_sc_data$site_no)
sites_unknown <- sites_storm[!sites_storm %in% c(sites_showing_expected, sites_showing_unexpected)]

storm_data_expected_pattern <- storm_sc_data %>% 
  filter(site_no %in% sites_showing_expected)

expected_pattern_plot <- ggplot(storm_data_expected_pattern, aes(x = storm_elapse_hrs, y = SC)) +
  geom_point(aes(color = site_no, alpha=storm), shape=16, stroke = 0) +
  scale_y_log10() + 
  facet_grid(rows = vars(site_no), scales = "free_y")

ggplotly(expected_pattern_plot)


##### Determine urban or not #####
site_metadata <- readNWISsite(sites_showing_expected) %>% 
  select(site_no, station_nm, site_tp_cd, latitude = dec_lat_va, 
         longitude = dec_long_va, huc_cd, state_cd, county_cd, drain_area_va)

# Urban = 100,000 (just for now ...)
# Although pkg readme says "10,000" in map key: https://cran.r-project.org/web/packages/noncensus/README.html
data(counties)
county_data <- counties %>% 
  mutate(state_cd = as.character(state_fips), county_cd = as.character(county_fips)) %>% 
  select(state_cd, county_cd, population)

site_metadata_pop <- left_join(site_metadata, county_data) %>% 
  mutate(site_city_type = ifelse(population >= 100000, "urban", "rural"))

sc_data <- left_join(storm_data_expected_pattern, site_metadata_pop)

##### Convert to quantity of salt #####

# Known drinking water facts:
#   500 ppm ~ 1 tsp salt/gal (from: https://books.google.com/books?id=-GB5pscqAZ8C&pg=PA16&lpg=PA16&dq=what+is+specific+conductance+of+1+tablespoon+of+salt+in+water&source=bl&ots=Xtm7H9P4wI&sig=ACfU3U1d-wzT2sMmbRp7ITFM59X4L1_9Rw&hl=en&ppis=_e&sa=X&ved=2ahUKEwin-c6zr67mAhUyw1kKHYaaCqsQ6AEwEXoECAkQAQ#v=onepage&q=teaspoon&f=false)
#   0.005 – 0.05 S/m conductivity (from: https://www.lenntech.com/applications/ultrapure/conductivity/water-conductivity.htm)
# Also known:
#   streams should be between 150 to 500 uS/cm to support diverse aquatic life (from: http://fosc.org/WQData/WQParameters.htm)

# Convert mS/m to uS/cm: 50-500 uS/cm
# Take average of range: 275 uS/cm

# So, convert units into teaspoons per gallon:
# 1 tsp salt/gal ~ 275 uS/cm
# Then, add flag for aquatic life suitability exceedance (500 uS/cm max)
sc_data <- sc_data %>% 
  mutate(SC_tsp = round(SC/275, digits = 2),
         suitable_for_aquatic_life = SC <= 500)

# Percent data not suitable for aquatic life:
sum(!sc_data$suitable_for_aquatic_life) / nrow(sc_data) * 100

sc_tsp_plot <- ggplot(sc_data, aes(x = storm_elapse_hrs, y = SC_tsp)) + 
  geom_hline(yintercept = 500/275, color = "red", size = 2, alpha = 0.5) +
  geom_point(aes(color = site_no, alpha=storm), shape=16, stroke = 0) +
  #scale_y_log10() + 
  ylab("Teaspoons of salt per gallon") +
  facet_grid(rows = vars(site_no), scales = "free_y")

ggplotly(sc_tsp_plot)

##### Write out data #####

write.csv(sc_data, "salt-propogation/example_sc_data.csv", row.names = FALSE)
