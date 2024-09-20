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
library(caret)
library(boot)
library(corrplot)
library(stargazer)
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
  
neighborhoodname <- read_csv("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/neighborhood_tract.csv")

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
  mutate(displacement=ifelse((neighborhoodtype=="exlusive growth with displacement risk"|neighborhoodtype=="established opportunity with displacement risk"),1,0)) %>% 
  mutate(pct_hcv_2012=HCV_2012_2020/total_hh_2012_2020,
         pct_hcv_2022=HCV_2022/total_hh_2022) %>% 
  mutate(pct_lowincome_2000=lowincome_2000_2020/total_hh_2000_2020,
         pct_lowincome_2012=lowincome_2012_2020/total_hh_2012_2020,
         pct_lowincome_2022=lowincome_2022/total_hh_2022) %>% 
  mutate(pct_black_2000=non_hispanic_black_hh_2000_2020/total_hh_2000_2020,
         pct_black_2012=non_hispanic_black_hh_2012_2020/total_hh_2012_2020,
         pct_black_2022=non_hispanic_black_hh_2022/total_hh_2022) 


logit <- glm(displacement ~ vacancy_2012 + distance_to_downtown_miles + medianhome_2012_2020
             + pct_lowincome_2012+ pct_black_2012 + pct_college_2012_2020 + pct_lowincjob_2012 + pct_hcv_2012, family=binomial(link="logit"), data=predictionmaster) 

summary(logit)
plot(logit)

write.csv(predictionmaster,"C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/prediction_data.csv")

mod1 <- glm(displacement ~ vacancy_2012 + distance_to_downtown_miles + medianhome_2012_2020
            + pct_lowincome_2012+ pct_black_2012 + pct_college_2012_2020 + pct_lowincjob_2012 + pct_hcv_2012, data=predictionmaster)
summary(mod1)



logit <- glm(displacement ~ vacancy_2012 + distance_to_downtown_miles + medianhome_2012_2020
             + pct_lowincome_2012+ pct_black_2012 + pct_college_2012_2020 + pct_lowincjob_2012 + pct_hcv_2012, family=binomial(link="logit"), data=predictionmaster) 

# Define a function for logistic regression that will be used by cv.glm
logit_fn <- function(data, indices) {
  # Create a logistic regression model on the sampled data
  model <- glm(isplacement ~ vacancy_2012 + distance_to_downtown_miles + medianhome_2012_2020
               + pct_lowincome_2012+ pct_black_2012 + pct_college_2012_2020 + pct_lowincjob_2012 + pct_hcv_2012, data = data[indices, ], family=binomial(link="logit"))
  return(model)
}

# Perform 10-fold cross-validation
cv_results <- cv.glm(predictionmaster, logit, K = 10)

# Print the cross-validation results
cv_results$delta  # These are the cross-validation errors

cv_results$delta[1]

# # Misclassification error calculation
# misclass_fn <- function(data, indices) {
#   # Fit the model on the sampled data
#   model <- glm(displacement ~ vacancy_2012 + distance_to_downtown_miles + medianhome_2012_2020
#                + pct_lowincome_2012+ pct_black_2012 + pct_college_2012_2020 + pct_lowincjob_2012 + pct_hcv_2012, data = data[indices, ], family=binomial(link="logit"))
#   
#   # Predict the probability of "am"
#   predicted_probs <- predict(model, data[indices, ], type = "response")
#   
#   # Convert probabilities to predicted class (0 or 1)
#   predicted_class <- ifelse(predicted_probs > 0.5, 1, 0)
#   
#   # Calculate misclassification rate
#   actual_class <- data$am[indices]
#   mean(predicted_class != actual_class)
# }

cost <- function(r, pi = 0) mean(abs(r-pi) > 0.5)

# 10-fold cross-validation
# cv_misclass <- cv.glm(predictionmaster, logit, cost = misclass_fn, K = 10)

cv.glm(predictionmaster, logit, cost, 10) #70% accuracy

corrdata <- predictionmaster %>% 
  select(vacancy_2012,distance_to_downtown_miles,medianhome_2012_2020,pct_lowincome_2012, pct_black_2012 , pct_college_2012_2020 , pct_lowincjob_2012 , pct_hcv_2012) %>% 
  rename(vacancy=vacancy_2012,
         distance=distance_to_downtown_miles,
         homevalue=medianhome_2012_2020,
         lowinc=pct_lowincome_2012,
         black=pct_black_2012 ,
         college=pct_college_2012_2020,
         lowincjob=pct_lowincjob_2012,
         hcv=pct_hcv_2012)

M = cor(corrdata)
corrplot(M, order = 'AOE') # after 'AOE' reorder
corrplot(M, order = 'hclust', addrect = 2)

#################predict

predictionmaster1 <- predictionmaster %>% 
  rename(vacancy=vacancy_2012,
         distance=distance_to_downtown_miles,
         homevalue=medianhome_2012_2020,
         lowinc=pct_lowincome_2012,
         black=pct_black_2012 ,
         college=pct_college_2012_2020,
         lowincjob=pct_lowincjob_2012,
         hcv=pct_hcv_2012)

predictionmaster2 <- predictionmaster %>% 
  rename(vacancy=vacancy_2022,
         distance=distance_to_downtown_miles,
         homevalue=medianhome_2022,
         lowinc=pct_lowincome_2022,
         black=pct_black_2022 ,
         college=pct_college_2022,
         lowincjob=pct_lowincjob_2021,
         hcv=pct_hcv_2022)

logit <- glm(displacement ~ vacancy + distance + homevalue
             + lowinc + black + college + lowincjob + hcv, family=binomial(link="logit"), data=predictionmaster1) 

stargazer(logit, type = "html", out = "C:/Users/Ysu/Desktop/DMPED maps/regression_test_results.html",
          title = "Regression test resuls")

logit2 <- glm(displacement ~  distance + homevalue
              + lowinc + black + lowincjob, family=binomial(link="logit"), data=predictionmaster1) 

AIC(logit, logit2)
anova(logit, logit2, test = "Chisq")

# Predict probabilities of "am" being 1 (manual transmission)
predicted_probs <- predict(logit, predictionmaster2, type = "response")
print(predicted_probs)
# Convert probabilities to predicted class (0 or 1) based on a threshold of 0.5
predicted_class <- ifelse(predicted_probs > 0.5, 1, 0)

# Print predicted classes
print(predicted_class)

predictionmaster2$predicted_probs <- predicted_probs
predictionmaster2$predicted_class <- predicted_class

Testresult <- predictionmaster2 %>% 
  left_join(neighborhoodname, by=c("GEOID")) %>% 
  select(GEOID, NBH_NAMES,Ward, NAME.y, displacement, predicted_probs,predicted_class )


write.csv(Testresult,"C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/Prediction_v1.csv")
