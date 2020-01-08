library(dataRetrieval)
library(tidyverse)
#get metadata
sites<-read.csv("drbTour//drb-stations-new.csv")
names(sites) <- "station"
siteList <- sites$station
reformatted <- gsub("USGS-","",siteList)
data<-readNWISsite(siteNumbers=reformatted)
data_sorted <- data %>%
  arrange(desc(dec_lat_va))
write.csv(data_sorted,"drbTour/drb-stations-sorted.csv")
