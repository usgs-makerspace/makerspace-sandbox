library(dataRetrieval)

#using a list of gages from the delaware river basin GIS website https://www.state.nj.us/drbc/library/documents/GIS/gage_stream.zip
sites_from_drb_gis_website <- read.csv("salt-propogation/spec_conductance_query/gages.csv",colClasses = "character")
#just get a list of the station numbers
listDRB <- sites_from_drb_gis_website$GAGE_USGS
#check what data exist for these stations and for specific conductance
available <- whatNWISdata(siteNumbers=listDRB, service="iv", parameterCd="00095")
#write out period of record to file
write.csv(available, "salt-propogation/spec_conductance_query/gages_with_sp_conductance.csv")


#used all the counties from the drb to query the WQP interface and get this csv of all stations in those counties
list_WQP <- read.csv("salt-propogation/spec_conductance_query/gages_drb_counties_wqp.csv", colClasses = "character")
#only keep the station name/number
listWQP <- list_WQP$Monitoring
#only keep USGS stations
listWQPUsgs <- subset(listWQP, grepl("^USGS", listWQP))
#remove USGS- prefix from number
listWQPStationsUsgs <- gsub("USGS-","",listWQPUsgs)
#check what's available
availableWQP <- whatNWISdata(siteNumbers=listWQPStationsUsgs, service="iv", parameterCd="00095")
#write out period of record to file
write.csv(availableWQP, "salt-propogation/spec_conductance_query/wqp_gages_with_sp_conductance.csv")
