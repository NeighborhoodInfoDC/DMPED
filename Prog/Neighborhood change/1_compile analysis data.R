## compile data used for neighborhood change and displacement analysis
## Yipeng Su
## last updated 9/25/2024

#load packages for this program
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, DescTools, purrr, tidycensus, mapview, stringr, 
               educationdata, sf, readxl, sp, ipumsr, 
               survey, srvyr,dplyr, Hmisc, haven)

census_api_key("05de4dca638d81abd2dc60d0d28e3781183e185e", install = TRUE)
#get your key at https://api.census.gov/data/key_signup.html

#update to your Box drive directory
setwd("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/")

Crosswalk_2000_to_2010 <- read_csv("Raw/tract crosswalks/nhgis_tr2000_tr2010_11.csv") %>% 
  mutate(GEOID = as.character(tr2000ge))
# Crosswalk_2020_to_2010 <- read_csv("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Raw/tract crosswalks/nhgis_tr2020_tr2010_11.csv")
Crosswalk_2010_to_2020 <- read_csv("Raw/tract crosswalks/nhgis_tr2010_tr2020_11.csv") %>% 
mutate(GEOID=as.character(tr2010ge))

#you can use these variable tables to check the variables used for each variable and year
v22 <- load_variables(2022, "acs5", cache = TRUE)
v12 <- load_variables(2012, "acs5", cache = TRUE)
subject22 <- load_variables(2022, "acs5/subject", cache = TRUE)
subject12 <- load_variables(2012, "acs5/subject", cache = TRUE)
v2000 <- load_variables(2000, "sf3", cache = TRUE)

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

test <- dc_median_home_value_2012
#pull in total home counts dc
dc_median_home_value_2000 <- 
  get_decennial(geography = "tract",
                variables = c("H076001"),  
                year = 2000,
                state = "DC",
                geometry = FALSE) %>% 
  mutate(medianhome_2000=value)

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

vacancy <- read.csv("Clean/vanacy.csv") %>% 
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
# Define downtown
downtown_point <- data.frame(
  name = "downtown",
  lat = 38.89556,
  lon = -77.032
)

# Convert the data frame to sf object
downtown_sf <- st_as_sf(downtown_point, coords = c("lon", "lat"), crs = 4326)

# Use CRS 3857
downtown_sf_proj <- st_transform(downtown_sf, crs = 3857)

# Create half-mile buffer
dt_halfmile <- st_buffer(downtown_sf_proj, dist = set_units(0.5, "mi"))

tracts_distance <- tractboundary_20 %>%
  st_transform(crs = st_crs(downtown_sf)) %>%
  mutate(distance_to_downtown_miles = as.numeric(set_units(st_distance(geometry, downtown_sf), "mi"))) %>%
  select(GEOID, distance_to_downtown_miles) %>% 
  st_drop_geometry()

write.csv(tracts_distance,"C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/distance_downtown.csv")


### college degree
#percent bachelor's degree -> do we want % of total pop, % of >18 pop or % of >= 25 pop?

percent_bachelors_over_25_2022 <- get_acs(geography = "tract",
                                          variables = c("B15003_022", "B15003_023", "B15003_024", "B15003_025", "B07001_006","B07001_007", "B07001_008",
                                                        "B07001_009", "B07001_010", "B07001_011", "B07001_012", "B07001_013",
                                                        "B07001_014", "B07001_015", "B07001_016" ),
                                          year = 2022,
                                          state = "DC",
                                          geometry = FALSE) %>%
  pivot_wider(id_cols = c(GEOID, NAME),
              names_from = variable,
              values_from = estimate) %>%
  mutate(over_25 = B07001_006 +  B07001_007 + B07001_008 + B07001_009 + B07001_010 + B07001_011 
         + B07001_012  + B07001_013  + B07001_014  + B07001_015  + B07001_016, #AGGREGATING THE 25 AND UP AGE CATEGORIES
         bachelors_or_more = B15003_022 + B15003_023 + B15003_024 + B15003_025,
         percent_bachelors = bachelors_or_more/over_25) 
