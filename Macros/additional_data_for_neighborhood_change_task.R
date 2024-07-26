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
sum(dc_total_population_22$estimate)
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
 
##gathering the age data

percent_bachelors_over_25 <- get_acs(geography = "tract",
                                     variables = c("B15003_022", "B07001_006","B07001_007", "B07001_008",
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
         percent_bachelors = B15003_022/over_25) 

#health insurance
#B27001_001
#B01003_001
dc_health_insurance <- 
  get_acs(geography = "tract",
          variables =  "B27001_001",
          year = 2022,
          state = "DC",
          geometry = TRUE)
sum(dc_health_insurance$estimate)

#661596
#gonna divide with population as I crosswalk


