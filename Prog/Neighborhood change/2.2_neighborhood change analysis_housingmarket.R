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

distance <- read_csv("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/distance_downtown.csv")

analysismaster <- housingmarket %>% 
  left_join(lowincome, by=c("GEOID")) %>% 
  left_join(raceethnicity, by=c("GEOID")) %>% 
  left_join(distance, by=c("GEOID") )

tractboundary_20 <- get_acs(geography = "tract", 
                            variables = c("B01003_001"),
                            state = "DC",
                            geometry = TRUE,
                            year = 2022)

neighborhood = "W:/Libraries/OCTO/Maps/Neighborhood_Clusters.shp"
neighborhood_sf <- read_sf(dsn= neighborhood, layer= basename(strsplit(neighborhood, "\\.")[[1]])[1])

wards = "W:/Libraries/OCTO/Maps/Wards_from_2022.shp"
wards_sf <- read_sf(dsn= wards , layer= basename(strsplit(wards, "\\.")[[1]])[1])

#attach neighborhood cluster name to tract
st_crs(neighborhood_sf) <- st_crs(tractboundary_20)
st_crs(wards_sf) <- st_crs(tractboundary_20)

tractboundary_20_2 <- tractboundary_20 %>% 
  st_centroid() %>% 
  st_join(neighborhood_sf) %>% 
  st_drop_geometry() %>% 
  select(GEOID, NBH_NAMES)

tractboundary_20_3 <- tractboundary_20 %>% 
  st_centroid() %>% 
  st_join(wards_sf) %>% 
  st_drop_geometry() %>% 
  select(GEOID.x, NAME.y) %>% 
  rename(GEOID=GEOID.x,
         Ward=NAME.y)

tractboundary_20 <- tractboundary_20 %>% 
  left_join(tractboundary_20_2, by=c("GEOID")) %>% 
  left_join(tractboundary_20_3, by=c("GEOID")) 


droptract <- c("11001000201", "11001009511", "11001980000", "11001006804", "11001010900")

#merge analysis data with shapefile
map_file <- merge(analysismaster,tractboundary_20, by=c("GEOID")) %>% 
  filter(!GEOID %in% c("11001000201", "11001009511", "11001980000", "11001006804", "11001010900")) %>% 
  st_as_sf()

######housing market evaluation

outlier <- map_file %>% 
  filter(GEOID=="11001004100") %>% 
  mutate(quintile_2000=5,
         quintile_2012=5,
         quintile_2022=5)

housingmarket <- map_file %>% 
  mutate(medianhome_2000_2020=ifelse(medianhome_2000_2020==0, NA, medianhome_2000_2020),
         medianhome_2012_2020=ifelse(medianhome_2012_2020==0, NA, medianhome_2012_2020)) %>% 
  filter(GEOID !="11001004100") %>% 
  mutate(quintile_2000=ntile(medianhome_2000_2020,5),
         quintile_2012=ntile(medianhome_2012_2020,5),
         quintile_2022=ntile(medianhome_2022,5)) %>% 
  rbind(outlier) %>% 
  mutate(homevaluecat_2000=case_when(quintile_2000==1|quintile_2000==2 ~ "low",
                                     quintile_2000==3 ~ "moderate",
                                     quintile_2000==4|quintile_2000==5 ~ "high"),
         homevaluecat_2012=case_when(quintile_2012==1|quintile_2012==2 ~ "low",
                                     quintile_2012==3 ~ "moderate",
                                     quintile_2012==4|quintile_2012==5 ~ "high"),
         homevaluecat_2022=case_when(quintile_2022==1|quintile_2022==2 ~ "low",
                                     quintile_2022==3 ~ "moderate",
                                     quintile_2022==4|quintile_2022==5 ~ "high")) %>% 
  mutate(nominal_00_12=medianhome_2012_2020-medianhome_2000_2020*1.3,
         nominal_12_22=medianhome_2022-medianhome_2012_2020*1.29,
         nominal_00_22=medianhome_2022-medianhome_2000_2020*1.7) %>% 
  select(GEOID,total_hh_2022,medianhome_2000_2020,medianhome_2012_2020,medianhome_2022, quintile_2000,homevaluecat_2000, homevaluecat_2012,homevaluecat_2022, nominal_00_12, nominal_00_22,nominal_12_22,NBH_NAMES) %>% 
  mutate(housing_market=case_when(homevaluecat_2000 %in% c("low", "moderate") & homevaluecat_2022 %in% c("moderate","high")~ "growing",
                                  homevaluecat_2000 %in% c("high", "moderate") & homevaluecat_2022 %in% c("moderate","low")~ "declining",
                                  homevaluecat_2000 %in% c("high") & homevaluecat_2022 %in% c("high")~ "established",
                                  homevaluecat_2000 %in% c("low") & homevaluecat_2022 %in% c("low")~ "stagnant",
                                  TRUE ~ "other (might be dynamic)" )) 

test <- housingmarket %>% 
  select(GEOID, total_hh_2022,NBH_NAMES,housing_market,homevaluecat_2000,homevaluecat_2012, homevaluecat_2022, medianhome_2000_2020,medianhome_2022,nominal_00_22) %>% 
  filter(housing_market=="other (might be dynamic)") %>% 
  mutate(GEOID=as.character(GEOID)) %>% 
  left_join(dc_median_home_value_2021, by=c("GEOID"))

dc_median_home_value_2021 <- 
  get_acs(geography = "tract",
          variables = "B25107_001",
          year = 2021,
          state = "DC",
          geometry = FALSE) %>% 
  mutate(medianhome_2021=estimate)

test <- housingmarket %>% 
  group_by(homevaluecat_2000) %>% 
  count()

test <- housingmarket %>% 
  group_by(housing_market) %>% 
  count()
  
  