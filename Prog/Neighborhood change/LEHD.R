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

se01_12 <- read.csv("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Raw/LEHD/dc_wac_SE01_JT00_2012.csv") %>% 
  mutate(block=as.character(w_geocode)) %>% 
  select(block, CE01, CE02, CE03) %>% 
  mutate(GEOID=substr(block,1,11)) %>% 
  group_by(GEOID) %>% 
  summarize(total_se01CE01_12=sum(CE01),
            total_se01CE02_12=sum(CE02)) %>% 
  select(GEOID,total_se01CE01_12,total_se01CE02_12 ) 

se02_12 <- read.csv("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Raw/LEHD/dc_wac_SE02_JT00_2012.csv") %>% 
  mutate(block=as.character(w_geocode)) %>% 
  select(block, CE01, CE02, CE03) %>% 
  mutate(GEOID=substr(block,1,11)) %>% 
  group_by(GEOID) %>% 
  summarize(total_se02CE01_12=sum(CE01),
            total_se02CE02_12=sum(CE02)) %>% 
  select(GEOID,total_se02CE01_12,total_se02CE02_12 ) 

lowincjob_12 <-se02_12 %>% 
  left_join(se01_12, by=c("GEOID")) %>% 
  mutate(lowinc_job_2012=total_se01CE01_12+total_se02CE02_12) %>% 
  select(GEOID,lowinc_job_2012)


se01_21 <- read.csv("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Raw/LEHD/dc_wac_SE01_JT00_2021.csv") %>% 
  mutate(block=as.character(w_geocode)) %>% 
  select(block, CE01, CE02, CE03) %>% 
  mutate(GEOID=substr(block,1,11)) %>% 
  group_by(GEOID) %>% 
  summarize(total_se01CE01_21=sum(CE01),
            total_se01CE02_21=sum(CE02)) %>% 
  select(GEOID,total_se01CE01_21,total_se01CE02_21 ) 

se02_21 <- read.csv("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Raw/LEHD/dc_wac_SE02_JT00_2021.csv") %>% 
  mutate(block=as.character(w_geocode)) %>% 
  select(block, CE01, CE02, CE03) %>% 
  mutate(GEOID=substr(block,1,11)) %>% 
  group_by(GEOID) %>% 
  summarize(total_se02CE01_21=sum(CE01),
            total_se02CE02_21=sum(CE02)) %>% 
  select(GEOID,total_se02CE01_21,total_se02CE02_21 ) 

lowincjob_21 <-se02_21 %>% 
  left_join(se01_21, by=c("GEOID")) %>% 
  mutate(lowinc_job_2021=total_se01CE01_21+total_se02CE02_21) %>% 
  select(GEOID,lowinc_job_2021)

lowincjob <- lowincjob_21 %>% 
  left_join(lowincjob_12, by=c("GEOID")) %>% 
  mutate(changeinlowincome=lowinc_job_2021-lowinc_job_2012)

