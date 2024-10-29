## neighborhood change analysis based on OTR home sales data
## Yipeng Su
## last updated 9/25/2024

# Install pacman if not already installed
if (!require("pacman")) install.packages("pacman")

# Load the required packages using pacman
pacman::p_load(
  tidyverse, DescTools, purrr, tidycensus, mapview, stringr, educationdata, sf, 
  readxl, urbnthemes, sp, ipumsr, survey, srvyr, dplyr, Hmisc, haven, corrplot
)

# census_api_key("05de4dca638d81abd2dc60d0d28e3781183e185e", install = TRUE)
#get your key at https://api.census.gov/data/key_signup.html

#update to your Box drive directory
setwd("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/")

# reference data on Sas drive, you might have it on a different drive than "W"
data <- read_sas("F:/Libraries/Realprop/Data/sales_sum_tr20.sas7bdat")
#tring the OTR sales data for median home value

OTR_sales <- data %>%
  rename(GEOID=Geo2020) %>%
  select(GEOID, mprice_tot_1999,mprice_tot_2000,mprice_tot_2001, mprice_tot_2012,mprice_tot_2011,mprice_tot_2010, mprice_tot_2013,mprice_tot_2022,mprice_tot_2021,mprice_tot_2023) %>%
  # filter(is.na(mprice_tot_2000)) #8 missing in 2022 #13 missing in 2012 #12 missing in 2000
  mutate(GEOID=as.numeric(GEOID))

#while they fix the VPN issue use this csv export
# OTR_sales <- read_csv("Clean/OTR_salesprice.csv")

housingmarket <- read_csv("Clean/housingmarket.csv") 

lowincome <- read_csv("Clean/lowincome_pop.csv")

raceethnicity <- read_csv("Clean/race_ethnicity.csv")

distance <- read_csv("Clean/distance_downtown.csv")

college <- read_csv("Clean/college.csv")

popbyrace<- read_csv("Clean/pop_race_ethnicity.csv")

blacktenure<- read_csv("Clean/Black_tenure.csv")

newrentdata <- read_csv("Clean/rentvalue_cat.csv") %>% 
  mutate(GEOID=as.numeric(GEOID)) %>% 
  select(GEOID,starts_with("pct_"))

analysismaster <- housingmarket %>% 
  left_join(lowincome, by=c("GEOID")) %>% 
  left_join(raceethnicity, by=c("GEOID")) %>% 
  left_join(distance, by=c("GEOID") ) %>% 
  left_join(college, by=c("GEOID")) %>% 
  left_join(popbyrace, by=c("GEOID")) %>% 
  left_join(blacktenure, by=c("GEOID")) %>% 
  left_join(newrentdata, by=c("GEOID")) %>% 
  select(-NAME.y, -NAME.x)

tractboundary_20 <- get_acs(geography = "tract", 
                            variables = c("B01003_001"),
                            state = "DC",
                            geometry = TRUE,
                            year = 2022)

neighborhood = "F:/Libraries/OCTO/Maps/Neighborhood_Clusters.shp"
neighborhood_sf <- read_sf(dsn= neighborhood, layer= basename(strsplit(neighborhood, "\\.")[[1]])[1])

watershp = "F:/Libraries/General/Maps/Waterbodies.shp"
water_sf <- read_sf(dsn= watershp, layer= basename(strsplit(watershp, "\\.")[[1]])[1])

wards = "F:/Libraries/OCTO/Maps/Wards_from_2022.shp"
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


#drop tracts with low pop in 2000
droptract <- analysismaster %>% 
  select(GEOID, total_hh_2000_2020)

#merge analysis data with shapefile
map_file <- merge(analysismaster,tractboundary_20, by=c("GEOID")) %>% 
  # filter(!GEOID %in% c("11001000201", "11001009511", "11001980000", "11001006804")) %>% #drop low pop tracts
  filter(!GEOID %in% c("11001010603", "11001980000", "11001007201", "11001010601", "11001000201","11001006804")) %>% #drop low pop tracts
  filter(!GEOID %in% c("11001001702","11001007301","11001010900")) %>% #drop Joint Base Anacostia-Bolling
  st_as_sf() 


#test the new combination of thresholds for loss of black population
blackpoploss <- popbyrace %>% 
  mutate(loss_2000_2012=non_hispanic_black_pop_2012_2020-non_hispanic_black_pop_2000_2010_2020,
         loss_2012_2022=non_hispanic_black_pop_2022-non_hispanic_black_pop_2012_2020) %>% 
  select(GEOID,non_hispanic_black_pop_2000_2010_2020,non_hispanic_black_pop_2012_2020,non_hispanic_black_pop_2022,loss_2012_2022,loss_2000_2012)

# Density plot for comparing two periods
ggplot(blackpoploss) +
  geom_density(aes(x = loss_2000_2012, color = "2000-2012"), fill = "blue", alpha = 0.3) +
  geom_density(aes(x = loss_2012_2022, color = "2012-2022"), fill = "green", alpha = 0.3) +
  labs(
    title = "Comparison of Population Change Distribution",
    x = "Population Change",
    y = "Density"
  ) +
  scale_color_manual(values = c("2000-2012" = "blue", "2012-2022" = "green")) +
  theme_minimal()

