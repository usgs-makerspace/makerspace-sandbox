library(sf)
library(lwgeom) ## Needed for st_make_valid on Windows

gfdb <- "cache/GF_nat_reg.gdb"

# What layers exist: sf::st_layers(gfdb)

# Clean up HRU spatial data
hru_loaded <- read_sf(gfdb, "nhru")
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

#TODO:
#intersect HRUs with a state so can work with political
#boundaries and get a sense of scale
#probably need to get them in the same projection first

#this seem like best option that preserves topology
# Might use: rmapshaper::ms_simplify()
hru_sample <- hru_loaded$Shape[1:1000]
hru_sample_simple <- ms_simplify(hru_sample, keep=0.01)
pryr::object_size(hru_sample)
pryr::object_size(hru_sample_simple)
plot(hru_sample)
plot(hru_sample_simple)