sum(percent_bachelors_over_25_2022$bachelors_or_more)
sum(percent_bachelors_over_25_2022$over_25)
# write.csv(percent_bachelors_over_25_2022, "age_college_22_data.csv")
#303532/484596 = 6263609 thats right
percent_bachelors_over_25_2012 <- get_acs(geography = "tract",
                                          variables = c("B15003_022", "B15003_023", "B15003_024", "B15003_025", "B07001_006","B07001_007", "B07001_008",
                                                        "B07001_009", "B07001_010", "B07001_011", "B07001_012", "B07001_013",
                                                        "B07001_014", "B07001_015", "B07001_016" ),
                                          year = 2012,
                                          state = "DC",
                                          geometry = FALSE) %>%
  pivot_wider(id_cols = c(GEOID, NAME),
              names_from = variable,
              values_from = estimate) %>%
  mutate(over_25 = B07001_006 +  B07001_007 + B07001_008 + B07001_009 + B07001_010 + B07001_011 
         + B07001_012  + B07001_013  + B07001_014  + B07001_015  + B07001_016, #AGGREGATING THE 25 AND UP AGE CATEGORIES
         bachelors_or_more = B15003_022 + B15003_023 + B15003_024 + B15003_025,
         percent_bachelors = bachelors_or_more/over_25) 
sum(percent_bachelors_over_25_2012$bachelors_or_more)
sum(percent_bachelors_over_25_2012$over_25)

#age 25 and above men
m_over_25_2000 <- get_decennial(geography = "tract",
                                variables = c("P012011", "P012012", "P012013",
                                              "P012014", "P012015", "P012016", "P012017", "P012018", "P012019", "P012020",
                                              "P012021", "P012022", "P012023", "P012024","P012025"),
                                year = 2000,
                                state = "DC",
                                geometry = FALSE) %>%
  pivot_wider(id_cols = c(GEOID, NAME),
              names_from = variable,
              values_from = value) %>%
  mutate(m_over_25 = P012011 + P012012 + P012013 + P012014 + P012015 + P012016 + P012017 + P012018 + P012019 + P012020 +
           P012021 + P012022 + P012023 + P012024 + P012025)
#bachelors men 2000
m_percent_bachelors_over_25_2000 <- get_decennial(geography = "tract",
                                                  variables = c("P037015", "P037016", "P037017", "P037018"),
                                                  year = 2000,
                                                  state = "DC",
                                                  geometry = FALSE) %>%
  pivot_wider(id_cols = c(GEOID, NAME),
              names_from = variable,
              values_from = value) %>%
  mutate(m_bachelors_or_more = P037015 + P037016 + P037017 + P037018)
#joining together
m_percent_bachelors_over_25_2000 <- left_join(m_percent_bachelors_over_25_2000, m_over_25_2000, by = "GEOID")
m_percent_bachelors_over_25_2000 <- m_percent_bachelors_over_25_2000 %>%
  select(-NAME.y)
sum(m_percent_bachelors_over_25_2000$m_bachelors_or_more)
sum(m_percent_bachelors_over_25_2000$m_over_25)
# 74203/178393 #thats right

#women over 25 2000
w_over_25_2000 <- get_decennial(geography = "tract",
                                variables = c("P012035", "P012036", "P012037", "P012038", "P012039",
                                              "P012040", "P012041", "P012042", "P012043", "P012044",
                                              "P012045", "P012046", "P012047", "P012048", "P012049"),
                                year = 2000,
                                state = "DC",
                                geometry = FALSE) %>%
  pivot_wider(id_cols = c(GEOID, NAME),
              names_from = variable,
              values_from = value) %>%
  mutate(w_over_25 = P012035 + P012036 + P012037 + P012038 + P012039 + P012040 + P012041 + 
           P012042 + P012043 + P012044 + P012045 + P012046 + P012047 + P012048 + P012049)

#women bachelors 2000
w_percent_bachelors_over_25_2000 <- get_decennial(geography = "tract",
                                                  variables = c("P037032", "P037033", "P037034", "P037035"),
                                                  year = 2000,
                                                  state = "DC",
                                                  geometry = FALSE) %>%
  pivot_wider(id_cols = c(GEOID, NAME),
              names_from = variable,
              values_from = value) %>%
  mutate(w_bachelors_or_more = P037032 + P037033 + P037034 + P037035)
