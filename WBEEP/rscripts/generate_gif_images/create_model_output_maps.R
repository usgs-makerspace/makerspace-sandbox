
create_maps <- function(data_downloaded, hru_sf, canada_sf, mexico_sf) {
  
  dates <- gsub("model_output_categorized_|.csv", "", basename(data_downloaded))
  
  map_fns <- c()
  for(i in 1:length(dates)) {
    map_data_i <- readr::read_csv(data_downloaded[i]) %>% 
      select(hru_id_nat, value) %>% 
      filter(value != "Undefined")
    map_fns[i] <- make_map(dates[i], hru_sf, canada_sf, mexico_sf, map_data_i)
  }
  
  return(map_fns)
}


make_map <- function(date, hru_sf, canada_sf, mexico_sf, map_data) {

  map_colors_vec <- c("#967a4a", "#BDAD9D", "#C8D3BA", "#337598", "#1C2040")
  names(map_colors_vec) <- c("very low", "low", "average", "high", "very high")
  map_colors_df <- data.frame(value = c("very low", "low", "average", "high", "very high"),
                              color = c("#967a4a", "#BDAD9D", "#C8D3BA", "#337598", "#1C2040"),
                              stringsAsFactors = FALSE)
  
  hru_data_sf <- left_join(hru_sf, map_data, by = "hru_id_nat") %>% 
    filter(!is.na(value)) %>% # there are some HRUs in hru_sf that aren't in the data
    left_join(map_colors_df, by = "value")

  # Base plot is much faster to save than a ggplot2
  map_fn <- sprintf("WBEEP/rscripts/generate_gif_images/img/map_%s.png", date)
  png(map_fn, width = 11, height = 8, units="in", res=300)
  plot(st_geometry(hru_data_sf), col = hru_data_sf$color, border=NA, 
       axes=FALSE, main = date)
  # CANADA/MEXICO not quite right yet.
  #plot(st_geometry(canada_sf), col = "black", add=TRUE)
  dev.off()

  message(sprintf("Completed %s", date))
  return(map_fn)

}

load_hru_shape <- function(fn, proj) {
  
  topo_data_hru <- topojson_read(fn)
  hru_sf <- st_as_sf(topo_data_hru)
  st_crs(hru_sf) <- proj
  
  # No longer need, but want to keep record.
  # Self-intersections were causing downstream problems with summarizing for a dissolve
  # hru_sf_valid <- st_make_valid(hru_sf) # Needs pkg `lwgeom`
  
  return(hru_sf)
}

create_country_overlays <- function(country, proj) {
  
  country_data <- map("worldHires", country, fill = TRUE, plot = FALSE)
  country_sf <- st_as_sf(country_data)
  country_sf_transf <- st_transform(country_sf, st_crs(proj))
  
  return(country_sf_transf)
}
