library(RColorBrewer)
library(geojsonio)
library(sf) 
library(dplyr)
library(ggplot2)
library(mapview)

map_data <- readRDS("cache/runoff_soilm_map_data.rds")

# This topojson file was shared by David
topo_data_conus <- topojson_read("cache/simp_10.topojson")
topo_data_conus@data$hru_id_nat <- factor(topo_data_conus@data$hru_id_nat)
conus_sf <- st_as_sf(topo_data_conus)
st_crs(conus_sf) <- "+proj=lcc +lat_1=43.26666666666667 +lat_2=42.06666666666667 +lat_0=41.5 +lon_0=-93.5 +x_0=1500000 +y_0=1000000 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"
conus_data_sf <- left_join(conus_sf, map_data, by = c("hru_id_nat" = "HRU"))

# Turn categories into colors
soilm_col <- colorRampPalette(c("#CC4C02", "#FED98E")) # Brown to yellow
runoff_col <- colorRampPalette(c("#a7b9d7", "#144873")) # Light blue to dark blue 
runoff_cat <- c("very low runoff", "low runoff", "high runoff", "very high runoff")
soilm_cat <- c("very low soil m", "low soil m", "high soil m", "very high soil m")
map_cats <- c("no water", soilm_cat, runoff_cat)
map_colors <- c("black", soilm_col(length(soilm_cat)), runoff_col(length(runoff_cat)))
names(map_colors) <- map_cats
conus_data_sf$map_cat <- factor(conus_data_sf$map_cat, levels=map_cats)

# Plot
conus_nosmoothing <- ggplot(conus_data_sf, aes(fill=map_cat)) +
  geom_sf(color = NA)+
  scale_fill_manual(name = "Water Availability", values = map_colors) +
  theme_void() +
  coord_sf(datum = NA)

# takes ~10 min to save
ggsave(conus_nosmoothing, filename = "img/conus_runoffsoilm.png", 
       height = 8, width = 11)

# Interactive version to mess with
mapviewOptions(vector.palette = map_colors)
mapview(conus_data_sf, zcol = "map_cat", color = "white", lwd=0.5)

# Make a smaller & correctly projected file to use for Tableau
# Simplify into fewer features based on category
# https://github.com/r-spatial/sf/issues/290#issuecomment-291663628
# Dissolve into just 1 geometry per category
#   Get an error when I run this (wasn't working as of 5/21)
#   Error in CPL_geos_union(st_geometry(x), by_feature) :
#     Evaluation error: TopologyException: found non-noded intersection between LINESTRING
conus_data_dissolved_sf <- sf::st_buffer(conus_data_sf, dist = 0) %>%
  group_by(map_cat) %>%
  summarize()
# Save into tableau projection
conus_data_sf_proj <- st_transform(conus_data_dissolved_sf, "+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs")
st_write(conus_data_sf_proj, "co_example_data_shp/conus_tableau.shp")

# Try smoothing as one potential way to make sense at the national view
# https://pudding.cool/process/regional_smoothing/
library(proj4)
library(spdep)
library(maptools)
library(rgdal)

coords <- coordinates(topo_data_conus)
knn50 <- knn2nb(knearneigh(coords, k = 20), row.names = as.character(conus_sf$hru_id_nat))
knn50 <- include.self(knn50)

# Make NAs 0
conus_data_sf$map_cat <- as.character(conus_data_sf$map_cat)
conus_data_sf$map_cat[is.na(conus_data_sf$map_cat)] <- "no water"
conus_data_sf$map_cat <- factor(conus_data_sf$map_cat, levels=map_cats)

# Creating the localG statistic for each of HRUs, with a k-nearest neighbor value of 5, and round this to 3 decimal places
localGvalues <- localG(x = as.numeric(conus_data_sf$map_cat), listw = nb2listw(knn50, style = "B"), zero.policy = TRUE)
localGvalues <- round(localGvalues,3)
conus_data_sf$map_smooth <- localGvalues
smooth_breaks <- quantile(conus_data_sf$map_smooth, probs=seq(0,1,length.out=length(map_cats)+1))
conus_data_sf$map_smooth_cats <- cut(conus_data_sf$map_smooth, smooth_breaks, map_cats)

conus_smoothing <- ggplot(conus_data_sf, aes(fill=map_smooth)) +
  geom_sf(color = NA)+
  scale_fill_gradientn(name = "Water Availability", colors=map_colors[-1]) +
  theme_void() +
  coord_sf(datum = NA)

ggsave(conus_smoothing, filename = "img/conus_runoffsoilm_smoothing.png", 
       height = 8, width = 11)

# Converting to JSON and saving
#conus_data_json <- jsonlite::toJSON(conus_data_sf)
#readr::write_lines(conus_data_json, "cache/runoff_soilm_map_data_spatial.json")
