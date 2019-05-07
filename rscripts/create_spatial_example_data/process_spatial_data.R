library(sf)
library(lwgeom) ## Needed for st_make_valid on Windows

gfdb <- "cache/GF_nat_reg.gdb"

# What layers exist: sf::st_layers(gfdb)

# Clean up HRU spatial data
hru_loaded <- read_sf(gfdb, "nhru")

#intersect HRUs with a state so can work with political
#boundaries and get a sense of scale
#probably need to get them in the same projection first
library(raster)
states_shapes <- raster::getData('GADM', country="usa", level=1)
ohio <- subset(states_shapes, NAME_1 == "Ohio")
sp::plot(ohio)
class(ohio)
ohio_sf <- st_as_sf(ohio)
st_crs(ohio_sf)
ohio_projected <- st_transform(ohio_sf, crs = st_crs(hru_loaded))
hru_ohio_intersect <- st_intersection(ohio_projected, hru_loaded)
plot(hru_ohio_intersect$geometry) #all hru inside ohio

#this seem like best option that preserves topology
# Might use: rmapshaper::ms_simplify()
library(rmapshaper)
ohio_simple <- ms_simplify(hru_ohio_intersect, keep=0.005)
pryr::object_size(hru_ohio_intersect)
pryr::object_size(ohio_simple)
plot(ohio_simple$geometry)

#there are layers that list point/line errors,
#not sure if these are useful?
#line_errors <- read_sf(gfdb, "T_1_LineErrors")
pryr::object_size(hru_loaded$Shape)
#shape size is yuge
#all geometries are simple, but some are invalid
hru_valid <- st_make_valid(hru_loaded)
hru <- hru_valid %>% 
  select(hru_id_nat) %>%
  st_sf()

st_agr(hru) <- "constant"




#TODO: write out to topojson or however is used by 
#water use viz
library(geojsonio)
