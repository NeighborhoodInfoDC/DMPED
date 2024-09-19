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
census_api_key("05de4dca638d81abd2dc60d0d28e3781183e185e", install = TRUE)

housingmarket <- read_csv("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/housingmarket.csv") 

lowincome <- read_csv("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/lowincome_pop.csv")

raceethnicity <- read_csv("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/race_ethnicity.csv")

distance <- read_csv("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/distance_downtown.csv")

analysismaster <- housingmarket %>% 
  left_join(lowincome, by=c("GEOID")) %>% 
  left_join(raceethnicity, by=c("GEOID")) %>% 
  left_join(distance, by=c("GEOID") )

tractboundary_20 <- get_acs(geography = "tract", 
                            variables = c("B01003_001"),
                            state = "DC",
                            geometry = TRUE,
                            year = 2022)

neighborhood = "W:/Libraries/OCTO/Maps/Neighborhood_Clusters.shp"
neighborhood_sf <- read_sf(dsn= neighborhood, layer= basename(strsplit(neighborhood, "\\.")[[1]])[1])

watershp = "W:/Libraries/General/Maps/Waterbodies.shp"
water_sf <- read_sf(dsn= watershp, layer= basename(strsplit(watershp, "\\.")[[1]])[1])

wards = "W:/Libraries/OCTO/Maps/Wards_from_2022.shp"
wards_sf <- read_sf(dsn= wards , layer= basename(strsplit(wards, "\\.")[[1]])[1])

#attach neighborhood cluster name to tract
st_crs(neighborhood_sf) <- st_crs(tractboundary_20)
st_crs(wards_sf) <- st_crs(tractboundary_20)

tractboundary_20_2 <- tractboundary_20 %>% 
  st_centroid() %>% 
  st_join(neighborhood_sf) %>% 
  st_drop_geometry() %>% 
  select(GEOID, NBH_NAMES)

tractboundary_20_3 <- tractboundary_20 %>% 
  st_centroid() %>% 
  st_join(wards_sf) %>% 
  st_drop_geometry() %>% 
  select(GEOID.x, NAME.y) %>% 
  rename(GEOID=GEOID.x,
         Ward=NAME.y)

tractboundary_20 <- tractboundary_20 %>% 
  left_join(tractboundary_20_2, by=c("GEOID")) %>% 
  left_join(tractboundary_20_3, by=c("GEOID")) 

#merge analysis data with shapefile

droptract <- c("11001000201", "11001009511", "11001980000", "11001006804", "11001010900")

#merge analysis data with shapefile
map_file <- merge(analysismaster,tractboundary_20, by=c("GEOID")) %>% 
  filter(!GEOID %in% c("11001000201", "11001009511", "11001980000", "11001006804", "11001010900")) %>% 
  st_as_sf()

droptract <- c("11001000201", "11001009511", "11001980000", "11001006804")

#separate out houisng price outlier
outlier <- map_file %>% 
  filter(GEOID=="11001004100") %>% 
  mutate(quintile_2000=5,
         quintile_2012=5,
         quintile_2022=5)

master <- map_file %>% 
  mutate(medianhome_2000_2020=ifelse(medianhome_2000_2020==0, NA, medianhome_2000_2020),
         medianhome_2012_2020=ifelse(medianhome_2012_2020==0, NA, medianhome_2012_2020)) %>% 
  filter(GEOID !="11001004100") %>% 
  mutate(quintile_2000=ntile(medianhome_2000_2020,5),
         quintile_2012=ntile(medianhome_2012_2020,5),
         quintile_2022=ntile(medianhome_2022,5)) %>% 
  rbind(outlier) %>% 
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
         nominal_00_22=medianhome_2022-medianhome_2000_2020*1.7) %>% 
  # select(GEOID,total_hh_2022,medianhome_2000_2020,medianhome_2012_2020,medianhome_2022, quintile_2000,homevaluecat_2000, homevaluecat_2012,homevaluecat_2022, nominal_00_12, nominal_00_22,nominal_12_22,NBH_NAMES) %>% 
  mutate(housing_market=case_when(homevaluecat_2000 %in% c("low", "moderate") & homevaluecat_2022 %in% c("moderate","high")~ "growing",
                                  homevaluecat_2000 %in% c("high", "moderate") & homevaluecat_2022 %in% c("moderate","low")~ "declining",
                                  homevaluecat_2000 %in% c("high") & homevaluecat_2022 %in% c("high")~ "established",
                                  homevaluecat_2000 %in% c("low") & homevaluecat_2022 %in% c("low")~ "stagnant",
                                  TRUE ~ "other (might be dynamic)" )) %>% 
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
  mutate(vulnerable=ifelse(lossblk_2012_2022=="notblackloss"&lowinc_2012_2022=="notlowincomeloss", "nolossvulnerable", "lossvulnerable")) 

master2 <- map_file %>% 
  mutate(medianhome_2000_2020=ifelse(medianhome_2000_2020==0, NA, medianhome_2000_2020),
         medianhome_2012_2020=ifelse(medianhome_2012_2020==0, NA, medianhome_2012_2020)) %>% 
  filter(GEOID !="11001004100") %>% 
  mutate(quintile_2000=ntile(medianhome_2000_2020,5),
         quintile_2012=ntile(medianhome_2012_2020,5),
         quintile_2022=ntile(medianhome_2022,5)) %>% 
  rbind(outlier) %>% 
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
         nominal_00_22=medianhome_2022-medianhome_2000_2020*1.7) %>% 
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

displacementarea <- master2 %>% 
  filter(neighborhoodtype=="exlusive growth with displacement risk"|neighborhoodtype=="established opportunity with displacement risk")

urban_colors6 <- c("#73bfe2", "#f5cbdf","#fce39e", "#1696d2" ,"#e9807d","#dcedd9")
                   

ggplot() +
  geom_sf(data =master2, aes( fill = `neighborhood category`))+
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
  labs(title = paste0("Neighborhood Change in DC"),
       subtitle= "Potential displacement area highlighted in red",
       caption = "Source: Census 2000, ACS 5-year estimates 2008-2012, 2018-2022")


ggsave("Neighborhood change map.png",
       device = "png",
       width = 8.5,
       height = 8.5,
       path = "C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Analysis/Charts/")


neighborhood_type <- master2 %>% 
  select(GEOID, NAME.x, NBH_NAMES, Ward, neighborhoodtype) %>% 
  st_drop_geometry()

write.csv(neighborhood_type,"C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/neighborhoodchangetype.csv")

master3 <- master2 %>% 
  st_drop_geometry()
write.csv(master3,"C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/neighborhoodchange_masterdata.csv")


test <- master2 %>% 
  filter(neighborhoodtype=="stagnant or dynamic") %>% 
  # select(GEOID, NBH_NAMES, pct_lowincome_2000,pct_black_2000,total_hh_2000_2020, vulnerable,lowinc_2012_2022, lossblk_2012_2022) %>% 
  group_by(vulnerable) %>% 
  count()
