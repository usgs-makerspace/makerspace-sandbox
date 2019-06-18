library(sf)
library(lwgeom) ## Needed for st_make_valid on Windows

gfdb <- "WBEEP/cache/GF_nat_reg.gdb"

# What layers exist: sf::st_layers(gfdb)

# Clean up HRU spatial data
hru_loaded <- read_sf(gfdb, "nhru")

#intersect HRUs with a state so can work with political
#boundaries and get a sense of scale
#probably need to get them in the same projection first
library(raster)
states_shapes <- raster::getData('GADM', country="usa", level=1)
one_state <- subset(states_shapes, NAME_1 == "Colorado")
sp::plot(one_state)
class(one_state)
one_state_sf <- st_as_sf(one_state)
st_crs(one_state_sf)
one_state_projected <- st_transform(one_state_sf, crs = st_crs(hru_loaded))
hru_one_state_intersect <- st_intersection(one_state_projected, hru_loaded)
plot(hru_one_state_intersect$geometry) #all hru inside one_state

#this seem like best option that preserves topology
# Might use: rmapshaper::ms_simplify()
library(rmapshaper)
one_state_simple <- ms_simplify(hru_one_state_intersect, keep=0.001)
pryr::object_size(hru_one_state_intersect)
pryr::object_size(one_state_simple)
plot(one_state_simple$geometry)
one_state_reduced <- dplyr::select(one_state_simple, 
                                   hru_id_nat, geometry)
library(geojsonio)
geojsonio::topojson_write(one_state_reduced, geometry = "polygon",
                          object_name = "test_state_hrus",
                          file = "WBEEP/cache/test_state_hru_simple.topojson",
                          quantization = 1e6)
one_state_valid <- st_make_valid(one_state_reduced$geometry)
#there are layers that list point/line errors,
#not sure if these are useful?
#line_errors <- read_sf(gfdb, "T_1_LineErrors")
pryr::object_size(hru_loaded$Shape)
#shape size is yuge
#all geometries are simple, but some are invalid
hru_valid <- st_make_valid(hru_loaded$Shape)
hru <- hru_valid %>% 
  select(hru_id_nat) %>%
  st_sf()

st_agr(hru) <- "constant"
