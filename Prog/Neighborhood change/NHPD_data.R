#new tasks: Bring in the NHPD data -- aggregate in the NHPD data with 2020 tract boundry, 
#total count of units by subsidy type in each tract
#see if I can get other NHPD data from 2012 and 2000 after finishing the above section 

#nhpd script
library(tidyverse)
library(readxl)
library(lubridate)
library(tidycensus)
###IMPORTANT DEDUPLICATE ALL
NHPD_Subsidies_Only_Export <- read_excel("C:/Users/slieberman/Downloads/NHPD Subsidies Only Export.xlsx")
NHPD_Properties_Only_Export <- read_excel("C:/Users/slieberman/Downloads/NHPD Properties Only Export.xlsx")
View(NHPD_Properties_Only_Export)
#flag for inactive / inconclusive properties
compiled_NHPD_data <- left_join(NHPD_Properties_Only_Export, NHPD_Subsidies_Only_Export, by = "NHPD Property ID")

