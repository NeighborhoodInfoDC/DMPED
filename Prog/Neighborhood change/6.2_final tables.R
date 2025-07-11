blacktenure_table <- blacktenure %>% 
  mutate(total=1) %>% 
  group_by(total) %>% 
  summarise(blackrenter_2000=sum(black_renter_2000_2010_2020),
            blackrenter_2012=sum(black_renter_2012_2020),
            blackrenter_2022=sum(black_renter_2022),
            blackowner_2000=sum(black_owner_2000_2010_2020),
            blackowner_2012=sum(black_owner_2012_2020),
            blackowner_2022=sum(black_owner_2022))

test2 <-map_file %>% 
  left_join(OTR_sales,by=c("GEOID")) %>%
  mutate(medianhome_2000_2020=mprice_tot_2000,
         medianhome_2012_2020=mprice_tot_2012,
         medianhome_2022=mprice_tot_2022) %>%
  mutate(medianhome_2000_2020=ifelse(GEOID=="11001004702",165000,medianhome_2000_2020),
         medianhome_2022=ifelse(GEOID=="11001005602",1039500,medianhome_2022),
         medianhome_2012_2020=ifelse(GEOID=="11001007401",178250,medianhome_2012_2020),
         medianhome_2022=ifelse(GEOID=="11001007401",500000,medianhome_2022),
         medianhome_2012_2020=ifelse(GEOID=="11001007401",207250,medianhome_2012_2020),
         medianhome_2012_2020=ifelse(GEOID=="11001009602",284900,medianhome_2012_2020)) %>% #use nearest year sales data if available
  filter(is.na(medianhome_2022)| is.na(medianhome_2012_2020) | is.na(medianhome_2000_2020)) %>%
  select(GEOID, NBH_NAMES, Ward, medianhome_2000_2020, medianhome_2012_2020, medianhome_2022) 

test3 <- map_file %>% 
  mutate(changeunits_2022=housing_2022-housing_2012_2020,
  changelowincome_2022=lowincome_2022-lowincome_2012_2020) 

# Create scatter plot of change in unit and change in low income hh
# Determine the limits for a 1:1 scale
axis_limits <- range(c(test3$changelowincome_2022, test3$changeunits_2022), na.rm = TRUE)


set_urbn_defaults(style = "print")
# Create scatter plot
library(urbnthemes)

ggplot(test3, aes(x = changelowincome_2022, y = changeunits_2022)) +
  geom_point(alpha = 0.6, color = "#1696d2", size = 1.5) + 
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "#eb99c2") + # 1:1 diagonal line
  labs(
    x = "Change in Low-Income HH",
    y = "Change in Housing Units",
    title = "Scatter Plot of Housing Unit Change vs. Low-Income HH Change",
    subtitle = "Red dashed line represents 1:1 ratio (1 unit = 1 household)"
  ) +
  coord_fixed(ratio = 1, xlim = axis_limits, ylim = axis_limits) + # Ensure 1:1 scale
  theme_minimal()

ggplot(test3, aes(x = changelowincome_2022, y = changeunits_2022)) +
  geom_point(alpha = 0.6, color = "#1696d2", size = 1.5) + 
  geom_smooth(method = "lm", se = FALSE, color = "#eb99c2", linetype = "dashed") +  # Regression trend line
  labs(
    x = "Change in Low-Income HH",
    y = "Change in Housing Units",
    title = "Scatter Plot of Housing Unit Change vs. Low-Income HH Change",
    subtitle = "Dashed red line represents the linear trend"
  ) +
  coord_fixed(ratio = 1, xlim = axis_limits, ylim = axis_limits) + # Ensure 1:1 scale
  theme_minimal()
  
