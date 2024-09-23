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
# library(dummies)
library(dplyr)
library(Hmisc)
library(haven)
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

neighborhoodtype_OTR <- read_csv("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/neighborhoodtype_homevalueOTR.csv") %>% 
  select(GEOID, neighborhoodtype, NBH_NAMES)

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

predictionmaster <-  neighborhoodtype_OTR %>% 
  left_join(housingmarket, by=c("GEOID")) %>% 
  left_join(lowincome, by=c("GEOID")) %>% 
  left_join(raceethnicity, by=c("GEOID")) %>% 
  left_join(distance, by=c("GEOID")) %>% 
  # left_join(vacancy, by=c("GEOID")) %>% 
  left_join(lowincjobs, by=c("GEOID")) %>% 
  left_join(HUDsubsidy, by=c("GEOID")) %>% 
  left_join(college, by=c("GEOID")) %>% 
  mutate(displacement=ifelse((neighborhoodtype=="exclusive growth with displacement risk"|neighborhoodtype=="established opportunity with displacement risk"),1,0)) %>% 
  mutate(pct_hcv_2012=HCV_2012_2020/total_hh_2012_2020,
         pct_hcv_2022=HCV_2022/total_hh_2022) %>% 
  mutate(pct_lowincome_2000=lowincome_2000_2020/total_hh_2000_2020,
         pct_lowincome_2012=lowincome_2012_2020/total_hh_2012_2020,
         pct_lowincome_2022=lowincome_2022/total_hh_2022) %>% 
  mutate(pct_black_2000=non_hispanic_black_hh_2000_2020/total_hh_2000_2020,
         pct_black_2012=non_hispanic_black_hh_2012_2020/total_hh_2012_2020,
         pct_black_2022=non_hispanic_black_hh_2022/total_hh_2022) %>% 
  mutate(medianhome_2000_2020=medianhome_2000_2020/100000,
         medianhome_2012_2020=medianhome_2012_2020/100000,
         medianhome_2022=medianhome_2022/100000) %>% 
  mutate(distancesquared=distance_to_downtown_miles*distance_to_downtown_miles)

### test correlation
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
corrplot(M, order = 'AOE', diag=FALSE) # after 'AOE' reorder

predictionmaster1 <- predictionmaster %>% 
  rename(vacancy=vacancy_2012,
         distance=distance_to_downtown_miles,
         homevalue=medianhome_2012_2020,
         lowinc=pct_lowincome_2012,
         black=pct_black_2012 ,
         college=pct_college_2012_2020,
         lowincjob=pct_lowincjob_2012,
         hcv=pct_hcv_2012) 
  
write.csv(predictionmaster1, "C:/Users/Ysu/Downloads/testset.csv")

predictionmaster2 <- predictionmaster %>% 
  rename(vacancy=vacancy_2022,
         distance=distance_to_downtown_miles,
         homevalue=medianhome_2022,
         lowinc=pct_lowincome_2022,
         black=pct_black_2022 ,
         college=pct_college_2022,
         lowincjob=pct_lowincjob_2021,
         hcv=pct_hcv_2022)

logit <- glm(displacement ~ vacancy + distance + distancesquared+homevalue
             + black  + lowincjob + hcv, family=binomial(link="logit"), data=predictionmaster1) 

logit2 <- glm(displacement ~  distance + distancesquared+homevalue
              + black  + lowincjob + hcv , family=binomial(link="logit"), data=predictionmaster1) 

logit3 <- glm(displacement ~ vacancy + distance + distancesquared+homevalue
              + black  + lowincjob , family=binomial(link="logit"), data=predictionmaster1) 

logit4 <- glm(displacement ~ vacancy + distance + distancesquared+homevalue
              + black + hcv, family=binomial(link="logit"), data=predictionmaster1) 

logit5 <- glm(displacement ~  distance + distancesquared+homevalue
              + black  + lowincjob , family=binomial(link="logit"), data=predictionmaster1) 

logit6 <- glm(displacement ~ vacancy + distance + distancesquared+homevalue
              + black  , family=binomial(link="logit"), data=predictionmaster1) 

logit7 <- glm(displacement ~  distance + distancesquared+homevalue
              + black  , family=binomial(link="logit"), data=predictionmaster1) 