blackpoploss2 <- blackpoploss %>% 
  mutate(total=1) %>% 
  mutate(pctloss2012=loss_2000_2012/non_hispanic_black_pop_2000_2010_2020,
         pctloss2022=loss_2012_2022/non_hispanic_black_pop_2012_2020,
         lossalltime=non_hispanic_black_pop_2022-non_hispanic_black_pop_2000_2010_2020) %>% 
  group_by(total) %>% 
  summarise(median2012=median(loss_2000_2012),
            median2022=median(loss_2012_2022),
            medianalltimechange=median(lossalltime),
            medianpct2012=median(pctloss2012,na.rm=TRUE),
            medianpct2022=median(pctloss2022,na.rm=TRUE),
            total2000=sum(non_hispanic_black_pop_2000_2010_2020),
            total2012=sum(non_hispanic_black_pop_2012_2020),
            total2022=sum(non_hispanic_black_pop_2022))

master6 <- map_file %>% 
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
  filter(!is.na(medianhome_2022)& !is.na(medianhome_2012_2020) & !is.na(medianhome_2000_2020)) %>%
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
  # select(GEOID,total_hh_2022,medianhome_2000_2020,medianhome_2012_2020,medianhome_2022, quintile_2000,homevaluecat_2000, homevaluecat_2012,homevaluecat_2022, nominal_00_12, nominal_00_22,nominal_12_22,NBH_NAMES) %>% 
  # mutate(housing_market=case_when(homevaluecat_2000 %in% c("low", "moderate") & homevaluecat_2022 %in% c("moderate","high")~ "growing",
  #                                 homevaluecat_2000 %in% c("high", "moderate") & homevaluecat_2022 %in% c("moderate","low")~ "declining",
  #                                 homevaluecat_2000 %in% c("high") & homevaluecat_2022 %in% c("high")~ "established",
  #                                 homevaluecat_2000 %in% c("low") & homevaluecat_2022 %in% c("low")~ "stagnant",
  #                                 TRUE ~ "other (might be dynamic)" )) %>% 
  mutate(pct_lowincome_2000=lowincome_2000_2020/total_hh_2000_2020,
         pct_lowincome_2012=lowincome_2012_2020/total_hh_2012_2020,
         pct_lowincome_2022=lowincome_2022/total_hh_2022) %>% 
  mutate(pctchg_lowincome=pct_lowincome_2022-pct_lowincome_2012,
         change_lowincome=lowincome_2022-lowincome_2012_2020) %>% 
  # mutate(pctchange_2012_2022=(lowincome_2022-lowincome_2012_2020)/lowincome_2012_2020) %>% 
  mutate(pctchange_2000_2022=(lowincome_2022-lowincome_2000_2020)/lowincome_2000_2020) %>% 
  mutate(pct_lowinc_2000=lowincome_2000_2020/total_hh_2000_2020, na.rm=TRUE) %>% 
  mutate(quintile_cutoffs_inc= ntile(pct_lowinc_2000, 10)) %>% 
  mutate(lowinc_2000_2022=ifelse(pctchange_2000_2022<=-0.1& quintile_cutoffs_inc>2, "lowincomeloss", "notlowincomeloss")) %>%  
  # mutate(lowinc_2012_2022=ifelse(pctchange_2012_2022<=-0.1 & lowincome_2000_2020>345, "lowincomeloss", "notlowincomeloss")) %>% 
  mutate(loss_2000_2012=non_hispanic_black_pop_2012_2020-non_hispanic_black_pop_2000_2010_2020,
         loss_2012_2022=non_hispanic_black_pop_2022-non_hispanic_black_pop_2012_2020,
         loss_2000_2022=loss_2000_2012+loss_2012_2022) %>% 
  mutate(pctchange_2012_2022_blk=(loss_2012_2022/ non_hispanic_black_pop_2012_2020)) %>% 
  mutate(pctchange_2000_2022_blk=((loss_2012_2022+loss_2000_2012)/ non_hispanic_black_pop_2000_2010_2020)) %>% 
  # mutate(lossblk_2012_2022=ifelse(pctchange_2012_2022_blk<=-0.1 & non_hispanic_black_hh_2000_2020>126, "blackloss", "notblackloss")) %>% 
  mutate(lossblk_2000_2022=ifelse( (pctchange_2000_2022_blk<=-0.1|loss_2000_2022<=-186 )& non_hispanic_black_hh_2000_2020>266, "blackloss", "notblackloss")) %>% 
  mutate(vulnerable=ifelse(lossblk_2000_2022=="notblackloss"&lowinc_2000_2022=="notlowincomeloss", "nolossvulnerable", "lossvulnerable")) %>% 
  #filter(GEOID=="11001000102") %>%
  #select(GEOID, NBH_NAMES,lossblk_2012_2022, lowinc_2012_2022, vulnerable,non_hispanic_black_hh_2022,lowincome_2000_2020,non_hispanic_black_hh_2000_2020)
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
                                    lowmod_housing_2000=="yes" & overallincreasevalue_2012_2022=="yes" & vulnerable=="lossvulnerable" ~ "exclusive growth with displacement risk",
                                    lowmod_housing_2000=="no" & overalldecreasevalue_2012_2022=="yes" ~ "decreasing value neighborhood",
                                    continuedhigh=="yes" & vulnerable=="lossvulnerable" ~ "established opportunity with displacement risk",
                                    continuedhigh=="yes" & vulnerable=="nolossvulnerable" ~ "established opportunity",
                                    continuedlow=="yes" & vulnerable=="lossvulnerable" ~ "underinvestment with displacement risk",
                                    continuedlow=="yes" & vulnerable=="nolossvulnerable" ~ "underinvestment & future opportunity",
                                    TRUE~ "dynamic")) %>% 
  mutate(`neighborhood category` = factor(neighborhoodtype,
                                          levels = c("stable growing",
                                                     "exclusive growth with displacement risk",
                                                     "decreasing value neighborhood",
                                                     "established opportunity",
                                                     "established opportunity with displacement risk",
                                                     "underinvestment with displacement risk",
                                                     "underinvestment & future opportunity",
                                                     "dynamic"
                                          ))) 

