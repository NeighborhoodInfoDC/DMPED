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
library(haven)
census_api_key("05de4dca638d81abd2dc60d0d28e3781183e185e", install = TRUE)

data <- read_sas("W:/Libraries/Realprop/Data/sales_sum_tr20.sas7bdat")
#tring the OTR sales data for median home value

OTR_sales <- data %>% 
  rename(GEOID=Geo2020) %>% 
  select(GEOID, mprice_tot_1999,mprice_tot_2000,mprice_tot_2001, mprice_tot_2012,mprice_tot_2011,mprice_tot_2010, mprice_tot_2013,mprice_tot_2022,mprice_tot_2021,mprice_tot_2023) %>% 
  # filter(is.na(mprice_tot_2000)) #8 missing in 2022 #13 missing in 2012 #12 missing in 2000
  mutate(GEOID=as.numeric(GEOID))

housingmarket <- read_csv("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/housingmarket.csv") 

lowincome <- read_csv("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/lowincome_pop.csv")

raceethnicity <- read_csv("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/race_ethnicity.csv")

distance <- read_csv("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/distance_downtown.csv")

college <- read_csv("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/college.csv")

analysismaster <- housingmarket %>% 
  left_join(lowincome, by=c("GEOID")) %>% 
  left_join(raceethnicity, by=c("GEOID")) %>% 
  left_join(distance, by=c("GEOID") ) %>% 
  left_join(college, by=c("GEOID"))

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


#drop tracts with low pop in 2000
droptract <- analysismaster %>% 
  select(GEOID, total_hh_2000_2020)

#merge analysis data with shapefile
map_file <- merge(analysismaster,tractboundary_20, by=c("GEOID")) %>% 
  # filter(!GEOID %in% c("11001000201", "11001009511", "11001980000", "11001006804")) %>% #drop low pop tracts
  filter(!GEOID %in% c("11001010603", "11001980000", "11001007201", "11001010601", "11001000201","11001006804")) %>% #drop low pop tracts
  filter(!GEOID %in% c("11001001702","11001007301","11001010900")) %>% #drop Joint Base Anacostia-Bolling
  st_as_sf() 
# 
# write.csv(master5, "C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/OTR_nosales.csv" )
master5 <- map_file %>% 
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
  # select(GEOID, NBH_NAMES, total_hh_2022, pct_lowincome_2000, pct_lowincome_2012,pct_lowincome_2022,lowincome_2022,lowincome_2012_2020) %>% 
  mutate(pctchg_lowincome=pct_lowincome_2022-pct_lowincome_2012,
         change_lowincome=lowincome_2022-lowincome_2012_2020) %>% 
  mutate(pctchange_2012_2022=(lowincome_2022-lowincome_2012_2020)/lowincome_2012_2020) %>% 
  mutate(lowinc_2012_2022=ifelse(pctchange_2012_2022<=-0.1 & lowincome_2000_2020>345, "lowincomeloss", "notlowincomeloss")) %>% 
  mutate(pct_black_2000=non_hispanic_black_hh_2000_2020/total_hh_2000_2020,
         pct_black_2012=non_hispanic_black_hh_2012_2020/total_hh_2012_2020,
         pct_black_2022=non_hispanic_black_hh_2022/total_hh_2022) %>% 
  # select(GEOID, NBH_NAMES, total_hh_2022, pct_black_2000, pct_black_2012,pct_black_2022) %>% 
  mutate(pctchange_2012_2022_blk=(non_hispanic_black_hh_2022-non_hispanic_black_hh_2012_2020)/ non_hispanic_black_hh_2012_2020) %>% 
  mutate(lossblk_2012_2022=ifelse(pctchange_2012_2022_blk<=-0.1 & non_hispanic_black_hh_2000_2020>126, "blackloss", "notblackloss")) %>% 
  mutate(vulnerable=ifelse(lossblk_2012_2022=="notblackloss"&lowinc_2012_2022=="notlowincomeloss", "nolossvulnerable", "lossvulnerable")) %>% 
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
                                    lowmod_housing_2000=="no" & overalldecreasevalue_2012_2022=="yes" ~ "decreasing neighborhood",
                                    continuedhigh=="yes" & vulnerable=="lossvulnerable" ~ "established opportunity with displacement risk",
                                    continuedhigh=="yes" & vulnerable=="nolossvulnerable" ~ "established opportunity",
                                    continuedlow=="yes" ~ "stagnant",
                                    TRUE~ "dynamic")) %>% 
  mutate(`neighborhood category` = factor(neighborhoodtype,
                                          levels = c("stable growing",
                                                     "exclusive growth with displacement risk",
                                                     "decreasing value neighborhood",
                                                     "established opportunity",
                                                     "established opportunity with displacement risk",
                                                     "stagnant",
                                                     "dynamic"
                                          ))) 

sumtract_OTR <- master5 %>% 
  group_by(neighborhoodtype) %>% 
  count() %>% 
  rename(Homevalue_method=n) %>% 
  st_drop_geometry()

test <- master5 %>% 
  filter(GEOID=="11001006804")

displacementarea <- master5 %>% 
  filter(neighborhoodtype=="exclusive growth with displacement risk"|neighborhoodtype=="established opportunity with displacement risk")

urban_colors7 <- c("#73bfe2", "#f5cbdf","#fce39e", "#1696d2" ,"#e9807d","#fdd870","#dcedd9")

test6 <- master5 %>% 
  filter(Ward=="Ward 4") %>% 
  filter(neighborhoodtype=="established opportunity with displacement risk")

ggplot() +
  geom_sf(data =master5, aes( fill = `neighborhood category`))+
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
  geom_sf(data = displacementarea, fill = "transparent", color="#ec008b")+
  coord_sf(datum = NA)+
  labs(title = paste0("Neighborhood Change in DC based on OTR sales data"),
       subtitle= "Potential displacement area highlighted in red",
       caption = "Source: Census 2000, ACS 5-year estimates 2008-2012, 2018-2022, Real Property Tax Database")

summary <- master5 %>% 
  group_by(neighborhoodtype) %>% 
  mutate(total=1) %>% 
  summarise(renter_2022=sum(renter_2022),
            owner_2022=sum(owner_2022),
            totalhh_2022=sum(total_hh_2022),
            black_2022=sum(non_hispanic_black_hh_2022),
            distance=mean(distance_to_downtown_miles),
            pctchangexx=mean(pctchg_lowincome),
            pctchangeblk=mean(pctchange_2012_2022_blk),
            pct_college=mean(pct_college_2022),
            homeprice=mean(medianhome_2022),
            rentlevel=mean(rent_2022, na.rm=TRUE),
            vacancy=mean(vacancy_2022),
            total=sum(total)) %>% 
  mutate(pct_owner=owner_2022/totalhh_2022,
         pct_blck=black_2022/totalhh_2022 ) %>% 
  select(neighborhoodtype,total,homeprice, rentlevel,pct_owner,pct_blck,pctchangexx,pctchangeblk,pct_college,vacancy) %>% 
  st_drop_geometry()

write.csv(summary, "C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/summary_bytype.csv")

type <- master5 %>% 
  select(GEOID, neighborhoodtype) %>% 
  st_drop_geometry()


write.csv(type, "C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/neighborhoodtype_homevalueOTR.csv")

