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

#USPS data is already compiled by HUD and standardized to 2020 tract ID see Box for source: https://urbanorg.app.box.com/s/1rxg1ym5aefllz26qrx2xzs5g6f21i1l/folder/274698289526
USPS <- read.csv("C:/Users/Ysu/Downloads/tract_unit_counts_2008_2024.csv") %>% 
  filter(STATEA==11)

DCUSPS <- USPS %>% 
  mutate(fullid=str_pad(geoid,11,pad="0")) %>% 
  mutate(state=substr(fullid,1,2)) %>% 
  filter(state=="11")
  
write.csv(DCUSPS, 'C:/Users/Ysu/Downloads/vanacy_DC.csv')

#for analysis

vacancy <-DCUSPS %>% 
  select(geoid, year, quarter, total_residential, longterm_vacancy_residential,shortterm_vacancy_residential) %>% 
  group_by(geoid, year) %>% 
  summarise_all("mean") %>% 
  mutate(vacancyrate=(longterm_vacancy_residential+shortterm_vacancy_residential)/total_residential) %>% 
  select(geoid, year,total_residential,vacancyrate)

write.csv(vacancy, 'C:/Users/Ysu/Downloads/vanacy.csv')

