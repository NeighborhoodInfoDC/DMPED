predicted <- predict(OLS1, predictionmaster2, type = "response")
predictionmaster2$predictedchangeinblack <- predicted


test <- predictionmaster2 %>% 
  select(GEOID,predictedchangeinblack,changeblack_2022,non_hispanic_black_hh_2022) %>% 
  mutate(pct=predictedchangeinblack/non_hispanic_black_hh_2022) %>% 
  filter(pct<(-0.1))

quintile_cutoffs <- quantile(popbyrace$non_hispanic_black_pop_2022, probs = seq(0, 1, by = 0.1))
print(quintile_cutoffs)

# 0%    10%    20%    30%    40%    50%    60%    70%    80%    90%   100% 
# 0.0  152.5  213.0  397.0  683.0 1024.5 1468.0 1990.0 2669.0 3332.0 5720.0 

Testresult <- predictionmaster2 %>% 
  left_join(neighborhoodname, by=c("GEOID")) %>% 
  left_join(predictionmaster, by=c("GEOID")) %>% 
  mutate(pct=predictedchangeinblack/non_hispanic_black_hh_2022.x) %>% 
  mutate(startpop=ntile(non_hispanic_black_hh_2022.x,10)) %>% 
  # select(GEOID, NBH_NAMES,Ward, NAME.y, displacement, predictedchangeinblack) %>% 
  # select(GEOID,predictedchangeinblack,non_hispanic_black_hh_2022-non_hispanic_black_hh_2000_2020)
  mutate(lossmorethan10=ifelse(pct<-0.1 & startpop>2 ,1,0),
         lossmorethan20=ifelse(pct<-0.2 & startpop>2 ,1,0)) %>% 
  select(GEOID,pct,lossmorethan10,lossmorethan20)

quintile_cutoffs <- quantile(Testresult$pct, probs = seq(0, 1, by = 0.1))
print(quintile_cutoffs)

upcomingdisplacement <- predicteddisplacementmap %>% 
  left_join(Testresult,by=c("GEOID")) %>% 
  filter(lossmorethan20==1) %>% 
  filter(non_hispanic_black_hh_2022.x>213)



ggplot() +
  # geom_sf(data =predicteddisplacementmap, aes( fill = `neighborhood category`))+
  # scale_fill_manual(name="neighborhoodchange type", values = urban_colors8, guide = guide_legend(override.aes = list(linetype = "blank", 
  #                                                                                                                    shape = NA)))+ 
  # geom_sf(BBCF, mapping = aes(), fill=NA,lwd =  0.5, color="#fdbf11",show.legend = "line")+
  # geom_sf(cog_all, mapping = aes(), fill=NA,lwd =  1, color="#ec008b",show.legend = "line")+
  # scale_color_manual(values = 'transparent', guide = guide_legend(override.aes = list(linetype = "solid"))) +
  # geom_sf(water_sf, mapping=aes(), fill="#dcdbdb", color="#dcdbdb", size=0.05)+
  # coord_sf(datum = NA)+
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


#test the new combination of thresholds for loss of black population
popchange <- master6 %>% 
  mutate(loss_2000_2012=total_hh_2012_2020-total_hh_2000_2020,
         loss_2012_2022=total_hh_2022-total_hh_2012_2020) %>% 
  filter(loss_2012_2022<0) %>% 
  select(GEOID, Ward,NBH_NAMES,loss_2000_2012, loss_2000_2012,loss_2012_2022) %>% 
  group_by(NBH_NAMES,Ward) %>% 
  count()

# Density plot for comparing two periods
ggplot(popchange) +
  geom_density(aes(x = loss_2000_2012, color = "2000-2012"), fill = "blue", alpha = 0.3) +
  geom_density(aes(x = loss_2012_2022, color = "2012-2022"), fill = "green", alpha = 0.3) +
  labs(
    title = "Comparison of Population Change Distribution",
    x = "Population Change",
    y = "Density"
  ) +
  scale_color_manual(values = c("2000-2012" = "blue", "2012-2022" = "green")) +
  theme_minimal()



#try new model for predicting black loss
library(dplyr)

# Define the dataset and target variable
target_var <- "changeinblack"  # or "changeinblack" based on your analysis
predictors <- c("distance", "distancesquared","vacancy", "changerent", "changeunits", "hcv", 
                "lowincjob", "college", "black", "lowinc", "homevalue")

# Initialize an empty data frame to store the results
results <- data.frame(Model = character(), R_squared = numeric(), RMSE = numeric(), Variables = character())

# Define a function to calculate RMSE
calculate_rmse <- function(actual, predicted) {
  sqrt(mean((actual - predicted)^2))
}

# Loop through each possible combination of predictors
for (i in 1:length(predictors)) {
  # Generate all combinations of predictors of size i
  predictor_combinations <- combn(predictors, i, simplify = FALSE)
  
  for (combo in predictor_combinations) {
    # Create a formula for the model
    formula <- as.formula(paste(target_var, "~", paste(combo, collapse = " + ")))
    
    # Fit the model
    model <- lm(formula, data = predictionmaster1)
    
    # Calculate R-squared
    r_squared <- summary(model)$r.squared
    
    # Calculate RMSE
    predictions <- predict(model, newdata = predictionmaster1)
    rmse <- calculate_rmse(df[[target_var]], predictions)
    
    # Store the results
    results <- results %>%
      add_row(Model = paste(combo, collapse = " + "), 
              R_squared = r_squared, 
              RMSE = rmse, 
              Variables = paste(combo, collapse = ", "))
  }
}

# Filter for the best model based on highest R-squared and lowest RMSE
best_model <- results %>%
  arrange(desc(R_squared), RMSE) %>%
  slice(1)

print("Best Model Based on Highest R-squared and Lowest RMSE:")
print(best_model)




# Load necessary libraries
library(caret)
library(dplyr)

# Define the dataset and target variable
target_var <- "changeinlowinc"  # or "changeinblack" based on your analysis
predictors <- c("distance", "vacancy", "changerent", "changeunits", "hcv", 
                "lowincjob", "college", "black", "lowinc", "homevalue")

# Initialize an empty data frame to store the results
results <- data.frame(Model = character(), R_squared = numeric(), CV_RMSE = numeric(), Variables = character())

# Set up cross-validation control
train_control <- trainControl(method = "cv", number = 10)

# Loop through each possible combination of predictors
for (i in 1:length(predictors)) {
  # Generate all combinations of predictors of size i
  predictor_combinations <- combn(predictors, i, simplify = FALSE)
  
  for (combo in predictor_combinations) {
    # Create a formula for the model
    formula <- as.formula(paste(target_var, "~", paste(combo, collapse = " + ")))
    
    # Fit the model using 10-fold cross-validation
    model_cv <- train(formula, data =  predictionmaster1, method = "lm", trControl = train_control)
    
    # Extract cross-validated RMSE
    cv_rmse <- model_cv$results$RMSE
    
    # Calculate R-squared on the full dataset
    model <- lm(formula, data = predictionmaster1)
    r_squared <- summary(model)$r.squared
    
    # Store the results
    results <- results %>%
      add_row(Model = paste(combo, collapse = " + "), 
              R_squared = r_squared, 
              CV_RMSE = cv_rmse, 
              Variables = paste(combo, collapse = ", "))
  }
}

# Filter for the best model based on highest R-squared and lowest CV RMSE
best_model <- results %>%
  arrange(desc(R_squared), CV_RMSE) %>%
  slice(1)

print("Best Model Based on Highest R-squared and Lowest Cross-Validated RMSE:")
print(best_model)