selected_vars <- c("medianhome_2022","changeinhomevalue", "pctchangeinhomevalue", "changeinunits", "pctchangeinunits",
                   "pctchangeinlowrent","changeinowner","pctchangeinowner","changeinrenter","pctchangeinrenter",
                   "changeinblackrenter","pctchangeinblackrenter","changeinblackowner","pctchangeinblackowner")

summary_by_loss <- master6 %>% 
  mutate(changeinhomevalue=medianhome_2022-medianhome_2000_2020,
         pctchangeinhomevalue=(medianhome_2022-medianhome_2000_2020)/medianhome_2000_2020) %>% 
  mutate(changeinunits=housing_2022-housing_2000_2020,
         pctchangeinunits=(housing_2022-housing_2000_2020)/housing_2000_2020) %>% 
  mutate(pctchangeinlowrent=pct_2022_low-pct_2000_low) %>% 
  mutate(changeinowner=owner_2022-owner_2000_2020,
         pctchangeinowner=(owner_2022-owner_2000_2020)/owner_2000_2020) %>% 
  mutate(changeinrenter=renter_2022-renter_2000_2020,
         pctchangeinrenter=(renter_2022-renter_2000_2020)/renter_2000_2020) %>% 
  mutate(changeinblackrenter=black_renter_2022-black_renter_2000_2010_2020,
         pctchangeinblackrenter=(black_renter_2022-black_renter_2000_2010_2020)/black_renter_2000_2010_2020) %>% 
  mutate(changeinblackowner=black_owner_2022-black_owner_2000_2010_2020,
         pctchangeinblackowner=(black_owner_2022-black_owner_2000_2010_2020)/black_owner_2000_2010_2020,na.rm=TRUE) %>% 
  group_by(vulnerable) %>% 
  summarise(across(all_of(selected_vars), ~ mean(.x, na.rm = TRUE), .names = "{.col}_mean")) %>% 
  st_drop_geometry()

summary_by_type <- master6 %>% 
  mutate(changeinhomevalue=medianhome_2022-medianhome_2000_2020,
         pctchangeinhomevalue=(medianhome_2022-medianhome_2000_2020)/medianhome_2000_2020) %>% 
  mutate(changeinunits=housing_2022-housing_2000_2020,
         pctchangeinunits=(housing_2022-housing_2000_2020)/housing_2000_2020) %>% 
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

write.csv(summary_by_type, "C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/revision/neighborhood_summarystat.csv")
write.csv(summary_by_loss, "C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/revision/neighborhood_summarystat2.csv")

sumtract <- master6 %>% 
  group_by(neighborhoodtype) %>% 
  count() %>% 
  rename(Homevalue_method=n) %>% 
  st_drop_geometry()


displacementarea <- master6 %>% 
  filter(neighborhoodtype=="exclusive growth with displacement risk"|neighborhoodtype=="established opportunity with displacement risk"|neighborhoodtype=="underinvestment with displacement risk")

urban_colors7 <- c("#73bfe2", "#f5cbdf","#fce39e", "#1696d2" ,"#e9807d","#fdd870","#dcedd9")
urban_colors8 <- c("#f5f5f5", "#f5cbdf","#fce39e", "#e3e3e3" ,"#e9807d" ,"#e46aa7","#fdd870","#dcedd9")
urban_colors8_2 <- c("#f5f5f5", "#cfe8f3","#fce39e", "#e3e3e3" ,"#73bfed" ,"#1696d2","#f5cbdf","#dcedd9")