master7 <- map_file %>% 
  left_join(OTR_sales,by=c("GEOID")) %>%
  mutate(medianhome_2000_2020=mprice_tot_2000,
         medianhome_2012_2020=mprice_tot_2012,
         medianhome_2022=mprice_tot_2022) %>%
  mutate(medianhome_2000_2020=ifelse(GEOID=="11001004702",165000,medianhome_2000_2020),
         medianhome_2022=ifelse(GEOID=="11001005602",1039500,medianhome_2022),
         medianhome_2012_2020=ifelse(GEOID=="11001007401",178250,medianhome_2012_2020),
         medianhome_2022=ifelse(GEOID=="11001007401",500000,medianhome_2022),
         medianhome_2012_2020=ifelse(GEOID=="11001007401",207250,medianhome_2012_2020),
         medianhome_2012_2020=ifelse(GEOID=="11001009602",284900,medianhome_2012_2020)) %>% #use nearest year sales data if available
  filter(!is.na(medianhome_2022)& !is.na(medianhome_2012_2020)) %>%
  # filter(is.na(medianhome_2022)==TRUE |is.na(medianhome_2012_2020==TRUE)) %>%
  # select(GEOID, medianhome_2022, medianhome_2012_2020,total_hh_2012_2020)
  mutate(quintile_2000=ntile(medianhome_2000_2020,5),
         quintile_2012=ntile(medianhome_2012_2020,5),
         quintile_2022=ntile(medianhome_2022,5)) %>% 
  mutate(homevaluecat_2000=case_when(quintile_2000==1|quintile_2000==2 ~ "low",
                                     quintile_2000==3 ~ "moderate",
                                     quintile_2000==4|quintile_2000==5 ~ "high"),
         homevaluecat_2012=case_when(quintile_2012==1|quintile_2012==2 ~ "low",
                                     quintile_2012==3 ~ "moderate",
                                     quintile_2012==4|quintile_2012==5 ~ "high"),
         homevaluecat_2022=case_when(quintile_2022==1|quintile_2022==2 ~ "low",
                                     quintile_2022==3 ~ "moderate",
                                     quintile_2022==4|quintile_2022==5 ~ "high")) %>% 
  mutate(nominal_00_12=medianhome_2012_2020-medianhome_2000_2020*1.127,
         nominal_12_22=medianhome_2022-medianhome_2012_2020*1.275,
         nominal_00_22=medianhome_2022-medianhome_2000_2020*1.7) %>% #bsed on dollar adjustment marcro Dollar_convert.sas
  mutate(pct_lowincome_2000=lowincome_2000_2020/total_hh_2000_2020,
         pct_lowincome_2012=lowincome_2012_2020/total_hh_2012_2020,
         pct_lowincome_2022=lowincome_2022/total_hh_2022) %>% 
  mutate(change_lowincome=lowincome_2022-lowincome_2012_2020) %>% 
  mutate(pctchange_2000_2022=(lowincome_2022-lowincome_2000_2020)/lowincome_2000_2020) %>% 
  mutate(pct_lowinc_2000=lowincome_2000_2020/total_hh_2000_2020, na.rm=TRUE) %>% 
  mutate(quintile_cutoffs_inc= ntile(pct_lowinc_2000, 10)) %>% 
  mutate(totalpop2000=non_hispanic_black_pop_2000_2010_2020+non_hispanic_white_pop_2000_2010_2020+hispanic_or_latino_pop_2000_2010_2020+non_hispanic_aapi_pop_2000_2010_2020+non_hispanic_other_pop_2000_2010_2020) %>% 
  mutate(pct_lowinc_black=non_hispanic_black_pop_2000_2010_2020/totalpop2000, na.rm=TRUE) %>% 
  mutate(quintile_cutoffs_black= ntile(pct_lowinc_black, 10)) 

medianlosslowinc_12_22 <-master7 %>% 
  mutate(pctchange_2012_2022=change_lowincome/total_hh_2012_2020,
         change_share_lowincome_2012_2022=pct_lowincome_2022-pct_lowincome_2012) %>% 
  select(GEOID, change_lowincome, pctchange_2012_2022, change_share_lowincome_2012_2022, pct_lowincome_2012, pct_lowincome_2022) %>%
  # mutate(total=1) %>%
  # group_by(total) %>%
  summarise(medianchange=median(change_lowincome),#-6
            medianpctchange_2012_2022=median(pctchange_2012_2022),
            median_change_share=median(change_share_lowincome_2012_2022))

quintiles_A <- quantile(medianlosslowinc_12_22$pct_lowincome_2012, probs = seq(0, 1, 0.1), na.rm = TRUE)
print(quintiles_A)
  
#understand the distritbution of change of low income population

map_report1 <- merge(analysismaster,tractboundary_20, by=c("GEOID")) %>% 
  mutate(change_black=non_hispanic_black_pop_2022-non_hispanic_black_pop_2012_2020,
         change_lowinc=total_hh_2022-total_hh_2012_2020) %>% 
  select(GEOID, geometry,change_black,change_lowinc ) %>% 
  pivot_longer(cols = c(change_black, change_lowinc),
               names_to = "variable", values_to = "value") %>% 
  st_as_sf() %>% 
  filter(GEOID!=11001010900 & GEOID!=11001007301)

map_report2 <- merge(analysismaster,tractboundary_20, by=c("GEOID")) %>% 
  mutate(change_black=non_hispanic_black_pop_2012_2020-non_hispanic_black_pop_2000_2010_2020,
         change_lowinc=total_hh_2012_2020-total_hh_2000_2020) %>% 
  select(GEOID, geometry,change_black,change_lowinc ) %>% 
  pivot_longer(cols = c(change_black, change_lowinc),
               names_to = "variable", values_to = "value") %>% 
  st_as_sf() %>% 
  filter(GEOID!=11001010900 & GEOID!=11001007301)

map_report3 <- merge(analysismaster,tractboundary_20, by=c("GEOID")) %>% 
  mutate(change_black_22_12=non_hispanic_black_pop_2022-non_hispanic_black_pop_2012_2020,
         change_black_12_00=non_hispanic_black_pop_2012_2020-non_hispanic_black_pop_2000_2010_2020) %>% 
  select(GEOID, geometry,change_black_22_12, change_black_12_00) %>% 
  pivot_longer(cols = c(change_black_12_00,change_black_22_12),
               names_to = "variable", values_to = "value") %>% 
  st_as_sf() %>% 
  filter(GEOID!=11001010900 & GEOID!=11001007301)

