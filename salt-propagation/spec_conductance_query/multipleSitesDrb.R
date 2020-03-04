library(dataRetrieval)
library(ggplot2)
library(dplyr)
library(tidyr)

sites <- c("01427207", "01427510", "01432160", "01434000", "01438500", "01439500", "01446500", "01458500", "01463500", "01465798", "01467048", "01467200", "01474703")

pCodes <- c("00095")
startDate <- "2019-11-28"
endDate <- "2019-12-07"

for (i in 1:length(sites)) {
  
  wideMulti <- readNWISuv(sites[i], pCodes, startDate,endDate) %>%
    select(-ends_with("_cd"))
  
  if (length(wideMulti>0)) {
    siteInfo <- attr(wideMulti, "siteInfo")
    paramInfo <- attr(wideMulti, "variableInfo")
    
    longMulti <- gather(wideMulti, variable, value, -site_no, -dateTime) %>%
      mutate(variable = "Specific Conductance") %>%
      mutate(site_no = as.factor(site_no))
    
    levels(longMulti$variable) <- paramInfo$param_units
    levels(longMulti$site_no) <- paste0(siteInfo$station_nm, " - ", siteInfo$site_no)
    
    gp <- ggplot(longMulti, 
                 aes(dateTime, value, color=site_no)) +
      geom_line(size=1.5) + xlab("") + ylab("") +
      facet_grid(variable ~ .,scales= "free") + 
      theme(legend.title=element_blank(),
            legend.position='bottom',legend.direction = "vertical")
    ggsave(filename=paste0("salt-propagation/spec_conductance_query/drb/",sites[i],".png"), plot=last_plot(), device="png")
  }
}