ggplot() +
  geom_sf(data =master6, aes( fill = `neighborhood category`))+
  scale_fill_manual(name="neighborhoodchange type", values = urban_colors8_2, guide = guide_legend(override.aes = list(linetype = "blank", 
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
  # geom_sf(data = displacementarea, fill = "transparent", color="#ec008b")+
  # coord_sf(datum = NA)+
  labs(title = paste0("Neighborhood Change in DC based on OTR sales data"),
       subtitle= "Potential displacement area highlighted in red",
       caption = "Source: Census 2000, ACS 5-year estimates 2008-2012, 2018-2022, Real Property Tax Database")

#tracts that loss vulnerbale households
data <- master6 %>%
  mutate(loss_gt_10 = pctchange_2000_2022_blk<=-0.1)

data2 <- master6 %>%
  mutate(loss_gt_10 = loss_2000_2012<=-100)

data3 <- master6 %>%
  mutate(loss_gt_10 = loss_2000_2012>100)

# Now plot using a discrete color scale
ggplot() +
  geom_sf(data = data3, aes(fill = loss_gt_10), color = "white", size = 0.2) +
  # scale_fill_manual(values = c("FALSE" = "gray", "TRUE" = "red"), labels = c("≤ 10%", "> 10%")) +
  scale_fill_manual(values = c("FALSE" = "gray", "TRUE" = "red"), labels = c("more than 100", "les than 100")) +
  labs(
    title = "Black Population Gain by Tract",
    fill = "Population Gain"
  ) +
  theme_minimal()




#test new categories

test <- master6 %>% 
  mutate(neighborhoodtype=case_when(lowmod_housing_2000=="yes" & overallincreasevalue_2012_2022=="yes" & vulnerable=="nolossvulnerable" ~ "stable growing",
                                    lowmod_housing_2000=="yes" & overallincreasevalue_2012_2022=="yes" & vulnerable=="lossvulnerable" ~ "exclusive growth with displacement risk",
                                    lowmod_housing_2000=="no" & overalldecreasevalue_2012_2022=="yes" ~ "future opportunity for growth",
                                    continuedhigh=="yes" & vulnerable=="lossvulnerable" ~ "established opportunity with displacement risk",
                                    continuedhigh=="yes" & vulnerable=="nolossvulnerable" ~ "established opportunity",
                                    continuedlow=="yes" & vulnerable=="lossvulnerable" ~ "disinvestment with displacement risk",
                                    continuedlow=="yes" & vulnerable=="nolossvulnerable" ~ "future opportunity for growth",
                                    TRUE~ "future opportunity for growth")) %>% 
  mutate(`neighborhood category` = factor(neighborhoodtype,
                                          levels = c("stable growing",
                                                     "exclusive growth with displacement risk",
                                                     
                                                     "established opportunity",
                                                     "established opportunity with displacement risk",
                                                     "disinvestment with displacement risk",
                                                     
                                                     "future opportunity for growth"
                                          ))) 


urban_colors6 <- c("#73bfe2", "#f5cbdf", "#1696d2" ,"#e9807d","#e46aa7","#dcedd9")

ggplot() +
  geom_sf(data =test, aes( fill = `neighborhood category`))+
  scale_fill_manual(name="neighborhoodchange type", values = urban_colors6, guide = guide_legend(override.aes = list(linetype = "blank", 
                                                                                                                     shape = NA)))+ 
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
  geom_sf(data = displacementarea, fill = "transparent", color="#ec008b")+
  coord_sf(datum = NA)+
  labs(title = paste0("Neighborhood Change in DC based on OTR sales data"),
       subtitle= "Potential displacement area highlighted in red",
       caption = "Source: Census 2000, ACS 5-year estimates 2008-2012, 2018-2022, Real Property Tax Database")

#prediction

neighborhoodtype_Oct <- master6 %>% 
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


predictionmaster <-  neighborhoodtype_Oct %>% 
  left_join(housingmarket, by=c("GEOID")) %>% 
  left_join(lowincome, by=c("GEOID")) %>% 
  left_join(raceethnicity, by=c("GEOID")) %>% 
  left_join(distance, by=c("GEOID")) %>% 
  # left_join(vacancy, by=c("GEOID")) %>% 
  left_join(lowincjobs, by=c("GEOID")) %>% 
  left_join(HUDsubsidy, by=c("GEOID")) %>% 
  left_join(college, by=c("GEOID")) %>% 
  left_join(newrentdata, by=c("GEOID")) %>% 
  left_join(popbyrace, by=c("GEOID")) %>% 
  mutate(displacement=ifelse((neighborhoodtype=="exclusive growth with displacement risk"|neighborhoodtype=="established opportunity with displacement risk"|neighborhoodtype=="disinvestment with displacement risk"),1,0)) %>% 
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
  mutate(distancesquared=distance_to_downtown_miles*distance_to_downtown_miles) %>% 
  mutate(changeunits_2012=housing_2012_2020-housing_2000_2020,
         changerent_2012=pct_2022_low-pct_2000_low,
         changeunits_2022=housing_2022-housing_2012_2020,
         changerent_2022=pct_2022_low-pct_2012_low, 
         changelowincome_2012=lowincome_2012_2020-lowincome_2000_2020,
         changelowincome_2022=lowincome_2022-lowincome_2012_2020,
         changeblack_2012=non_hispanic_black_pop_2012_2020-non_hispanic_black_pop_2000_2010_2020,
         changeblack_2022=non_hispanic_black_pop_2022-non_hispanic_black_pop_2012_2020,
         pct_renter_2022=renter_2022/(renter_2022+owner_2022),
         pct_renter_2012=renter_2012_2020/(renter_2012_2020+owner_2012_2020)) 

predictionmaster1 <- predictionmaster %>% 
  rename(vacancy=vacancy_2012,
         distance=distance_to_downtown_miles,
         homevalue=medianhome_2012_2020,
         lowinc=pct_lowincome_2012,
         black=pct_black_2012 ,
         college=pct_college_2012_2020,
         lowincjob=pct_lowincjob_2012,
         hcv=pct_hcv_2012,
         changeunits=changeunits_2012,
         changerent=changerent_2012,
         changeinblack=changeblack_2022,
         changeinlowinc=changelowincome_2022,
         pct_renter=pct_renter_2012) 

out <- predictionmaster1 %>% 
  select(GEOID,changeinlowinc,distance,vacancy,changeinblack,changerent,changeunits,hcv,lowincjob,college,black,lowinc,homevalue)
write.csv(out,"C:/Users/Ysu/Documents/regression.csv")

predictionmaster2 <- predictionmaster %>% 
  rename(vacancy=vacancy_2022,
         distance=distance_to_downtown_miles,
         homevalue=medianhome_2022,
         lowinc=pct_lowincome_2022,
         black=pct_black_2022 ,
         college=pct_college_2022,
         lowincjob=pct_lowincjob_2021,
         hcv=pct_hcv_2022,
         changeunits=changeunits_2022,
         changerent=changerent_2022,
         pct_renter=pct_renter_2022) 

### test correlation
corrdata <- predictionmaster %>% 
  select(vacancy_2012,distance_to_downtown_miles,medianhome_2012_2020,pct_lowincome_2012, pct_black_2012 , pct_college_2012_2020 , pct_lowincjob_2012 , pct_hcv_2012, changeunits_2012, changeblack_2012,changelowincome_2012,changerent_2012,pct_renter_2012) %>% 
  rename(vacancy=vacancy_2012,
         distance=distance_to_downtown_miles,
         homevalue=medianhome_2012_2020,
         pct_renter=pct_renter_2012,
         lowinc=pct_lowincome_2012,
         black=pct_black_2012 ,
         college=pct_college_2012_2020,
         lowincjob=pct_lowincjob_2012,
         hcv=pct_hcv_2012,
         units=changeunits_2012,
         lowrent=changerent_2012,
         changeblk=changeblack_2012,
         changelowinc=changelowincome_2012)
M = cor(corrdata)
corrplot(M, order = 'AOE', diag=FALSE) # after 'AOE' reorder
#remove college as it's correlated with many variables
library(stargazer)

corrdata2 <- predictionmaster %>% 
  select(vacancy_2012,distance_to_downtown_miles,medianhome_2012_2020,pct_black_2012 ,  pct_lowincjob_2012 , pct_hcv_2012, changeunits_2012, changeblack_2012,changelowincome_2012,changerent_2012,pct_renter_2012) %>% 
  rename(vacancy=vacancy_2012,
         distance=distance_to_downtown_miles,
         homevalue=medianhome_2012_2020,
         black=pct_black_2012 ,
         lowincjob=pct_lowincjob_2012,
         hcv=pct_hcv_2012,
         units=changeunits_2012,
         lowrent=changerent_2012,
         changeblk=changeblack_2012,
         changelowinc=changelowincome_2012)
M2= cor(corrdata2)
#remove college, lowincome as they are highly correlated with share balck population

OLS1 <- lm(changeinblack ~ vacancy + distance + distancesquared+ homevalue
           + black  + lowincjob + hcv+changeunits+changerent, data = predictionmaster1)

OLS2 <- lm(changeinblack ~ vacancy + distance + distancesquared+homevalue
           + black  + lowincjob + hcv+changeunits, data = predictionmaster1)

OLS3 <- lm(changeinblack ~ vacancy + distance + distancesquared+homevalue
           + black  + lowincjob + hcv+changerent, data = predictionmaster1)

OLS4 <- lm(changeinblack ~ vacancy + distance + distancesquared+homevalue
           + black  + lowincjob +changeunits+changerent, data = predictionmaster1)
OLS5 <- lm(changeinblack ~ vacancy + distance + distancesquared+homevalue
           + black   + hcv+changeunits+changerent, data = predictionmaster1)
OLS6 <- lm(changeinblack ~ vacancy + distance + distancesquared+homevalue
             + lowincjob + hcv+changeunits+changerent, data = predictionmaster1)
OLS7 <- lm(changeinblack ~ vacancy + distance + distancesquared
           + black  + lowincjob + hcv+changeunits+changerent, data = predictionmaster1)
OLS8 <- lm(changeinblack ~  distance + distancesquared+homevalue
           + black  + lowincjob + hcv+changeunits+changerent, data = predictionmaster1)

testbest <- lm(changeinblack ~ distance + vacancy + changerent + 
                 changeunits + hcv + lowincjob + college + black + lowinc + 
                 homevalue, data = predictionmaster1)
test <- lm(changeinblack ~ pct_renter+ changerent + changeunits + college + black + lowinc, data = predictionmaster1)
summary(test)

#################test model for black population change

# Load necessary libraries
library(caret)
library(dplyr)

# Define the dataset and target variable
target_var <- "changeinblack"  # or "changeinblack" based on your analysis
predictors <- c( "distance","distancesquared" ,"vacancy", "changerent", "changeunits", "hcv", 
                "lowincjob", "black", "homevalue", "pct_renter")

# Initialize an empty data frame to store the results
results <- data.frame(Model = character(), R_squared = numeric(), Adjusted_R_squared = numeric(),CV_RMSE = numeric(), AIC = numeric(), Variables = character())

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
    model_cv <- train(formula, data = predictionmaster1, method = "lm", trControl = train_control)
    
    # Extract cross-validated RMSE
    cv_rmse <- model_cv$results$RMSE
    
    # Fit the model on the entire dataset to calculate R-squared and AIC
    model <- lm(formula, data = predictionmaster1)
    adjusted_r_squared <- summary(model)$adj.r.squared
    model_aic <- AIC(model)
    
    # Store the results
    results <- results %>%
      add_row(Model = paste(combo, collapse = " + "), 
              Adjusted_R_squared = adjusted_r_squared, 
              CV_RMSE = cv_rmse, 
              AIC = model_aic,
              Variables = paste(combo, collapse = ", "))
  }
}

# Filter for the best model based on highest R-squared, lowest CV RMSE, and lowest AIC
best_model <- results %>%
  arrange(CV_RMSE,desc(R_squared), AIC) %>%
  slice(1)

print("Best Model Based on Highest R-squared, Lowest Cross-Validated RMSE, and Lowest AIC:")
print(best_model)

blackmodel <- lm(changeinblack ~ distancesquared + vacancy + changeunits + hcv + black, data = predictionmaster1)
summary(blackmodel)

#################predict

# Print predicted classes
predicted <- predict(blackmodel, predictionmaster2, type = "response")
predictionmaster2$predictedchangeinblack <- predicted

predictresult <- predictionmaster2 %>% 
  # left_join(neighborhoodname, by=c("GEOID")) %>% 
  # left_join(predictionmaster, by=c("GEOID")) %>% 
  mutate(pct=predictedchangeinblack/non_hispanic_black_pop_2022) %>% 
  mutate(pct=ifelse(pct<(-1),-1,pct)) %>% 
  filter(non_hispanic_black_pop_2022>0) %>% 
  mutate(startpop=ntile(non_hispanic_black_pop_2022,10)) %>% 
  mutate(lossmorethan10=ifelse((pct< -0.1|predictedchangeinblack< -50)& startpop>2,1,0),
         lossmorethan20=ifelse(pct< -0.2 & startpop>2 ,1,0)) %>% 
  select(GEOID,NBH_NAMES,neighborhoodtype,pct,startpop,non_hispanic_black_pop_2022,lossmorethan10,lossmorethan20,predictedchangeinblack,changeblack_2022) %>% 
  mutate(predicted_class=ifelse(lossmorethan10==1,1,0))

# Density plot for comparing two periods
ggplot(predictresult) +
  geom_density(aes(x = changeblack_2022, color = "2012-2022"), fill = "blue", alpha = 0.3) +
  geom_density(aes(x = predictedchangeinblack, color = "2022-2032"), fill = "green", alpha = 0.3) +
  labs(
    title = "Comparison of Population Change Distribution",
    x = "Population Change",
    y = "Density"
  ) +
  scale_color_manual(values = c("2012-2022" = "blue", "2022-2032" = "green")) +
  theme_minimal()

test <- predictresult %>% 
  filter(predicted_class==1) 

test2 <- predicteddisplacementmap %>% 
  # filter(displacement==1)
  group_by(predicted_class,displacement) %>% 
  count()
  filter(predicted_class==1) 

test <- master6 %>% 
  left_join(predictionmaster2 , by="GEOID") %>% 
  left_join(predictresult , by="GEOID") %>% 
  filter(predicted_class==1)

ggplot() +
  geom_sf(test, mapping=aes(), fill="#dcdbdb", color="red", size=0.05)+
  coord_sf(datum = NA)+  
  geom_sf(data = tractboundary_20, fill = "transparent", color="#adabac")+
  coord_sf(datum = NA)




predicteddisplacementmap <- master6%>% 
  left_join(predictionmaster2 , by="GEOID") %>% 
  left_join(predictresult , by="GEOID") %>% 
  # select(GEOID, displacement, predicted_probs,predicted_class) %>% 
  mutate(predictiontype=case_when(displacement==1 & predicted_class==1 ~ "continued displacement risk",
                                  displacement==0 & predicted_class==1 ~ "upcoming displacement risk",
                                  displacement==1 & predicted_class==0 ~ "decreased displacement risk",
                                  displacement==0 & predicted_class==0 ~ "no displacement risk")) %>% 
  mutate(`predict category` = factor(predictiontype,
                                          levels = c("continued displacement risk",
                                                     "upcoming displacement risk",
                                                     "decreased displacement risk",
                                                     "no displacement risk"
                                          ))) 

prediction_blackpop <- predicteddisplacementmap %>% 
  select(GEOID,predictiontype,`predict category`) %>% 
  st_drop_geometry()


upcomingdisplacement <- predicteddisplacementmap %>% 
  filter(predictiontype=="continued displacement risk"|predictiontype=="upcoming displacement risk") 


urban_colors7 <- c("#73bfe2", "#f5cbdf","#fce39e", "#1696d2" ,"#e9807d","#fdd870","#dcedd9")
urban_colors8 <- c("#73bfe2", "#f5cbdf","#fce39e", "#1696d2" ,"#e9807d" ,"#9d9d9d","#fdd870","#dcedd9")
urban_colors4 <- c("#f5cbdf","#fce39e","#dcedd9","#f5f5f5")

ggplot() +
  geom_sf(data =predicteddisplacementmap, aes( fill = `predict category`))+
  scale_fill_manual(name="future displacement type", values = urban_colors4, guide = guide_legend(override.aes = list(linetype = "blank", 
                                                                                                                     shape = NA)))+ 
  geom_sf(water_sf, mapping=aes(), fill="#dcdbdb", color="#dcdbdb", size=0.05)+
  coord_sf(datum = NA)+
  guides(color = guide_legend(override.aes = list(size=5)))+
  geom_sf(data = tractboundary_20, fill = "transparent", color="#adabac")+
  coord_sf(datum = NA)+
  # geom_sf(data = upcomingdisplacement, fill = "transparent", color="#ec008b")+
  # coord_sf(datum = NA)+
  labs(title = paste0("Predicted Displacement of Black population in DC based on OTR sales data"),
       subtitle= "",
       caption = "Source: Census 2000, ACS 5-year estimates 2008-2012, 2018-2022")


########predicting low income households

# Load necessary libraries
library(caret)
library(dplyr)

# Define the dataset and target variable
target_var <- "changeinlowinc"  # or "changeinblack" based on your analysis
predictors <- c("distance","distancesquared","vacancy", "changerent", "changeunits", "hcv", 
                "lowincjob", "black", "homevalue","pct_renter")

# Initialize an empty data frame to store the results
results <- data.frame(Model = character(), R_squared = numeric(), Adjusted_R_squared = numeric(),CV_RMSE = numeric(), AIC = numeric(), Variables = character())

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
    model_cv <- train(formula, data = predictionmaster1, method = "lm", trControl = train_control)
    
    # Extract cross-validated RMSE
    cv_rmse <- model_cv$results$RMSE
    
    # Fit the model on the entire dataset to calculate R-squared and AIC
    model <- lm(formula, data = predictionmaster1)
    adjusted_r_squared <- summary(model)$adj.r.squared
    model_aic <- AIC(model)
    
    # Store the results
    results <- results %>%
      add_row(Model = paste(combo, collapse = " + "), 
              Adjusted_R_squared = adjusted_r_squared, 
              CV_RMSE = cv_rmse, 
              AIC = model_aic,
              Variables = paste(combo, collapse = ", "))
  }
}

