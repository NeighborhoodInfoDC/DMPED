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

analysismaster <- housingmarket %>% 
  left_join(lowincome, by=c("GEOID")) %>% 
  left_join(raceethnicity, by=c("GEOID"))

tractboundary_20 <- get_acs(geography = "tract", 
                            variables = c("B01003_001"),
                            state = "DC",
                            geometry = TRUE,
                            year = 2022)

neighborhood = "W:/Libraries/OCTO/Maps/Neighborhood_Clusters.shp"
neighborhood_sf <- read_sf(dsn= neighborhood, layer= basename(strsplit(neighborhood, "\\.")[[1]])[1])

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
map_file <- merge(analysismaster,tractboundary_20, by=c("GEOID")) %>% 
  st_as_sf()

droptract <- c("11001000201", "11001009511", "11001980000", "11001006804")

######test treshold for which tracts to drop in the analysis 
pop <- map_file %>% 
  select(GEOID,total_hh_2012_2020,total_hh_2000_2020, total_hh_2022,medianhome_2000_2020, NBH_NAMES) %>% 
  mutate(pct_black_2000=non_hispanic_black_hh_2000_2020/total_hh_2000_2020,
         pct_black_2012=non_hispanic_black_hh_2012_2020/total_hh_2012_2020,
         pct_black_2022=non_hispanic_black_hh_2022/total_hh_2022) %>% 
  # select(GEOID, NBH_NAMES, total_hh_2022, pct_black_2000, pct_black_2012,pct_black_2022) %>% 
  mutate(changeinblack=pct_black_2022-pct_black_2012) %>% 
  filter(changeinblack<0)

changeinlowincome <- map_file %>% 
  # select(GEOID,lowincome_2000_2020,lowincome_2012_2020,lowincome_2022, total_hh_2000_2020, total_hh_2012_2020,total_hh_2022,NBH_NAMES) %>% 
  mutate(pct_lowincome_2000=lowincome_2000_2020/total_hh_2000_2020,
         pct_lowincome_2012=lowincome_2012_2020/total_hh_2012_2020,
         pct_lowincome_2022=lowincome_2022/total_hh_2022) %>% 
  # select(GEOID, NBH_NAMES, total_hh_2022, pct_lowincome_2000, pct_lowincome_2012,pct_lowincome_2022,lowincome_2022,lowincome_2012_2020) %>% 
  mutate(pctchg_lowincome=pct_lowincome_2022-pct_lowincome_2012,
         change_lowincome=lowincome_2022-lowincome_2012_2020) %>% 
st_centroid() %>% 
  filter(change_lowincome<0)

changeinblack %>%
  ggplot() +
  geom_sf(aes(
    # Color in states by the chip_pct variable
    fill = changeinblack
  )) +
  scale_fill_steps(
    # Convert legend from decimal to percentages
    labels = scales::percent_format(),
    # Make legend title more readable
    name = "change in black %",
    # Show top and bottom limits on legend
    show.limits = TRUE,
    # Roughly set number of bins. Won't be exact as R uses algorithms under the
    # hood for pretty looking breaks.
    n.breaks = 4
  )+
  geom_sf(
    data = changeinlowincome,
    # Size bubbles by number of trucks at each station
    aes(size =-change_lowincome),
    color = palette_urbn_main["red"],
    # Adjust transparency for readability
    alpha = 0.7
  )  +
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
  labs(title = paste0("Neighborhood change 2012-2022"),
       subtitle= "loss of lowincome and black households",
       caption = "Source: ACS 5 year estiamtes, 2012; 2022")

changeoverall <- map_file %>% 
  mutate(pct_black_2000=non_hispanic_black_hh_2000_2020/total_hh_2000_2020,
         pct_black_2012=non_hispanic_black_hh_2012_2020/total_hh_2012_2020,
         pct_black_2022=non_hispanic_black_hh_2022/total_hh_2022,
         pct_lowincome_2000=lowincome_2000_2020/total_hh_2000_2020,
         pct_lowincome_2012=lowincome_2012_2020/total_hh_2012_2020,
         pct_lowincome_2022=lowincome_2022/total_hh_2022) %>% 
  mutate(changeinblack=pct_black_2022-pct_black_2012,
         pctchg_lowincome=pct_lowincome_2022-pct_lowincome_2012,
         change_lowincome=lowincome_2022-lowincome_2012_2020) %>% 
  mutate(location=ifelse(Ward=="Ward 7"|Ward=="Ward 8","East of River","West of River"))

changeoverall %>% 
  ggplot(mapping = aes(x = changeinblack, y = pctchg_lowincome)) +
  ggplot2::geom_point(mapping = aes(size = total_hh_2022,color = location), alpha = 0.5) +
  scale_x_continuous(
                     limits = c(-0.5, 0.5)) +
  scale_y_continuous(
                     limits = c(-0.5, 0.5)) +
  scale_radius(range = c(3, 15),
               breaks = c(250, 1000, 2000), 
               labels = scales::comma) +
  labs(x = "Household income",
       y = "Homeownership rate") +
  scatter_grid() +
  theme(plot.margin = margin(r = 20))


