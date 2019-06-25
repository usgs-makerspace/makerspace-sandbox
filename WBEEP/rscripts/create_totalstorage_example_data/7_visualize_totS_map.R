library(RColorBrewer)
library(geojsonio)
library(sf) 
library(dplyr)
library(ggplot2)
library(mapview)

# This topojson file was shared by David
topo_data_conus <- topojson_read("WBEEP/cache/simp_10.topojson")
topo_data_conus$hru_id_nat <- factor(topo_data_conus$hru_id_nat)
conus_sf <- st_as_sf(topo_data_conus)
st_crs(conus_sf) <- "+proj=lcc +lat_1=43.26666666666667 +lat_2=42.06666666666667 +lat_0=41.5 +lon_0=-93.5 +x_0=1500000 +y_0=1000000 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"

# Make plots using historic percentiles by HRU
for(season in c("winter", "spring", "summer", "autumn")) {
  
  map_data <- readRDS(sprintf("WBEEP/cache/totS_map_hru_data_%s.rds", season))
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
  ggsave(conus_nosmoothing, 
         filename = sprintf("WBEEP/img/conus_totS_hru_%s.png", season), 
         height = 8, width = 11)
  
  message(sprintf("Completed %s", season))
}

# Make plots using historic percentiles for all of CONUS
for(season in c("winter", "spring", "summer", "autumn")) {
  
  map_data <- readRDS(sprintf("WBEEP/cache/totS_map_data_%s.rds", season))
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
  ggsave(conus_nosmoothing, 
         filename = sprintf("WBEEP/img/conus_totS_conus_%s.png", season), 
         height = 8, width = 11)
  
  message(sprintf("Completed %s", season))
}

# Per of max (one max for all HRUs) results in all low values for winter.
for(season in c("winter", "spring", "summer", "autumn")) {
  
  map_data <- readRDS(sprintf("WBEEP/cache/totS_map_data_perofmax_%s.rds", season))
  conus_data_sf <- left_join(conus_sf, map_data, by = c("hru_id_nat" = "HRU"))

  # test
  # conus_data_sf <- conus_data_sf[48000:58000,]
  
  # Turn categories into colors
  totS_low_col <- colorRampPalette(c("#CC4C02", "#FED98E")) # Brown to yellow
  totS_high_col <- colorRampPalette(c("#a7b9d7", "#144873")) # Light blue to dark blue
  map_cats <- c("very low", "low", "high", "very high")
  map_colors <- c(totS_low_col(2), totS_high_col(2))
  names(map_colors) <- map_cats
  conus_data_sf$map_cat <- factor(conus_data_sf$map_cat, levels=map_cats)

  # Plot
  conus_permax <- ggplot(conus_data_sf, aes(fill=map_cat)) +
    geom_sf(color = NA)+
    scale_fill_manual(name = "Water Storage", values = map_colors) +
    theme_void() +
    coord_sf(datum = NA)

  # takes ~10 min to save
  ggsave(conus_permax,
         filename = sprintf("WBEEP/img/conus_totS_permax_%s.png", season),
         height = 8, width = 11)
  
  message(sprintf("Completed %s", season))
}

# Per of avg (one avg for all HRUs) results in all low values for winter.
for(season in c("winter", "spring", "summer", "autumn")) {
  
  map_data <- readRDS(sprintf("WBEEP/cache/totS_map_data_perofavg_%s.rds", season))
  conus_data_sf <- left_join(conus_sf, map_data, by = c("hru_id_nat" = "HRU"))
  
  # test
  #conus_data_sf <- conus_data_sf[48000:58000,]
  
  # Turn categories into colors
  totS_low_col <- colorRampPalette(c("#CC4C02", "#FED98E")) # Brown to yellow
  totS_high_col <- colorRampPalette(c("#a7b9d7", "#144873")) # Light blue to dark blue
  map_cats <- c("way below avg", "below avg", "average", "above avg", "way above avg")
  map_colors <- c(totS_low_col(2), "#FFFFFF", totS_high_col(2))
  names(map_colors) <- map_cats
  conus_data_sf$map_cat <- factor(conus_data_sf$map_cat, levels=map_cats)
  
  # Plot
  conus_peravg <- ggplot(conus_data_sf, aes(fill=map_cat)) +
    geom_sf(color = NA)+
    scale_fill_manual(name = "Water Storage", values = map_colors) +
    theme_void() +
    coord_sf(datum = NA)
  
  # takes ~10 min to save
  ggsave(conus_peravg,
         filename = sprintf("WBEEP/img/conus_totS_peravg_%s.png", season),
         height = 8, width = 11)
  
  message(sprintf("Completed %s", season))
}

# Per of max (unique to each HRU)
for(season in c("winter", "spring", "summer", "autumn")) {
  
  map_data <- readRDS(sprintf("WBEEP/cache/totS_map_data_perofmax_hru_%s.rds", season))
  conus_data_sf <- left_join(conus_sf, map_data, by = c("hru_id_nat" = "HRU"))
  
  # test
  # conus_data_sf <- conus_data_sf[48000:58000,]
  
  # Turn categories into colors
  totS_low_col <- colorRampPalette(c("#CC4C02", "#FED98E")) # Brown to yellow
  totS_high_col <- colorRampPalette(c("#a7b9d7", "#144873")) # Light blue to dark blue
  map_cats <- c("very low", "low", "high", "very high")
  map_colors <- c(totS_low_col(2), totS_high_col(2))
  names(map_colors) <- map_cats
  conus_data_sf$map_cat <- factor(conus_data_sf$map_cat, levels=map_cats)
  
  # Plot
  conus_permax <- ggplot(conus_data_sf, aes(fill=map_cat)) +
    geom_sf(color = NA)+
    scale_fill_manual(name = "Water Storage", values = map_colors) +
    theme_void() +
    coord_sf(datum = NA)
  
  # takes ~10 min to save
  ggsave(conus_permax,
         filename = sprintf("WBEEP/img/conus_totS_permax_hru_%s.png", season),
         height = 8, width = 11)
  
  message(sprintf("Completed %s", season))
}

# Per of avg (unique to each HRU)
for(season in c("winter", "spring", "summer", "autumn")) {
  
  map_data <- readRDS(sprintf("WBEEP/cache/totS_map_data_perofavg_hru_%s.rds", season))
  conus_data_sf <- left_join(conus_sf, map_data, by = c("hru_id_nat" = "HRU"))
  
  # test
  # conus_data_sf <- conus_data_sf[48000:58000,]
  
  # Turn categories into colors
  totS_low_col <- colorRampPalette(c("#CC4C02", "#FED98E")) # Brown to yellow
  totS_high_col <- colorRampPalette(c("#a7b9d7", "#144873")) # Light blue to dark blue
  map_cats <- c("way below avg", "below avg", "average", "above avg", "way above avg")
  map_colors <- c(totS_low_col(2), "#FFFFFF", totS_high_col(2))
  names(map_colors) <- map_cats
  conus_data_sf$map_cat <- factor(conus_data_sf$map_cat, levels=map_cats)
  
  # Plot
  conus_peravg <- ggplot(conus_data_sf, aes(fill=map_cat)) +
    geom_sf(color = NA)+
    scale_fill_manual(name = "Water Storage", values = map_colors) +
    theme_void() +
    coord_sf(datum = NA)
  
  # takes ~10 min to save
  ggsave(conus_peravg,
         filename = sprintf("WBEEP/img/conus_totS_peravg_hru_%s.png", season),
         height = 8, width = 11)
  
  message(sprintf("Completed %s", season))
}