map_report3 <- merge(analysismaster,tractboundary_20, by=c("GEOID")) %>% 
  mutate(change_lowinc_22_12=total_hh_2022-total_hh_2012_2020,
         change_lowinc_12_00=total_hh_2012_2020-total_hh_2000_2020) %>% 
  select(GEOID, geometry,change_lowinc_22_12, change_lowinc_12_00) %>% 
  pivot_longer(cols = c(change_lowinc_12_00,change_lowinc_22_12),
               names_to = "variable", values_to = "value") %>% 
  st_as_sf() %>% 
  filter(GEOID!=11001010900 & GEOID!=11001007301)

ggplot() +
  geom_sf(data =map_report1, aes( fill = value), color = NA)+
  scale_fill_gradient2(low = "#ec008b", mid = "white", high = "#46abdb", midpoint = 0, 
                       name = "Change in total") +  geom_sf(water_sf, mapping=aes(), fill="#dcdbdb", color="#dcdbdb", size=0.05)+
  coord_sf(datum = NA)+
  facet_wrap(~ variable, ncol = 2, labeller = labeller(
    variable = c("change_black" = "Change in Black Population",
                 "change_lowinc" = "Change in Low-Income Households"))) +
  # labs(title = "Population and Household Change in DC during 2012-2022",
  #      caption = "Source: Your Data Source") +
  theme_minimal() +
  theme(legend.position = "right")+
  guides(color = guide_legend(override.aes = list(size=5)))+
  theme(
    legend.position = "right",
    strip.text = element_text(size = 14, face = "bold")  # Increases facet title size and makes it bold
  )

ggplot() +
  geom_sf(data =map_report3, aes( fill = value), color = NA)+
  scale_fill_gradient2(low = "#ec008b", mid = "white", high = "#46abdb", midpoint = 0, 
                       name = "Change in low-income households") +  geom_sf(water_sf, mapping=aes(), fill="#dcdbdb", color="#dcdbdb", size=0.05)+
  coord_sf(datum = NA)+
  facet_wrap(~ variable, ncol = 2, labeller = labeller(
    variable = c("change_lowinc_12_00" = "2000 to 2010",
                 "change_lowinc_22_12" = "2010 to 2020"
                 ))) +
  # labs(title = "Population and Household Change in DC during 2012-2022",
  #      caption = "Source: Your Data Source") +
  theme_minimal() +
  theme(legend.position = "right")+
  guides(color = guide_legend(override.aes = list(size=5)))+
  theme(
    legend.position = "right",
    strip.text = element_text(size = 14, face = "bold")  # Increases facet title size and makes it bold
  )

#map of low income household loss
# lowinccat <- master7 %>% 
#   mutate(pctchange_12_22=(lowincome_2022-lowincome_2012_2020)/lowincome_2012_2020) %>%
#   mutate(lowinclosstype=ifelse(pctchange_12_22<=-0.1 & change_lowincome<(-6), "lowincomeloss", "notlowincomeloss")) %>%  
#   mutate(lowincgaintype=ifelse(pctchange_12_22>=0.1 , "lowincomegain", "notlowincomegain")) %>%
#   mutate(quintile_cutoffs_inc_2012= ntile(pct_lowincome_2012, 10)) %>% 
#   mutate(lowincomeexclusion=ifelse(quintile_cutoffs_inc_2012<2 & pctchange_12_22 <0.1, "lowincome exclusion", "notlowincomeexclusion")) %>% 
#   mutate(neighborhoodtype=case_when(lowinclosstype=="lowincomeloss" ~ "lowincomeloss",
#                                     lowincgaintype=="lowincomegain" ~ "lowincomegain",
#                                     lowincomeexclusion=="lowincome exclusion" & lowinclosstype=="notlowincomeloss" ~ "lowincome exclusion",
#                                     TRUE ~ "no change"))

lowinccat <- master7 %>% 
  mutate(pctchange_12_22=(lowincome_2022-lowincome_2012_2020)/lowincome_2012_2020) %>%
  mutate(quintile_cutoffs_inc_2012= ntile(pct_lowincome_2012, 10)) %>% 
  mutate(quintile_cutoffs_inc_2022= ntile(pct_lowincome_2022, 10)) %>% 
  mutate(lowincomeexclusion=ifelse(quintile_cutoffs_inc_2012<3 & quintile_cutoffs_inc_2022<3 , "lowincome exclusion", "notlowincomeexclusion")) %>%
  mutate(lowinclosstype=ifelse(pctchange_12_22<=-0.11 & change_lowincome<(-6), "lowincomeloss", "notlowincomeloss")) %>%
  mutate(lowincgaintype=ifelse(pctchange_12_22>=0.12 & pct_lowincome_2022>=pct_lowincome_2012, "lowincomegain", "notlowincomegain")) %>%
  mutate(neighborhoodtype=case_when(lowincomeexclusion=="lowincome exclusion" ~ "Exclusion of households with low incomes",
                                    lowinclosstype=="lowincomeloss" ~ "Loss of households with low incomes",
                                    lowincgaintype=="lowincomegain" ~ "Gain of households with low incomes",
                                    TRUE ~ "no change"))
  # mutate(neighborhoodtype=case_when(lowincomeexclusion=="lowincome exclusion" ~ "exclusion",
  #                                 TRUE ~ "no change"))
test <- lowinccat %>% 
  group_by(lowinclosstype,lowincgaintype,lowincomeexclusion ) %>% 
  count()

test2 <- lowinccat %>% 
  group_by(neighborhoodtype) %>% 
  count()

