
# Visualizing floods using rayshader
# Followed blog by Will Bishop (https://wcmbishop.github.io/rayshader-demo/)

#### CURRENT IMPLEMENTATION IS NOT ACCURATE
#### Datum for bottom of the stream is not set up correctly.
#### Need to set the appropriate datum for the gage height & relationship to zscale.
#### This means the resulting water levels are innaccurate.

library(elevatr)
library(sp)
library(rayshader)
library(dataRetrieval)
library(dplyr)
source("rayshader/get_usgs_elevation_data.R")
source("rayshader/get_overlay.R")

start_str <- "2018-08-20 12:00:00"# August Flooding; June storm: "2018-06-16 01:00:00"
end_str <- "2018-08-21 14:00:00"# August Flooding; June storm: "2018-06-16 07:00:00"
river_data <- readNWISuv(siteNumbers = "05427948", parameterCd = "00065",
                         startDate = as.Date(start_str), endDate = as.Date(end_str)) %>%
  renameNWISColumns()

# Plot a quick hydrograph of this event
plot(river_data$dateTime, river_data$GH_Inst, xlab="Time", ylab="Water Level, ft")

# Get site info
site_info <- attr(river_data, "siteInfo")
site_lat <- site_info$dec_lat_va
site_lon <- site_info$dec_lon_va

# dplyr commands after extracting siteinfo since resulting dfs drop dataRetrieval attributes
river_data <- river_data  %>% 
  filter(dateTime >= as.POSIXct(start_str),
         dateTime <= as.POSIXct(end_str)) %>% 
  # keep half & full hourly observations
  mutate(minute = as.numeric(format(dateTime, "%M"))) %>% 
  filter(minute %in% c(0, 30)) %>% 
  # adjust depth column to fit elevation (HACK -- NEED A MORE PERMANENT SOLUTION)
  mutate(waterdepth = GH_Inst+272.5)

# Get bounding box around site
bbox <- list(
  p1 = list(long = site_lon-0.01, lat = site_lat-0.01),
  p2 = list(long = site_lon+0.01, lat = site_lat+0.01)
)

# scale site location to img dimensions
convert_to_img_dim <- function(spatial_input, spatial_min, spatial_max, img_min = 0, img_max = 400) {
  img_output <- ((spatial_input - spatial_min)/(spatial_max-spatial_min)) * (img_max - img_min) + img_min
  return(img_output)
}

site_y_img <- convert_to_img_dim(site_lat, bbox$p2$lat, bbox$p1$lat)
site_x_img <- convert_to_img_dim(site_lon, bbox$p2$long, bbox$p1$long)

# Download elevation data (using example from https://wcmbishop.github.io/rayshader-demo/)
elev_file <- "rayshader/input/sf-elevation.tif"
get_usgs_elevation_data(bbox, size = "400,400", 
                        file = elev_file,
                        sr_bbox = 4326, sr_image = 4326)

# Use elevation data to make a map
elev_img <- raster::raster(elev_file)
elev_matrix <- matrix(
  raster::extract(elev_img, raster::extent(elev_img), buffer = 1000), 
  nrow = nrow(elev_img), ncol = ncol(elev_img)
)

zscale <- 10

# calculate rayshader layers
ambmat <- ambient_shade(elev_matrix, zscale = zscale)
raymat <- ray_shade(elev_matrix, zscale = zscale, lambert = TRUE)
watermap <- detect_water(elev_matrix, zscale = zscale)

# Get overlay image
overlay_file <- get_overlay(400, 400)
overlay_img <- png::readPNG(overlay_file)

n_frames <- nrow(river_data)
img_frames <- paste0("rayshader/cache/img/augustflood_", seq_len(n_frames), ".png")

for (i in seq_len(n_frames)) {
  message(paste(" - image", i, "of", n_frames))
  elev_matrix %>%
    sphere_shade(texture = "imhof1") %>%
    add_shadow(ambmat, 0.5) %>%
    add_shadow(raymat, 0.5) %>%
    #add_overlay(overlay_img, alphalayer = 0.5) %>% 
    plot_3d(elev_matrix, solid = TRUE, shadow = TRUE, zscale = 1, 
            water = TRUE, watercolor = "#4e9bf8", #river_data$watertemp_cat[i], 
            wateralpha = 1, 
            waterlinealpha = 0.5,
            waterdepth = river_data$waterdepth[i], 
            phi = 25, theta = 115, fov=50, zoom=0.2)
  render_label(elev_matrix, x = site_x_img, y = site_y_img, z = 20, zscale=1, 
               text = site_info$station_nm, freetype = F)
  render_label(elev_matrix, x = 315, y = 300, z = 0, zscale=1, 
               text = river_data$dateTime[i], freetype = F)
  render_depth(focus=0.6,focallength = 10, filename = img_frames[i])
  rgl::clear3d()
}

# build gif
magick::image_write_gif(magick::image_read(img_frames), 
                        path = "rayshader/cache/pheasantbranchaugust2018.gif", 
                        delay = 10/n_frames)
