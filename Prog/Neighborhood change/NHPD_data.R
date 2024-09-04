#new tasks: Bring in the NHPD data -- aggregate in the NHPD data with 2020 tract boundry, 
#total count of units by subsidy type in each tract
#see if I can get other NHPD data from 2012 and 2000 after finishing the above section 

#nhpd script
library(tidyverse)
library(readxl)
library(lubridate)
library(tidycensus)
###IMPORTANT DEDUPLICATE ALL
NHPD_DC_Sub <- read_excel("C:/Users/slieberman/Downloads/NHPD_Subsidies_DC.xlsx")
NHPD_DC_Prop <- read_excel("C:/Users/slieberman/Downloads/NHPD_Properties_DC.xlsx")
View(NHPD_Properties_Only_Export)
#flag for inactive / inconclusive properties
DC_NHPD_data <- left_join(NHPD_DC_Prop, NHPD_DC_Sub, by = "NHPD Property ID")


