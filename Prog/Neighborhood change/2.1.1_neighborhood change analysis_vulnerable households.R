# displacement population methodology tests


# tracts that have lost more than 10 percent of vulnerable hh during 2000-2022
#65 tracts 2000-2022 83 2012-2022
method1 <-  map_file %>% 
  # select(GEOID,lowincome_2000_2020,lowincome_2012_2020,lowincome_2022, total_hh_2000_2020, total_hh_2012_2020,total_hh_2022,NBH_NAMES) %>% 
  mutate(pct_lowincome_2000=lowincome_2000_2020/total_hh_2000_2020,
         pct_lowincome_2012=lowincome_2012_2020/total_hh_2012_2020,
         pct_lowincome_2022=lowincome_2022/total_hh_2022) %>% 
  # select(GEOID, NBH_NAMES, total_hh_2022, pct_lowincome_2000, pct_lowincome_2012,pct_lowincome_2022,lowincome_2022,lowincome_2012_2020) %>% 
  mutate(pctchg_lowincome=pct_lowincome_2022-pct_lowincome_2012,
         change_lowincome=lowincome_2022-lowincome_2012_2020) %>% 
  mutate(pctchange_2012_2022=(lowincome_2022-lowincome_2012_2020)/lowincome_2012_2020 ) %>% 
  # st_centroid() %>% 
  filter(pctchange_2012_2022<(-0.05)) %>% 
  select(GEOID,NBH_NAMES,lowincome_2000_2020,lowincome_2012_2020,lowincome_2022, total_hh_2000_2020, total_hh_2012_2020,total_hh_2022,pctchange_2000_2022)
  # mutate(quintile_2000=cut(medianhome_2000_2020,5, label = FALSE),
  #        quintile_2012=cut(medianhome_2012_2020,5, label = FALSE),
  #        quintile_2022=cut(medianhome_2022,5, label = FALSE)) %>% 

# tracts that have lost more than 10 percent of vulnerable hh during 2012-2022
#83 tracts
method2 <-  map_file %>% 
  # select(GEOID,lowincome_2000_2020,lowincome_2012_2020,lowincome_2022, total_hh_2000_2020, total_hh_2012_2020,total_hh_2022,NBH_NAMES) %>% 
  mutate(pct_lowincome_2000=lowincome_2000_2020/total_hh_2000_2020,
         pct_lowincome_2012=lowincome_2012_2020/total_hh_2012_2020,
         pct_lowincome_2022=lowincome_2022/total_hh_2022) %>% 
  # select(GEOID, NBH_NAMES, total_hh_2022, pct_lowincome_2000, pct_lowincome_2012,pct_lowincome_2022,lowincome_2022,lowincome_2012_2020) %>% 
  mutate(pctchg_lowincome=pct_lowincome_2022-pct_lowincome_2012,
         change_lowincome=lowincome_2022-lowincome_2012_2020) %>% 
  mutate(pctchange_2012_2022=(lowincome_2022-lowincome_2012_2020)/lowincome_2012_2020 ) %>% 
  # st_centroid() %>% 
  filter(pctchange_2012_2022>0.1) %>% 
  select(GEOID,NBH_NAMES,lowincome_2000_2020,lowincome_2012_2020,lowincome_2022, total_hh_2000_2020, total_hh_2012_2020,total_hh_2022,pctchange_2012_2022)
# mutate(quintile_2000=cut(medianhome_2000_2020,5, label = FALSE),
#        quintile_2012=cut(medianhome_2012_2020,5, label = FALSE),
#        quintile_2022=cut(medianhome_2022,5, label = FALSE)) %>% 

# top 20 percentile of tracst that have lost the greated number of low inome

#41 tracts
method3 <-  map_file %>% 
  # select(GEOID,lowincome_2000_2020,lowincome_2012_2020,lowincome_2022, total_hh_2000_2020, total_hh_2012_2020,total_hh_2022,NBH_NAMES) %>% 
  mutate(pct_lowincome_2000=lowincome_2000_2020/total_hh_2000_2020,
         pct_lowincome_2012=lowincome_2012_2020/total_hh_2012_2020,
         pct_lowincome_2022=lowincome_2022/total_hh_2022) %>% 
  # select(GEOID, NBH_NAMES, total_hh_2022, pct_lowincome_2000, pct_lowincome_2012,pct_lowincome_2022,lowincome_2022,lowincome_2012_2020) %>% 
  mutate(pctchg_lowincome=pct_lowincome_2022-pct_lowincome_2012,
         change_lowincome=lowincome_2022-lowincome_2012_2020) %>% 
  mutate(pctchange_2012_2022=(lowincome_2022-lowincome_2012_2020)/lowincome_2012_2020 ) %>% 
  # st_centroid() %>% 
  # filter(pctchange_2000_2022>0.1) %>% 
  mutate(vulnerable_top20percent_2012_2022=ntile( change_lowincome,10)) %>% 
  filter(vulnerable_top20percent_2012_2022==1) %>% 
  select(GEOID,NBH_NAMES,vulnerable_top20percent_2012_2022,lowincome_2000_2020,lowincome_2012_2020,lowincome_2022, total_hh_2000_2020, total_hh_2012_2020,total_hh_2022,pctchange_2012_2022)


