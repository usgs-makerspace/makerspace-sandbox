
create_maps <- function(data_downloaded, hru_sf) {
  
  dates <- gsub("model_output_categorized_|.csv", "", basename(data_downloaded))
  
  map_fns <- c()
  for(i in 1:length(dates)) {
    map_data_i <- readr::read_csv(data_downloaded[i]) %>% 
      select(hru_id_nat, value) %>% 
      filter(value != "Undefined")
    map_fns[i] <- make_map(dates[i], hru_sf, map_data_i)
  }
  
  return(map_fns)
}


make_map <- function(date, hru_sf, map_data) {

  map_colors_vec <- c("#967a4a", "#BDAD9D", "#C8D3BA", "#337598", "#1C2040")
  names(map_colors_vec) <- c("very low", "low", "average", "high", "very high")
  map_colors_df <- data.frame(value = c("very low", "low", "average", "high", "very high"),
                              color = c("#967a4a", "#BDAD9D", "#C8D3BA", "#337598", "#1C2040"),
                              stringsAsFactors = FALSE)
  
  message(sprintf("Joining HRU availability data to sf object for %s", date))
  hru_data_sf <- left_join(hru_sf, map_data, by = "hru_id_nat") %>% 
    filter(!is.na(value)) %>% # there are some HRUs in hru_sf that aren't in the data 
    left_join(map_colors_df, by = "value")

  # Base plot is much faster to save than a ggplot2
  map_fn <- sprintf("WBEEP/rscripts/generate_gif_images/img/map_%s.png", date)
  message(sprintf("Saving HRU availability map for %s", date))
  png(map_fn, width = 11, height = 8, units="in", res=300)
  plot(st_geometry(hru_data_sf), col = hru_data_sf$color, border=NA,
       axes=FALSE, main = date)
  dev.off()

  message(sprintf("Completed %s", date))
  return(map_fn)

}

load_hru_shape <- function(fn, proj) {
  
  hru_sf <- read_sf(fn, "nhru")
  hru_sf_transf <- st_transform(hru_sf, st_crs(proj))
  
  # Self-intersections were causing downstream problems with cropping and summarizing for a dissolve
  hru_sf_valid <- st_make_valid(hru_sf_transf) # Needs pkg `lwgeom`
  hru_sf_valid_selfinter <- st_buffer(hru_sf_valid, dist = 0)
  
  return(hru_sf_valid_selfinter)
}

simplify_hru_sf <- function(hru_sf) {
  # According to this post, converting to `sp` and then 
  # simplifying using rmapshaper::ms_simplify works best.
  # https://gis.stackexchange.com/questions/243569/simplify-polygons-of-sf-object
  ms_simplify(input = as(hru_sf, 'Spatial')) %>%
    st_as_sf()
}

crop_hru_to_conus <- function(shape_to_crop, crop_sf) {
  st_intersection(shape_to_crop, crop_sf)
}

create_conus_sf <- function(proj) {
  
  conus_data <- map("usa", fill = TRUE, plot = FALSE)
  conus_sf <- st_as_sf(conus_data)
  conus_sf_transf <- st_transform(conus_sf, st_crs(proj))
  conus_sf_valid <- lwgeom::st_make_valid(conus_sf_transf)
  
  return(conus_sf_valid)
}
