#install.packages("rsconnect") #to publish it using shiny.io


library(shiny)
library(shinydashboard)
library(leaflet)
library(sf)
library(dplyr)
library(ggplot2)
library(tidycensus)

# Source the map.R file
source("map_YES.R")

# Define UI
ui <- dashboardPage(
  dashboardHeader(title = "Neighborhood Change and Displacement in DC"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Change_Home Value", tabName = "map", icon = icon("map")),
      menuItem("Change_Rent Level", tabName = "map2", icon = icon("map")),  # New menu item
      menuItem("Predicted Future Displacement", tabName = "map3", icon = icon("map"))  # New menu item
    )
  ),
  dashboardBody(
    tabItems(
      # Existing Map tab
      tabItem(tabName = "map",
        fluidRow(
          box(
            title = "Neighborhood Categories",
            status = "primary",
            solidHeader = TRUE,
            width = 3,
            actionButton("select_all", "Select All", class = "btn-primary"),
            actionButton("unselect_all", "Unselect All", class = "btn-primary"),
            checkboxGroupInput("neighborhood_category", NULL,
                               choices = unique(master$neighborhoodtype),
                               selected = unique(master$neighborhoodtype))
          ),
          box(
            title = "Neighborhood Change in DC Using Median Home Value",
            status = "primary",
            solidHeader = TRUE,
            width = 9,
            leafletOutput("map", height = "600px"),
            p(
              class = "text-muted",
              style = "font-size: 12px; margin-top: 5px;",
              "Source: Census 2000, ACS 5-year estimates 2008-2012, 2018-2022"
            )
          )
        )
      ),
      
      # New Map2 tab
      tabItem(tabName = "map2",
        fluidRow(
          box(
            title = "Neighborhood Categories",
            status = "primary",
            solidHeader = TRUE,
            width = 3,
            actionButton("select_all2", "Select All", class = "btn-primary"),
            actionButton("unselect_all2", "Unselect All", class = "btn-primary"),
            checkboxGroupInput("neighborhood_category2", NULL,
                               choices = unique(master2$neighborhoodtype),
                               selected = unique(master2$neighborhoodtype))
          ),
          box(
            title = "Neighborhood Change in DC Using Rent Level",
            status = "primary",
            solidHeader = TRUE,
            width = 9,
            leafletOutput("map2", height = "600px"),
            p(
              class = "text-muted",
              style = "font-size: 12px; margin-top: 5px;",
              "Census 2000, ACS 5-year estimates 2008-2012, 2018-2022"
            )
          )
        )
      ),
      
      # New Map3 tab
      tabItem(tabName = "map3",
              fluidRow(
                box(
                  title = "Predicted Displacement Risk Categories",
                  status = "primary",
                  solidHeader = TRUE,
                  width = 3,
                  actionButton("select_all3", "Select All", class = "btn-primary"),
                  actionButton("unselect_all3", "Unselect All", class = "btn-primary"),
                  checkboxGroupInput("neighborhood_category3", NULL,
                                     choices = unique(master3$predictiontype),
                                     selected = unique(master3$predictiontype))
                ),
                box(
                  title = "Predicted Future Displacement Areas",
                  status = "primary",
                  solidHeader = TRUE,
                  width = 9,
                  leafletOutput("map3", height = "600px"),
                  p(
                    class = "text-muted",
                    style = "font-size: 12px; margin-top: 5px;",
                    "Census 2000, ACS 5-year estimates 2008-2012, 2018-2022"
                  )
                )
              )
      )
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  
  # Select All button
  observeEvent(input$select_all, {
    updateCheckboxGroupInput(session, "neighborhood_category",
                             selected = unique(master$neighborhoodtype))
  })
  
  # Unselect All button
  observeEvent(input$unselect_all, {
    updateCheckboxGroupInput(session, "neighborhood_category",
                             selected = character(0))
  })
  
  # Reactive filtered data
  filtered_data <- reactive({
    req(input$neighborhood_category)
    master %>% filter(neighborhoodtype %in% input$neighborhood_category)
  })
  
  # Render the map
  output$map <- renderLeaflet({
    # Start with the base map from map.R
    m %>%
      # Clear existing polygons
      clearShapes() %>%
      # Add base layer of all tracts in DC
      addPolygons(
        data = tractboundary_20,
        fillColor = "transparent",
        color = "#adabac",
        weight = 1,
        opacity = 1
      ) %>%
      # Add filtered polygons
      addPolygons(
        data = filtered_data(),
        fillColor = ~urban_colors7(neighborhoodtype),
        weight = 1,
        opacity = 1,
        color = "white",
        dashArray = "3",
        fillOpacity = 0.7,
        highlightOptions = highlightOptions(
          weight = 5,
          color = "#666",
          dashArray = "",
          fillOpacity = 0.7,
          bringToFront = TRUE
        ),
        label = ~sprintf(
          "Census Tract: %s<br>Neighborhood: %s<br>Type: %s",
          GEOID,  NBH_NAMES, neighborhoodtype
        ) %>% lapply(htmltools::HTML),
        labelOptions = labelOptions(
          style = list("font-weight" = "normal", padding = "3px 8px"),
          textsize = "15px",
          direction = "auto"
        )
      )
  })
  
  # Select All button for Map2
  observeEvent(input$select_all2, {
    updateCheckboxGroupInput(session, "neighborhood_category2",
                             selected = unique(master2$neighborhoodtype))
  })
  
  # Unselect All button for Map2
  observeEvent(input$unselect_all2, {
    updateCheckboxGroupInput(session, "neighborhood_category2",
                             selected = character(0))
  })
  
  # Reactive filtered data for Map2
  filtered_data2 <- reactive({
    req(input$neighborhood_category2)
    master2 %>% filter(neighborhoodtype %in% input$neighborhood_category2)
  })
  
  # Render the map for Map2
  output$map2 <- renderLeaflet({
    # Start with the base map from map.R
    m2 %>%
      # Clear existing polygons
      clearShapes() %>%
      # Add base layer of all tracts in DC
      addPolygons(
        data = tractboundary_20,
        fillColor = "transparent",
        color = "#adabac",
        weight = 1,
        opacity = 1
      ) %>%
      # Add filtered polygons
      addPolygons(
        data = filtered_data2(),
        fillColor = ~urban_colors7_m2(neighborhoodtype),
        weight = 1,
        opacity = 1,
        color = "white",
        dashArray = "3",
        fillOpacity = 0.7,
        highlightOptions = highlightOptions(
          weight = 5,
          color = "#666",
          dashArray = "",
          fillOpacity = 0.7,
          bringToFront = TRUE
        ),
        label = ~sprintf(
          "Census Tract: %s<br>Neighborhood: %s<br>Type: %s",
          GEOID, NBH_NAMES, neighborhoodtype
        ) %>% lapply(htmltools::HTML),
        labelOptions = labelOptions(
          style = list("font-weight" = "normal", padding = "3px 8px"),
          textsize = "15px",
          direction = "auto"
        )
      )
  })
  
  # Select All button for Map3
  observeEvent(input$select_all3, {
    updateCheckboxGroupInput(session, "neighborhood_category3",
                             selected = unique(master3$predictiontype))
  })
  
  # Unselect All button for Map3
  observeEvent(input$unselect_all3, {
    updateCheckboxGroupInput(session, "neighborhood_category3",
                             selected = character(0))
  })
  
  # Reactive filtered data for Map3
  filtered_data3 <- reactive({
    req(input$neighborhood_category3)
    master3 %>% filter(predictiontype %in% input$neighborhood_category3)
  })
  
  # Render the map for Map3
  output$map3 <- renderLeaflet({
    # Start with the base map from map.R
    m3 %>%
      # Clear existing polygons
      clearShapes() %>%
      # Add base layer of all tracts in DC
      addPolygons(
        data = tractboundary_20,
        fillColor = "transparent",
        color = "#adabac",
        weight = 1,
        opacity = 1
      ) %>%
      # Add filtered polygons
      addPolygons(
        data = filtered_data3(),
        fillColor = ~urban_colors4_m3(predictiontype),
        weight = 1,
        opacity = 1,
        color = "white",
        dashArray = "3",
        fillOpacity = 0.7,
        highlightOptions = highlightOptions(
          weight = 5,
          color = "#666",
          dashArray = "",
          fillOpacity = 0.7,
          bringToFront = TRUE
        ),
        label = ~sprintf(
          "Census Tract: %s<br>Neighborhood: %s<br>Displacement Type: %s",
          GEOID, NBH_NAMES, predictiontype
        ) %>% lapply(htmltools::HTML),
        labelOptions = labelOptions(
          style = list("font-weight" = "normal", padding = "3px 8px"),
          textsize = "15px",
          direction = "auto"
        )
      )
  })
  
  
  
}


# Run the application 
shinyApp(ui = ui, server = server)