library(dataRetrieval)

sites <- c("01427207", "01427510", "01432160", "01434000", "01438500", "01439500", "01446500", "01458500", "01463500", "01465798", "01467048", "01467200", "01474703")

sitesPA <- c("01474703","01467200","01467048","01465798","01439500")
sitesNYNJ <- c("01463500","01458500","01446500","01438500","01434000","01432160","01427510","01427207")
sitesNYHigh <- c("01427207","01427510","01432160")

pCodes <- c("00095")
startDate <- "2019-11-21"
endDate <- "2019-11-28"

wideMulti <- readNWISuv(sitesNYHigh, pCodes, startDate,endDate) %>%
  select(-ends_with("_cd"))

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
gp