test <- predictionmaster1 %>% 
  filter(is.na(displacement))

# Perform 10-fold cross-validation
cv_results <- cv.glm(predictionmaster1,logit, K = 10)
# Print the cross-validation results
cv_results$delta  # These are the cross-validation errors
cv_results$delta[1]

cv_results_list <- list()

cv_results_list$logit <- cv.glm(predictionmaster1, logit, K = 10)$delta
cv_results_list$logit2 <- cv.glm(predictionmaster1, logit2, K = 10)$delta
cv_results_list$logit3 <- cv.glm(predictionmaster1, logit3, K = 10)$delta
cv_results_list$logit4 <- cv.glm(predictionmaster1, logit4, K = 10)$delta
cv_results_list$logit5 <- cv.glm(predictionmaster1, logit5, K = 10)$delta
cv_results_list$logit6 <- cv.glm(predictionmaster1, logit6, K = 10)$delta
cv_results_list$logit7 <- cv.glm(predictionmaster1, logit7, K = 10)$delta
cv_results_df <- as.data.frame(cv_results_list)

#collect AIC information
AIC(logit, logit2,logit3,logit4,logit5,logit6,logit7 )
AIC(logit)

# Create a function to calculate accuracy, FPR, and FNR
calculate_metrics <- function(model, data) {
  # Make predictions (probabilities)
  predicted_probs <- predict(model, data, type = "response")
  
  # Classify observations based on a 0.5 threshold
  predicted_classes <- ifelse(predicted_probs > 0.5, 1, 0)
  
  # Actual classes
  actual_classes <- data$displacement
  
  # Calculate accuracy
  accuracy <- mean(predicted_classes == actual_classes)
  
  # Calculate confusion matrix components
  true_positives <- sum((predicted_classes == 1) & (actual_classes == 1))
  true_negatives <- sum((predicted_classes == 0) & (actual_classes == 0))
  false_positives <- sum((predicted_classes == 1) & (actual_classes == 0))
  false_negatives <- sum((predicted_classes == 0) & (actual_classes == 1))
  
  # Calculate False Positive Rate (FPR) and False Negative Rate (FNR)
  total_actual_negatives <- sum(actual_classes == 0)
  total_actual_positives <- sum(actual_classes == 1)
  
  FPR <- false_positives / total_actual_negatives
  FNR <- false_negatives / total_actual_positives
  
  # Return the metrics as a named list
  return(list(accuracy = accuracy, FPR = FPR, FNR = FNR))
}

# Create an empty data frame to store metrics for each model
metrics_df <- data.frame(Model = character(), Accuracy = numeric(), FPR = numeric(), FNR = numeric(), stringsAsFactors = FALSE)

# List of models for easier looping
models <- list(logit = logit, logit2 = logit2, logit3 = logit3, logit4 = logit4, logit5 = logit5, logit6 = logit6, logit7 = logit7) # Add more models here if needed

# Loop over each model, calculate metrics, and store them in the data frame
for (model_name in names(models)) {
  metrics <- calculate_metrics(models[[model_name]], predictionmaster1)
  
  # Append the metrics to the data frame
  metrics_df <- rbind(metrics_df, data.frame(
    Model = model_name,
    Accuracy = metrics$accuracy,
    FPR = metrics$FPR,
    FNR = metrics$FNR
  ))
}

# Print the final data frame with accuracy, FPR, and FNR for each model
print(metrics_df)





predicted_probs <- predict(logit3, predictionmaster1, type = "response")

# Classify observations based on a 0.5 threshold
predicted_classes <- ifelse(predicted_probs > 0.5, 1, 0)

# Actual classes
actual_classes <- predictionmaster1$displacement

# Calculate accuracy
accuracy <- mean(predicted_classes == actual_classes)



#################predict

# Predict probabilities of "am" being 1 (manual transmission)
predicted_probs <- predict(logit6, predictionmaster2, type = "response")
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

write.csv(Testresult,"C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/Prediction_v1_OTR.csv")

predicteddisplacementmap <- master5 %>% 
  left_join(predictionmaster2, by=c("GEOID")) %>% 
  # select(GEOID, displacement, predicted_probs,predicted_class) %>% 
    mutate(predictiontype=case_when(displacement==1 & predicted_class==1 ~ "continued displacement risk",
                                    displacement==0 & predicted_class==1 ~ "upcoming displacement risk",
                                    displacement==1 & predicted_class==0 ~ "decreased displacement risk",
                                    displacement==0 & predicted_class==0 ~ "no displacement risk")) %>% 
    # group_by(predictiontype) %>% 
    # count()
