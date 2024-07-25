library(tidyverse)
library(tidycensus)
library(sf)
library(mapview)

census_api_key("e623b8b3caeaf6ad382196d1dac43e625440e80f", install = TRUE, overwrite = TRUE)
readRenviron("~/.Renviron")



#ACS median home value 2018-2022

dc_median_home_value_22 <- 
get_acs(geography = "tract",
        variables = "B25107_001",
        year = 2022,
        state = "DC",
        geometry = FALSE)

dc_median_home_value_12 <- 
  get_acs(geography = "tract",
          variables = "B25107_001",
          year = 2012,
          state = "DC",
          geometry = FALSE)
#pull in total home counts dc
dc_median_home_value_2000 <- 
  get_decennial(geography = "tract",
          variables = c("H076001"),
          year = 2000,
          state = "DC",
          geometry = FALSE)

#median rents 2000 - 2022

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
#now going to cross walk the data

#need to get weights 


#B25087_001
#130,865
total_unit_test <- 
  get_acs(geography = "tract",
          variable = "B25087_001",
          year = 2022,
          state = "DC",
          geometry = FALSE)
sum(total_unit_test$estimate)
#B25081_001
#130,865
total_unit_test_2 <- 
  get_acs(geography = "tract",
          variable = "B25081_001",
          year = 2022,
          state = "DC",
          geometry = FALSE)
sum(total_unit_test_2$estimate)
#B25042_001
#315,785 <- this is the right var
total_unit_test_3 <- 
  get_acs(geography = "tract",
          variable = "B25042_001",
          year = 2022,
          state = "DC",
          geometry = FALSE)
sum(total_unit_test_3$estimate)

##weight identified, B25042_001
#double checked below with sim, var same number comes out

total_unit_test_4 <- 
  get_acs(geography = "tract",
          variable = "B25038_001",
          year = 2022,
          state = "DC",
          geometry = FALSE)
sum(total_unit_test_4$estimate)


###now weighting vars
total_units_2022_alt <-
  get_acs(geography = "tract",
         variable = "B25038_001",
         year = 2022,
         state = "DC",
         geometry = FALSE)
sum(total_units_2022_alt$estimate)
total_units_2022 <- 
  get_acs(geography = "tract",
          variable = "B25042_001",
          year = 2022,
          state = "DC",
          geometry = FALSE)
sum(total_units_2022$estimate)
total_units_2012 <-
  get_acs(geography = "tract",
           variable = "B25042_001",
           year = 2012,
           state = "DC",
           geometry = FALSE)
total_units_2000 <-
  get_decennial(geography = "tract",
                variable = "H001001",
                year = 2000,
                state = "DC",
                geometry = FALSE)
total_units_2010 <-
  get_decennial(geography = "tract",
                variable = "H001001",
                year = 2010,
                state = "DC",
                geometry = FALSE)

#now joining the weights to the totals

#but first gonna import NHGIS weights
#they come from this link: https://www.nhgis.org/geographic-crosswalks
Crosswalk_2000_to_2010 <- read_csv("C:/Users/slieberman/Downloads/nhgis_tr2000_tr2010_11/nhgis_tr2000_tr2010_11.csv")
Crosswalk_2020_to_2010 <- read_csv("C:/Users/slieberman/Downloads/nhgis_tr2020_tr2010_11/nhgis_tr2020_tr2010_11.csv")
Crosswalk_2010_to_2020 <- read_csv("C:/Users/slieberman/Downloads/nhgis_tr2010_tr2020_11/nhgis_tr2010_tr2020_11.csv")

#crosswalking 2000 data to 2010
Crosswalk_2000_to_2010 <- Crosswalk_2000_to_2010 %>% mutate(GEOID = as.character(tr2000ge))

#(multiply median by (specific count, in this case housing count) to get back to count, then multiple by the weight), 
#then divide by the count I used before grouping targets
#first put the total housing units through the crosswalk 

total_units_2000_weights <- left_join(total_units_2000, Crosswalk_2000_to_2010, by = "GEOID")

#/
#/ #/ #/ #/ crosswalking 2000 to 2010 home value #\ #\ 
#/ 


#now pull average values into the dataframe

consolidated_2000_value_unit_weights <- left_join(total_units_2000_weights, dc_median_home_value_2000, by = "GEOID") #put in keep argument

#now multiply the totals by the median, this will be me aggregate metric

consolidated_2000_value_unit_weights <- consolidated_2000_value_unit_weights %>%
  mutate(aggregate_metric = value.x * value.y)

#now multiply the aggregate across the crosswalk

consolidated_2000_value_unit_weights <- consolidated_2000_value_unit_weights %>%
  mutate(aggregate_2010 = aggregate_metric * wt_ownhu)

