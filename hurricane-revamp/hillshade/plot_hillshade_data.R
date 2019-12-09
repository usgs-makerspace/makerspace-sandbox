# Add hill-shading

library(raster)
# Downloaded & unzipped tif from https://earthexplorer.usgs.gov/
#   Searched "National Map" under "Data Sets"
#   Then "Shaded Relief" under "Additional Criteria" tab in the "Title" section
#   Then looked at results.
# This is the "Shaded Relief Land - Gray - North America 1"
hillshade_raster <- raster("hurricane-revamp/hillshade/srgrayi1kml.tif")

# Reprojecting took about 7 minutes
hillshade_raster_proj <- projectRaster(hillshade_raster, crs = "+proj=lcc +lat_1=30.7 +lat_2=29.3 +lat_0=28.5 +lon_0=-91.33333333333333 +x_0=999999.9999898402 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs")
saveRDS(hillshade_raster_proj, "hurricane-revamp/hillshade/reprojected_hillshade_raster.rds")

# Cut hillshade to just view polygon
view_polygon <- readRDS("hurricane-revamp/hillshade/view_polygon.rds")
view_polygon_bbox <- sf::st_bbox(view_polygon)[c(1,3,2,4)] # reordered to match raster::extent vector
hillshade_cropped <- crop(hillshade_raster_proj, view_polygon_bbox)

# Plot the hillshade
plot(hillshade_raster, col=grey(0:100/100))
plot(hillshade_raster_proj, col=grey(0:100/100))
plot(hillshade_cropped, col=grey(0:100/100))

