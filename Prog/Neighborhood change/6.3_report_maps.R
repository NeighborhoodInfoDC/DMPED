map <- read.csv("Clean/NeighborhoodTypes_DMPED.csv")

map_risk <-map %>% 
  mutate(GEOID=as.character(GEOID)) %>% 
  left_join(tractboundary_20, by=c("GEOID")) %>% 
  st_as_sf() %>% 
  mutate(population_vulnerability_cat= case_when(
    population_vulnerability_cat == "Lowest" ~ "Lowest risk",
    population_vulnerability_cat == "Lower" ~ "Lower risk",
    population_vulnerability_cat == "Intermediate" ~ "Intermediate risk",
    population_vulnerability_cat == "Higher" ~ "Higher risk",
    population_vulnerability_cat == "Highest" ~ "Highest risk"
  )) %>%
  mutate(housing_condition_cat = case_when(
    housing_condition_cat == "Lowest" ~ "Lowest risk",
    housing_condition_cat == "Lower" ~ "Lower risk",
    housing_condition_cat == "Intermediate" ~ "Intermediate risk",
    housing_condition_cat == "Higher" ~ "Higher risk",
    housing_condition_cat == "Highest" ~ "Highest risk"
  )) %>%
  mutate(market_pressure_cat = case_when(
    market_pressure_cat == "Lowest" ~ "Lowest risk",
    market_pressure_cat == "Lower" ~ "Lower risk",
    market_pressure_cat == "Intermediate" ~ "Intermediate risk",
    market_pressure_cat == "Higher" ~ "Higher risk",
    market_pressure_cat == "Highest" ~ "Highest risk"
  )) %>%
  mutate(displacement_cat = case_when(
    displacement_cat == "Lowest" ~ "Lowest risk",
    displacement_cat == "Lower" ~ "Lower risk",
    displacement_cat == "Intermediate" ~ "Intermediate risk",
    displacement_cat == "Higher" ~ "Higher risk",
    displacement_cat == "Highest" ~ "Highest risk"
  )) %>%
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


ggplot() +
  geom_sf(data =map_risk, aes( fill = `population vulnerability`))+
  scale_fill_manual(name="Population Vulnerabilities", values = urban_vulnerable, guide = guide_legend(override.aes = list(linetype = "blank", 
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

