
master4 <- map_file %>% 
  mutate(rent_2000_2020=ifelse(rent_2000_2020==0, NA, rent_2000_2020),
         rent_2012_2020=ifelse(rent_2012_2020==0, NA, rent_2012_2020)) %>% 
  # filter(GEOID !="11001004100") %>% 
  mutate(quintile_2000=ntile(rent_2000_2020,5),
         quintile_2012=ntile(rent_2012_2020,5),
         quintile_2022=ntile(rent_2022,5)) %>% 
  # rbind(outlier) %>% 
  mutate(homevaluecat_2000=case_when(quintile_2000==1|quintile_2000==2 ~ "low",
                                     quintile_2000==3 ~ "moderate",
                                     quintile_2000==4|quintile_2000==5 ~ "high"),
         homevaluecat_2012=case_when(quintile_2012==1|quintile_2012==2 ~ "low",
                                     quintile_2012==3 ~ "moderate",
                                     quintile_2012==4|quintile_2012==5 ~ "high"),
         homevaluecat_2022=case_when(quintile_2022==1|quintile_2022==2 ~ "low",
                                     quintile_2022==3 ~ "moderate",
                                     quintile_2022==4|quintile_2022==5 ~ "high")) %>% 
  mutate(nominal_00_12=rent_2012_2020-rent_2000_2020*1.336,
         nominal_12_22=rent_2022-rent_2012_2020*1.227,
         nominal_00_22=rent_2022-rent_2000_2020*1.64) %>%  #based on sas macro dollar adjust, using less shelter series
  # select(GEOID,total_hh_2022,medianhome_2000_2020,medianhome_2012_2020,medianhome_2022, quintile_2000,homevaluecat_2000, homevaluecat_2012,homevaluecat_2022, nominal_00_12, nominal_00_22,nominal_12_22,NBH_NAMES) %>% 
  # mutate(housing_market=case_when(homevaluecat_2000 %in% c("low", "moderate") & homevaluecat_2022 %in% c("moderate","high")~ "growing",
  #                                 homevaluecat_2000 %in% c("high", "moderate") & homevaluecat_2022 %in% c("moderate","low")~ "declining",
  #                                 homevaluecat_2000 %in% c("high") & homevaluecat_2022 %in% c("high")~ "established",
  #                                 homevaluecat_2000 %in% c("low") & homevaluecat_2022 %in% c("low")~ "stagnant",
  #                                 TRUE ~ "other (might be dynamic)" )) %>% 
  mutate(pct_lowincome_2000=lowincome_2000_2020/total_hh_2000_2020,
         pct_lowincome_2012=lowincome_2012_2020/total_hh_2012_2020,
         pct_lowincome_2022=lowincome_2022/total_hh_2022) %>% 
  # select(GEOID, NBH_NAMES, total_hh_2022, pct_lowincome_2000, pct_lowincome_2012,pct_lowincome_2022,lowincome_2022,lowincome_2012_2020) %>% 
  mutate(pctchg_lowincome=pct_lowincome_2022-pct_lowincome_2012,
         change_lowincome=lowincome_2022-lowincome_2012_2020) %>% 
  mutate(pctchange_2012_2022=(lowincome_2022-lowincome_2012_2020)/lowincome_2012_2020) %>% 
  mutate(lowinc_2012_2022=ifelse(pctchange_2012_2022<=-0.1, "lowincomeloss", "notlowincomeloss")) %>% 
  mutate(pct_black_2000=non_hispanic_black_hh_2000_2020/total_hh_2000_2020,
         pct_black_2012=non_hispanic_black_hh_2012_2020/total_hh_2012_2020,
         pct_black_2022=non_hispanic_black_hh_2022/total_hh_2022) %>% 
  # select(GEOID, NBH_NAMES, total_hh_2022, pct_black_2000, pct_black_2012,pct_black_2022) %>% 
  mutate(pctchange_2012_2022_blk=(non_hispanic_black_hh_2022-non_hispanic_black_hh_2012_2020)/ non_hispanic_black_hh_2012_2020) %>% 
  mutate(lossblk_2012_2022=ifelse(pctchange_2012_2022_blk<=-0.1, "blackloss", "notblackloss")) %>% 
  mutate(vulnerable=ifelse(lossblk_2012_2022=="notblackloss"&lowinc_2012_2022=="notlowincomeloss", "nolossvulnerable", "lossvulnerable")) %>% 
  mutate(lowmod_housing_2000=ifelse(homevaluecat_2000=="low"|homevaluecat_2000=="moderate", "yes", "no")) %>% 
  mutate(overallincreasevalue_2012_2022=case_when(nominal_12_22>0 & homevaluecat_2022=="moderate"~"yes",
                                                  nominal_12_22>0 & homevaluecat_2022=="high"~"yes",
                                                  TRUE ~ "no")) %>% 
  mutate(overalldecreasevalue_2012_2022=case_when(nominal_12_22<0 & homevaluecat_2022=="low" ~"yes",
                                                  nominal_12_22<0 & homevaluecat_2022=="moderaete"~"yes",
                                                  TRUE ~ "no")) %>% 
  mutate(continuedhigh=ifelse(homevaluecat_2000=="high" & homevaluecat_2012=="high" & homevaluecat_2022=="high", "yes", "no")) %>% 
  mutate(continuedlow= ifelse(homevaluecat_2000=="low" & homevaluecat_2012=="low" & homevaluecat_2022=="low", "yes", "no")) %>% 
  mutate(neighborhoodtype=case_when(lowmod_housing_2000=="yes" & overallincreasevalue_2012_2022=="yes" & vulnerable=="nolossvulnerable" ~ "stable growing",
                                    lowmod_housing_2000=="yes" & overallincreasevalue_2012_2022=="yes" & vulnerable=="lossvulnerable" ~ "exlusive growth with displacement risk",
                                    lowmod_housing_2000=="no" & overalldecreasevalue_2012_2022=="yes" ~ "decreasing neighborhood",
                                    continuedhigh=="yes" & vulnerable=="lossvulnerable" ~ "established opportunity with displacement risk",
                                    continuedhigh=="yes" & vulnerable=="nolossvulnerable" ~ "established opportunity",
                                    TRUE~ "stagnant or dynamic")) %>% 
  mutate(`neighborhood category` = factor(neighborhoodtype,
                                          levels = c("stable growing",
                                                     "exlusive growth with displacement risk",
                                                     "decreasing neighborhood",
                                                     "established opportunity",
                                                     "established opportunity with displacement risk",
                                                     "stagnant or dynamic"
                                          )))


