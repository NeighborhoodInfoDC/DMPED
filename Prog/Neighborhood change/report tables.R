
selected_vars <- c("total_hh_2022", "total_hh_2012_2020", "total_hh_2000_2020","total_pop_2022","lowincome_2000_2020","lowincome_2012_2020","lowincome_2022",
                   "non_hispanic_black_pop_2000_2010_2020","non_hispanic_black_pop_2012_2020","non_hispanic_black_pop_2022")

table <- analysismaster %>% 
  mutate(total_pop_2022=hispanic_or_latino_pop_2022+non_hispanic_black_pop_2022+non_hispanic_aapi_pop_2022+non_hispanic_black_pop_2022+non_hispanic_other_pop_2022+non_hispanic_white_pop_2022) %>% 
  # select(GEOID, total_hh_2022,total_pop_2022, lowincome_2000_2020,lowincome_2012_2020,lowincome_2022,non_hispanic_black_pop_2000_2010_2020,non_hispanic_black_pop_2012_2020,non_hispanic_black_pop_2022) %>% 
  mutate(total="total") %>% 
  st_drop_geometry() %>% 
  group_by(total) %>% 
  summarise(across(all_of(selected_vars), ~ sum(.x, na.rm = TRUE), .names = "{.col}")) 

map_report1 <- merge(analysismaster,tractboundary_20, by=c("GEOID")) %>% 
    mutate(change_black=non_hispanic_black_pop_2022-non_hispanic_black_pop_2012_2020,
           change_lowinc=total_hh_2022-total_hh_2012_2020) %>% 
  select(GEOID, geometry,change_black,change_lowinc ) %>% 
  pivot_longer(cols = c(change_black, change_lowinc),
               names_to = "variable", values_to = "value") %>% 
  st_as_sf() 

map_report2 <- merge(analysismaster,tractboundary_20, by=c("GEOID")) %>% 
  mutate(change_black=non_hispanic_black_pop_2012_2020-non_hispanic_black_pop_2000_2010_2020,
         change_lowinc=total_hh_2012_2020-total_hh_2000_2020) %>% 
  select(GEOID, geometry,change_black,change_lowinc ) %>% 
  pivot_longer(cols = c(change_black, change_lowinc),
               names_to = "variable", values_to = "value") %>% 
  st_as_sf() 


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
ggplot(tracts) +
  geom_sf(aes(fill = population_change), color = NA) +  # Color by population change
  scale_fill_gradient2(low = "red", mid = "white", high = "blue", midpoint = 0, 
                       name = "Population Change") +
  labs(title = "Population Change by Census Tract (Past 20 Years)",
       caption = "Source: Your Data Source") +
  theme_minimal() +
  theme(legend.position = "right")
  
neighborhoodtype <- master6 %>% 
  mutate(count=1) %>% 
  group_by(neighborhoodtype) %>% 
  summarise(totaltract=sum(count),
            totalhh=sum(total_hh_2022)) %>% 
  st_drop_geometry()


selected_vars <- c("medianhome_2022","changeinhomevalue", "lowincchange","blkchange","pctlowincchange","pctblkchange","pctchangeinhomevalue","totalunits", "shareassisted","changeinunits", "pctchangeinunits",
                   "changeinassistedunits","pctchangeinassistedunits", "pctchangeinlowrent","changeinowner","pctchangeinowner","changeinrenter","pctchangeinrenter",
                   "changeinblackrenter","pctchangeinblackrenter","changeinblackowner","pctchangeinblackowner")

summary_by_type <- master6 %>% 
  mutate(lowincchange=lowincome_2022-lowincome_2000_2020,
         blkchange=non_hispanic_black_pop_2022-non_hispanic_black_pop_2000_2010_2020,
         pctlowincchange=(lowincome_2022-lowincome_2000_2020)/lowincome_2000_2020,
         pctblkchange=(non_hispanic_black_pop_2022-non_hispanic_black_pop_2000_2010_2020)/non_hispanic_black_pop_2000_2010_2020) %>% 
  mutate(changeinhomevalue=medianhome_2022-medianhome_2000_2020,
         pctchangeinhomevalue=(medianhome_2022-medianhome_2000_2020)/medianhome_2000_2020) %>% 
  mutate(totalunits=housing_2022,
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
  summarise(across(all_of(selected_vars), ~ mean(.x, na.rm = TRUE), .names = "{.col}_mean")) %>% 
  st_drop_geometry() 

selected_vars <- c("shareassisted",
                   "changeinassistedunits","pctchangeinassistedunits"
                  )

test <- master6 %>% 
  mutate(change=mid_asst_units_2022-mid_asst_units_2000) %>% 
  # select(GEOID, change, mid_asst_units_2000,mid_asst_units_2022) %>% 
  mutate(nochange0=ifelse(mid_asst_units_2000==0 & mid_asst_units_2022==0,1,0)) %>% 
  filter(nochange0==0) %>% 
  mutate(mid_asst_units_2000=ifelse(mid_asst_units_2000==0,1,mid_asst_units_2000)) %>% 
  # right_join(master6, by=c("GEOID")) %>% 
  mutate(shareassisted=mid_asst_units_2022/housing_2022,
         totalassisted=mid_asst_units_2022,
         changeinassistedunits=mid_asst_units_2022-mid_asst_units_2000,
         pctchangeinassistedunits=(mid_asst_units_2022-mid_asst_units_2000)/mid_asst_units_2000) %>% 
  # filter(neighborhoodtype=="stable growing") %>% 
  # select(GEOID, change, mid_asst_units_2000,mid_asst_units_2022) %>%
  group_by(neighborhoodtype) %>% 
  summarise(across(all_of(selected_vars), ~ mean(.x, na.rm = TRUE), .names = "{.col}_mean")) %>% 
  st_drop_geometry() 

stabel <- master6 %>% 
  filter(neighborhoodtype=="stable growing") %>% 
  select(GEOID) %>% 
  left_join(test,by=c("GEOID"))

#investigate east of river trend and confirm prediction results
testeast <-  master6 %>%
  mutate(lowincchange=lowincome_2022-lowincome_2000_2020,
         blkchange=non_hispanic_black_pop_2022-non_hispanic_black_pop_2000_2010_2020,
         pctlowincchange=(lowincome_2022-lowincome_2000_2020)/lowincome_2000_2020,
         pctblkchange=(non_hispanic_black_pop_2022-non_hispanic_black_pop_2000_2010_2020)/non_hispanic_black_pop_2000_2010_2020) %>% 
  