#Additional Data
library(tidyverse)
library(tidycensus)
library(sf)
library(mapview)
library(hudr)

census_api_key("e623b8b3caeaf6ad382196d1dac43e625440e80f", install = TRUE, overwrite = TRUE)
readRenviron("~/.Renviron")
#total population 
dc_total_population_22 <- 
  get_acs(geography = "tract",
          variable = "B01003_001",
          year = 2022,
          state = "DC",
          geometry = FALSE)
sum(dc_total_population_22$estimate)
dc_total_population_12 <- 
  get_acs(geography = "tract",
          variable = "B01003_001",
          year = 2012,
          state = "DC",
          geometry = FALSE)
sum(dc_total_population_12$estimate)
dc_total_population_2000 <- 
get_decennial(geography = "tract",
              variables = "P001001",
              year = 2000,
              state = "DC",
              geometry = FALSE)
sum(dc_total_population_2000$value)

###median income
dc_median_income_22 <- 
  get_acs(geography = "tract",
          variable =  "B19013_001",
          year = 2022,
          state = "DC",
          geometry = FALSE)
dc_median_income_12 <- 
  get_acs(geography = "tract",
          variable =  "B19013_001",
          year = 2012,
          state = "DC",
          geometry = FALSE)
dc_median_income_2000 <- 
  get_decennial(geography = "tract",
                variables = "P053001",
                year = 2000,
                state = "DC",
                geometry = FALSE)

#percent bachelor's degree -> do we want % of total pop, % of >18 pop or % of >= 25 pop?
dc_bachelors <- 
  get_acs(geography = "tract",
          variable =  "B15003_022",
          year = 2022,
          state = "DC",
          geometry = FALSE)
sum(dc_bachelors$estimate) #124860  -> number seems low but also not accounting for children
dc_bachelors_18 <- 
  get_acs(geography = "tract",
          variable =  "S1501_C02_015E",
          year = 2022,
          state = "DC",
          geometry = FALSE)
sum(dc_bachelors_18$estimate)
##gathering the age data

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
#213749/417432 .5120571
#for the 2000 census the degree data is broken down by gender
#P037015 = male bachelor's, P037016 male masters, P037017 = male professional school, P037018	 = male phd
#P012011 m25-29, P012012	= m30-34, "P012013" m35-39 "P012014" = m40-44, "P012015" =m45-49, "P012016"=m50-54, "P012017" = m55-59
#"P012018 = 60-61, "P012019" = 62-64,"P012020" 65- 66, "P012021 - 67-69, "P012022 70-74" "P012023" 75-79, "P012024" 80 -84, 
#"P012025"= 85+
percent_bachelors_over_25_2000 <- get_decennial(geography = "tract",
                                          variables = c("P037015", "P037016", "P037017", "P037018", "P012011", "P012012", "P012013",
                                                        "P012014", "P012015", "P0120146", "P012017", "P012018", "P012019", "P012020",
                                                        "P012021", "P012022", "P012023", "P012024","P012025"),
                                          year = 2000,
                                          state = "DC",
                                          geometry = FALSE) %>%
  pivot_wider(id_cols = c(GEOID, NAME),
              names_from = variable,
              values_from = estimate) %>%
  mutate(over_25 =   
         bachelors_or_more = P037015
         percent_bachelors = bachelors_or_more/over_25) 
sum(percent_bachelors_over_25_2012$bachelors_or_more)
sum(percent_bachelors_over_25_2012$over_25)




#health insurance
#B27001_001
#B01003_001
dc_health_insurance <- 
  get_acs(geography = "tract",
          variables =  "B27001_001",
          year = 2022,
          state = "DC",
          geometry = FALSE)
sum(dc_health_insurance$estimate)

#661596
#gonna divide with population as I crosswalk
#B09019_001
total_housing_units<- 
  get_acs(geography = "tract",
          variables =  "B25002_002",
          year = 2022,
          state = "DC",
          geometry = FALSE)
sum(dc_households$estimate)
#homeowners
dc_homeowners<- 
  get_acs(geography = "tract",
          variables =  "B25003_002",
          year = 2022,
          state = "DC",
          geometry = FALSE)
dc_homeowners <- left_join(dc_homeowners, total_housing_units, by = "GEOID")
dc_homeowners <- dc_homeowners %>% select(-moe.x, -moe.y, -NAME.y)
dc_homeowners <- dc_homeowners %>% rename(owner_occupied_homes = estimate.x, housing_units = estimate.y )
dc_homeowners <- dc_homeowners %>% mutate(share_homeowners = owner_occupied_homes/housing_units)

#no mortgage
dc_no_mortgage_homeowners <-
  get_acs(geography = "tract",
          variables =  "B25140_006",
          year = 2022,
          state = "DC",
          geometry = FALSE)
dc_no_mortgage_homeowners <- dc_no_mortgage_homeowners %>% rename(mortgaged_homes = estimate)
sum(dc_no_mortgage_homeowners$mortgaged_homes) 

#renters
dc_renters_22<- 
  get_acs(geography = "tract",
          variables =  "B25003_003",
          year = 2022,
          state = "DC",
          geometry = FALSE)
dc_renters_12<- 
  get_acs(geography = "tract",
          variables =  "B25003_003",
          year = 2012,
          state = "DC",
          geometry = FALSE)




#CROSSWALK
Crosswalk_2000_to_2010 <- read_csv("C:/Users/slieberman/Downloads/nhgis_tr2000_tr2010_11/nhgis_tr2000_tr2010_11.csv")
Crosswalk_2010_to_2020 <- read_csv("C:/Users/slieberman/Downloads/nhgis_tr2010_tr2020_11/nhgis_tr2010_tr2020_11.csv")


#totals crosswalk

#adding population in

#health insurance

#total housing units


#renters
