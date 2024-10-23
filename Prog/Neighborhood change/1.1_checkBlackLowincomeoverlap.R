# Install pacman if not already installed
if (!require("pacman")) install.packages("pacman")

# Load the required packages using pacman
pacman::p_load(
  tidyverse, DescTools, purrr, tidycensus, mapview, stringr, educationdata, sf, 
  readxl, urbnthemes, sp, ipumsr, survey, srvyr, dplyr, Hmisc, haven, caret, 
  boot, corrplot, stargazer
)

# census_api_key("05de4dca638d81abd2dc60d0d28e3781183e185e", install = TRUE)

#update to your Box drive directory
setwd("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/")

Crosswalk_2000_to_2010 <- read_csv("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Raw/tract crosswalks/nhgis_tr2000_tr2010_11.csv") %>% 
  mutate(GEOID = as.character(tr2000ge))
# Crosswalk_2020_to_2010 <- read_csv("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Raw/tract crosswalks/nhgis_tr2020_tr2010_11.csv")
Crosswalk_2010_to_2020 <- read_csv("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Raw/tract crosswalks/nhgis_tr2010_tr2020_11.csv") %>% 
  mutate(GEOID=as.character(tr2010ge))
v22 <- load_variables(2022, "acs5", cache = TRUE)
v12 <- load_variables(2012, "acs5", cache = TRUE)
subject22 <- load_variables(2022, "acs5/subject", cache = TRUE)
subject12 <- load_variables(2012, "acs5/subject", cache = TRUE)
v2000 <- load_variables(2000, "sf3", cache = TRUE)
#####################LOW INCOME POPULATION####################################################

#HUD INCOME LIMIT 60% for 2 person household in 2022 is 68400, S1901_C01_007 gives $50,000 to $74,999 - the total is weird, use normal table instead
#HUD INCOME LIMIT 60% for 2 person household in 2022 is 68400, B19001_012 gives $60,000 to $74,999

lowincomeblack_2022<- 
  get_acs(geography = "tract",
          variables =  c("B19001B_002","B19001B_003","B19001B_004","B19001B_005","B19001B_006","B19001B_007","B19001B_008","B19001B_009","B19001B_010","B19001B_011","B19001B_012"),
          year = 2022,
          state = "DC",
          geometry = FALSE)%>% 
  pivot_wider(id_cols = c(GEOID, NAME),
              names_from = variable,
              values_from = c(estimate, moe))%>%
  replace(is.na(.), 0) %>% 
  mutate(lowincomeblack_2022=as.numeric(estimate_B19001B_002)+as.numeric(estimate_B19001B_003)+as.numeric(estimate_B19001B_004)+as.numeric(estimate_B19001B_005)+as.numeric(estimate_B19001B_006)+as.numeric(estimate_B19001B_007)
         +as.numeric(estimate_B19001B_008)
         +as.numeric(estimate_B19001B_009)
         +as.numeric(estimate_B19001B_010)
         +as.numeric(estimate_B19001B_011)
         +as.numeric(estimate_B19001B_012)*0.56) %>% 
  select(GEOID, lowincomeblack_2022)


#HUD INCOME LIMIT 60% for 2 person household in 2012 is 51600, B19001A_011 gives $50,000 to $59,999
lowincomeblack_2012<- 
  get_acs(geography = "tract",
          variables =  c("B19001B_002","B19001B_003","B19001B_004","B19001B_005","B19001B_006","B19001B_007","B19001B_008","B19001B_009","B19001B_010","B19001B_011"),
          year = 2012,
          state = "DC",
          geometry = FALSE)%>% 
  pivot_wider(id_cols = c(GEOID, NAME),
              names_from = variable,
              values_from = c(estimate, moe))%>%
  replace(is.na(.), 0) %>% 
  mutate(lowincomeblack_2012=as.numeric(estimate_B19001B_002)+as.numeric(estimate_B19001B_003)+as.numeric(estimate_B19001B_004)+as.numeric(estimate_B19001B_005)+as.numeric(estimate_B19001B_006)+as.numeric(estimate_B19001B_007)
         +as.numeric(estimate_B19001B_008)
         +as.numeric(estimate_B19001B_009)
         +as.numeric(estimate_B19001B_010)
         +as.numeric(estimate_B19001B_011)*0.16)%>% 
  select(GEOID, lowincomeblack_2012)