###################################change in vulnerable 2000-2012
changeinblack <- map_file %>% 
  # select(GEOID,non_hispanic_black_hh_2000_2020,non_hispanic_black_hh_2012_2020,non_hispanic_black_hh_2022, total_hh_2000_2020, total_hh_2012_2020,total_hh_2022,NBH_NAMES) %>% 
  mutate(pct_black_2000=non_hispanic_black_hh_2000_2020/total_hh_2000_2020,
         pct_black_2012=non_hispanic_black_hh_2012_2020/total_hh_2012_2020,
         pct_black_2022=non_hispanic_black_hh_2022/total_hh_2022) %>% 
  select(GEOID, NBH_NAMES, total_hh_2022, pct_black_2000, pct_black_2012,pct_black_2022) %>% 
  mutate(changeinblack=pct_black_2012-pct_black_2000) %>% 
  filter(changeinblack<0)

changeinlowincome <- map_file %>% 
  # select(GEOID,lowincome_2000_2020,lowincome_2012_2020,lowincome_2022, total_hh_2000_2020, total_hh_2012_2020,total_hh_2022,NBH_NAMES) %>% 
  mutate(pct_lowincome_2000=lowincome_2000_2020/total_hh_2000_2020,
         pct_lowincome_2012=lowincome_2012_2020/total_hh_2012_2020,
         pct_lowincome_2022=lowincome_2022/total_hh_2022) %>% 
  # select(GEOID, NBH_NAMES, total_hh_2022, pct_lowincome_2000, pct_lowincome_2012,pct_lowincome_2022,lowincome_2022,lowincome_2012_2020) %>% 
  mutate(pctchg_lowincome=pct_lowincome_2012-pct_lowincome_2000,
         change_lowincome=lowincome_2012_2020-lowincome_2000_2020) %>% 
  st_centroid() %>% 
  filter(change_lowincome<0)

changeinblack %>%
  ggplot() +
  geom_sf(aes(
    # Color in states by the chip_pct variable
    fill = changeinblack
  )) +
  scale_fill_steps(
    # Convert legend from decimal to percentages
    labels = scales::percent_format(),
    # Make legend title more readable
    name = "change in black %",
    # Show top and bottom limits on legend
    show.limits = TRUE,
    # Roughly set number of bins. Won't be exact as R uses algorithms under the
    # hood for pretty looking breaks.
    n.breaks = 4
  )+
  geom_sf(
    data = changeinlowincome,
    # Size bubbles by number of trucks at each station
    aes(size =-change_lowincome),
    color = palette_urbn_main["red"],
    # Adjust transparency for readability
    alpha = 0.7
  )  +
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
  labs(title = paste0("Neighborhood change 2000-2012"),
       subtitle= "loss of lowincome and black households",
       caption = "Source: ACS 5 year estiamtes 2012, Census 2000")



###################################change in vulnerable 2000-2022
changeinblack <- map_file %>% 
  # select(GEOID,non_hispanic_black_hh_2000_2020,non_hispanic_black_hh_2012_2020,non_hispanic_black_hh_2022, total_hh_2000_2020, total_hh_2012_2020,total_hh_2022,NBH_NAMES) %>% 
  mutate(pct_black_2000=non_hispanic_black_hh_2000_2020/total_hh_2000_2020,
         pct_black_2012=non_hispanic_black_hh_2012_2020/total_hh_2012_2020,
         pct_black_2022=non_hispanic_black_hh_2022/total_hh_2022) %>% 
  # select(GEOID, NBH_NAMES, total_hh_2022, pct_black_2000, pct_black_2012,pct_black_2022) %>% 
  mutate(changeinblack=pct_black_2022-pct_black_2000) %>% 
  filter(changeinblack<0)

changeinlowincome <- map_file %>% 
  # select(GEOID,lowincome_2000_2020,lowincome_2012_2020,lowincome_2022, total_hh_2000_2020, total_hh_2012_2020,total_hh_2022,NBH_NAMES) %>% 
  mutate(pct_lowincome_2000=lowincome_2000_2020/total_hh_2000_2020,
         pct_lowincome_2012=lowincome_2012_2020/total_hh_2012_2020,
         pct_lowincome_2022=lowincome_2022/total_hh_2022) %>% 
  # select(GEOID, NBH_NAMES, total_hh_2022, pct_lowincome_2000, pct_lowincome_2012,pct_lowincome_2022,lowincome_2022,lowincome_2012_2020) %>% 
  mutate(pctchg_lowincome=pct_lowincome_2022-pct_lowincome_2000,
         change_lowincome=lowincome_2022-lowincome_2000_2020) %>% 
  st_centroid() %>% 
  filter(change_lowincome<0)

changeinblack %>%
  ggplot() +
  geom_sf(aes(
    # Color in states by the chip_pct variable
    fill = changeinblack
  )) +
  scale_fill_steps(
    # Convert legend from decimal to percentages
    labels = scales::percent_format(),
    # Make legend title more readable
    name = "change in black %",
    # Show top and bottom limits on legend
    show.limits = TRUE,
    # Roughly set number of bins. Won't be exact as R uses algorithms under the
    # hood for pretty looking breaks.
    n.breaks = 4
  )+
  geom_sf(
    data = changeinlowincome,
    # Size bubbles by number of trucks at each station
    aes(size =-change_lowincome),
    color = palette_urbn_main["red"],
    # Adjust transparency for readability
    alpha = 0.7
  )  +
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
  labs(title = paste0("Neighborhood change 2000-2022"),
       subtitle= "loss of lowincome and black households",
       caption = "Source: ACS 5 year estiamtes 2022, Census 2000")