displacementarea <- master4 %>% 
  filter(neighborhoodtype=="exlusive growth with displacement risk"|neighborhoodtype=="established opportunity with displacement risk")

urban_colors6 <- c("#73bfe2", "#f5cbdf","#fce39e", "#1696d2" ,"#e9807d","#dcedd9")


ggplot() +
  geom_sf(data =master4, aes( fill = `neighborhood category`))+
  scale_fill_manual(name="neighborhoodchange type", values = urban_colors6, guide = guide_legend(override.aes = list(linetype = "blank", 
                                                                                                                     shape = NA)))+ 
  # geom_sf(BBCF, mapping = aes(), fill=NA,lwd =  0.5, color="#fdbf11",show.legend = "line")+
  # geom_sf(cog_all, mapping = aes(), fill=NA,lwd =  1, color="#ec008b",show.legend = "line")+
  # scale_color_manual(values = 'transparent', guide = guide_legend(override.aes = list(linetype = "solid"))) +
  geom_sf(water_sf, mapping=aes(), fill="#dcdbdb", color="#dcdbdb", size=0.05)+
  coord_sf(datum = NA)+
  # geom_label(
  #   data = town_labels,
  #   aes(x = X, y = Y, label = NAME),
  #   size = 3,
  #   label.padding = unit(.1, "lines"), alpha = .7
  # )+
  theme(
    panel.grid.major = element_line(colour = "transparent", size = 0),
    axis.title = element_blank(),
    axis.line.y = element_blank(),
    plot.caption = element_text(hjust = 0, size = 16),
    plot.title = element_text(size = 18),
    legend.title=element_text(size=14), 
    legend.text = element_text(size = 14)
    
  )+
  guides(color = guide_legend(override.aes = list(size=5)))+
  geom_sf(data = tractboundary_20, fill = "transparent", color="#adabac")+
  coord_sf(datum = NA)+
  geom_sf(data = displacementarea, fill = "transparent", color="#ec008b")+
  coord_sf(datum = NA)+
  labs(title = paste0("Neighborhood Change in DC based on rent value"),
       subtitle= "Potential displacement area highlighted in red",
       caption = "Source: Census 2000, ACS 5-year estimates 2008-2012, 2018-2022")


master4 <- master4 %>% 
  st_drop_geometry()
write.csv(master4,"C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/neighborhoodchange_masterdata_rentvaluemethod.csv")

master7 <- master5 %>% 
  select(GEOID, NBH_NAMES, NAME.y, Ward) %>% 
  st_drop_geometry()

write.csv(master7,"C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/neighborhood_tract.csv")