# Filter for the best model based on highest R-squared, lowest CV RMSE, and lowest AIC
best_model <- results %>%
  arrange(desc(R_squared), CV_RMSE,AIC) %>%
  slice(1)

print("Best Model Based on Highest R-squared, Lowest Cross-Validated RMSE, and Lowest AIC:")
print(best_model)

lowincmodel <- lm(changeinlowinc ~ distance + changerent + hcv + college + black + lowinc + homevalue + pct_renter, data = predictionmaster1)
summary(lowincmodel)

# Print predicted classes
predicted <- predict(lowincmodel, predictionmaster2, type = "response")
predictionmaster2$predictedchangeinlowinc <- predicted

predictresult <- predictionmaster2 %>% 
  # left_join(neighborhoodname, by=c("GEOID")) %>% 
  # left_join(predictionmaster, by=c("GEOID")) %>% 
  mutate(pct=predictedchangeinlowinc/lowincome_2022) %>% 
  mutate(pct=ifelse(pct<(-1),-1,pct)) %>% 
  filter(non_hispanic_black_pop_2022>0) %>% 
  mutate(startpop=ntile(lowincome_2022,10)) %>% 
  mutate(lossmorethan10=ifelse((pct< -0.1|predictedchangeinlowinc< -90)& startpop>2,1,0),
         lossmorethan20=ifelse(pct< -0.2 & startpop>2 ,1,0)) %>% 
  select(GEOID,NBH_NAMES,predictedchangeinlowinc,neighborhoodtype,pct,lossmorethan10,lossmorethan20,predictedchangeinlowinc,changelowincome_2022) %>% 
  mutate(predicted_class=ifelse(lossmorethan10==1,1,0))

