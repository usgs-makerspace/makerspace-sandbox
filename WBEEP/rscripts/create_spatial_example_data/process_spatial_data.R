library(sf)
library(lwgeom) ## Needed for st_make_valid on Windows

gfdb <- "WBEEP/cache/GF_nat_reg.gdb"

# What layers exist: sf::st_layers(gfdb)

# Clean up HRU spatial data
hru_loaded <- read_sf(gfdb, "nhru")
hru_valid <- st_make_valid(hru_loaded)
hru <- hru_valid %>% 
  select(hru_id_nat) %>%
  st_sf()

st_agr(hru) <- "constant"


# Might use: rmapshaper::ms_simplify()