#joining
w_percent_bachelors_over_25_2000 <- left_join(w_percent_bachelors_over_25_2000, w_over_25_2000, by = "GEOID")
w_percent_bachelors_over_25_2000 <- w_percent_bachelors_over_25_2000 %>% select(-NAME.x)
#alltogether
percent_bachelors_over_25_2000 <-
  left_join(m_percent_bachelors_over_25_2000, w_percent_bachelors_over_25_2000, by = "GEOID")
percent_bachelors_over_25_2000 <- percent_bachelors_over_25_2000 %>%
  mutate(over_25 = m_over_25 + w_over_25) %>%
  mutate(bachelors_or_more = m_bachelors_or_more + w_bachelors_or_more)

sum(percent_bachelors_over_25_2000$over_25)
sum(percent_bachelors_over_25_2000$bachelors_or_more)


#crosswalk 2000-2010
consolidated_2000_2010_college <-Crosswalk_2000_to_2010 %>% 
  left_join(percent_bachelors_over_25_2000, by=c("GEOID")) %>% 
  mutate(college_2000_subpart=bachelors_or_more*wt_pop,
         age25_2000_subpart=over_25*wt_pop) %>% 
  group_by(tr2010ge) %>% 
  summarize(college_2000_2010 = sum(college_2000_subpart, na.rm= TRUE),
            age25_2000_2010=sum(age25_2000_subpart, na.rm= TRUE)) 

# Crosswalk 2000 to 2020

consolidated_2000_2010_2020_college <- Crosswalk_2010_to_2020 %>% 
  left_join(consolidated_2000_2010_college, by=c("tr2010ge")) %>% 
  mutate(college_2000_subpart=college_2000_2010*wt_pop,
         age25_2000_subpart= age25_2000_2010*wt_pop) %>% 
  group_by(tr2020ge) %>% 
  summarize(college_2000_2020 = sum(college_2000_subpart, na.rm= TRUE),
            age25_2000_2020= sum(age25_2000_subpart, na.rm= TRUE)) %>% 
  mutate(pct_college_2000_2020=college_2000_2020/age25_2000_2020) %>% 
  select(tr2020ge,pct_college_2000_2020)

# Crosswalk 2012 to 2020
consolidated_2010_2020_college <-Crosswalk_2010_to_2020 %>% 
  left_join(percent_bachelors_over_25_2012, by=c("GEOID")) %>% 
  mutate(college_2012_subpart=bachelors_or_more*wt_pop,
         age25_2012_subpart=over_25*wt_pop) %>% 
  group_by(tr2020ge) %>% 
  summarize(college_2012_2020 = sum(college_2012_subpart, na.rm= TRUE),
            age25_2012_2020= sum(age25_2012_subpart, na.rm= TRUE)) %>% 
  mutate(pct_college_2012_2020=college_2012_2020/age25_2012_2020) %>% 
  select(tr2020ge,pct_college_2012_2020)

college <- consolidated_2000_2010_2020_college %>% 
  left_join(consolidated_2010_2020_college,by=c("tr2020ge")) %>% 
  mutate(GEOID=as.character(tr2020ge)) %>% 
  left_join(percent_bachelors_over_25_2022,by=c("GEOID")) %>% 
  mutate(pct_college_2022=bachelors_or_more/over_25) %>% 
  select(GEOID,pct_college_2000_2020,pct_college_2012_2020,pct_college_2022)

write.csv(college,"C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/college.csv")

######## new method for rent level calculation

dc_rent_2022 <- 
  get_acs(geography = "county",
          variables = "B25113_001",
          year = 2022,
          state = "DC",
          geometry = FALSE) %>% 
  mutate(medianrent_2022=estimate) #1817

dc_rent_2012_county <- 
  get_acs(geography = "county",
          variables = c("B25063_003","B25063_004","B25063_005","B25063_006","B25063_007","B25063_008",
          "B25063_009","B25063_010","B25063_011","B25063_012","B25063_013","B25063_014",
          "B25063_015","B25063_016","B25063_017","B25063_018","B25063_019","B25063_020",
          "B25063_021","B25063_022","B25063_023"),
          year = 2012,
          state = "DC",
          geometry = FALSE) %>% 
  mutate(cumulative_estimate = cumsum(estimate))

