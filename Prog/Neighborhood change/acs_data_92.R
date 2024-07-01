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
        geometry = FALSE)

dc_median_home_value_12 <- 
  get_acs(geography = "tract",
          variable = "B25107_001",
          year = 2012,
          state = "DC",
          geometry = FALSE)


dc_median_rent_2000 <-
  get_decennial(geography = "tract",
                variable = "H063001",
                year = 2000,
                state = "DC",
                geometry = FALSE)
dc_median_rent_22 <- 
  get_acs(geography = "tract",
          variable = "B25113_001",
          year = 2022,
          state = "DC",
          geometry = FALSE)
dc_median_rent_2012 <- 
  get_acs(geography = "tract",
          variable = "B25113_001",
          year = 2012,
          state = "DC",
          geometry = FALSE)

dc


B25113_001


