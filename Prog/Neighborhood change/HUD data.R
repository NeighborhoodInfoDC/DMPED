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
  mutate(`Summary of All HUD Programs_2022`=ifelse(`Summary of All HUD Programs_2022`==-1,0,`Summary of All HUD Programs_2022`))

HUDsubsidy_2012 <- read_xlsx("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Raw/HUD/TRACT_AK_MN_2012.xlsx",.name_repair = "unique") 

subsidy_2012 <- HUDsubsidy_2012 %>% 
  filter(states=="DC District of Columbia") %>% 
  mutate(program_label=paste0(program_label,"_2012")) %>% 
  spread(program_label, total_units) %>% 
  rename(GEOID=code) %>% 
  replace(is.na(.), 0) %>% 
