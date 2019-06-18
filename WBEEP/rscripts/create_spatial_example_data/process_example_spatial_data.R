library(sf)
library(lwgeom) ## Needed for st_make_valid on Windows
library(dplyr)
library(rmapshaper)
gfdb <- "WBEEP/cache/GF_nat_reg.gdb"

# What layers exist: sf::st_layers(gfdb)

# Clean up HRU spatial data
hru_loaded <- read_sf(gfdb, "nhru") 

hru_reduced <- dplyr::select(hru_loaded, Shape, hru_id_nat)
#parallelize validation
library(parallel)
cl <- makeCluster(detectCores() - 1)
split_hru_shapes <- clusterSplit(cl, hru_reduced$Shape)
#takes ~10 minutes on my laptop with 7 core cluster
hru_list_valid <- parLapply(cl, split_hru_shapes, fun = st_make_valid)
hru_valid_shapes <- do.call(what = c, hru_list_valid)
stopCluster(cl)
#NOTE: assuming orders haven't been shuffled here
hru_reduced$Shape <- hru_valid_shapes
saveRDS(hru_reduced, file = 'WBEEP/cache/hru_reduced_valid.rds')
#now simplify -- don't think this can be parallized
#write out to shapefile and do rest via command line
write_sf(hru_reduced, 'WBEEP/cache/hru_reduced_valid.shp')
#simplify and quantize
#some features get lost here, and some are invalidated
#need a way to get this shape file to a format node can use 
# to test if toposimplify does better.  Creates a massive 
# geojson file with no simplification, would be pretty unwieldy
#note would need to increase memory limits for node -- can set an 
#environment variable
system('mapshaper WBEEP/cache/hru_reduced_valid.shp -simplify 10% -o WBEEP/cache/simp_10.topojson')
