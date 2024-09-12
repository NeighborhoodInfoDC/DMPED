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

Crosswalk_2000_to_2010 <- read_csv("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Raw/tract crosswalks/nhgis_tr2000_tr2010_11.csv") %>% 
  mutate(GEOID = as.character(tr2000ge))
# Crosswalk_2020_to_2010 <- read_csv("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Raw/tract crosswalks/nhgis_tr2020_tr2010_11.csv")
Crosswalk_2010_to_2020 <- read_csv("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Raw/tract crosswalks/nhgis_tr2010_tr2020_11.csv") %>% 
mutate(GEOID=as.character(tr2010ge))
v22 <- load_variables(2022, "acs5", cache = TRUE)
v12 <- load_variables(2012, "acs5", cache = TRUE)
subject22 <- load_variables(2022, "acs5/subject", cache = TRUE)
subject12 <- load_variables(2012, "acs5/subject", cache = TRUE)
v2000 <- load_variables(2000, "decennial", cache = TRUE)

##########################HOME VALUE AND RENT####################################
dc_median_home_value_2022 <- 
  get_acs(geography = "tract",
          variables = "B25107_001",
          year = 2022,
          state = "DC",
          geometry = FALSE) %>% 
  mutate(medianhome_2022=estimate)

dc_median_home_value_2012 <- 
  get_acs(geography = "tract",
          variables = "B25107_001",
          year = 2012,
          state = "DC",
          geometry = FALSE) %>% 
  mutate(medianhome_2012=estimate)
#pull in total home counts dc
dc_median_home_value_2000 <- 
  get_decennial(geography = "tract",
                variables = c("H076001"),
                year = 2000,
                state = "DC",
                geometry = FALSE) %>% 
  mutate(medianhome_2000=value)

#median rents 2000 - 2022

dc_median_rent_2000 <-
  get_decennial(geography = "tract",
                variable = "H063001",
                year = 2000,
                state = "DC",
                geometry = FALSE) %>% 
  mutate(rent_2000=value)

dc_median_rent_2022 <- 
  get_acs(geography = "tract",
          variable = "B25113_001",
          year = 2022,
          state = "DC",
          geometry = FALSE) %>% 
  mutate(rent_2022=estimate)

dc_median_rent_2012 <- 
  get_acs(geography = "tract",
          variable = "B25113_001",
          year = 2012,
          state = "DC",
          geometry = FALSE) %>% 
  mutate(rent_2012=estimate)

total_units_2012 <-
  get_acs(geography = "tract",
          variable = "B25042_001",
          year = 2012,
          state = "DC",
          geometry = FALSE) %>% 
  rename(units_2012=estimate)

total_units_2000 <-
  get_decennial(geography = "tract",
                variable = "H001001",
                year = 2000,
                state = "DC",
                geometry = FALSE) %>% 
  rename(units_2000=value)

total_units_2010 <-
  get_decennial(geography = "tract",
                variable = "H001001",
                year = 2010,
                state = "DC",
                geometry = FALSE) %>% 
  rename(units_2010=value)

consolidated_2000_2010 <- total_units_2000 %>% 
  left_join(Crosswalk_2000_to_2010, by=c("GEOID")) %>% 
  left_join(dc_median_home_value_2000, by=c("GEOID")) %>% 
  left_join(dc_median_rent_2000, by=c("GEOID")) %>% 
  mutate(medianvalue2000_subpart=units_2000*medianhome_2000*wt_ownhu,
         rent2000_subpart=units_2000*rent_2000*wt_renthu) %>% 
  group_by(tr2010ge) %>% 
  summarize(total_units = sum(units_2000, na.rm = TRUE),
            medianhome_2000_2010 = sum(medianvalue2000_subpart, na.rm= TRUE)/total_units,
            rent_2000_2010 = sum(rent2000_subpart, na.rm= TRUE)/total_units) 
  
# Crosswalk 2000 to 2020

