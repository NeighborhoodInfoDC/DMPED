#Additional Data
library(tidyverse)
library(tidycensus)
library(sf)
library(mapview)

census_api_key("e623b8b3caeaf6ad382196d1dac43e625440e80f", install = TRUE, overwrite = TRUE)
readRenviron("~/.Renviron")
#total population 
dc_total_population_22 <- 
  get_acs(geography = "tract",
          variable = "B01003_001",
          year = 2022,
          state = "DC",
          geometry = TRUE)
###median income
dc_median_income_22 <- 
  get_acs(geography = "tract",
          variable =  "B19013_001",
          year = 2022,
          state = "DC",
          geometry = TRUE)
#potential top coding/ seems to be a data error not a coding error
mapview(dc_median_income_22, zcol = "estimate")
# alt_dc_median_income_22 <- 
#   get_acs(geography = "tract",
#           variable = "B25119_001",
#           year = 2022,
#           state = "DC",
#           geometry = TRUE)
##data errors for median income no matter what var I use

#percent bachelor's degree -> do we want % of total pop, % of >18 pop or % of >= 25 pop?
dc_bachelors <- 
  get_acs(geography = "tract",
          variable =  "B07009_005",
          year = 2022,
          state = "DC",
          geometry = TRUE)
sum(dc_bachelors$estimate) #124860  -> number seems low but also not accounting for children
dc_bachelors_25_and_over <- 
  get_acs(geography = "tract",
          variable =  "B15003_022",
          year = 2022,
          state = "DC",
          geometry = TRUE)
sum(dc_bachelors_25_and_over$estimate)#124860 hmmmm
#try to do it as percetn of pop >25

v21 <- load_variables(2021, "acs5", cache = TRUE)