selected_vars <- c( "changelowinc12_22","changeunits_2022", "changeinhomevalue_2022", "changelowincome_2022","changeinblackhh_2022", "changeinwhitehh_2022",
                    "changeblkrenter_2022", "changeblkowner_2022", "pct_lowincome_2022","pctblkhh_2022","pctwhite_2022")

summary_by_type <-lowinccat %>% 
  mutate(changelowinc12_22= lowincome_2022-lowincome_2012_2020, 
         changeunits_2012=housing_2012_2020-housing_2000_2020,
         changerent_2012=pct_2022_low-pct_2000_low,
         changeunits_2022=housing_2022-housing_2012_2020,
         changerent_2022=pct_2022_low-pct_2012_low, 
         changeinhomevalue_2022=medianhome_2022-medianhome_2012_2020,
         changelowincome_2012=lowincome_2012_2020-lowincome_2000_2020,
         changelowincome_2022=lowincome_2022-lowincome_2012_2020,
         changeblack_2012=non_hispanic_black_pop_2012_2020-non_hispanic_black_pop_2000_2010_2020,
         changeblack_2022=non_hispanic_black_pop_2022-non_hispanic_black_pop_2012_2020,
         pct_renter_2022=renter_2022/(renter_2022+owner_2022),
         pct_renter_2012=renter_2012_2020/(renter_2012_2020+owner_2012_2020),
         changeinblackhh_2022=non_hispanic_black_hh_2022-non_hispanic_black_hh_2012_2020,
         changeblkrenter_2022=black_renter_2022-black_renter_2012_2020,
         changeblkowner_2022=black_owner_2022-black_owner_2012_2020,
         changeinwhitehh_2022= non_hispanic_white_hh_2022-non_hispanic_white_hh_2012_2020,
         pct_lowincome_2022=lowincome_2022/total_hh_2022,
         pctblkhh_2022=non_hispanic_black_hh_2022/total_hh_2022,
         pctwhite_2022=non_hispanic_white_hh_2022/total_hh_2022) %>% 
  group_by(neighborhoodtype) %>% 
  summarise(across(all_of(selected_vars), ~ mean(.x, na.rm = TRUE), .names = "{.col}_mean")) %>% 
  st_drop_geometry() 

housingvars <- c("medianhome_2022","changeinhomevalue","pctchangeinhomevalue","totalunits", "shareassisted","changeinunits", "pctchangeinunits",
                 "changeinassistedunits","pctchangeinassistedunits", "pctchangeinlowrent")

marketsummary_by_type <-lowinccat %>% 
  mutate(lowincchange=(lowincome_2022-lowincome_2000_2020)/lowincome_2000_2020,
         blkchange=(non_hispanic_black_pop_2022-non_hispanic_black_pop_2000_2010_2020)/non_hispanic_black_pop_2000_2010_2020) %>% 
  mutate(changeinhomevalue=medianhome_2022-medianhome_2000_2020,
         pctchangeinhomevalue=(medianhome_2022-medianhome_2000_2020)/medianhome_2000_2020) %>% 
  mutate(totalunits=housing_2022,,
         changeinunits=housing_2022-housing_2000_2020,
         pctchangeinunits=(housing_2022-housing_2000_2020)/housing_2000_2020) %>% 
  mutate(shareassisted=mid_asst_units_2022/totalunits,
         totalassisted=mid_asst_units_2022,
         changeinassistedunits=mid_asst_units_2022-mid_asst_units_2000,
         pctchangeinassistedunits=(mid_asst_units_2022-mid_asst_units_2000)/mid_asst_units_2000) %>% 
  mutate(pctchangeinlowrent=pct_2022_low-pct_2000_low) %>% 
  mutate(changeinowner=owner_2022-owner_2000_2020,
         pctchangeinowner=(owner_2022-owner_2000_2020)/owner_2000_2020) %>% 
  mutate(changeinrenter=renter_2022-renter_2000_2020,
         pctchangeinrenter=(renter_2022-renter_2000_2020)/renter_2000_2020) %>% 
  mutate(changeinblackrenter=black_renter_2022-black_renter_2000_2010_2020,
         pctchangeinblackrenter=(black_renter_2022-black_renter_2000_2010_2020)/black_renter_2000_2010_2020) %>% 
  mutate(changeinblackowner=black_owner_2022-black_owner_2000_2010_2020,
         pctchangeinblackowner=(black_owner_2022-black_owner_2000_2010_2020)/black_owner_2000_2010_2020,na.rm=TRUE) %>% 
  group_by(neighborhoodtype) %>% 
  summarise(across(all_of(housingvars), ~ mean(.x, na.rm = TRUE), .names = "{.col}_mean")) %>% 
  st_drop_geometry() 

write.csv(summary_by_type, "Clean/summary_by_type_Feb.csv")
write.csv(marketsummary_by_type, "Clean/marketsummary_by_type_Feb.csv")

maplowinccat <- lowinccat %>% 
  mutate(`neighborhood category` = factor(neighborhoodtype,
                                          levels = c("Loss of households with low incomes",
                                                     "Gain of households with low incomes",
                                                     "Exclusion of households with low incomes",
                                                     "no change"
                                          ))) %>% 
  filter(neighborhoodtype!="no change")

