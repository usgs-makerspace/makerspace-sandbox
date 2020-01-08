# https://mesonet.agron.iastate.edu/cgi-bin/wms/nexrad/n0r-t.cgi?LAYERS=nexrad-n0r-wmst&TRANSPARENT=TRUE&FORMAT=image%2Fpng&TIME=2018-10-12T05%3A00&SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&STYLES=&BBOX=-10449247.5147,2876478.2484,-7318386.8361,6222585.5986&SRS=EPSG:3857&WIDTH=256&HEIGHT=256
# url breakdown by param
# https://mesonet.agron.iastate.edu/cgi-bin/wms/nexrad/n0r-t.cgi?
# LAYERS=nexrad-n0r-wmst
# &TRANSPARENT=TRUE
# &FORMAT=image%2Fpng
# &TIME=2018-10-12T05%3A00
# &SERVICE=WMS&VERSION=1.1.1
# &REQUEST=GetMap
# &STYLES=
# &BBOX=-10449247.5147,2876478.2484,-7318386.8361,6222585.5986
# &SRS=EPSG:3857
# &WIDTH=256
# &HEIGHT=256
# we want to use this request over and over to get the period of record we are interested in, 
# which means swapping in the TIME param and then saving the request as an image and then moving on
# TIME=2018-10-12T05%3A00

prefix <- "https://mesonet.agron.iastate.edu/cgi-bin/wms/nexrad/n0r-t.cgi?LAYERS=nexrad-n0r-wmst&TRANSPARENT=TRUE&FORMAT=image%2Ftiff&TIME="
suffix <- "&SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&STYLES=&BBOX=-10449247.5147,2876478.2484,-7318386.8361,6222585.5986&SRS=EPSG:3857&WIDTH=256&HEIGHT=256"
timestamps_desired <- 
  seq(
    from=as.POSIXct("2018-10-10 0:00", tz="UTC"),
    to=as.POSIXct("2018-10-12 24:00", tz="UTC"),
    by="hour"
  )  
string_timestamps_desired <- as.character(timestamps_desired)
string_timestamps_desired <- gsub(":","%3A",string_timestamps_desired)
string_timestamps_desired <- gsub(" ","T",string_timestamps_desired)
for (i in 1:length(string_timestamps_desired)) {
  path <- paste0(prefix,string_timestamps_desired[i],suffix)
  filename <- paste0("michael",i)
  download.file(path, destfile=paste0(filename,".tiff"),method="auto")
}