# top 20 percentile of tracts that have lost the greatest percentage of vulnerable hh 2012-2022
#41 tracts
method4 <-  map_file %>% 
  # select(GEOID,lowincome_2000_2020,lowincome_2012_2020,lowincome_2022, total_hh_2000_2020, total_hh_2012_2020,total_hh_2022,NBH_NAMES) %>% 
  mutate(pct_lowincome_2000=lowincome_2000_2020/total_hh_2000_2020,
         pct_lowincome_2012=lowincome_2012_2020/total_hh_2012_2020,
         pct_lowincome_2022=lowincome_2022/total_hh_2022) %>% 
  # select(GEOID, NBH_NAMES, total_hh_2022, pct_lowincome_2000, pct_lowincome_2012,pct_lowincome_2022,lowincome_2022,lowincome_2012_2020) %>% 
  mutate(pctchg_lowincome=pct_lowincome_2022-pct_lowincome_2012,
         change_lowincome=lowincome_2022-lowincome_2012_2020) %>% 
  mutate(pctchange_2012_2022=(lowincome_2022-lowincome_2012_2020)/lowincome_2012_2020 ) %>% 
  # st_centroid() %>% 
  # filter(pctchange_2000_2022>0.1) %>% 
  mutate(vulnerable_top20percent_2012_2022=ntile(pctchange_2012_2022,5)) %>% 
  filter(vulnerable_top20percent_2012_2022==1) %>% 
  select(GEOID,NBH_NAMES,vulnerable_top20percent_2012_2022,lowincome_2000_2020,lowincome_2012_2020,lowincome_2022, total_hh_2000_2020, total_hh_2012_2020,total_hh_2022,pctchange_2012_2022)


# tract that lost more than median number of vulnerable hh
#100 tracts
medianchange_2012_2022 <- map_file %>% 
  # select(GEOID,lowincome_2000_2020,lowincome_2012_2020,lowincome_2022, total_hh_2000_2020, total_hh_2012_2020,total_hh_2022,NBH_NAMES) %>% 
  mutate(change_lowincome=lowincome_2022-lowincome_2012_2020) %>% 
  mutate(total="total") %>% 
  group_by(total) %>% 
  summarize(median=median(change_lowincome)) #10.59687

method5 <-  map_file %>% 
  mutate(
         change_lowincome=lowincome_2022-lowincome_2012_2020) %>% 
  filter(change_lowincome>10.59687) %>% 
  select(GEOID,NBH_NAMES,lowincome_2000_2020,lowincome_2012_2020,lowincome_2022, total_hh_2000_2020, total_hh_2012_2020,total_hh_2022,pctchange_2000_2022)
# mutate(quintile_2000=cut(medianhome_2000_2020,5, label = FALSE),
#        quintile_2012=cut(medianhome_2012_2020,5, label = FALSE),
#        quintile_2022=cut(medianhome_2022,5, label = FALSE)) %>% 

  
changeinblack <- map_file %>% 
  # select(GEOID,non_hispanic_black_hh_2000_2020,non_hispanic_black_hh_2012_2020,non_hispanic_black_hh_2022, total_hh_2000_2020, total_hh_2012_2020,total_hh_2022,NBH_NAMES) %>% 
  mutate(pct_black_2000=non_hispanic_black_hh_2000_2020/total_hh_2000_2020,
         pct_black_2012=non_hispanic_black_hh_2012_2020/total_hh_2012_2020,
         pct_black_2022=non_hispanic_black_hh_2022/total_hh_2022) %>% 
  # select(GEOID, NBH_NAMES, total_hh_2022, pct_black_2000, pct_black_2012,pct_black_2022) %>% 
  mutate(changeinblack_12_22=pct_black_2022-pct_black_2012,
         changeinblack_00_22=pct_black_2022-pct_black_2000 ) %>% 
  # filter(changeinblack_12_22<0) %>%  #152 tracts have less than 0 value 2012-2022
  # filter(changeinblack_00_22 <0) %>%  #168 tracts have less than 0 value 2012-2022
  mutate(quintile_12_22=ntile(changeinblack_12_22,5),
         quintile_00_22=ntile(changeinblack_00_22,5)) %>% 
  select(GEOID, NBH_NAMES,quintile_12_22,changeinblack_12_22,total_hh_2022, pct_black_2000, pct_black_2012,pct_black_2022 ) %>% 
  filter(quintile_12_22==1) #51 tracts 

changeinblack2 <- map_file %>% 
  # select(GEOID,non_hispanic_black_hh_2000_2020,non_hispanic_black_hh_2012_2020,non_hispanic_black_hh_2022, total_hh_2000_2020, total_hh_2012_2020,total_hh_2022,NBH_NAMES) %>% 
  mutate(pct_black_2000=non_hispanic_black_hh_2000_2020/total_hh_2000_2020,
         pct_black_2012=non_hispanic_black_hh_2012_2020/total_hh_2012_2020,
         pct_black_2022=non_hispanic_black_hh_2022/total_hh_2022) %>% 
  # select(GEOID, NBH_NAMES, total_hh_2022, pct_black_2000, pct_black_2012,pct_black_2022) %>% 
  mutate(changeinblack_12_22=(non_hispanic_black_hh_2022-non_hispanic_black_hh_2012_2020)/non_hispanic_black_hh_2012_2020,
         changeinblack_00_22=pct_black_2022-pct_black_2000 ) %>% 
  # filter(changeinblack_12_22<0) %>%  #152 tracts have less than 0 value 2012-2022
  # filter(changeinblack_00_22 <0) %>%  #168 tracts have less than 0 value 2012-2022
  mutate(quintile_12_22=ntile(changeinblack_12_22,5),
         quintile_00_22=ntile(changeinblack_00_22,5)) %>% 
  select(GEOID, NBH_NAMES,quintile_12_22,changeinblack_12_22,total_hh_2022, pct_black_2000, pct_black_2012,pct_black_2022 ) %>% 
  # filter(quintile_12_22==1) #51 tracts 
  filter(changeinblack_12_22<(-0.05))