neighborhoodchangemap_DMPED <- lowinccat %>% 
  select(GEOID,Ward,NBH_NAMES,neighborhoodtype, lowincome_2022, lowincome_2012_2020, lowincome_2000_2020,non_hispanic_black_hh_2022,non_hispanic_black_hh_2012_2020,non_hispanic_black_hh_2000_2020,
  total_hh_2022, total_hh_2012_2020, total_hh_2000_2020,housing_2022,housing_2012_2020,housing_2000_2020 ) %>% 
  st_drop_geometry()

write.csv(neighborhoodchangemap_DMPED , "Clean/neighborhoodchange_DMPED.csv")


urban_colors4 <- c("#f5cbdf","#cfe8f3","#fce39e")


ggplot() +
  geom_sf(data = maplowinccat, aes(fill = `neighborhood category`)) +
  scale_fill_manual(name = "Neighborhood Change Type", values = urban_colors4, 
                    guide = guide_legend(override.aes = list(linetype = "blank", shape = NA))) + 
  geom_sf(data = water_sf, fill = "#dcdbdb", color = "#dcdbdb", size = 0.05) +
  geom_sf(data = tractboundary_20, fill = "transparent", color = "#adabac") +
  coord_sf(expand = FALSE) +  # Prevents extra padding
  labs(
    title = "Neighborhood Change in DC",
    subtitle = "Types by change in households with low-income",
    caption = "Source: Census 2000, ACS 5-year estimates 2008-2012, 2018-2022, Real Property Tax Database"
  ) +
  theme_void() +  # Ensures no background/grid elements
  theme(
    panel.border = element_blank(),    # Removes panel border
    panel.background = element_blank(), # Removes panel background
    plot.background = element_blank(),  # Ensures no gray background
    legend.background = element_blank() # Removes legend background
  )



displacement_tracts <- maplowinccat %>% 
  filter(neighborhoodtype=="Loss of households with low incomes")

neighbors <- lowinccat %>%
  filter(st_touches(geometry, st_union(displacement_tracts), sparse = FALSE)) %>% 
  select(GEOID) %>% 
  st_drop_geometry() %>% 
  mutate(type="neighbor")


#future displacement calculation
neighborhoodtype_Jan <- lowinccat %>% 
  select(GEOID, neighborhoodtype, NBH_NAMES) %>% 
  st_drop_geometry()

neighborhoodname <- read_csv("Clean/neighborhood_tract.csv")
lowincome <- read_csv("Clean/lowincome_pop.csv")
raceethnicity <- read_csv("Clean/race_ethnicity.csv")
vacancy <- read_csv("Clean/vacancy.csv") %>% 
  mutate(GEOID=geoid) %>% 
  select(GEOID, year, vacancyrate) %>% 
  filter(year==2012|year==2022) %>% 
  mutate(year=paste0("vacancy_", as.character(year))) %>% 
  spread(key=year,value=vacancyrate) 
distance <- read_csv("Clean/distance_downtown.csv")
lowincjobs <- read_csv("Clean/lowincome_jobs.csv")
HUDsubsidy <- read_csv("Clean/HUD_subsidy.csv")
college <- read_csv("Clean/college.csv")
newrentdata <- read_csv("Clean/rentvalue_cat.csv") %>% 
  mutate(GEOID=as.numeric(GEOID)) %>% 
  select(GEOID,starts_with("pct_"))
cityrentcompare <- read_csv("Clean/cityrentchange.csv") %>% 
  select(-...1)
assisted <- read_csv("Raw/PresCat/Assisted_units_by_year_tract_20241104.csv") %>% 
  mutate(GEOID=Geo2020) 

rentburden <- read_csv("Clean/rentburdenshare_22.csv") %>% 
  select(-...1)

#cityavenonassisted
nonincomerestricted <- assisted %>% 
  left_join(housingmarket, by=c("GEOID")) %>% 
  mutate(total=1) %>% 
  group_by(total) %>% 
  summarise(totalunits=sum(housing_2022),
            nonincomerestricted=sum(housing_2022-mid_asst_units_2022)) %>%
  mutate(sharenonincomerestricted_city=nonincomerestricted/totalunits) #	0.7575405

OTRtest <- OTR_sales %>% 
  filter(is.na(mprice_tot_2022)==TRUE
)

