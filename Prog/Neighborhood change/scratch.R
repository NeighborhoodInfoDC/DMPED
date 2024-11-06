

ggplot(map_file) +
  geom_density(aes(x = non_hispanic_black_pop_2012_2020, color = "2012"), fill = "blue", alpha = 0.3) +
  geom_density(aes(x = non_hispanic_black_pop_2022, color = "2022"), fill = "green", alpha = 0.3) +
  geom_density(aes(x = non_hispanic_black_pop_2000_2010_2020, color = "2000"), fill = "yellow", alpha = 0.3) +
  labs(
    title = "Comparison of Black Population Distribution",
    x = "Population",
    y = "Density"
  ) +
  scale_color_manual(values = c("2012" = "blue", "2022" = "green", "2022"="yellow")) +
  theme_minimal()


test <- map_file %>% 
  mutate(black_quintile = ntile(non_hispanic_black_pop_2000_2010_2020, 10)) %>% 
  mutate(lossalltime=non_hispanic_black_pop_2022-non_hispanic_black_pop_2000_2010_2020,na.rm=TRUE) %>% 
  mutate(blackchangequintile=ntile(lossalltime,10)) %>% 
  mutate(lowinomce_quintile=ntile(lowincome_2000_2020,10)) %>% 
  # select(non_hispanic_black_pop_2000_2010_2020, black_quintile,lowinomce_quintile,lowincome_2000_2020) %>% 
  mutate(pct_lowinc=lowincome_2000_2020/total_hh_2000_2020, na.rm=TRUE) %>% 
  select(GEOID, pct_lowinc)

quintile_cutoffs <- quantile(map_file$black_quintile, probs = seq(0, 1, by = 0.1))
quintile_cutoffs <- quantile(test$non_hispanic_black_pop_2000_2010_2020, probs = seq(0, 1, by = 0.1))
print(quintile_cutoffs)

ggplot() +
  geom_sf(data = test, aes(fill = factor(black_quintile)), color = "white", size = 0.2) +
  scale_fill_brewer(palette = "YlGnBu", name = "Population Quintile") +
  labs(
    title = "Population Quintiles by Tract",
    subtitle = "Colored by Population in 10 Quintiles"
  ) +
  theme_minimal()


test2 <- master6 %>% 
  filter(GEOID==11001011002) %>% 
  select(GEOID,total_hh_2022,overallincreasevalue_2012_2022, quintile_2022,homevaluecat_2022, homevaluecat_2012,medianhome_2022,medianhome_2012_2020)


library(broom)
library(gt)
library(dplyr)
library(knitr)
logit_model <- glm(displacement ~ vacancy + distance + distancesquared+homevalue
                   + black  + lowincjob + hcv+changeunits+changerent, 
                   data = predictionmaster1, 
                   family = binomial(link = "logit"))

tidy_logit <- logit_model %>%
  tidy() %>%
  mutate(across(estimate:p.value, ~ round(., 4))) 

tidy_logit %>%
  select(term, estimate, std.error, statistic, p.value) %>%
  kable(col.names = c("Predictor", "Coefficient", "Std. Error", "Z-Value", "P-Value"),
        caption = "Logistic Regression Results: Predicting Displacement")


# Full model (with all predictors)
model_full <- glm(displacement ~ vacancy + distance + distancesquared + homevalue + 
                    black + lowincjob + hcv + changeunits + changerent, 
                  data = predictionmaster1, family = binomial(link = "logit"))

# Perform stepwise selection starting from the full model
best_model_step <- step(model_full, direction = "both")
# Extract the stepwise selection process
stepwise_aic <- best_model_step$anova

# Print the AIC values from each step
stepwise_aic %>%
  select(Step, AIC) %>%
  knitr::kable(caption = "AIC Values for Each Step of Stepwise Regression")

# Summary of the best model based on stepwise selection
summary(best_model_step)