total_renter12 <- sum(dc_rent_2012_county$estimate)

rent_2012 <- dc_rent_2012_county %>%
  mutate(cumulative_proportion = cumulative_estimate / total_renter12)

# B25063_016  $700 to $749 21% ~ 20%
# B25063_019  $900 to $999 38% ~ 40%
# B25063_021  $1,250 to $1,499 67% ~ 60%
# B25063_022  $1,500 to $1,999 83% ~ 80%
# B25063_023  $2,000 or more 100% ~ 100%
dc_rent_2012_cat <- 
  get_acs(geography = "tract",
          variables = c("B25063_003","B25063_004","B25063_005","B25063_006","B25063_007","B25063_008",
                        "B25063_009","B25063_010","B25063_011","B25063_012","B25063_013","B25063_014",
                        "B25063_015","B25063_016","B25063_017","B25063_018","B25063_019","B25063_020",
                        "B25063_021","B25063_022","B25063_023"),
          year = 2012,
          state = "DC",
          geometry = FALSE) %>% 
  pivot_wider(id_cols = c(GEOID, NAME),
              names_from = variable,
              values_from = estimate) %>%
  mutate(totalrenterhh_2012= rowSums(select(., starts_with("B25063_")), na.rm = TRUE)) %>% 
  mutate(rentcat_20percent_2012=rowSums(select(., B25063_003: B25063_016),  na.rm = TRUE),
         rentcat_40percent_2012=rowSums(select(., B25063_017: B25063_019),  na.rm = TRUE),
         rentcat_60percent_2012=rowSums(select(., B25063_020: B25063_021),  na.rm = TRUE),
         rentcat_80percent_2012=rowSums(select(., B25063_022),  na.rm = TRUE),
         rentcat_100percent_2012=rowSums(select(., B25063_023),  na.rm = TRUE))

dc_rent_2022_county <- 
  get_acs(geography = "county",
          variables = c("B25063_003","B25063_004","B25063_005","B25063_006","B25063_007","B25063_008",
                        "B25063_009","B25063_010","B25063_011","B25063_012","B25063_013","B25063_014",
                        "B25063_015","B25063_016","B25063_017","B25063_018","B25063_019","B25063_020",
                        "B25063_021","B25063_022","B25063_023","B25063_024","B25063_025","B25063_026"),
          year = 2022,
          state = "DC",
          geometry = FALSE) %>% 
  mutate(cumulative_estimate = cumsum(estimate))

total_renter <- sum(dc_rent_2022_county$estimate)

rent_2022 <- dc_rent_2022_county %>%
  mutate(cumulative_proportion = cumulative_estimate / total_renter)
#DC 2022
#B25063_019	$900 to $999  16% ~ 20%
#B25063_021	$1,250 to $1,499  36% ~ 40%
#B25063_022 $1,500 to $1,999 58% ~ 60%
#B25063_024 $2,500 to $2,999 85% ~ 80%
#B25063_026 $3,500 or more 100% ~ 100%

dc_rent_2022_cat <- 
  get_acs(geography = "tract",
          variables = c("B25063_003","B25063_004","B25063_005","B25063_006","B25063_007","B25063_008",
                        "B25063_009","B25063_010","B25063_011","B25063_012","B25063_013","B25063_014",
                        "B25063_015","B25063_016","B25063_017","B25063_018","B25063_019","B25063_020",
                        "B25063_021","B25063_022","B25063_023","B25063_024","B25063_025","B25063_026"),
          year = 2022,
          state = "DC",
          geometry = FALSE) %>% 
  pivot_wider(id_cols = c(GEOID, NAME),
              names_from = variable,
              values_from = estimate) %>%
  mutate(totalrenterhh_2022= rowSums(select(., starts_with("B25063_")), na.rm = TRUE)) %>% 
  mutate(rentcat_20percent_2022=rowSums(select(., B25063_003: B25063_019),  na.rm = TRUE),
         rentcat_40percent_2022=rowSums(select(., B25063_020: B25063_021),  na.rm = TRUE),
         rentcat_60percent_2022=rowSums(select(., B25063_022),  na.rm = TRUE),
         rentcat_80percent_2022=rowSums(select(., B25063_023:B25063_024),  na.rm = TRUE),
         rentcat_100percent_2022=rowSums(select(., B25063_025:B25063_026),  na.rm = TRUE))

