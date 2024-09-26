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

HUDsubsidy <- read_xlsx("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Raw/HUD/TRACT_AK_MN_2022_2020census.xlsx",.name_repair = "unique") 

subsidy_2022 <- HUDsubsidy %>% 
  filter(states=="DC District of Columbia") %>% 
  select(code,program_label,total_units) %>% 
  mutate(program_label=paste0(program_label,"_2022")) %>% 
  spread(program_label, total_units) %>% 
  rename(GEOID=code) %>% 
  replace(is.na(.), 0) %>% 
  mutate(`Summary of All HUD Programs_2022`=ifelse(`Summary of All HUD Programs_2022`==-1,0,`Summary of All HUD Programs_2022`)) %>% 
  rename(HCV_2022=`Housing Choice Vouchers_2022`,
         publichousing_2022=`Public Housing_2022`,
         section8_2022=`Project Based Section 8_2022`) %>% 
  select(GEOID,HCV_2022,publichousing_2022,section8_2022 )

HUDsubsidy_2012 <- read_xlsx("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Raw/HUD/TRACT_AK_MN_2012.xlsx",.name_repair = "unique") 

subsidy_2012 <- HUDsubsidy_2012 %>% 
  filter(states=="DC District of Columbia") %>% 
  select(code,program_label,total_units) %>% 
  mutate(program_label=paste0(program_label,"_2012")) %>% 
  spread(program_label, total_units) %>% 
  rename(GEOID=code) %>% 
  replace(is.na(.), 0) 

#crosswalk to 2022

total_units_2010 <-
  get_decennial(geography = "tract",
                variable = "H001001",
                year = 2010,
                state = "DC",
                geometry = FALSE) %>% 
  rename(units_2010=value)

Crosswalk_2010_to_2020 <- read_csv("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Raw/tract crosswalks/nhgis_tr2010_tr2020_11.csv") %>% 
  mutate(GEOID=as.character(tr2010ge))

consolidated_2010_2020 <- total_units_2010 %>% 
  left_join(Crosswalk_2010_to_2020, by=c("GEOID")) %>% 
  left_join(subsidy_2012, by=c("GEOID")) %>% 
  mutate(HCV_subpart=units_2010*`Housing Choice Vouchers_2012`*wt_hu,
         publichousing_subpart=units_2010*`Public Housing_2012`*wt_hu,
         section8_subpart=units_2010*`Section 8 NC/SR_2012`*wt_hu,) %>% 
  group_by(tr2020ge) %>% 
  summarize(total_units = sum(units_2010, na.rm = TRUE),
            HCV_2012_2020 = sum(HCV_subpart, na.rm= TRUE)/total_units,
            publichousing_2012_2020 = sum(publichousing_subpart, na.rm= TRUE)/total_units,
            section8_2012_2020 = sum( section8_subpart, na.rm= TRUE)/total_units) %>% 
  mutate(GEOID=as.character(tr2020ge)) %>% 
  select(-total_units, -tr2020ge)

HUD_subsidy <- subsidy_2022 %>% 
  left_join(consolidated_2010_2020, by=c("GEOID"))

write.csv(HUD_subsidy, "C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/HUD_subsidy.csv")