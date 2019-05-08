# Just colorado data

library(RColorBrewer)
library(geojsonio)
library(sf) 
library(dplyr)
library(ggplot2)
library(mapview)

# Get just Colorado data as `sf`
map_data <- readRDS("cache/runoff_soilm_map_data.rds")
# This topojson file was shared by David
topo_data_co <- geojsonio::topojson_read("cache/test_state_hru_simple.topojson")
topo_data_co@data$hru_id_nat <- factor(topo_data_co@data$hru_id_nat)
co_sf <- st_as_sf(topo_data_co)
co_data_sf <- left_join(co_sf, map_data, by = c("hru_id_nat" = "HRU"))

# Turn categories into colors
soilm_col <- colorRampPalette(c("#CC4C02", "#FED98E")) # Brown to yellow
runoff_col <- colorRampPalette(c("#a7b9d7", "#144873")) # Light blue to dark blue 
runoff_cat <- c("very low runoff", "low runoff", "high runoff", "very high runoff")
soilm_cat <- c("very low soil m", "low soil m", "high soil m", "very high soil m")
map_cats <- c("no water", soilm_cat, runoff_cat)
map_colors <- c("black", soilm_col(length(soilm_cat)), runoff_col(length(runoff_cat)))
names(map_colors) <- map_cats
co_data_sf$map_cat <- factor(co_data_sf$map_cat, levels=map_cats)

# Plot
ggplot(co_data_sf, aes(fill=map_cat)) +
  geom_sf(color = "white", size=0.5)+
  scale_fill_manual(name = "Water Availability", values = map_colors) +
  theme_void() +
  coord_sf(datum = NA)

# Interactive version to mess with
mapviewOptions(vector.palette = map_colors)
mapview(co_data_sf, zcol = "map_cat", color = "white", lwd=0.5)
