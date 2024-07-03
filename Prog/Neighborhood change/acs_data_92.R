library(tidyverse)
library(tidycensus)
library(sf)

census_api_key("e623b8b3caeaf6ad382196d1dac43e625440e80f", install = TRUE, overwrite = TRUE)
readRenviron("~/.Renviron")

#ACS median home value 2018-2022

dc_median_home_value_22 <- 
get_acs(geography = "tract",
        variables = c("B25038_001", "B25107_001"),
        year = 2022,
        state = "DC",
        geometry = TRUE)

dc_median_home_value_12 <- 
  get_acs(geography = "tract",
          variable = c("B25038_001","B25107_001"),
          year = 2012,
          state = "DC",
          geometry = TRUE)
#pull in total home counts dc
dc_median_home_value_2000 <- 
  get_decennial(geography = "tract",
          variables = c("H001001", "H076001"),
          year = 2000,
          state = "DC",
          geometry = TRUE)

#median rents 2000 - 2022

dc_median_rent_2000 <-
  get_decennial(geography = "tract",
                variable = "H063001",
                year = 2000,
                state = "DC",
                geometry = TRUE)
dc_median_rent_22 <- 
  get_acs(geography = "tract",
          variable = "B25113_001",
          year = 2022,
          state = "DC",
          geometry = TRUE)
dc_median_rent_2012 <- 
  get_acs(geography = "tract",
          variable = "B25113_001",
          year = 2012,
          state = "DC",
          geometry = TRUE)
#now going to cross walk the data

#need to get weights 


#B25087_001
#130,865
total_unit_test <- 
  get_acs(geography = "tract",
          variable = "B25087_001",
          year = 2022,
          state = "DC",
          geometry = TRUE)
sum(total_unit_test$estimate)
#B25081_001
#130,865
total_unit_test_2 <- 
  get_acs(geography = "tract",
          variable = "B25081_001",
          year = 2022,
          state = "DC",
          geometry = TRUE)
sum(total_unit_test_2$estimate)
#B25042_001
#315,785 <- this is the right var
total_unit_test_3 <- 
  get_acs(geography = "tract",
          variable = "B25042_001",
          year = 2022,
          state = "DC",
          geometry = TRUE)
sum(total_unit_test_3$estimate)

##weight identified, B25042_001
#double checked below with sim, var same number comes out

total_unit_test_4 <- 
  get_acs(geography = "tract",
          variable = "B25038_001",
          year = 2022,
          state = "DC",
          geometry = TRUE)
sum(total_unit_test_4$estimate)


###now weighting vars
total_units_2022_alt <-
  get_acs(geography = "tract",
         variable = "B25038_001",
         year = 2022,
         state = "DC",
         geometry = TRUE)
sum(total_units_2022_alt$estimate)
total_units_2022 <- 
  get_acs(geography = "tract",
          variable = "B25042_001",
          year = 2022,
          state = "DC",
          geometry = TRUE)
sum(total_units_2022$estimate)
total_units_2012 <-
  get_acs(geography = "tract",
           variable = "B25042_001",
           year = 2012,
           state = "DC",
           geometry = TRUE)
total_units_2000 <-
  get_decennial(geography = "tract",
                variable = "H001001",
                year = 2000,
                state = "DC",
                geometry = TRUE)

#now joining the weights to the totals

#but first gonna import NHGIS weights
#they come from this link: https://www.nhgis.org/geographic-crosswalks
Crosswalk_2000_to_2010 <- read_csv("C:/Users/slieberman/Downloads/nhgis_tr2000_tr2010_11/nhgis_tr2000_tr2010_11.csv")
Crosswalk_2020_to_2010 <- read_csv("C:/Users/slieberman/Downloads/nhgis_tr2020_tr2010_11/nhgis_tr2020_tr2010_11.csv")


#crosswalking 2000 data to 2010
Crosswalk_2000_to_2010 <- Crosswalk_2000_to_2010 %>% mutate(GEOID = as.character(tr2000ge))



left_join(dc_median_home_value_2000, Crosswalk_2000_to_2010, by = "GEOID" )
home_value_2000_weights <- left_join(dc_median_home_value_2000, Crosswalk_2000_to_2010, by = "GEOID") #put in keep argument

#(multiply median by count to get back to count, then multiple by the weight), 
#then divide by the count I used before grouping targets
home_value_2000_weights <- home_value_2000_weights %>% mutate(estimate = value * wt_ownhu)

#put in checks back there 

home_value_2000_weights %>% filter(estimate > 0)#178 rows

dc_median_home_value_2000 %>% filter(value > 0)
test_dc_median_home_value_12_test <- dc_median_home_value_12%>% filter(estimate >0 )#175 rows

df_home_2012 <- st_drop_geometry(dc_median_home_value_12)

df_home_200_to_2012 <- st_drop_geometry(home_value_2000_weights)


value_2000_2012 <- left_join(df_home_200_to_2012, df_home_2012, by = "GEOID")
mean(value_2000_2012$estimate.x, na.rm = TRUE) #210398.6
mean(value_2000_2012$estimate.y, na.rm = TRUE) #459524.3

#SOMETHING IS WRONG

  