consolidated_2000_2010_2020 <- total_units_2010 %>% 
  left_join(Crosswalk_2010_to_2020, by=c("GEOID")) %>% 
  left_join(consolidated_2000_2010, by=c("tr2010ge")) %>% 
  mutate(medianvalue2000_subpart=units_2010*medianhome_2000_2010*wt_ownhu,
         rent2000_subpart=units_2010*rent_2000_2010*wt_renthu) %>% 
  group_by(tr2020ge) %>% 
  summarize(total_units = sum(units_2010, na.rm = TRUE),
            medianhome_2000_2020 = sum(medianvalue2000_subpart, na.rm= TRUE)/total_units,
            rent_2000_2020 = sum(rent2000_subpart, na.rm= TRUE)/total_units) 

# crosswalk 2010 data to 2020
consolidated_2010_2020 <- total_units_2010 %>% 
  left_join(Crosswalk_2010_to_2020, by=c("GEOID")) %>% 
  left_join(dc_median_home_value_2012, by=c("GEOID")) %>% 
  left_join(dc_median_rent_2012, by=c("GEOID")) %>% 
  mutate(medianvalue2012_subpart=units_2010*medianhome_2012*wt_ownhu,
         rent2012_subpart=units_2010*rent_2012*wt_renthu) %>% 
  group_by(tr2020ge) %>% 
  summarize(total_units = sum(units_2010, na.rm = TRUE),
            medianhome_2012_2020 = sum(medianvalue2012_subpart, na.rm= TRUE)/total_units,
            rent_2012_2020 = sum(rent2012_subpart, na.rm= TRUE)/total_units) 

master_housingvalue <- consolidated_2000_2010_2020 %>% 
  left_join(consolidated_2010_2020, by=c("tr2020ge")) %>% 
  mutate(GEOID=as.character(tr2020ge)) %>% 
  left_join(dc_median_home_value_2022,by=c("GEOID")) %>% 
  left_join(dc_median_rent_2022,by=c("GEOID")) %>% 
  select(GEOID, medianhome_2000_2020,rent_2000_2020, medianhome_2012_2020, rent_2012_2020,rent_2022, medianhome_2022 )

##########################HOUSING UNITS ####################################


total_housing_units_2022<- 
  get_acs(geography = "tract",
          variables =  "B25002_001",
          year = 2022,
          state = "DC",
          geometry = FALSE) %>% 
  mutate(housing_2022=estimate)

total_housing_units_2012<- 
  get_acs(geography = "tract",
          variables =  "B25002_001",
          year = 2012,
          state = "DC",
          geometry = FALSE)%>% 
  mutate(housing_2012=estimate)

total_housing_units_2000 <- 
  get_decennial(geography = "tract",
                variables =  "H001001",
                year = 2000,
                state = "DC",
                geometry = FALSE)%>% 
  mutate(housing_2000=value)
owner_occupied_2022 <- 
  get_acs(geography = "tract",
          variables =  "B25003_002",
          year = 2022,
          state = "DC",
          geometry = FALSE)%>% 
  mutate(owner_2022=estimate)
owner_occupied_2012<- 
  get_acs(geography = "tract",
          variables =  "B25003_002",
          year = 2012,
          state = "DC",
          geometry = FALSE)%>% 
  mutate(owner_2012=estimate)

owner_occupied_2000<- 
  get_decennial(geography = "tract",
                variables =  "H004002",
                year = 2000,
                state = "DC",
                geometry = FALSE)%>% 
  mutate(owner_2000=value)
#renters
renters_2022<- 
  get_acs(geography = "tract",
          variables =  "B25003_003",
          year = 2022,
          state = "DC",
          geometry = FALSE)%>% 
  mutate(renter_2022=estimate)
renters_2012<- 
  get_acs(geography = "tract",
          variables =  "B25003_003",
          year = 2012,
          state = "DC",
          geometry = FALSE)%>% 
  mutate(renter_2012=estimate)
