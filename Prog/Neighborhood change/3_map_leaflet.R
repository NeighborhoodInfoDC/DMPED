library(leaflet)

# tract <- tract(cb=T)
# states %>% 
#   leaflet() %>% 
#   addTiles() %>% 
#   addPolygons(popup=~NAME)

merged_sb <- map_file %>% 
  filter(!is.na(total_hh_2022)) %>% 
  leaflet() %>% 
  addTiles() %>% 
  addPolygons(popup=~NBH_NAMES) 

test2 <- map_file %>% 
  filter(!is.na(total_hh_2022))

# Creating a color palette based on the number range in the total column
pal <- colorNumeric("Greens", domain=test2$total_hh_2022)

# Setting up the pop up text
popup_sb <- paste0("Total households: ", as.character(test2$total_hh_2022))

leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  setView(-98.483330, 38.712046, zoom = 4) %>% 
  addPolygons(data = merged_sb$geometry, 
              fillColor = ~pal_sb(merged_sb$total_hh_2022), 
              fillOpacity = 0.9, 
              weight = 0.2, 
              smoothFactor = 0.2, 
              popup = ~popup_sb) %>%
  addLegend(pal = pal_sb, 
            values = states_merged_sb_pc$opup_sb <- paste0("<strong>", states_merged_sb_pc$NAME, 
                   "</strong><br />Total: ", states_merged_sb_pc$total,
                   "<br />Per capita: ", 
                   as.character(states_merged_sb_pc$per_capita)), 
            position = "bottomright", 
            title = "Starbucks<br />per 100,000<br/>residents")