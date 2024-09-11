library(tidyverse)
library(DescTools)
library(purrr)
library(tidycensus)
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
library(dummies)
library(dplyr)
library(Hmisc)
census_api_key("05de4dca638d81abd2dc60d0d28e3781183e185e", install = TRUE)

housingmarket <- read_csv("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/housingmarket.csv") 

lowincome <- read_csv("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/lowincome_pop.csv")

raceethnicity <- read_csv("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/race_ethnicity.csv")

analysismaster <- housingmarket %>% 
  left_join(lowincome, by=c("GEOID")) %>% 
  left_join(raceethnicity, by=c("GEOID"))

tractboundary_20 <- get_acs(geography = "tract", 
                            variables = c("B01003_001"),
                            state = "DC",
                            geometry = TRUE,
                            year = 2022)

neighborhood = "W:/Libraries/OCTO/Maps/Neighborhood_Clusters.shp"
neighborhood_sf <- read_sf(dsn= neighborhood, layer= basename(strsplit(neighborhood, "\\.")[[1]])[1])

#attach neighborhood cluster name to tract
st_crs(neighborhood_sf) <- st_crs(tractboundary_20)

tractboundary_20_2 <- tractboundary_20 %>% 
  st_centroid() %>% 
  st_join(neighborhood_sf) %>% 
  st_drop_geometry() %>% 
  select(GEOID, NBH_NAMES)

tractboundary_20 <- tractboundary_20 %>% 
  left_join(tractboundary_20_2, by=c("GEOID"))

#merge analysis data with shapefile
map_file <- merge(analysismaster,tractboundary_20, by=c("GEOID")) %>% 
  st_as_sf()

######Change in vulnerable population

changeinblack <- map_file %>% 
  select(GEOID,non_hispanic_black_hh_2000_2020,non_hispanic_black_hh_2012_2020,non_hispanic_black_hh_2022, total_hh_2000_2020, total_hh_2012_2020,total_hh_2022,NBH_NAMES) %>% 
  
