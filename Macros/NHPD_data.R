#new tasks: Bring in the NHPD data -- aggregate in the NHPD data with 2020 tract boundry, 
#total count of units by subsidy type in each tract
#see if I can get other NHPD data from 2012 and 2000 after finishing the above section 

#nhpd script
library(tidyverse)
library(readxl)
library(lubridate)
library(tidycensus)
###IMPORTANT DEDUPLICATE ALL
DC_Active_properties <- read_csv("C:/Users/slieberman/Downloads/DC_Active_properties.csv")
DC_active_subsidies <- read_csv("C:/Users/slieberman/Downloads/DC_active_subsidies.csv")
#sumcheck
setwd('C:/Users/slieberman/Documents/DMPEDD/DMPED/Macros')
#flag for inactive / inconclusive properties
DC_NHPD_data <- left_join(DC_Active_properties, DC_active_subsidies, by = "NHPD Property ID")
sum(DC_NHPD_data$`Assisted Units`, na.rm = TRUE)
sum(DC_active_subsidies$`Assisted Units`, na.rm = TRUE)
### units per tract
DC_NHPD_data_tract_grouped <- DC_NHPD_data %>%
  group_by(`Census Tract`) %>%
  summarise(Assisted_Units_per_tract = sum(`Assisted Units`, na.rm = TRUE))
#units per tract by subsidy type
unique(DC_NHPD_data$`Subsidy Name`)

DC_NHPD_data_tract_grouped_HOME <- DC_NHPD_data %>%
  filter(`Subsidy Name` == "HOME") %>%
  group_by(`Census Tract`) %>%
  summarise(Assisted_Units_per_tract = sum(`Assisted Units`, na.rm = TRUE))
DC_NHPD_data_tract_grouped_HOME <- DC_NHPD_data_tract_grouped_HOME %>%
  rename(HOME_grant_units = Assisted_Units_per_tract)
DC_NHPD_data_tract_grouped_Section_8 <- DC_NHPD_data %>%
  filter(`Subsidy Name` == "Section 8") %>%
  group_by(`Census Tract`) %>%
  summarise(Assisted_Units_per_tract = sum(`Assisted Units`, na.rm = TRUE))
DC_NHPD_data_tract_grouped_Section_8 <- DC_NHPD_data_tract_grouped_Section_8 %>%
  rename(Section_8_units = Assisted_Units_per_tract)
######
DC_NHPD_data_tract_grouped_HUD_INSURED <- DC_NHPD_data %>%
  filter(`Subsidy Name` == "HUD Insured") %>%
  group_by(`Census Tract`) %>%
  summarise(Assisted_Units_per_tract = sum(`Assisted Units`, na.rm = TRUE))
DC_NHPD_data_tract_grouped_HUD_INSURED  <- DC_NHPD_data_tract_grouped_HUD_INSURED  %>%
  rename(HUD_Insured_units = Assisted_Units_per_tract)

DC_NHPD_data_tract_grouped_public_housing <- DC_NHPD_data %>%
  filter(`Subsidy Name` == "Public Housing") %>%
  group_by(`Census Tract`) %>%
  summarise(Assisted_Units_per_tract = sum(`Assisted Units`, na.rm = TRUE))
DC_NHPD_data_tract_grouped_public_housing  <- DC_NHPD_data_tract_grouped_public_housing  %>%
  rename(public_housing_units = Assisted_Units_per_tract)

DC_NHPD_data_tract_grouped_LIHTC <- DC_NHPD_data %>%
  filter(`Subsidy Name` == "LIHTC") %>%
  group_by(`Census Tract`) %>%
  summarise(Assisted_Units_per_tract = sum(`Assisted Units`, na.rm = TRUE))
DC_NHPD_data_tract_grouped_Project_Based_Vouchers <- DC_NHPD_data %>%
  filter(`Subsidy Name` == "Project Based Vouchers") %>%
  group_by(`Census Tract`) %>%
  summarise(Assisted_Units_per_tract = sum(`Assisted Units`, na.rm = TRUE))
DC_NHPD_data_tract_grouped_Section_202 <- DC_NHPD_data %>%
  filter(`Subsidy Name` == "Section 202") %>%
  group_by(`Census Tract`) %>%
  summarise(Assisted_Units_per_tract = sum(`Assisted Units`, na.rm = TRUE))
DC_NHPD_data_tract_grouped_Mod_Rehab <- DC_NHPD_data %>%
  filter(`Subsidy Name` == "Mod Rehab") %>%
  group_by(`Census Tract`) %>%
  summarise(Assisted_Units_per_tract = sum(`Assisted Units`, na.rm = TRUE))

write.csv(DC_NHPD_data, "DC_NHPD_data.csv")
write.csv(DC_NHPD_data_tract_grouped, "DC_NHPD_tracts.csv")

###Pull in old data __ pasting below