renters_2000<- 
  get_decennial(geography = "tract",
                variables =  "H004003",
                year = 2000,
                state = "DC",
                geometry = FALSE)%>% 
  mutate(renter_2000=value)

housing_2000 <- total_housing_units_2000 %>% 
  left_join(owner_occupied_2000, by=c("GEOID")) %>% 
  left_join(renters_2000, by=c("GEOID"))

housing_2012 <- total_housing_units_2012%>% 
  left_join(owner_occupied_2012,by=c("GEOID")) %>% 
  left_join(renters_2012,by=c("GEOID"))

housing_2022 <- total_housing_units_2022%>% 
  left_join(owner_occupied_2022,by=c("GEOID")) %>% 
  left_join(renters_2022,by=c("GEOID"))
 

consolidated_2000_2010_housing <-Crosswalk_2000_to_2010 %>% 
  left_join(housing_2000, by=c("GEOID")) %>% 
  mutate(housing2000_subpart=housing_2000*wt_hu,
         renter2000_subpart=renter_2000*wt_renthu,
         owner2000_subpart=owner_2000*wt_ownhu) %>% 
  group_by(tr2010ge) %>% 
  summarize(housing_2000_2010 = sum(housing2000_subpart, na.rm= TRUE),
            renter_2000_2010 = sum(renter2000_subpart, na.rm= TRUE),
            owner_2000_2010= sum(owner2000_subpart, na.rm= TRUE)) 

# Crosswalk 2000 to 2020

consolidated_2000_2010_2020_housing <- Crosswalk_2010_to_2020 %>% 
  left_join(consolidated_2000_2010_housing, by=c("tr2010ge")) %>% 
  mutate(housing2000_subpart=housing_2000_2010*wt_hu,
         renter2000_subpart=renter_2000_2010*wt_renthu,
         owner2000_subpart=owner_2000_2010*wt_ownhu) %>% 
  group_by(tr2020ge) %>% 
  summarize(housing_2000_2020 = sum(housing2000_subpart, na.rm= TRUE),
            renter_2000_2020 = sum(renter2000_subpart, na.rm= TRUE),
            owner_2000_2020=sum(owner2000_subpart, na.rm= TRUE)) 

consolidated_2010_2020_housing <-Crosswalk_2010_to_2020 %>% 
  left_join(housing_2012, by=c("GEOID")) %>% 
  mutate(housing2012_subpart=housing_2012*wt_hu,
         renter2012_subpart=renter_2012*wt_renthu,
         owner2012_subpart=owner_2012*wt_ownhu) %>% 
  group_by(tr2020ge) %>% 
  summarize(housing_2012_2020 = sum(housing2012_subpart, na.rm= TRUE),
            renter_2012_2020 = sum(renter2012_subpart, na.rm= TRUE),
            owner_2012_2020= sum(owner2012_subpart, na.rm= TRUE)) 

master_housingunits <- consolidated_2000_2010_2020_housing %>% 
  left_join(consolidated_2010_2020_housing, by=c("tr2020ge")) %>% 
  mutate(GEOID=as.character(tr2020ge)) %>% 
  left_join(housing_2022,by=c("GEOID")) %>% 
  select(GEOID, housing_2000_2020, renter_2000_2020, owner_2000_2020, housing_2012_2020, renter_2012_2020, owner_2012_2020
         , housing_2022, owner_2022,renter_2022)

#####################JOINING ALL HOUSING STUFF TOGETHER####################################################
housingmarket <- master_housingunits %>% 
  left_join(master_housingvalue,by=c("GEOID"))

vacancy <- read.csv("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/vanacy.csv") %>% 
  select(-X) %>% 
  mutate(GEOID=as.character(geoid)) %>% 
  select(-geoid, -total_residential)%>% 
  filter(year==2000|year==2012|year==2022) %>% 
  mutate(year=paste0("vacancy_", as.character(year))) %>% 
  spread(key=year,value=vacancyrate) 

