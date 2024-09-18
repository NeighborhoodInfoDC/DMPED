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

HUDsubsidy <- read_xlsx("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Raw/HUD/TRACT_AK_MN_2023_2020census.xlsx") 

subsidy_2023 <- HUDsubsidy %>% 
  filter(states=="DC District of Columbia") %>% 
  select(code,program_label,total_units) %>% 
  spread(program_label, total_units)