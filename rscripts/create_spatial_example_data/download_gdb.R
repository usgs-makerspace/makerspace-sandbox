# Download data

library(googledrive)

# Authenticate in Google
drive_auth()

# Download the geodatabase from dblodgett
# ~ 800 MB, takes a few min on Middleton network
zipped_gdb_fn <- "cache/GF_nat_reg.gdb.zip"
downloaded_file <- drive_download(as_id("1PeiKUZ-fmigYhvz2d-jveMtb5L39csVn"), 
                                  path = zipped_gdb_fn)

# Unzip the file
# HAD TO MANUALLY UNZIP AND PLACE IN CACHE BECAUSE IT WAS CORRUPTED OTHERWISE
#unzip(zipped_gdb_fn, exdir = "cache")