housingmarket <- housingmarket %>% 
  left_join(vacancy,by=c("GEOID"))

write.csv(housingmarket,"C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/housingmarket.csv")


#####################LOW INCOME POPULATION####################################################

#HUD INCOME LIMIT 60% for 2 person household in 2022 is 68400, S1901_C01_007 gives $50,000 to $74,999 - the total is weird, use normal table instead
#HUD INCOME LIMIT 60% for 2 person household in 2022 is 68400, B19001_012 gives $60,000 to $74,999

lowincome_2022<- 
  get_acs(geography = "tract",
          variables =  c("B19001_002","B19001_003","B19001_004","B19001_005","B19001_006","B19001_007","B19001_008","B19001_009","B19001_010","B19001_011","B19001_012"),
          year = 2022,
          state = "DC",
          geometry = FALSE)%>% 
  pivot_wider(id_cols = c(GEOID, NAME),
              names_from = variable,
              values_from = c(estimate, moe))%>%
  replace(is.na(.), 0) %>% 
  mutate(lowincome_2022=as.numeric(estimate_B19001_002)+as.numeric(estimate_B19001_003)+as.numeric(estimate_B19001_004)+as.numeric(estimate_B19001_005)+as.numeric(estimate_B19001_006)+as.numeric(estimate_B19001_007)
         +as.numeric(estimate_B19001_008)
         +as.numeric(estimate_B19001_009)
         +as.numeric(estimate_B19001_010)
         +as.numeric(estimate_B19001_011)
         +as.numeric(estimate_B19001_012)*0.56) %>% 
  select(GEOID, lowincome_2022)


#HUD INCOME LIMIT 60% for 2 person household in 2012 is 51600, B19001A_011 gives $50,000 to $59,999
lowincome_2012<- 
  get_acs(geography = "tract",
          variables =  c("B19001_002","B19001_003","B19001_004","B19001_005","B19001_006","B19001_007","B19001_008","B19001_009","B19001_010","B19001_011"),
          year = 2012,
          state = "DC",
          geometry = FALSE)%>% 
  pivot_wider(id_cols = c(GEOID, NAME),
              names_from = variable,
              values_from = c(estimate, moe))%>%
  replace(is.na(.), 0) %>% 
  mutate(lowincome_2012=as.numeric(estimate_B19001_002)+as.numeric(estimate_B19001_003)+as.numeric(estimate_B19001_004)+as.numeric(estimate_B19001_005)+as.numeric(estimate_B19001_006)+as.numeric(estimate_B19001_007)
         +as.numeric(estimate_B19001_008)
         +as.numeric(estimate_B19001_009)
         +as.numeric(estimate_B19001_010)
         +as.numeric(estimate_B19001_011)*0.16)%>% 
  select(GEOID, lowincome_2012)

test3 <- lowincome_2012 %>% 
  mutate(total="total") %>% 
  group_by(total) %>% 
  summarize(lowincome=sum(lowincome_2012))

test4 <-consolidated_2010_2020_lowincome %>% 
  mutate(total="total") %>% 
  group_by(total) %>% 
  summarize(lowincome=sum(lowincome_2012_2020))

#HUD INCOME LIMIT 60% for 2 person household in 2000 is 38700, P052008 gives $35,000 to $39,999
#https://api.census.gov/data/2000/dec/sf3/variables.html
lowincome_2000<- get_decennial(geography = "tract",
                variables =  c("P052002","P052003","P052004","P052005","P052006","P052007","P052008"),
                year = 2000,
                state = "DC",
                geometry = FALSE)%>% 
  pivot_wider(id_cols = c(GEOID, NAME),
              names_from = variable,
              values_from = c(value)) %>% 
  replace(is.na(.), 0) %>% 
  mutate(lowincome_2000=as.numeric(P052002)+as.numeric(P052003)+as.numeric(P052004)+as.numeric(P052005)+as.numeric(P052006)+as.numeric(P052007)+as.numeric(P052008)) %>% 
  select(GEOID, lowincome_2000)


