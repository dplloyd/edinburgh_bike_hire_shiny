library(shiny)
library(leaflet)
library(shinythemes)



# Choices for drop-downs
vars <- c(
    "Is SuperZIP?" = "superzip",
    "Centile score" = "centile",
    "College education" = "college",
    "Median income" = "income",
    "Population" = "adultpop"
)


navbarPage("Edinburgh Bike Hire", id="nav", theme = shinytheme("flatly"),
           
           tabPanel("Interactive map",
                    div(class="outer",
                        
                        tags$head(
                            # Include our custom CSS
                            includeCSS("styles.css"),
                            includeScript("gomap.js")
                        ),
                        
                        # If not using custom CSS, set height of leafletOutput to a number instead of percent
                        leafletOutput("map", width="100%", height="100%"),
                        # Shiny versions prior to 0.11 should use class = "modal" instead.
                        absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                      draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                                      width = 330, height = "auto",
                                      
                                      h2("Bike stations"),
                                      
                                      textOutput("outward_counts_header"),
                                      plotlyOutput("outward_counts", height = 200),
                                      plotlyOutput("inward_counts", height = 250)
                        ),
                        
                        tags$div(id="cite",
                                 'Data available from', tags$a(href='https://edinburghcyclehire.com/open-data','edinburghcyclehire.com'), '| mapped by Diarmuid Lloyd.'
                        )
                    )
           ),
           
           tabPanel("Station explorer",
                    fluidRow(
                        column(3,
                               selectInput("states", "States", c("All states"="", structure(state.abb, names=state.name), "Washington, DC"="DC"), multiple=TRUE)
                        ),
                        column(3,
                               conditionalPanel("input.states",
                                                selectInput("cities", "Cities", c("All cities"=""), multiple=TRUE)
                               )
                        ),
                        column(3,
                               conditionalPanel("input.states",
                                                selectInput("zipcodes", "Zipcodes", c("All zipcodes"=""), multiple=TRUE)
                               )
                        )
                    ),
                    fluidRow(
                        column(1,
                               numericInput("minScore", "Min score", min=0, max=100, value=0)
                        ),
                        column(1,
                               numericInput("maxScore", "Max score", min=0, max=100, value=100)
                        )
                    ),
                    hr(),
                    DT::dataTableOutput("ziptable")
           ),
           
           conditionalPanel("false", icon("crosshair"))
)