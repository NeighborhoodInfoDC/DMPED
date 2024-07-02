library(tidyverse)
library(tidycensus)
library(sf)

census_api_key("e623b8b3caeaf6ad382196d1dac43e625440e80f", install = TRUE, overwrite = TRUE)
readRenviron("~/.Renviron")

#ACS median home value 2018-2022

dc_median_home_value_22 <- 
get_acs(geography = "tract",
        variable = "B25107_001",
        year = 2022,
        state = "DC",
        geometry = TRUE)

dc_median_home_value_12 <- 
  get_acs(geography = "tract",
          variable = "B25107_001",
          year = 2012,
          state = "DC",
          geometry = TRUE)
dc_median_home_value_2000 <- 
  get_decennial(geography = "tract",
          variable = "H076001",
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


B25087_001
#130,865
total_unit_test <- 
  get_acs(geography = "tract",
          variable = "B25087_001",
          year = 2022,
          state = "DC",
          geometry = TRUE)
sum(total_unit_test$estimate)
B25081_001
#130,865
total_unit_test_2 <- 
  get_acs(geography = "tract",
          variable = "B25081_001",
          year = 2022,
          state = "DC",
          geometry = TRUE)
sum(total_unit_test_2$estimate)
B25042_001
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

total_units_2022 <- 
  get_acs(geography = "tract",
          variable = "B25042_001",
          year = 2022,
          state = "DC",
          geometry = TRUE)
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
  