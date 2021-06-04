library(shiny)
library(leaflet)
library(shinythemes)
library(plotly)


# Choices for drop-downs
vars <- c(
    "Is SuperZIP?" = "superzip",
    "Centile score" = "centile",
    "College education" = "college",
    "Median income" = "income",
    "Population" = "adultpop"
)


navbarPage(
    "Edinburgh Bike Hire",
    id = "nav",
    theme = shinytheme("flatly"),
    
    tabPanel(
        "Interactive map",
        div(
            class = "outer",
            
            tags$head(# Include our custom CSS
                includeCSS("styles.css"),
                includeScript("gomap.js")),
            
            # If not using custom CSS, set height of leafletOutput to a number instead of percent
            leafletOutput("map", width = "100%", height = "100%"),
            # Shiny versions prior to 0.11 should use class = "modal" instead.
            absolutePanel(
                id = "overall_info",
                class = "panel panel-default",
                fixed = TRUE,
                draggable = TRUE,
                top = 60,
                left = "auto",
                right = 520,
                bottom = "auto",
                width = 250,
                height = "auto",
                
             tableOutput("summary_information")
                
                
            ),
            absolutePanel(
                id = "controls",
                class = "panel panel-default",
                fixed = TRUE,
                draggable = TRUE,
                top = 60,
                left = "auto",
                right = 20,
                bottom = "auto",
                width = 500,
                height = "auto",
                
                h2("Bike departure and arrival trends"),
                
                htmlOutput("counts_header"),
                htmlOutput("counts_station_selected_title"),
                htmlOutput("outbound_counts_header"),
                plotlyOutput("outward_counts", height = 200),
                htmlOutput("inbound_counts_header"),
                plotlyOutput("inward_counts", height = 250),
                htmlOutput("counts_note")
                
            ),
            
            tags$div(
                id = "cite",
                'Data available from',
                tags$a(href = 'https://edinburghcyclehire.com/open-data', 'edinburghcyclehire.com'),
                '| code available ', tags$a(href = 'https://github.com/dplloyd/edinburgh_bike_hire_shiny', 'here')
            )
        )
    )
)