#crosswalk 2010 renter counts by category to 2020 geography
consolidated_2012_2020_rentcat <-Crosswalk_2010_to_2020 %>% 
  left_join(dc_rent_2012_cat, by=c("GEOID")) %>% 
  mutate(renthousing2012_subpart=totalrenterhh_2012*wt_renthu,
         rentcat_20percent_subpart=rentcat_20percent_2012*wt_renthu,
         rentcat_40percent_subpart=rentcat_40percent_2012*wt_renthu,
         rentcat_60percent_subpart=rentcat_60percent_2012*wt_renthu,
         rentcat_80percent_subpart=rentcat_80percent_2012*wt_renthu,
         rentcat_100percent_subpart=rentcat_100percent_2012*wt_renthu) %>% 
  group_by(tr2020ge) %>% 
  summarise(totalrenterhh_2012_2020 = sum(renthousing2012_subpart, na.rm= TRUE),
            rentcat_20percent_2012_2020 = sum(rentcat_20percent_subpart, na.rm= TRUE),
            rentcat_40percent_2012_2020 = sum(rentcat_40percent_subpart, na.rm= TRUE),
            rentcat_60percent_2012_2020 = sum(rentcat_60percent_subpart, na.rm= TRUE),
            rentcat_80percent_2012_2020 = sum(rentcat_80percent_subpart, na.rm= TRUE),
            rentcat_100percent_2012_2020 = sum(rentcat_100percent_subpart, na.rm= TRUE)) 


dc_rent_2000_county <-
  get_decennial(geography = "county",
                variable = c("H054003","H054004","H054005","H054006","H054007","H054008","H054009","H054010",
                             "H054011","H054012","H054013","H054014","H054015","H054016","H054017","H054018",
                             "H054019","H054020","H054021","H054022","H054023"),
                year = 2000,
                state = "DC",
                geometry = FALSE) %>% 
  mutate(cumulative_estimate = cumsum(value))

total_renter <- sum(dc_rent_2000_county$value)

rent_2000 <- dc_rent_2000_county %>%
  mutate(cumulative_proportion = cumulative_estimate / total_renter)
#DC 2022
#H054009	$350 to $399  22% ~ 20%
#H054012 $500 to $549  45% ~ 40%
#H054014 $600 to $649 60% ~ 60%
#H054018 $800 to $899 82% ~ 80%
#H054023 $2,000 or more 100% ~ 100%

dc_rent_2000_cat <- 
  get_decennial(geography = "tract",
                variable = c("H054003","H054004","H054005","H054006","H054007","H054008","H054009","H054010",
                             "H054011","H054012","H054013","H054014","H054015","H054016","H054017","H054018",
                             "H054019","H054020","H054021","H054022","H054023"),
                year = 2000,
                state = "DC",
                geometry = FALSE) %>% 
  pivot_wider(id_cols = c(GEOID, NAME),
              names_from = variable,
              values_from = value) %>%
  mutate(totalrenterhh_2000= rowSums(select(., starts_with("H054")), na.rm = TRUE)) %>% 
  mutate(rentcat_20percent_2000=rowSums(select(., H054003: H054009),  na.rm = TRUE),
         rentcat_40percent_2000=rowSums(select(., H054010: H054012),  na.rm = TRUE),
         rentcat_60percent_2000=rowSums(select(., H054013: H054014),  na.rm = TRUE),
         rentcat_80percent_2000=rowSums(select(., H054015: H054018),  na.rm = TRUE),
         rentcat_100percent_2000=rowSums(select(., H054019: H054023),  na.rm = TRUE))