#crosswalk 2000-2010
consolidated_2000_2010_lowincome <-Crosswalk_2000_to_2010 %>% 
  left_join(lowincome_2000, by=c("GEOID")) %>% 
  mutate(lowincome_2000_subpart=lowincome_2000*wt_pop) %>% 
  group_by(tr2010ge) %>% 
  summarize(lowincome_2000_2010 = sum(lowincome_2000_subpart, na.rm= TRUE)) 

# Crosswalk 2000 to 2020

consolidated_2000_2010_2020_lowincome <- Crosswalk_2010_to_2020 %>% 
  left_join(consolidated_2000_2010_lowincome, by=c("tr2010ge")) %>% 
  mutate(lowincome_2000_subpart=lowincome_2000_2010*wt_pop) %>% 
  group_by(tr2020ge) %>% 
  summarize(lowincome_2000_2020 = sum(lowincome_2000_subpart, na.rm= TRUE)) 

# Crosswalk 2012 to 2020
consolidated_2010_2020_lowincome <-Crosswalk_2010_to_2020 %>% 
  left_join(lowincome_2012, by=c("GEOID")) %>% 
  mutate(lowincome2012_subpart=lowincome_2012*wt_pop) %>% 
  group_by(tr2020ge) %>% 
  summarize(lowincome_2012_2020 = sum(lowincome2012_subpart, na.rm= TRUE)) 

lowincomepop <- consolidated_2000_2010_2020_lowincome %>% 
  left_join(consolidated_2010_2020_lowincome,by=c("tr2020ge")) %>% 
  mutate(GEOID=as.character(tr2020ge)) %>% 
  left_join(lowincome_2022,by=c("GEOID"))

write.csv(lowincomepop,"C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/lowincome_pop.csv")

#########################distance to downtown#####################################

name <- c('downtown')
lat <- c(38.8955556)
lon <- c(-077.0320000)
downtown_point <- data.frame(name, lat, lon)

dt_sf = st_as_sf(downtown_point, coords = c("lon", "lat"), 
                 crs = 4326, agr = "constant") %>%
  st_transform(5070) ## project to a coordinate system, in meters

dt_onemile <- dt_sf %>% 
  st_buffer(1609) %>% ## buffer by a mile
  plot()

dt_halfmile <- dt_sf %>% 
  st_buffer(805) %>% ## buffer by half mile
  plot()

dt_onemile <- dt_sf %>% 
  st_buffer(1609) %>% ## buffer by a mile
  plot()

tractboundary_20 <- get_acs(geography = "tract", 
                            variables = c("B01003_001"),
                            state = "DC",
                            geometry = TRUE,
                            year = 2022)

#attach neighborhood cluster name to tract

tractpoint <-tractboundary_20 %>% 
  st_centroid() 
st_crs(dt_halfmile) <- st_crs(tractboundary_20 )

tract_inhalfmile <- dt_halfmile %>% 
  st_intersection(tractpoint) %>% 
  mutate(inbuffer_a =1) %>% 
  st_intersection(placedata) %>% 
  select(GEOID,inbuffer_a) %>% 
  st_drop_geometry() %>% 
  select(GEOID, inbuffer_a)


tract_inhalfmile <- tractpoint %>% 
  st_covered_by(dt_halfmile) %>% 
  mutate(inbuffer_a =1) %>% 
  st_intersection(placedata) %>% 
  select(GEOID,inbuffer_a) %>% 
  st_drop_geometry() %>% 
  select(GEOID, inbuffer_a)

test <- sf::st_intersection(tractpoint, dt_halfmile)

plot (tractboundary_halfmile)

dt_halfmile %>%
  ggplot() +
  geom_sf(aes(
    # Color in states by the chip_pct variable
    fill ="#ec008b"
  )) + 
  geom_sf(
    data = tractboundary_20,
    fill = NA
  )  