predictionmaster <-  neighborhoodtype_Jan %>% 
  left_join(housingmarket, by=c("GEOID")) %>% 
  left_join(OTR_sales, by=c("GEOID")) %>% 
  mutate(mprice_tot_2012=ifelse(GEOID==11001009602, 284900,mprice_tot_2012), #2013
         mprice_tot_2012=ifelse(GEOID==11001007401, 178250,mprice_tot_2012),#missing data impute withand 2011
         mprice_tot_2022=ifelse(is.na(mprice_tot_2022)==TRUE, mprice_tot_2021,mprice_tot_2022)) %>%  
  filter(is.na(mprice_tot_2022)==FALSE) %>% 
  left_join(lowincome, by=c("GEOID")) %>% 
  left_join(raceethnicity, by=c("GEOID")) %>% 
  left_join(distance, by=c("GEOID")) %>% 
  # left_join(vacancy, by=c("GEOID")) %>% 
  left_join(lowincjobs, by=c("GEOID")) %>% 
  left_join(HUDsubsidy, by=c("GEOID")) %>% 
  left_join(college, by=c("GEOID")) %>% 
  left_join(newrentdata, by=c("GEOID")) %>% 
  left_join(popbyrace, by=c("GEOID")) %>% 
  left_join(rentburden, by=c("GEOID")) %>% 
  left_join(assisted, by=c("GEOID")) %>% 
  mutate(mid_asst_units_2022=ifelse(is.na(mid_asst_units_2022)==TRUE,0,mid_asst_units_2022))%>% 
  left_join(cityrentcompare, by=c("GEOID")) %>% 
  #population vulnerabilities
  mutate(pct_black_2022=non_hispanic_black_hh_2022/total_hh_2022,
         pct_lowincome_2022=lowincome_2022/total_hh_2022,
         morethancityrentburden=ifelse(share_rentburdened>cityave_rentburden, 100,0)) %>% 
  mutate(
    quintile = ntile(pct_lowincome_2022, 5),  # Create quintiles
    qtilelowinc = case_when(
      quintile == 1 ~ 0,   # Lowest quintile
      quintile == 2 ~ 25,  # Second quintile
      quintile == 3 ~ 50,  # Middle quintile
      quintile == 4 ~ 75,  # Fourth quintile
      quintile == 5 ~ 100  # Top quintile
    )
  ) %>% 
  mutate(
    normalizedpctblack = (pct_black_2022 - min(pct_black_2022)) / (max(pct_black_2022) - min(pct_black_2022)) * 100,
    normalizedpctlowincome = (pct_lowincome_2022 - min(pct_lowincome_2022)) / (max(pct_lowincome_2022) - min(pct_lowincome_2022)) * 100
    ) %>% 
#housing conditions
  mutate(sharerental=renter_2022/housing_2022,
         sharenotincomerestricted=(housing_2022-mid_asst_units_2022)/housing_2022,
         morethancitysharerestricted=ifelse(sharenotincomerestricted>	0.7575405, 100,0)) %>% 
    mutate(
      quintile2 = ntile(sharerental, 5),  # Create quintiles
      qtilerental = case_when(
        quintile2 == 1 ~ 0,   # Lowest quintile
        quintile2 == 2 ~ 25,  # Second quintile
        quintile2 == 3 ~ 50,  # Middle quintile
        quintile2 == 4 ~ 75,  # Fourth quintile
        quintile2 == 5 ~ 100  # Top quintile
      )
    ) %>% 
    mutate(
      normalized_notrestricted = (sharenotincomerestricted - min(sharenotincomerestricted)) / (max(sharenotincomerestricted) - min(sharenotincomerestricted)) * 100
    ) %>% 
  #market pressures
  mutate(changeinrent=ifelse(changeinlowrenthh <citychangeinlowrent, 100,0),
         changeinhomeprice=mprice_tot_2022-mprice_tot_2012,
         changeincollege=ifelse(pct_college_2022-pct_college_2012_2020>0.1143038,100,0)) %>% 
    mutate(
      normalized_price = (changeinhomeprice - min(changeinhomeprice)) / (max(changeinhomeprice) - min(changeinhomeprice)) * 100
    ) %>% 
  left_join(neighbors,by=c("GEOID")) %>%
  mutate(adjacency=ifelse(type=="neighbor", 50, 0)) %>% 
  mutate(adjacency=ifelse(is.na(adjacency)==TRUE,0,adjacency)) %>% 
  select(GEOID,normalizedpctblack,qtilelowinc,morethancityrentburden,qtilerental,normalized_notrestricted,changeinrent,mprice_tot_2022,mprice_tot_2012,changeinhomeprice,normalized_price,changeincollege,adjacency,pct_lowincome_2022) %>% 
    mutate(population_vulnerability=(normalizedpctblack+qtilelowinc+morethancityrentburden)/3) %>% 
    mutate(housing_condition=(qtilerental+normalized_notrestricted)/2) %>% 
    mutate(market_pressure=(changeinrent+normalized_price+changeincollege+adjacency)/4) %>%
    mutate(displacement_risk=population_vulnerability*(housing_condition+market_pressure)) %>%
    mutate(quintile3 = ntile(population_vulnerability, 5),  # Create quintiles
           population_vulnerability_cat = case_when(
                 quintile3 == 1 ~ "Lowest risk",   # Lowest quintile
                 quintile3 == 2 ~ "Lower risk",  # Second quintile
                 quintile3 == 3 ~ "Intermediate risk",  # Middle quintile
                 quintile3 == 4 ~ "Higher risk",  # Fourth quintile
                 quintile3 == 5 ~ "Highest risk"  # Top quintile
               )
             ) %>% 
    mutate(quintile4 = ntile(housing_condition, 5),  # Create quintiles
           housing_condition_cat = case_when(
             quintile3 == 1 ~ "Lowest risk",   # Lowest quintile
             quintile3 == 2 ~ "Lower risk",  # Second quintile
             quintile3 == 3 ~ "Intermediate risk",  # Middle quintile
             quintile3 == 4 ~ "Higher risk",  # Fourth quintile
             quintile3 == 5 ~ "Highest risk"  # Top quintile
               )
             ) %>%
    mutate(quintile5 = ntile(market_pressure, 5),  # Create quintiles
           market_pressure_cat = case_when(
             quintile3 == 1 ~ "Lowest risk",   # Lowest quintile
             quintile3 == 2 ~ "Lower risk",  # Second quintile
             quintile3 == 3 ~ "Intermediate risk",  # Middle quintile
             quintile3 == 4 ~ "Higher risk",  # Fourth quintile
             quintile3 == 5 ~ "Highest risk"  # Top quintile
               )
             ) %>%
    mutate(quintile6 = ntile(displacement_risk, 5),  # Create quintiles
           displacement_cat=case_when(
             quintile3 == 1 ~ "Lowest risk",   # Lowest quintile
             quintile3 == 2 ~ "Lower risk",  # Second quintile
             quintile3 == 3 ~ "Intermediate risk",  # Middle quintile
             quintile3 == 4 ~ "Higher risk",  # Fourth quintile
             quintile3 == 5 ~ "Highest risk"  # Top quintile
               )
             )