#crosswalk 2000-2010
consolidated_2000_2010_rent <-Crosswalk_2000_to_2010 %>% 
  left_join(dc_rent_2000_cat, by=c("GEOID")) %>% 
  mutate(renthousing2000_subpart=totalrenterhh_2000*wt_renthu,
         rentcat_20percent_subpart=rentcat_20percent_2000*wt_renthu,
         rentcat_40percent_subpart=rentcat_40percent_2000*wt_renthu,
         rentcat_60percent_subpart=rentcat_60percent_2000*wt_renthu,
         rentcat_80percent_subpart=rentcat_80percent_2000*wt_renthu,
         rentcat_100percent_subpart=rentcat_100percent_2000*wt_renthu) %>% 
  group_by(tr2010ge) %>% 
  summarise(renthousing_2000_2010 = sum(renthousing2000_subpart, na.rm= TRUE),
            rentcat_20percent_2000_2010 = sum(rentcat_20percent_subpart, na.rm= TRUE),
            rentcat_40percent_2000_2010 = sum(rentcat_40percent_subpart, na.rm= TRUE),
            rentcat_60percent_2000_2010 = sum(rentcat_60percent_subpart, na.rm= TRUE),
            rentcat_80percent_2000_2010 = sum(rentcat_80percent_subpart, na.rm= TRUE),
            rentcat_100percent_2000_2010 = sum(rentcat_100percent_subpart, na.rm= TRUE)) 

# Crosswalk 2000 to 2020

consolidated_2000_2010_2020_rent <- Crosswalk_2010_to_2020 %>% 
  left_join(consolidated_2000_2010_rent, by=c("tr2010ge")) %>% 
  mutate(renthousing2000_subpart=renthousing_2000_2010*wt_renthu,
         rentcat_20percent_2000_2010_subpart = rentcat_20percent_2000_2010*wt_renthu,
         rentcat_40percent_2000_2010_subpart = rentcat_40percent_2000_2010*wt_renthu,
         rentcat_60percent_2000_2010_subpart = rentcat_60percent_2000_2010*wt_renthu,
         rentcat_80percent_2000_2010_subpart = rentcat_80percent_2000_2010*wt_renthu,
         rentcat_100percent_2000_2010_subpart = rentcat_100percent_2000_2010*wt_renthu,
) %>% 
  group_by(tr2020ge) %>% 
  summarise(totalrenterhh_2000_2020 = sum(renthousing2000_subpart, na.rm= TRUE),
            rentcat_20percent_2000_2020 = sum(rentcat_20percent_2000_2010_subpart, na.rm= TRUE),
            rentcat_40percent_2000_2020 = sum(rentcat_40percent_2000_2010_subpart, na.rm= TRUE),
            rentcat_60percent_2000_2020 = sum(rentcat_60percent_2000_2010_subpart, na.rm= TRUE),
            rentcat_80percent_2000_2020 = sum(rentcat_80percent_2000_2010_subpart, na.rm= TRUE),
            rentcat_100percent_2000_2020 = sum(rentcat_100percent_2000_2010_subpart, na.rm= TRUE)) 

renvaluedata <- consolidated_2012_2020_rentcat %>% 
  left_join(consolidated_2000_2010_2020_rent, by=c("tr2020ge")) %>% 
  mutate(GEOID=as.character(tr2020ge)) %>% 
  left_join(dc_rent_2022_cat,by=c("GEOID")) %>% 
  mutate(pct_2012_low=(rentcat_20percent_2012_2020+rentcat_40percent_2012_2020)/totalrenterhh_2012_2020,
         pct_2012_moderate=(rentcat_20percent_2012_2020+rentcat_40percent_2012_2020+rentcat_60percent_2012_2020)/totalrenterhh_2012_2020,
         pct_2012_high=(rentcat_20percent_2012_2020+rentcat_40percent_2012_2020+rentcat_60percent_2012_2020+rentcat_80percent_2012_2020+rentcat_100percent_2012_2020)/totalrenterhh_2012_2020) %>% 
  mutate(homevaluecat_2012=case_when(pct_2012_low>0.5 ~ "low",
                                     pct_2012_moderate>0.5 ~ "moderate",
                                     TRUE ~ "high")) %>%
  mutate(pct_2000_low=(rentcat_20percent_2000_2020+rentcat_40percent_2000_2020)/totalrenterhh_2000_2020,
         pct_2000_moderate=(rentcat_20percent_2000_2020+rentcat_40percent_2000_2020+rentcat_60percent_2000_2020)/totalrenterhh_2000_2020,
         pct_2000_high=(rentcat_20percent_2000_2020+rentcat_40percent_2000_2020+rentcat_60percent_2000_2020+rentcat_80percent_2000_2020+rentcat_100percent_2000_2020)/totalrenterhh_2000_2020) %>% 
  mutate(homevaluecat_2000=case_when(pct_2000_low>0.5 ~ "low",
                                     pct_2000_moderate>0.5 ~ "moderate",
                                     TRUE ~ "high")) %>%
  mutate(pct_2022_low=(rentcat_20percent_2022+rentcat_40percent_2022)/totalrenterhh_2022,
         pct_2022_moderate=(rentcat_20percent_2022+rentcat_40percent_2022+rentcat_60percent_2022)/totalrenterhh_2022,
         pct_2022_high=(rentcat_20percent_2022+rentcat_40percent_2022+rentcat_60percent_2022+rentcat_80percent_2022+rentcat_100percent_2022)/totalrenterhh_2022) %>% 
  mutate(homevaluecat_2022=case_when(pct_2022_low>0.5 ~ "low",
                                     pct_2022_moderate>0.5 ~ "moderate",
                                     TRUE ~ "high")) %>%
  select(GEOID, pct_2000_low, pct_2000_moderate,pct_2000_high, homevaluecat_2000, pct_2012_low, pct_2012_moderate,pct_2012_high, homevaluecat_2012,pct_2022_low, pct_2022_moderate,pct_2022_high, homevaluecat_2022)


