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

tractboundary_10 <- get_acs(geography = "tract", 
                variables = c("B01003_001"),
                state = "DC",
                geometry = TRUE,
                year = 2019)

tractboundary_20 <- get_acs(geography = "tract", 
                            variables = c("B01003_001"),
                            state = "DC",
                            geometry = TRUE,
                            year = 2022)

watershp = "W:/Libraries/General/Maps/Waterbodies.shp"
water_sf <- read_sf(dsn= watershp, layer= basename(strsplit(watershp, "\\.")[[1]])[1])

neighborhood = "W:/Libraries/OCTO/Maps/Neighborhood_Clusters.shp"
neighborhood_sf <- read_sf(dsn= neighborhood, layer= basename(strsplit(neighborhood, "\\.")[[1]])[1])

ggplot() +
  geom_sf(neighborhood_sf, mapping=aes(), fill="NA", color="red", size=0.05)+
  coord_sf(datum = NA)

st_crs(neighborhood_sf) <- st_crs(tractboundary_10)

tractboundary_10_2 <- tractboundary_10 %>% 
  st_centroid() %>% 
  st_join(neighborhood_sf) %>% 
  st_drop_geometry() %>% 
  select(GEOID, NBH_NAMES)

tractboundary_10 <- tractboundary_10 %>% 
  left_join(tractboundary_10_2, by=c("GEOID"))

demographics <- read.csv("C:/Users/Ysu/Box/Greater DC/Projects/DMPED Housing Assessment 2024/Task 2 - Nbrhd Change and Displacement Risk Assessment/Data collection/Raw/basic demographics test/nhgis0049_ts_geog2010_tract.csv") %>% 
  filter(STATEA==11)

changeinpop <- demographics %>% 
  select(GISJOIN,CL8AA2000,CL8AA2010,CL8AA2020) %>% 
  mutate(change00_10=CL8AA2010-CL8AA2000,
         change10_20=CL8AA2020-CL8AA2010) %>% 
  mutate(state=substr(GISJOIN,2,3),
         county=substr(GISJOIN,5,7),
         tract=substr(GISJOIN,9,14)) %>% 
  mutate(GEOID=paste0(state, county, tract)) %>% 
  mutate(type=case_when(change00_10<0 &change10_20 <0 ~ "continued loss",
                   change00_10>0 &change10_20 >0 ~ "continued gain",
                   change00_10<0 &change10_20 >0 ~ "trending up since 10",
                   change00_10>0 &change10_20 <0 ~ "trending down since 10")) %>% 
  mutate(overall=change00_10+change10_20) %>% 
  mutate(pct_change=overall/CL8AA2000)

map_file <- merge(changeinpop,tractboundary_10, by=c("GEOID")) %>% 
  st_as_sf()

set_urbn_defaults(style="map")

urban_colors8 <- c("#cfe8f3", "#a2d4ec", "#73bfe2", "#46abdb","#1696d2", "#12719e", "#0a4c6a", "#d2d2d2")
urban_colors6 <- c("#cfe8f3", "#73bfe2", "#46abdb","#1696d2", "#0a4c6a", "#d2d2d2")
urban_colors4 <- c("#ec008b","#12719e","#73bfe2","#eb99c2")


popchange <- map_file %>% 
  mutate(ratebucket = case_when(change00_10<0 &change10_20 <0 ~ "continued loss",
                                change00_10>0 &change10_20 >0 ~ "continued gain",
                                change00_10<0 &change10_20 >0 ~ "trending up since 10",
                                change00_10>0 &change10_20 <0 ~ "trending down since 10"
  )) %>% 
  mutate(`change category` = factor(ratebucket,
                                         levels = c("continued loss",
                                                    "continued gain",
                                                    "trending up since 10",
                                                    "trending down since 10"
                                         ))) 

ggplot() +
  geom_sf(data =popchange, aes( fill = `change category`))+
  scale_fill_manual(name="population change type", values = urban_colors4, guide = guide_legend(override.aes = list(linetype = "blank", 
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
  labs(title = paste0("Food Insecurity Rate in Alabama"),
       subtitle= "BBCF Service Areas highlighted in yellow",
       caption = "Source: USDA Food Environment Atlas, 2015")

ggsave("Food insecurity map.png",
       device = "png",
       width = 8.5,
       height = 8.5,
       path = "C:/Users/Ysu/Documents/Heron/Heron/Heron_capitals/")
