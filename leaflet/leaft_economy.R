library(leaflet)
library(sp)
library(mapproj)
library(maps)
library(mapdata)
library(maptools)
library(htmlwidgets)
library(magrittr)
library(XML)
library(plyr)
library(rgdal)
library(WDI)
library(raster)
library(noncensus)
library(stringr)
library(tidyr)
library(tigris)
library(rgeos)
library(ggplot2)
library(scales)

data(zip_codes)
data(counties)


Unemployment<- read.csv('Week2/Unemployment.csv')
Pop <- read.csv('Week2/2016PopulationEstimates.csv')
gdp <-read.csv("county_gdp.csv")

## Make all the column names lowercase
colnames(Unemployment) <- c("GEOID","state","name","laborforce","emp","unemp","UnRate")
colnames(Pop) <-c("GEOID","state","name","popest","BR","DR","NaInc")
Unemployment$GEOID <- formatC(Unemployment$GEOID, width = 5, format = "d", flag = "0")
Pop$GEOID <- formatC(Pop$GEOID, width = 5, format = "d", flag = "0")
gdp$GEOID <- formatC(gdp$GEOID, width = 5, format = "d", flag = "0")
Unemployment[] <- lapply(Unemployment, function(x) gsub(", [A-Z][A-Z]","",x))
Pop[] <- lapply(Pop, function(x) gsub(",","",x))
Unemployment$UnRate <- as.numeric(as.character(Unemployment$UnRate))
Pop$popest <- as.numeric(as.character(Pop$popest))

us.map <- readOGR(dsn = "Week2", layer = "cb_2016_us_county_20m", stringsAsFactors = FALSE)
head(us.map)
us.map <- us.map[!us.map$STATEFP %in% c("02", "15", "72", "66", "78", "60", "69",
                                        "64", "68", "70", "74"),]
us.map <- us.map[!us.map$STATEFP %in% c("81", "84", "86", "87", "89", "71", "76",
                                        "95", "79"),]


gdp <- merge(us.map, gdp, by=c("GEOID"))
Unemployment <-merge (us.map, Unemployment, by=c("GEOID"))
Pop <- merge (us.map, Pop, by=c("GEOID"))

# Format popup data for leaflet map.
popup_dat <- paste0("<strong>County: </strong>", 
                    gdp$county, 
                    "<br><strong>2015 GDP(Thousand dollars): </strong>", 
                    gdp$X2015_gdp)
#~ Wupeng Format popup data for leaflet map.
popup_dat2 <- paste0("<strong>County: </strong>",
                     Unemployment$name,
                     "<br><strong>Unemployment Rate: </strong>",
                     Unemployment$UnRate,"%",
                     "<br><strong>Number of unemployed: </strong>",
                     Unemployment$unemp)
#~ Wupeng Format popup data for leaflet map.
popup_dat3 <- paste0("<strong>County: </strong>",
                     Pop$name,
                     "<br><strong>Birth Rate: </strong>",
                     Pop$BR,"%",
                     "<br><strong>Death Rate: </strong>",
                     Pop$DR,"%",
                     "<br><strong>Natural Increase Rate: </strong>",
                     Pop$NaInc,"%")


pal <- colorQuantile("YlOrRd", NULL, n = 9)
#~ Wupeng 2 color
pal2 <- colorQuantile("Blues", NULL, n = 9)
#~ Wupeng 3 color
pal3 <- colorQuantile("Oranges", NULL, n = 9)
gmap <- leaflet(data = gdp) %>%
  # Base groups
  addTiles() %>%
  setView(lng = -105, lat = 40, zoom = 4) %>% 
  addPolygons(fillColor = ~pal(gdp$X2015_gdp), 
              fillOpacity = 0.8, 
              color = "#BDBDC3", 
              weight = 1,
              popup = popup_dat,
              group="2015 GDP by county") %>% 
  
  #~\\\\\\\\ Wupeng ////////add Unemployment
  addPolygons(fillColor = ~pal2(Unemployment$UnRate), 
              fillOpacity = 0.8, 
              color = "#BDBDC3", 
              weight = 1,
              popup = popup_dat2,
              group="2016 Unemployment Rate") %>%
  #~ Wupeng add Population
  addPolygons(fillColor = ~pal3(Pop$popest), 
              fillOpacity = 0.8, 
              color = "#BDBDC3", 
              weight = 1,
              popup = popup_dat3,
              group="2016 County Population") %>%
  addLayersControl(
    baseGroups = c("2015 GDP by county","2016 Unemployment Rate","2016 County Population"),
    #overlayGroups = c("Land Use Sites","Airport"),
    
    options = layersControlOptions(collapsed = FALSE)
  )


gmap
saveWidget(gmap, 'US_county_economy.html', selfcontained = TRUE)