write.csv(renvaluedata,"C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/rentvalue_cat.csv")

#########copied over from Sam's program compiling HH by race and ethnicity
#race by household
race_household_22 <- get_acs(geography = "tract",
                             variables = c("B11001H_001", "B11001_001", "B11001D_001", "B11001E_001", "B11001B_001",
                                           "B11001C_001", "B11001F_001", "B11001G_001", "B11001I_001"
                             ), state = "DC",
                             year = 2022,) %>%
  pivot_wider(id_cols = c(GEOID, NAME),
              names_from = variable,
              values_from = estimate)%>%
  rename(total_hh = B11001_001, non_hispanic_white_hh = B11001H_001,
         non_hispanic_black_hh = B11001B_001, non_hispanic_indigenous_hh = B11001C_001,
         non_hispanic_asian_hh = B11001D_001, non_hispanic_pacific_hh = B11001E_001,
         some_other_race_hh = B11001F_001, two_or_more_races_hh = B11001G_001, hispanic_or_latino_hh = B11001I_001)

race_household_12 <- get_acs(geography = "tract",
                             variables = c("B11001H_001", "B11001_001", "B11001D_001", "B11001E_001", "B11001B_001",
                                           "B11001C_001", "B11001F_001", "B11001G_001", "B11001I_001"
                             ), state = "DC",
                             year = 2012,) %>%
  pivot_wider(id_cols = c(GEOID, NAME),
              names_from = variable,
              values_from = estimate)%>%
  rename(total_hh = B11001_001, non_hispanic_white_hh = B11001H_001,
         non_hispanic_black_hh = B11001B_001, non_hispanic_indigenous_hh = B11001C_001,
         non_hispanic_asian_hh = B11001D_001, non_hispanic_pacific_hh = B11001E_001,
         some_other_race_hh = B11001F_001, two_or_more_races_hh = B11001G_001, hispanic_or_latino_hh = B11001I_001)

race_household_2000 <- get_decennial(geography = "tract",
                                     variables = c("P026001", "P026A001", "P026B001", "P026C001", "P026D001", "P026E001",
                                                   "P026F001", "P026G001", "P026H001"              
                                     ), state = "DC",
                                     year = 2000,) %>%
  pivot_wider(id_cols = c(GEOID, NAME),
              names_from = variable,
              values_from = value)%>%
  rename(total_hh = P026001, non_hispanic_white_hh = P026A001,
         non_hispanic_black_hh = P026B001, non_hispanoc_indigenous_hh = P026C001,
         non_hispanic_asian_hh = P026D001, non_hispanic_pacific_hh = P026E001,
         some_other_race_hh = P026F001	, two_or_more_races_hh = P026G001	, hispanic_or_latino_hh = P026H001)

#crosswalking is the same process, using hh weights