# Calculate the 10 quintiles
quintiles <- quantile(predictresult$predictedchangeinlowinc, probs = seq(0, 1, by = 0.1), na.rm = TRUE)

# Display the quintiles
print(quintiles)
# Density plot for comparing two periods
ggplot(predictresult) +
  geom_density(aes(x = changelowincome_2022, color = "2012-2022"), fill = "blue", alpha = 0.3) +
  geom_density(aes(x = predictedchangeinlowinc, color = "2022-2032"), fill = "green", alpha = 0.3) +
  labs(
    title = "Comparison of Population Change Distribution",
    x = "Population Change",
    y = "Density"
  ) +
  scale_color_manual(values = c("2012-2022" = "blue", "2022-2032" = "green")) +
  theme_minimal()

test <- predictresult %>% 
  filter(predicted_class==1) 

test2 <- predicteddisplacementmap %>% 
  # filter(displacement==1)
  group_by(predicted_class,displacement) %>% 
  count()
filter(predicted_class==1) 

test <- master6 %>% 
  left_join(predictionmaster2 , by="GEOID") %>% 
  left_join(predictresult , by="GEOID") %>% 
  filter(predicted_class==1)

ggplot() +
  geom_sf(test, mapping=aes(), fill="#dcdbdb", color="red", size=0.05)+
  coord_sf(datum = NA)+  
  geom_sf(data = tractboundary_20, fill = "transparent", color="#adabac")+
  coord_sf(datum = NA)