mapdisplacement <- predictionmaster %>% 
  mutate(GEOID=as.character(GEOID)) %>% 
  left_join(tractboundary_20, by=c("GEOID")) %>% 
  st_as_sf() %>% 
  mutate(`population vulnerability` = factor(population_vulnerability_cat,
                                          levels = c("Lowest risk",
                                                     "Lower risk",
                                                     "Intermediate risk",
                                                     "Higher risk",
                                                     "Highest risk"
                                          ))) %>% 
  mutate(`housing condition` = factor(housing_condition_cat,
                                      levels = c("Lowest risk",
                                                 "Lower risk",
                                                 "Intermediate risk",
                                                 "Higher risk",
                                                 "Highest risk"
                                             ))) %>% 
  mutate(`market pressure` = factor(market_pressure_cat,
                                    levels = c("Lowest risk",
                                               "Lower risk",
                                               "Intermediate risk",
                                               "Higher risk",
                                               "Highest risk"
                                      ))) 
  

urban_vulnerable <- c("#f5f5f5","#cfe8f3","#a2d4ec","#1696d2","#0a4c6a")
urban_housing <- c("#f5f5f5","#dcedd9","#bcdeb4","#55b748","#2c5c2d")
urban_market <- c("#f5f5f5","#fff2cf","#fce39e","#fccb41","#ca5800")
urban_displacement <- c("#f5f5f5","#fff2cf","#f5cbdf","#e54096","#af1f6b")

mapdisplacement_DMPED <- mapdisplacement %>% 
  mutate(GEOID=as.numeric(GEOID)) %>%
  select(GEOID,population_vulnerability_cat, housing_condition_cat, market_pressure_cat, displacement_cat) %>% 
  full_join(neighborhoodchangemap_DMPED, by=c("GEOID")) %>%
  # st_drop_geometry() %>% 
  select(GEOID,Ward, NBH_NAMES,neighborhoodtype, population_vulnerability_cat, housing_condition_cat, market_pressure_cat, displacement_cat,lowincome_2022, lowincome_2012_2020, lowincome_2000_2020,non_hispanic_black_hh_2022,non_hispanic_black_hh_2012_2020,non_hispanic_black_hh_2000_2020,
         total_hh_2022, total_hh_2012_2020, total_hh_2000_2020,housing_2022,housing_2012_2020,housing_2000_2020 ) %>% 
  mutate(across(where(is.numeric), round))

write.csv(mapdisplacement_DMPED, "Clean/NeighborhoodTypes_DMPED.csv")
st_write(mapdisplacement_DMPED, "Clean/NeighborhoodTypes_DMPED.shp", append = FALSE)

ggplot() +
  geom_sf(data =mapdisplacement, aes( fill = `population vulnerability`))+
  scale_fill_manual(name="Population Vulnerabilities", values = urban_displacement, guide = guide_legend(override.aes = list(linetype = "blank", 
                                                                                                                           shape = NA)))+ 
  geom_sf(water_sf, mapping=aes(), fill="#dcdbdb", color="#dcdbdb", size=0.05)+
  coord_sf(datum = NA)+
  guides(color = guide_legend(override.aes = list(size=5)))+
  geom_sf(data = tractboundary_20, fill = "transparent", color="#adabac")+
  coord_sf(datum = NA)+
  # geom_sf(data = displacementarea, fill = "transparent", color="#ec008b")+
  # coord_sf(datum = NA)+
  labs(title = paste0("Future Displacement Risk"),
       subtitle= "Population Vulnerabilities",
       caption = "Source: ACS 5-year estimates 2008-2012, 2018-2022")


ggplot() +
  geom_sf(data =mapdisplacement, aes( fill = `housing condition`))+
  scale_fill_manual(name="Housing Stock", values = urban_housing, guide = guide_legend(override.aes = list(linetype = "blank", 
                                                                                                               shape = NA)))+ 
  geom_sf(water_sf, mapping=aes(), fill="#dcdbdb", color="#dcdbdb", size=0.05)+
  coord_sf(datum = NA)+
  guides(color = guide_legend(override.aes = list(size=5)))+
  geom_sf(data = tractboundary_20, fill = "transparent", color="#adabac")+
  coord_sf(datum = NA)+
  # geom_sf(data = displacementarea, fill = "transparent", color="#ec008b")+
  # coord_sf(datum = NA)+
  labs(title = paste0("Future Displacement Risks"),
       subtitle= "Housing Stock",
       caption = "Source: ACS 5-year estimates 2018-2022,DC Preservation Catalog")


