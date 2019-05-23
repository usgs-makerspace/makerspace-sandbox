library(RColorBrewer)
library(geojsonio)
library(sf) 
library(dplyr)
library(ggplot2)
library(mapview)

map_data <- readRDS("WBEEP/cache/totS_map_data.rds")

# This topojson file was shared by David
topo_data_conus <- topojson_read("WBEEP/cache/simp_10.topojson")
topo_data_conus@data$hru_id_nat <- factor(topo_data_conus@data$hru_id_nat)
conus_sf <- st_as_sf(topo_data_conus)
st_crs(conus_sf) <- "+proj=lcc +lat_1=43.26666666666667 +lat_2=42.06666666666667 +lat_0=41.5 +lon_0=-93.5 +x_0=1500000 +y_0=1000000 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"
conus_data_sf <- left_join(conus_sf, map_data, by = c("hru_id_nat" = "HRU"))

# Turn categories into colors
totS_low_col <- colorRampPalette(c("#CC4C02", "#FED98E")) # Brown to yellow
totS_high_col <- colorRampPalette(c("#a7b9d7", "#144873")) # Light blue to dark blue
map_cats <- c("very low", "low", "average", "high", "very high")
map_colors <- c(totS_low_col(2), "#FFFFFF", totS_high_col(2))
names(map_colors) <- map_cats
conus_data_sf$map_cat <- factor(conus_data_sf$map_cat, levels=map_cats)

# Plot
conus_nosmoothing <- ggplot(conus_data_sf, aes(fill=map_cat)) +
  geom_sf(color = NA)+
  scale_fill_manual(name = "Water Availability", values = map_colors) +
  theme_void() +
  coord_sf(datum = NA)

# takes ~10 min to save
ggsave(conus_nosmoothing, filename = "WBEEP/img/conus_totS.png", 
       height = 8, width = 11)