predicteddisplacementmap <- master6%>% 
  left_join(predictionmaster2 , by="GEOID") %>% 
  left_join(predictresult , by="GEOID") %>% 
  # select(GEOID, displacement, predicted_probs,predicted_class) %>% 
  mutate(predictiontype=case_when(displacement==1 & predicted_class==1 ~ "continued displacement risk",
                                  displacement==0 & predicted_class==1 ~ "upcoming displacement risk",
                                  displacement==1 & predicted_class==0 ~ "decreased displacement risk",
                                  displacement==0 & predicted_class==0 ~ "no displacement risk")) %>% 
  mutate(predictiontype=ifelse(GEOID=="11001007603","no displacement risk",predictiontype)) %>% 
  mutate(`predict category` = factor(predictiontype,
                                     levels = c("continued displacement risk",
                                                "upcoming displacement risk",
                                                "decreased displacement risk",
                                                "no displacement risk"
                                     ))) 
  # select(GEOID,displacement, predicted_class,predictiontype,predictedchangeinlowinc.x,distance ,changerent ,hcv ,college ,black ,lowinc ,homevalue ,pct_renter) %>% 
  # filter(GEOID=="11001007603")





upcomingdisplacement <- predicteddisplacementmap %>% 
  filter(predictiontype=="continued displacement risk"|predictiontype=="upcoming displacement risk") 


