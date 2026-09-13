library(tidyverse)
library(DescTools)
library(purrr)
library(tidycensus) #you might need to install this first and get an API key-easy, just sign up
library(mapview)
library(stringr)
library(educationdata)
library(sf)
library(readxl)
library(urbnthemes)
library(sp)
library(ipumsr)
library(survey)
library(srvyr)
#library(dummies)
library(dplyr)
library(Hmisc)
library(leaflet)

#load your API key for downloading censsus data
#census_api_key("05de4dca638d81abd2dc60d0d28e3781183e185e", install = TRUE)

#ths step give you the shapefile of DC tracts
tractboundary_20 <- get_acs(geography = "tract", 
                            variables = c("B01003_001"),
                            state = "DC",
                            geometry = TRUE,
                            year = 2022)

# If this doesnt work, I sent a tract boundary shapefile as well

#read in the CSV I sent 
neighborhoodchange_masterdata <- read.csv("C:/Users/Ysu/Documents/DMPED/DMPED/Prog/Neighborhood change/App-1/neighborhoodchange_masterdata.csv")

tractboundary_20$GEOID <- as.numeric(tractboundary_20$GEOID)
# master <- neighborhoodchange_masterdata %>% 
#   #mutate(GEOID=as.numeric(GEOID)) %>% #you might need to switch the format of GEOID, character vs. numeric for merge
#   left_join(tractboundary_20, by=c("GEOID")) 
#yl: https://github.com/tidyverse/ggplot2/issues/3391 above code didn't work, so I use right_join to do the join to keep the sf class.
master<- tractboundary_20 %>% 
  right_join(neighborhoodchange_masterdata, by=c("GEOID"))

#identify the layer where we highlight displacement
displacementarea <- master %>% 
  filter(neighborhoodtype=="exclusive growth with displacement risk"|neighborhoodtype=="established opportunity with displacement risk")

# YL: Replace the ggplot code with the following leaflet code
# Create a color palette for the neighborhood types
urban_colors7 <- colorFactor(
  palette = c("#73bfe2", "#f5cbdf", "#fce39e", "#1696d2", "#e9807d", "#fdd870", "#dcedd9"),
  domain = master$neighborhood.category
)

Test<- master %>% 
  select(neighborhood.category)

# Create the leaflet map
m <- leaflet(master) %>%
  addProviderTiles(providers$Stadia.StamenTonerLite) %>%
  addPolygons(
    fillColor = ~urban_colors7(neighborhood.category),
    weight = 1,
    opacity = 1,
    color = "white",
    dashArray = "3",
    fillOpacity = 0.8,
    highlightOptions = highlightOptions(
      weight = 5,
      color = "#666",
      dashArray = "",
      fillOpacity = 0.7,
      bringToFront = TRUE
    ),
    label = ~sprintf(
      "Census Tract: %s<br>Ward: %s<br>Neighborhood: %s<br>Type: %s",
      GEOID, Ward, NBH_NAMES, neighborhood.category
    ) %>% lapply(htmltools::HTML),
    labelOptions = labelOptions(
      style = list("font-weight" = "normal", padding = "3px 8px"),
      textsize = "15px",
      direction = "auto"
    )
  ) %>%
  addLegend(
    pal = urban_colors7,
    values = ~neighborhood.category,
    opacity = 0.7,
    title = "Neighborhood Type",
    position = "bottomright"
  )

# Display the map
options(viewer = NULL) 
m
library(mapview)
(options(viewer = NULL) ) 
mapview(m)

#YL: to pengpeng, add your map 2 below:

urban_colors7_m2 <- colorFactor(
  palette = c("#73bfe2", "#f5cbdf", "#fce39e", "#1696d2", "#e9807d", "#fdd870", "#dcedd9", "#eee888"),
  domain = master$Ward
)
# Create the leaflet map 2
m2 <- leaflet(master) %>%
  addProviderTiles(providers$Stadia.StamenTonerLite) %>%
  addPolygons(
    fillColor = ~urban_colors7_m2(Ward),
    weight = 1,
    opacity = 1,
    color = "white",
    dashArray = "3",
    fillOpacity = 0.8,
    highlightOptions = highlightOptions(
      weight = 5,
      color = "#666",
      dashArray = "",
      fillOpacity = 0.7,
      bringToFront = TRUE
    ),
    label = ~sprintf(
      "Census Tract: %s<br>Ward: %s<br>Neighborhood: %s<br>Type: %s",
      GEOID, Ward, NBH_NAMES, neighborhood.category
    ) %>% lapply(htmltools::HTML),
    labelOptions = labelOptions(
      style = list("font-weight" = "normal", padding = "3px 8px"),
      textsize = "15px",
      direction = "auto"
    )
  ) %>%
  addLegend(
    pal = urban_colors7_m2,
    values = ~Ward,
    opacity = 0.7,
    title = "Ward",
    position = "bottomright"
  )

# Display the map
m2