ggplot() +
  geom_sf(data =mapdisplacement, aes( fill = `market pressure`))+
  scale_fill_manual(name="Market Pressures", values = urban_market, guide = guide_legend(override.aes = list(linetype = "blank", 
                                                                                                               shape = NA)))+ 
  geom_sf(water_sf, mapping=aes(), fill="#dcdbdb", color="#dcdbdb", size=0.05)+
  coord_sf(datum = NA)+
  guides(color = guide_legend(override.aes = list(size=5)))+
  geom_sf(data = tractboundary_20, fill = "transparent", color="#adabac")+
  coord_sf(datum = NA)+
  # geom_sf(data = displacementarea, fill = "transparent", color="#ec008b")+
  # coord_sf(datum = NA)+
  labs(title = paste0("Future Displacement Risks"),
       subtitle= "Market Pressures",
       caption = "Source: ACS 5-year estimates 2008-2012,2018-2022,DC Office of Tax and Revenue ")


#need to remove the bottom 20 percent tracts in terms of low income household from the overall risk map
overallriskmap <- mapdisplacement %>% 
  mutate(quintile_lowinc = ntile(pct_lowincome_2022, 5)) %>% 
  mutate(displacement_cat=ifelse(quintile_lowinc==1, "Lower risk",displacement_cat)) %>% 
  mutate(`displacement risk` = factor(displacement_cat,
                                      levels = c("Lowest risk",
                                                 "Lower risk",
                                                 "Intermediate risk",
                                                 "Higher risk",
                                                 "Highest risk"
                                      ))) 

ggplot() +
  geom_sf(data =overallriskmap, aes( fill = `displacement risk`))+
  scale_fill_manual(name="Overall displacement risk", values = urban_displacement, guide = guide_legend(override.aes = list(linetype = "blank", 
                                                                                                              shape = NA)))+ 
  geom_sf(water_sf, mapping=aes(), fill="#dcdbdb", color="#dcdbdb", size=0.05)+
  coord_sf(datum = NA)+
  guides(color = guide_legend(override.aes = list(size=5)))+
  geom_sf(data = tractboundary_20, fill = "transparent", color="#adabac")+
  coord_sf(datum = NA)+
  # geom_sf(data = displacementarea, fill = "transparent", color="#ec008b")+
  # coord_sf(datum = NA)+
  labs(title = paste0("Future Displacement Risk"),
       subtitle= "Displacement risk based on population vulnerabilities, housing conditions, and market pressure",
       caption = "Source: ACS 5-year estimates 2008-2012,2018-2022,DC Office of Tax and Revenue ")


ggplot() +
  geom_sf(data = overallriskmap, aes(fill = `displacement risk`)) +
  scale_fill_manual(
    name = "Overall displacement risk", 
    values = urban_displacement, 
    guide = guide_legend(
      override.aes = list(linetype = "blank", shape = NA)
    )
  ) + 
  geom_sf(data = water_sf, mapping = aes(), fill = "#dcdbdb", color = "#dcdbdb", size = 0.05) +
  geom_sf(data = tractboundary_20, fill = "transparent", color = "#adabac") +
  coord_sf(datum = NA) +
  # geom_sf(data = displacementarea, fill = "transparent", color = "#ec008b") +
  labs(
    title = paste0("Future Displacement Risk"),
    subtitle = "Displacement risk based on population vulnerabilities, housing conditions, and market pressure",
    caption = "Source: ACS 5-year estimates 2008-2012,2018-2022,DC Office of Tax and Revenue "
  ) +
  theme(
    legend.position = "right",
    legend.title = element_text(size = 10),
    legend.text = element_text(size = 9)
  )

library(urbnthemes)

set_urbn_defaults(style = "print")
set_urbn_defaults(style = "print")
# Create scatter plot
library(urbnthemes)
ggplot() +
  geom_sf(data = overallriskmap, aes(fill = `displacement risk`)) +
  scale_fill_manual(
    name = "Overall displacement risk", 
    values = urban_displacement, 
    guide = guide_legend(
      override.aes = list(linetype = "blank", shape = NA)
    )
  ) + 
  geom_sf(data = water_sf, mapping = aes(), fill = "#dcdbdb", color = "#dcdbdb", size = 0.05) +
  geom_sf(data = tractboundary_20, fill = "transparent", color = "#adabac") +
  coord_sf(datum = NA) +
  # geom_sf(data = displacementarea, fill = "transparent", color = "#ec008b") +
  labs(
    title = paste0("Future Displacement Risk"),
    subtitle = "Displacement risk based on population vulnerabilities, housing conditions, and market pressure",
    caption = "Source: ACS 5-year estimates 2008-2012,2018-2022,DC Office of Tax and Revenue "
  ) +
  theme(
    legend.position = "right",
    legend.direction = "vertical",
    legend.title = element_text(size = 10),
    legend.text = element_text(size = 9)
  ) +
  guides(fill = guide_legend(
    title = "Overall displacement risk",
    override.aes = list(linetype = "blank", shape = NA),
    ncol = 1
  ))