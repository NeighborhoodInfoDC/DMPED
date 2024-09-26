library(tidyverse)
library(DescTools)
library(purrr)
library(tidycensus) #you might need to install this first and get an API key-easy, just sign up
library(mapview)
library(stringr)
library(educationdata)
library(sf)
library(readxl)
#library(urbnthemes)
library(sp)
library(ipumsr)
library(survey)
library(srvyr)
#library(dummies)
library(dplyr)
library(Hmisc)
library(leaflet)

#load your API key for downloading censsus data
# census_api_key("05de4dca638d81abd2dc60d0d28e3781183e185e", install = TRUE)

tractboundary_20 <- get_acs(geography = "tract", 
                            variables = c("B01003_001"),
                            state = "DC",
                            geometry = TRUE,
                            year = 2022)

#read in the CSV from OTR method
neighborhoodchange_masterdata <- read.csv("neighborhoodtype_homevalueOTR.csv")

#read in the CSV from rent method
neighborhoodchange_masterdata2 <- read.csv("neighborhoodchange_masterdata_rentvaluemethod_cat (1).csv")

# read in prediction categories
neighborhoodchange_masterdata3 <- read.csv("Prediction_map_shiny (1).csv")


master<- tractboundary_20 %>% 
  mutate(GEOID=as.numeric(GEOID)) %>% 
  right_join(neighborhoodchange_masterdata, by=c("GEOID"))

master2<- tractboundary_20 %>% 
  mutate(GEOID=as.numeric(GEOID)) %>% 
  right_join(neighborhoodchange_masterdata2, by=c("GEOID"))

master3<- tractboundary_20 %>% 
  mutate(GEOID=as.numeric(GEOID)) %>% 
  right_join(neighborhoodchange_masterdata3, by=c("GEOID"))

#identify the layer where we highlight displacement
#displacementarea <- master %>% 
  #filter(neighborhoodtype=="exclusive growth with displacement risk"|neighborhoodtype=="established opportunity with displacement risk")

# Replace the ggplot code with the following leaflet code
# Create a color palette for the neighborhood types
urban_colors7 <- colorFactor(
  palette = c("#73bfe2", "#f5cbdf", "#fce39e", "#1696d2", "#e9807d", "#fdd870", "#dcedd9"),
  domain = master$neighborhoodtype
)

# master <- st_transform(master, crs = 4326) 

# Create the leaflet map
m <- leaflet(master) %>%
  addProviderTiles(providers$Stadia.StamenTonerLite) %>%
  addPolygons(
    fillColor = ~urban_colors7(neighborhoodtype),
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
      "Census Tract: %s<br>Neighborhood: %s<br>Type: %s<br>Total Households: %s",
      GEOID, NBH_NAMES, neighborhoodtype, total_hh_2022
    ) %>% lapply(htmltools::HTML),
    labelOptions = labelOptions(
      style = list("font-weight" = "normal", padding = "3px 8px"),
      textsize = "15px",
      direction = "auto"
    )
  ) %>%
  addLegend(
    pal = urban_colors7,
    values = ~neighborhoodtype,
    opacity = 0.7,
    title = "Neighborhood Change Type_HomeValue",
    position = "bottomright"
  )

# Display the map
m


#YL: to pengpeng, add your map 2 below:

urban_colors7_m2 <- colorFactor(
  palette = c("#73bfe2", "#f5cbdf", "#fce39e", "#1696d2", "#e9807d", "#fdd870", "#dcedd9"),
  domain = master2$neighborhoodtype
)
# Create the leaflet map 2
m2 <- leaflet(master2) %>%
  addProviderTiles(providers$Stadia.StamenTonerLite) %>%
  addPolygons(
    fillColor = ~urban_colors7_m2(neighborhoodtype),
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
      "Census Tract: %s<br>Neighborhood: %s<br>Type: %s<br>Total Households: %s",
      GEOID, NBH_NAMES, neighborhoodtype, total_hh_2022
    ) %>% lapply(htmltools::HTML),
    labelOptions = labelOptions(
      style = list("font-weight" = "normal", padding = "3px 8px"),
      textsize = "15px",
      direction = "auto"
    )
  ) %>%
  addLegend(
    pal = urban_colors7_m2,
    values = ~neighborhoodtype,
    opacity = 0.7,
    title = "Neighborhood Change Type_rent",
    position = "bottomright"
  )

# Display the map
m2

#######new code for adding the third map on predicted displacement


urban_colors4_m3 <- colorFactor(
  palette = c("#fce39e","#dcedd9", "#1696d2", "#f5cbdf"),
  domain = master3$predictiontype
)
# Create the leaflet map 2
m3 <- leaflet(master3) %>%
  addProviderTiles(providers$Stadia.StamenTonerLite) %>%
  addPolygons(
    fillColor = ~urban_colors4_m3(predictiontype),
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
      "Census Tract: %s<br>Neighborhood: %s<br>Predicted Type: %s<br>Total Households: %s",
      GEOID, NBH_NAMES, predictiontype, total_hh_2022
    ) %>% lapply(htmltools::HTML),
    labelOptions = labelOptions(
      style = list("font-weight" = "normal", padding = "3px 8px"),
      textsize = "15px",
      direction = "auto"
    )
  ) %>%
  addLegend(
    pal = urban_colors4_m3,
    values = ~predictiontype,
    opacity = 0.7,
    title = "Predicted Future Displacement Type",
    position = "bottomright"
  )

# Display the map
m3



