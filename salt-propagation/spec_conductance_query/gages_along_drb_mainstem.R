# gage at northern end of DRB on the Delaware River
png(file="salt-propagation/spec_conductance_query/drb/01427207.png", width=600, height=350)
parameterCd <- "00095"
startDate <- "2019-12-01"
endDate <- "2019-12-15"
dfWide <- readNWISuv("01427207", "00095",
                     startDate, endDate)
dfWide <- dfWide[1:4]
colnames(dfWide) <- c("agency","station","dateTime","value")

par(mar=c(5,5,5,5)) #sets the size of the plot window
plot(dfWide$dateTime, dfWide$value,
     ylab="spec conductance",xlab="dateTime" )
dev.off()


# gages at northern end of DRB on the Delaware River
parameterCd <- "00095"
startDate <- "2019-12-01"
endDate <- "2019-12-15"
dfWide <- readNWISuv("01427510", "00095",
                     startDate, endDate)
dfWide <- dfWide[1:4]
colnames(dfWide) <- c("agency","station","dateTime","value")

par(mar=c(5,5,5,5)) #sets the size of the plot window
plot(dfWide$dateTime, dfWide$value,
     ylab="spec conductance",xlab="dateTime" )


# gages at northern end of DRB on the Delaware River
parameterCd <- "00095"
startDate <- "2019-12-01"
endDate <- "2019-12-15"
dfWide <- readNWISuv("01432160", "00095",
                     startDate, endDate)
dfWide <- dfWide[1:4]
colnames(dfWide) <- c("agency","station","dateTime","value")

par(mar=c(5,5,5,5)) #sets the size of the plot window
plot(dfWide$dateTime, dfWide$value,
     ylab="spec conductance",xlab="dateTime" )


# gages at northern end of DRB on the Delaware River
parameterCd <- "00095"
startDate <- "2019-12-01"
endDate <- "2019-12-15"
dfWide <- readNWISuv("01434000", "00095",
                     startDate, endDate)
dfWide <- dfWide[1:4]
colnames(dfWide) <- c("agency","station","dateTime","value")

par(mar=c(5,5,5,5)) #sets the size of the plot window
plot(dfWide$dateTime, dfWide$value,
     ylab="spec conductance",xlab="dateTime" )


# gages at northern end of DRB on the Delaware River
parameterCd <- "00095"
startDate <- "2019-12-01"
endDate <- "2019-12-15"
dfWide <- readNWISuv("01438500", "00095",
                     startDate, endDate)
dfWide <- dfWide[1:4]
colnames(dfWide) <- c("agency","station","dateTime","value")

par(mar=c(5,5,5,5)) #sets the size of the plot window
plot(dfWide$dateTime, dfWide$value,
     ylab="spec conductance",xlab="dateTime" )


# gages at middle of DRB on the Delaware River
parameterCd <- "00095"
startDate <- "2019-12-01"
endDate <- "2019-12-15"
dfWide <- readNWISuv("01439500", "00095",
                     startDate, endDate)
dfWide <- dfWide[1:4]
colnames(dfWide) <- c("agency","station","dateTime","value")

par(mar=c(5,5,5,5)) #sets the size of the plot window
plot(dfWide$dateTime, dfWide$value,
     ylab="spec conductance",xlab="dateTime" )


# gages at middle of DRB on the Delaware River
parameterCd <- "00095"
startDate <- "2019-12-01"
endDate <- "2019-12-15"
dfWide <- readNWISuv("01446500", "00095",
                     startDate, endDate)
dfWide <- dfWide[1:4]
colnames(dfWide) <- c("agency","station","dateTime","value")

par(mar=c(5,5,5,5)) #sets the size of the plot window
plot(dfWide$dateTime, dfWide$value,
     ylab="spec conductance",xlab="dateTime" )

# gages at middle of DRB on the Delaware River
parameterCd <- "00095"
startDate <- "2019-12-01"
endDate <- "2019-12-15"
dfWide <- readNWISuv("01458500", "00095",
                     startDate, endDate)
dfWide <- dfWide[1:4]
colnames(dfWide) <- c("agency","station","dateTime","value")

par(mar=c(5,5,5,5)) #sets the size of the plot window
plot(dfWide$dateTime, dfWide$value,
     ylab="spec conductance",xlab="dateTime" )

# gages at middle of DRB on the Delaware River
parameterCd <- "00095"
startDate <- "2019-12-01"
endDate <- "2019-12-15"
dfWide <- readNWISuv("01463500", "00095",
                     startDate, endDate)
dfWide <- dfWide[1:4]
colnames(dfWide) <- c("agency","station","dateTime","value")

par(mar=c(5,5,5,5)) #sets the size of the plot window
plot(dfWide$dateTime, dfWide$value,
     ylab="spec conductance",xlab="dateTime" )


# gages at southern end of DRB on the Delaware River
parameterCd <- "00095"
startDate <- "2019-12-01"
endDate <- "2019-12-15"
dfWide <- readNWISuv("01465798", "00095",
                     startDate, endDate)
dfWide <- dfWide[1:4]
colnames(dfWide) <- c("agency","station","dateTime","value")

par(mar=c(5,5,5,5)) #sets the size of the plot window
plot(dfWide$dateTime, dfWide$value,
     ylab="spec conductance",xlab="dateTime" )

# gages at southern end of DRB on the Delaware River
parameterCd <- "00095"
startDate <- "2019-12-01"
endDate <- "2019-12-15"
dfWide <- readNWISuv("01467048", "00095",
                     startDate, endDate)
dfWide <- dfWide[1:4]
colnames(dfWide) <- c("agency","station","dateTime","value")

par(mar=c(5,5,5,5)) #sets the size of the plot window
plot(dfWide$dateTime, dfWide$value,
     ylab="spec conductance",xlab="dateTime" )


# gages at southern end of DRB on the Delaware River
parameterCd <- "00095"
startDate <- "2019-12-01"
endDate <- "2019-12-15"
dfWide <- readNWISuv("01467200", "00095",
                     startDate, endDate)
dfWide <- dfWide[1:4]
colnames(dfWide) <- c("agency","station","dateTime","value")

par(mar=c(5,5,5,5)) #sets the size of the plot window
plot(dfWide$dateTime, dfWide$value,
     ylab="spec conductance",xlab="dateTime" )



# gages at southern end of DRB on the Delaware River
parameterCd <- "00095"
startDate <- "2019-12-01"
endDate <- "2019-12-15"
dfWide <- readNWISuv("01474703", "00095",
                     startDate, endDate)
dfWide <- dfWide[1:4]
colnames(dfWide) <- c("agency","station","dateTime","value")

par(mar=c(5,5,5,5)) #sets the size of the plot window
plot(dfWide$dateTime, dfWide$value,
     ylab="spec conductance",xlab="dateTime" )

# gages at southern end of DRB on the Delaware River
parameterCd <- "00095"
startDate <- "2019-12-01"
endDate <- "2019-12-15"
dfWide <- readNWISuv("01482800", "00095",
                     startDate, endDate)
dfWide <- dfWide[1:4]
colnames(dfWide) <- c("agency","station","dateTime","value")

par(mar=c(5,5,5,5)) #sets the size of the plot window
plot(dfWide$dateTime, dfWide$value,
     ylab="spec conductance",xlab="dateTime" )