predict_map <- predicteddisplacementmap %>% 
  select(GEOID, neighborhoodtype.x, displacement, predictiontype, NBH_NAMES.x, total_hh_2022.x, pct_black_2022) %>% 
  rename(NBH_NAMES=NBH_NAMES.x,
         total_hh_2022=total_hh_2022.x,
         neighborhoodtype=neighborhoodtype.x)
  
write.csv(predict_map,"C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/Prediction_map_shiny.csv")

  

newtype <- predicteddisplacementmap %>% 
  # select(displacement, predicted_class, predictiontype,neighborhoodtype.x) %>% 
  # filter(predictiontype=="continued displacement risk")
  mutate(exclusive=ifelse(neighborhoodtype.x=="exclusive growth with displacement risk",1,0),
         established=ifelse(neighborhoodtype.x=="established opportunity with displacement risk",1,0)) %>% 
  group_by(predictiontype) %>% 
  count()
  summarise(exclusive=sum(exclusive),
            established=sum(established))

upcomingdisplacement <- predicteddisplacementmap %>% 
  filter(predictiontype=="upcoming displacement risk") 

test <- upcomingdisplacement %>% 
  group_by(NBH_NAMES, Ward,neighborhoodtype.x) %>% 
  count()


urban_colors7 <- c("#73bfe2", "#f5cbdf","#fce39e", "#1696d2" ,"#e9807d","#fdd870","#dcedd9")

ggplot() +
  geom_sf(data =predicteddisplacementmap, aes( fill = `neighborhood category`))+
  scale_fill_manual(name="neighborhoodchange type", values = urban_colors7, guide = guide_legend(override.aes = list(linetype = "blank", 
                                                                                                                     shape = NA)))+ 
  # geom_sf(BBCF, mapping = aes(), fill=NA,lwd =  0.5, color="#fdbf11",show.legend = "line")+
  # geom_sf(cog_all, mapping = aes(), fill=NA,lwd =  1, color="#ec008b",show.legend = "line")+
  # scale_color_manual(values = 'transparent', guide = guide_legend(override.aes = list(linetype = "solid"))) +
  geom_sf(water_sf, mapping=aes(), fill="#dcdbdb", color="#dcdbdb", size=0.05)+
  coord_sf(datum = NA)+
  # theme(
  #   panel.grid.major = element_line(colour = "transparent", linewidth = 0),
  #   axis.title = element_blank(),
  #   axis.line.y = element_blank(),
  #   plot.caption = element_text(hjust = 0, linewidth = 16),
  #   plot.title = element_text(linewidth = 18),
  #   legend.title=element_text(linewidth=14),
  #   legend.text = element_text(linewidth = 14)
  # 
  # )+
  guides(color = guide_legend(override.aes = list(size=5)))+
  geom_sf(data = tractboundary_20, fill = "transparent", color="#adabac")+
  coord_sf(datum = NA)+
  geom_sf(data = upcomingdisplacement, fill = "transparent", color="#ec008b")+
  coord_sf(datum = NA)+
  labs(title = paste0("Neighborhood Change in DC based on OTR sales data"),
       subtitle= "Increased displacement risk area highlighted in red",
       caption = "Source: Census 2000, ACS 5-year estimates 2008-2012, 2018-2022")


# Predict probabilities of "am" being 1 (manual transmission)
predicted_probs <- predict(logit, predictionmaster1, type = "response")
print(predicted_probs)
# Convert probabilities to predicted class (0 or 1) based on a threshold of 0.5
predicted_class <- ifelse(predicted_probs > 0.5, 1, 0)

predictionmaster1$predicted_probs <- predicted_probs
predictionmaster1$predicted_class <- predicted_class

Testresult <- predictionmaster1 %>% 
  left_join(neighborhoodname, by=c("GEOID")) %>% 
  select(GEOID, NBH_NAMES,Ward, NAME.y, displacement, predicted_probs,predicted_class )

write.csv(Testresult,"C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/Prediction_v1_accuracy.csv")