urban_colors7 <- c("#73bfe2", "#f5cbdf","#fce39e", "#1696d2" ,"#e9807d","#fdd870","#dcedd9")
urban_colors8 <- c("#73bfe2", "#f5cbdf","#fce39e", "#1696d2" ,"#e9807d" ,"#9d9d9d","#fdd870","#dcedd9")
urban_colors4 <- c("#f5cbdf","#fce39e","#dcedd9","#f5f5f5")

ggplot() +
  geom_sf(data =predicteddisplacementmap, aes( fill = `predict category`))+
  scale_fill_manual(name="future displacement type", values = urban_colors4, guide = guide_legend(override.aes = list(linetype = "blank", 
                                                                                                                      shape = NA)))+ 
  geom_sf(water_sf, mapping=aes(), fill="#dcdbdb", color="#dcdbdb", size=0.05)+
  coord_sf(datum = NA)+
  guides(color = guide_legend(override.aes = list(size=5)))+
  geom_sf(data = tractboundary_20, fill = "transparent", color="#adabac")+
  coord_sf(datum = NA)+
  # geom_sf(data = upcomingdisplacement, fill = "transparent", color="#ec008b")+
  # coord_sf(datum = NA)+
  labs(title = paste0("Predicted Displacement of low income housseholds in DC based on OTR sales data"),
       subtitle= "",
       caption = "Source: Census 2000, ACS 5-year estimates 2008-2012, 2018-2022")

prediction_lowinc <- predicteddisplacementmap %>% 
  select(GEOID,predictiontype,`predict category`) %>% 
  st_drop_geometry()

#compile data for interactive map
context <- master6 %>% 
  mutate(change_hh_12_22=total_hh_2022-total_hh_2012_2020) %>% 
  mutate(change_pop_12_22=(renter_2022+owner_2022)-(renter_2012_2020+owner_2012_2020)) %>% 
  select(GEOID,Ward,NBH_NAMES,neighborhoodtype,`neighborhood category`,change_hh_12_22,change_pop_12_22,total_hh_2022) %>% 
  st_drop_geometry()

write.csv(context,"Clean/map_context.csv")

mapdata_lowinc <- context %>% 
  left_join(prediction_lowinc,by=c("GEOID")) 
write.csv(mapdata_lowinc,"Clean/prediction_lowinc.csv")

mapdata_black <- context %>% 
  left_join(prediction_blackpop,by=c("GEOID")) 
write.csv(mapdata_black,"Clean/prediction_blackpop.csv")


  