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

###make sure you run the 2.3.1 and 2.3.2 program before this summary program

tractsummary <- sumtract_OTR %>% 
  left_join(sumtract_rent, by=c("neighborhoodtype")) %>% 
  st_drop_geometry()


write.csv(tractsummary, "C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Report tables/count_bytype.csv")