#group and divide
consolidated_2000_value_unit_weights_grouped <- consolidated_2000_value_unit_weights %>%
  group_by(tr2010ge) %>%
  summarize(total_units_2010 = sum(value.x, na.rm = TRUE),
            agg_median_value_2010 = sum(aggregate_2010, na.rm= TRUE)) %>%
  ungroup() %>%
  mutate(median_value_2010 = agg_median_value_2010 / total_units_2010)
  
#### putting rents into the crosswalk
consolidated_2000_rent_unit_weights <- left_join(total_units_2000_weights, dc_median_rent_2000, by = "GEOID")

#now multiply the totals by the median, this will be me aggregate metric
consolidated_2000_rent_unit_weights <- consolidated_2000_rent_unit_weights %>%
  mutate(aggregate_metric = value.x * value.y)
#now multiply the aggregate across the crosswalk
consolidated_2000_rent_unit_weights <- consolidated_2000_rent_unit_weights %>%
  mutate(aggregate_2010 = aggregate_metric * wt_renthu)
#group and divide
consolidated_2000_rent_unit_weights_grouped <- consolidated_2000_rent_unit_weights %>%
  group_by(tr2010ge) %>%
  summarize(total_units_2010 = sum(value.x, na.rm = TRUE),
            agg_rent_value_2010 = sum(aggregate_2010, na.rm = TRUE)) %>%
  ungroup() %>%
  mutate(median_rent_2010 = agg_rent_value_2010 / total_units_2010)


####

##crosswalking 2010 to 2020
Crosswalk_2010_to_2020 <- Crosswalk_2010_to_2020 %>% mutate(GEOID = as.character(tr2010ge))
total_2010_weights <- left_join(total_units_2010, Crosswalk_2010_to_2020)

#home value
consolidated_2010_value_weights <- left_join(total_2010_weights, dc_median_home_value_12, by = "GEOID")

#now multiply the totals by the median, this will be me aggregate metric
consolidated_2010_value_weights <- consolidated_2010_value_weights %>%
  mutate(aggregate_metric = value * estimate)
#now multiply the aggregate across the crosswalk
consolidated_2010_value_weights <- consolidated_2010_value_weights %>%
  mutate(aggregate_2020 = aggregate_metric * wt_ownhu)

#group and divide
consolidated_2010_value_weights_grouped <- consolidated_2010_value_weights %>%
  group_by(tr2020ge) %>%
  summarize(total_units_2020 = sum(value, na.rm = TRUE),
            agg_median_value_2020 = sum(aggregate_2020, na.rm = TRUE)) %>%
  ungroup() %>%
  mutate(median_value_2020 = agg_median_value_2020 / total_units_2020)

###---### rents 2012

#rents
consolidated_2010_rent_weights <- left_join(total_2010_weights, dc_median_rent_2012, by = "GEOID")

#now multiply the totals by the median, this will be me aggregate metric
consolidated_2010_rent_weights <- consolidated_2010_rent_weights %>%
  mutate(aggregate_metric = value * estimate)
#now multiply the aggregate across the crosswalk
consolidated_2010_rent_weights <- consolidated_2010_rent_weights %>%
  mutate(aggregate_2020 = aggregate_metric * wt_ownhu)

#group and divide
consolidated_2010_rent_weights_grouped <- consolidated_2010_rent_weights %>%
  group_by(tr2020ge) %>%
  summarize(total_units_2020 = sum(value, na.rm = TRUE),
            agg_median_rents_2020 = sum(aggregate_2020, na.rm = TRUE)) %>%
  ungroup() %>%
  mutate(median_rents_2020 = agg_median_rents_2020 / total_units_2020)

 

#####cleaning the data
consolidated_2010_value_weights_grouped <- consolidated_2010_value_weights_grouped %>%
  select(-agg_median_value_2020, -total_units_2020)
consolidated_2010_rent_weights_grouped <- consolidated_2010_rent_weights_grouped %>%
  select(-total_units_2020)
consolidated_2000_rent_unit_weights_grouped <- consolidated_2000_rent_unit_weights_grouped %>%
  select(-total_units_2010, -agg_rent_value_2010)
consolidated_2000_value_unit_weights_grouped <- consolidated_2000_value_unit_weights_grouped %>%
  select(-total_units_2010, -agg_median_value_2010)

###crosswalking the 2000 data, which has already been crosswalked to 2010, over to 2020
#rent
reweighted_2000_2010_rents <- 
left_join(consolidated_2000_rent_unit_weights_grouped, total_2010_weights)
reweighted_2000_2010_rents <- reweighted_2000_2010_rents %>%
  mutate(aggregate_2010_rents = value * median_rent_2010)
reweighted_2000_2010_rents <- reweighted_2000_2010_rents %>%
  mutate(aggregate_2020 = aggregate_2010_rents * wt_renthu)
#group and divide
egge


#homevalue
#use the official counts from 2010 but also try out my weighted total from the crosswalks
#also try the missouri one to cross reference for the 2000 to 2020 versus the 
reweighted_value_2000_to_2020 <- left_join(total_2010_weights, consolidated_2000_value_unit_weights_grouped)

