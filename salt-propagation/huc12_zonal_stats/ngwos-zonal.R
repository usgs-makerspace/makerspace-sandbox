library(raster)

ff <- list.files(".", pattern = "\\.tif$", full=TRUE)
s <- stack(ff)

poly <- shapefile("drb-huc12.shp")

ex <- extract(s, poly, fun='mean', na.rm=TRUE, df=TRUE, weights = TRUE)

#write to a data frame
df <- data.frame(ex)

#write to a CSV file
write.csv(df, file = "RSV_CSV.csv")
