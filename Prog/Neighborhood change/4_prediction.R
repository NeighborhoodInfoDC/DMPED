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
library(Haven)
library(tidy)
census_api_key("05de4dca638d81abd2dc60d0d28e3781183e185e", install = TRUE)

housingmarket <- read_csv("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/housingmarket.csv") 

data <- read_sas("W:/Libraries/Realprop/Data/sales_sum_tr20.sas7bdat")
#tring the OTR sales data for median home value

OTR_sales <- data %>% 
  rename(GEOID=Geo2020) %>% 
  select(GEOID, mprice_tot_1999,mprice_tot_2000,mprice_tot_2001, mprice_tot_2012,mprice_tot_2011,mprice_tot_2010, mprice_tot_2013,mprice_tot_2022,mprice_tot_2021,mprice_tot_2023) %>% 
  # filter(is.na(mprice_tot_2000)) #8 missing in 2022 #13 missing in 2012 #12 missing in 2000
  mutate(GEOID=as.numeric(GEOID))

#use the OTR data instead for home value
housingmarket <- housingmarket %>% 
  left_join(OTR_sales,by=c("GEOID")) %>% 
  mutate(medianhome_2000_2020=mprice_tot_2000,
         medianhome_2012_2020=mprice_tot_2012,
         medianhome_2022=mprice_tot_2022) %>% 
  # filter(is.na(medianhome_2022)|is.na(medianhome_2012_2020)) %>%
  # select(GEOID, NBH_NAMES, total_hh_2022, medianhome_2000_2020,medianhome_2012_2020,medianhome_2022,mprice_tot_1999,mprice_tot_2001, mprice_tot_2011,mprice_tot_2021) %>%
  mutate(medianhome_2000_2020=ifelse(GEOID=="11001004702",165000,medianhome_2000_2020),
         medianhome_2022=ifelse(GEOID=="11001005602",1039500,medianhome_2022),
         medianhome_2012_2020=ifelse(GEOID=="11001007401",178250,medianhome_2012_2020),
         medianhome_2022=ifelse(GEOID=="11001007401",500000,medianhome_2022),
         medianhome_2012_2020=ifelse(GEOID=="11001007401",207250,medianhome_2012_2020),
         medianhome_2012_2020=ifelse(GEOID=="11001009602",284900,medianhome_2012_2020)) %>% #use nearest year sales data if available
  # filter(is.na(medianhome_2022)|is.na(medianhome_2012_2020)|is.na(medianhome_2000_2020)) %>%
  # select(GEOID, NBH_NAMES, total_hh_2022, medianhome_2000_2020,medianhome_2012_2020,medianhome_2022,mprice_tot_1999,mprice_tot_2001, mprice_tot_2013,mprice_tot_2021,mprice_tot_2023) %>%
  # mutate(medianhome_2000_2020=ifelse(medianhome_2000_2020==0, NA, medianhome_2000_2020),
  # medianhome_2012_2020=ifelse(medianhome_2012_2020==0, NA, medianhome_2012_2020)) %>%
  filter(!is.na(medianhome_2022)& !is.na(medianhome_2012_2020) & !is.na(medianhome_2000_2020))
  



lowincome <- read_csv("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/lowincome_pop.csv")

raceethnicity <- read_csv("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/race_ethnicity.csv")

neighborhoodtype_OTR <- read_csv("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/neighborhoodtype_homevalueOTR.csv")

vacancy <- read_csv("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/vacancy.csv") %>% 
  mutate(GEOID=geoid) %>% 
  select(GEOID, year, vacancyrate) %>% 
  filter(year==2012|year==2022) %>% 
  mutate(year=paste0("vacancy_", as.character(year))) %>% 
  spread(key=year,value=vacancyrate) 

distance <- read_csv("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/distance_downtown.csv")

lowincjobs <- read_csv("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/lowincome_jobs.csv")

HUDsubsidy <- read_csv("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/HUD_subsidy.csv")

college <- read_csv("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/college.csv")

predictionmaster <- housingmarket %>% 
  left_join(lowincome, by=c("GEOID")) %>% 
  left_join(raceethnicity, by=c("GEOID")) %>% 
  left_join(distance, by=c("GEOID")) %>% 
  # left_join(vacancy, by=c("GEOID")) %>% 
  left_join(lowincjobs, by=c("GEOID")) %>% 
  left_join(HUDsubsidy, by=c("GEOID")) %>% 
  left_join(college, by=c("GEOID")) %>% 
  left_join(neighborhoodtype_OTR, by=c("GEOID")) %>% 
  mutate(displacement=ifelse((neighborhoodtype=="exlusive growth with displacement risk"|neighborhoodtype=="established opportunity with displacement risk"),1,0)) 


logit <- glm(displacement ~ vacancy_2012 + distance_to_downtown_miles + medianhome_2012_2020
             + pct_lowincome_2012+ pct_black_2012 + pct_college_2012_2020, family=binomial(link="logit"), data=predictionmaster) 

summary(logit)

# tidysummary_model <- tidy(logit) # summary table of the regression model
# 
# exp_coef_model <- exp(model$coefficients) # a table (?) of model coefficients
# 
# exp_confint_model <- exp(confint(model) # a table (?) of the confidence interval
# 
# list(Summary = tidysummary_model, 
#      Coefs = exp_coef_model, 
#      Intervals = exp_confint_model) |> 
#   openxlsx::write.xlsx("Model1tables.xlsx")


