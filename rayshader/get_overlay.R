# Get overlay imagery

# Adapted from Will Bishop example: https://github.com/wcmbishop/rayshader-demo/blob/master/R/map-image-api.R
get_overlay <- function(img_width, img_height, overlay_fp = "rayshader/input/overlay.png") {
  map_types <- c("World_Street_Map", "World_Topo_Map", "World_Imagery")
  map_selection <- 3
  
  url <- parse_url("https://utility.arcgisonline.com/arcgis/rest/services/Utilities/PrintingTools/GPServer/Export%20Web%20Map%20Task/execute")
  
  # define JSON query parameter
  web_map_param <- list(
    baseMap = list(
      baseMapLayers = list(
        list(url = jsonlite::unbox(sprintf("https://services.arcgisonline.com/ArcGIS/rest/services/%s/MapServer",
                                           map_types[map_selection])))
      )
    ),
    exportOptions = list(
      outputSize = c(img_width,img_height)
    ),
    mapOptions = list(
      extent = list(
        spatialReference = list(wkid = jsonlite::unbox(4326)),
        xmax = jsonlite::unbox(max(bbox$p1$long, bbox$p2$long)),
        xmin = jsonlite::unbox(min(bbox$p1$long, bbox$p2$long)),
        ymax = jsonlite::unbox(max(bbox$p1$lat, bbox$p2$lat)),
        ymin = jsonlite::unbox(min(bbox$p1$lat, bbox$p2$lat))
      )
    )
  )
  
  message("Copy and paste the following JSON query into")
  message("https://utility.arcgisonline.com/arcgis/rest/services/Utilities/PrintingTools/GPServer/Export%20Web%20Map%20Task/execute")
  message(jsonlite::toJSON(web_map_param))
  
  message(sprintf("Then manually download the resulting image and store as '%s'", overlay_fp))
  return(overlay_fp)
}
