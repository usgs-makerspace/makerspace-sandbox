library(dataRetrieval)
sites <- whatNWISsites(bBox=c(-75.702667,40.045752,-75.428352,40.109325),
                       parameterCd=("00095"),
                       hasDataTypeCd="uv")

# get data for Winter Storm (16-20 Jan 2019) https://www.wpc.ncep.noaa.gov/storm_summaries/event_reviews.php?YYYYMMDD=20190120 
# Valley Creek at PA Turnpike Br near Valley Forge - 01473169
parameterCd <- "00095"
startDate <- "2019-01-16"
endDate <- "2019-01-20"
dfWide <- readNWISuv("01473169", "00095",
                     startDate, endDate)
dfWide <- dfWide[1:4]
colnames(dfWide) <- c("agency","station","dateTime","value")

par(mar=c(5,5,5,5)) #sets the size of the plot window
plot(dfWide$dateTime, dfWide$value,
     ylab="spec conductance",xlab="dateTime" )


# get data for Winter Storm (27-30 Jan 2019) https://www.wpc.ncep.noaa.gov/storm_summaries/event_reviews.php?YYYYMMDD=20190130
# Valley Creek at PA Turnpike Br near Valley Forge - 01473169
parameterCd <- "00095"
startDate <- "2019-01-27"
endDate <- "2019-01-30"
dfWide <- readNWISuv("01473169", "00095",
                     startDate, endDate)
dfWide <- dfWide[1:4]
colnames(dfWide) <- c("agency","station","dateTime","value")

par(mar=c(5,5,5,5)) #sets the size of the plot window
plot(dfWide$dateTime, dfWide$value,
     ylab="spec conductance",xlab="dateTime" )


# get data for Winter Storms between Jan and Feb 
# Valley Creek at PA Turnpike Br near Valley Forge - 01473169
parameterCd <- "00095"
startDate <- "2019-01-01"
endDate <- "2019-02-01"
dfWide <- readNWISuv("01473169", "00095",
                     startDate, endDate)
dfWide <- dfWide[1:4]
colnames(dfWide) <- c("agency","station","dateTime","value")

par(mar=c(5,5,5,5)) #sets the size of the plot window
plot(dfWide$dateTime, dfWide$value,
     ylab="spec conductance",xlab="dateTime" )


# get data for Winter Storms between Feb and March
# Valley Creek at PA Turnpike Br near Valley Forge - 01473169
parameterCd <- "00095"
startDate <- "2019-02-01"
endDate <- "2019-03-01"
dfWide <- readNWISuv("01473169", "00095",
                     startDate, endDate)
dfWide <- dfWide[1:4]
colnames(dfWide) <- c("agency","station","dateTime","value")

par(mar=c(5,5,5,5)) #sets the size of the plot window
plot(dfWide$dateTime, dfWide$value,
     ylab="spec conductance",xlab="dateTime" )

# get data for Winter Storms between Mar and Apr
# Valley Creek at PA Turnpike Br near Valley Forge - 01473169
parameterCd <- "00095"
startDate <- "2019-03-01"
endDate <- "2019-04-01"
dfWide <- readNWISuv("01473169", "00095",
                     startDate, endDate)
dfWide <- dfWide[1:4]
colnames(dfWide) <- c("agency","station","dateTime","value")

par(mar=c(5,5,5,5)) #sets the size of the plot window
plot(dfWide$dateTime, dfWide$value,
     ylab="spec conductance",xlab="dateTime" )

# get data for Winter Storms between Apr and May
# Valley Creek at PA Turnpike Br near Valley Forge - 01473169
parameterCd <- "00095"
startDate <- "2019-04-01"
endDate <- "2019-05-01"
dfWide <- readNWISuv("01473169", "00095",
                     startDate, endDate)
dfWide <- dfWide[1:4]
colnames(dfWide) <- c("agency","station","dateTime","value")

par(mar=c(5,5,5,5)) #sets the size of the plot window
plot(dfWide$dateTime, dfWide$value,
     ylab="spec conductance",xlab="dateTime" )

# get data for Winter Storms between May and June
# Valley Creek at PA Turnpike Br near Valley Forge - 01473169
parameterCd <- "00095"
startDate <- "2019-05-01"
endDate <- "2019-06-01"
dfWide <- readNWISuv("01473169", "00095",
                     startDate, endDate)
dfWide <- dfWide[1:4]
colnames(dfWide) <- c("agency","station","dateTime","value")

par(mar=c(5,5,5,5)) #sets the size of the plot window
plot(dfWide$dateTime, dfWide$value,
     ylab="spec conductance",xlab="dateTime" )


# get data for Winter Storms between June and July
# Valley Creek at PA Turnpike Br near Valley Forge - 01473169
parameterCd <- "00095"
startDate <- "2019-06-01"
endDate <- "2019-07-01"
dfWide <- readNWISuv("01473169", "00095",
                     startDate, endDate)
dfWide <- dfWide[1:4]
colnames(dfWide) <- c("agency","station","dateTime","value")

par(mar=c(5,5,5,5)) #sets the size of the plot window
plot(dfWide$dateTime, dfWide$value,
     ylab="spec conductance",xlab="dateTime" )