# Crosswalk 2012 to 2020
consolidated_2010_2020_lowincome <-Crosswalk_2010_to_2020 %>% 
  left_join(lowincomeblack_2012, by=c("GEOID")) %>% 
  mutate(lowincome2012_subpart=lowincomeblack_2012*wt_pop) %>% 
  group_by(tr2020ge) %>% 
  summarise(lowincomeblack_2012_2020 = sum(lowincome2012_subpart, na.rm= TRUE)) 

lowincomeblack <- consolidated_2010_2020_lowincome %>% 
  mutate(GEOID=as.character(tr2020ge)) %>% 
  left_join(lowincomeblack_2022,by=c("GEOID"))

write.csv(lowincomeblack,"C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/lowincomeblack_pop.csv" )

lowincome <- read.csv("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/lowincome_pop.csv")

lowincblacksummary <- lowincome %>% 
  mutate(GEOID=as.character(GEOID)) %>% 
  left_join(lowincomeblack) %>% 
  mutate(total="total") %>% 
  group_by(total) %>% 
  summarise(lowincome_2022=sum(lowincome_2022),
            lowincome_2012_2020=sum(lowincome_2012_2020),
            lowincomeblack_2012_2020=sum(lowincomeblack_2012_2020),
            lowincomeblack_2022=sum(lowincomeblack_2022))

write.csv(lowincblacksummary,"C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Clean/lowincblacksummary.csv" )

lowincomesummary <- lowincome %>% 
  select(lowincome_2012_2020,lowincome_2022)

#validate against HUD QCT (2022) per DMPED feedback
#per discussion aggregate low income household estiamtes to PUMA and compare results

QCT <- read.csv("Raw/QCT2022.csv") %>% 
  filter(statefp==11) #61 tracts
#this gives a list of identified tracts, per our past table, the 10 percent
#threshold gives about 80 tracts
#next step is to try using loss of lowincome and blck population both in terms of percentage and absolute value

dc_pums_22 <- get_pums(
  variables = c("PUMA","SERIALNO", "SEX", "AGEP","WAGP" ,"SCHL","JWMNP","TAXAMT","RAC1P", "HISP", "HUPAC", "R65", "TEN", "VALP","BDSP","NP" ,"HINCP","GRNTP", "OCPIP","BLD"),
  state = "DC",
  survey = "acs1",
  year = 2022
) %>% 
  mutate(jur="DC") 

lowincome_pums <- dc_pums_22%>% 
  filter(!is.na(HINCP)) %>% 
  mutate(lowincome=ifelse(HINCP<68400,"lowincome","notlowincome")) %>% 
  filter(lowincome=="lowincome") %>% 
  distinct(SERIALNO, .keep_all = TRUE) %>%  # Ensure each household is counted once
  count(PUMA, lowincome, wt = WGTP) 
  
crosswalk <- read.delim("C:/Users/Ysu/Desktop/2020_Census_Tract_to_2020_PUMA.txt",
                        sep =",",header = TRUE) %>% 
  filter(STATEFP==11) %>% 
  mutate(COUNTYFP=str_pad(COUNTYFP,3, pad="0"),
         TRACTCE=str_pad(TRACTCE,6,pad="0"),
         PUMA5CE=str_pad(PUMA5CE,5,pad="0")) %>% 
  mutate(GEOID=paste0(STATEFP,COUNTYFP,TRACTCE))

lowincome_tract_puma <- lowincome %>% 
  mutate(GEOID=as.character(GEOID)) %>% 
  left_join(crosswalk, by=c("GEOID")) %>% 
  group_by(PUMA5CE) %>% 
  summarise(lowincome_analysis=sum(lowincome_2022)) %>% 
  mutate(PUMA=PUMA5CE) %>% 
  left_join(lowincome_pums,by=c("PUMA"))

pumaboundary <- get_acs(
  geography = "public use microdata area", 
  variables = "B01003_001",                
  state = "DC",                           
  year = 2022,                            
  geometry = TRUE                        
) %>% 
  mutate(PUMA=substr(GEOID, 3,7)) %>% 
  left_join(lowincome_tract_puma,by=c("PUMA")) %>% 
  mutate(difference=lowincome_analysis-n) %>% 
  mutate(color = ifelse(difference > 0, "green", "yellow")) 

ggplot(data = pumaboundary) +
  geom_sf(aes(fill = color)) +                       # Fill PUMA regions based on the color mapping
  geom_sf_text(aes(label = difference), size = 3) +  # Add labels showing the difference in each PUMA
  scale_fill_identity() +                            # Use the colors specified directly in the data
  labs(title = "Map of Differences between Actual and Analysis in PUMA Regions",
       fill = "Difference") +
  theme_minimal()       
