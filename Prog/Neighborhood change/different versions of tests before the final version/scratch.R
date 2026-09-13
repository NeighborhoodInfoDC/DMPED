
map_report1 <- merge(analysismaster,tractboundary_20, by=c("GEOID")) %>% 
  mutate(change_black_22=non_hispanic_black_pop_2022-non_hispanic_black_pop_2012_2020,
         change_black_12=non_hispanic_black_pop_2012_2020-non_hispanic_black_pop_2000_2010_2020) %>% 
  select(GEOID, geometry,change_black_22, change_black_12) %>% 
  pivot_longer(cols = c(change_black_22, change_black_12),
               names_to = "variable", values_to = "value") %>% 
  st_as_sf() %>% 
  filter(GEOID!=11001010900 & GEOID!=11001007301)

map_report2 <- merge(analysismaster,tractboundary_20, by=c("GEOID")) %>% 
  mutate(change_lowinc_22=total_hh_2022-total_hh_2012_2020,
         change_lowinc_12=total_hh_2012_2020-total_hh_2000_2020) %>% 
  select(GEOID, geometry,change_lowinc_12, change_lowinc_22) %>% 
  pivot_longer(cols = c(change_lowinc_12, change_lowinc_22),
               names_to = "variable", values_to = "value") %>% 
  st_as_sf() %>% 
  filter(GEOID!=11001010900 & GEOID!=11001007301)

ggplot() +
  geom_sf(data =map_report1, aes( fill = value), color = NA)+
  scale_fill_gradient2(low = "#ec008b", mid = "white", high = "#46abdb", midpoint = 0, 
                       name = "Change in total") +  geom_sf(water_sf, mapping=aes(), fill="#dcdbdb", color="#dcdbdb", size=0.05)+
  coord_sf(datum = NA)+
  facet_wrap(~ variable, ncol = 2, labeller = labeller(
    variable = c("change_black_12" = "Change in Black Population 2000-2010",
                 "change_black_22" = "Change in Black Population 2010-2020"))) +
  # labs(title = "Population and Household Change in DC during 2012-2022",
  #      caption = "Source: Your Data Source") +
  theme_minimal() +
  theme(legend.position = "right")+
  guides(color = guide_legend(override.aes = list(size=5)))+
  theme(
    legend.position = "right",
    strip.text = element_text(size = 14, face = "bold")  # Increases facet title size and makes it bold
  )

ggplot() +
  geom_sf(data = map_report2, aes(fill = value), color = NA) +
  scale_fill_gradient2(
    low = "#ec008b", mid = "white", high = "#46abdb", 
    midpoint = 0, 
    limits = c(-650, 2000),  # Ensure full range is applied
    breaks = c(-500, 0, 1000),  # Explicitly define legend values
    oob = scales::squish,  # Ensure values outside limits are properly mapped
    name = "Change in total"
  ) +
  geom_sf(data = water_sf, fill = "#dcdbdb", color = "#dcdbdb", size = 0.05) +
  coord_sf(datum = NA) +
  facet_wrap(~ variable, ncol = 2, labeller = labeller(
    variable = c("change_lowinc_12" = "Change in Low Income Households 2000-2010",
                 "change_lowinc_22" = "Change in Low Income Households 2010-2020")
  )) +
  theme_minimal() +
  theme(
    legend.position = "right",
    strip.text = element_text(size = 14, face = "bold")  # Increases facet title size and makes it bold
  ) +
  guides(color = guide_legend(override.aes = list(size = 5)))
