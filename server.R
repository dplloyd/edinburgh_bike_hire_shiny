library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)
library(plotly)
library(ggplot2)
library(lubridate)

# Function sources all files in named directory
sourceDir <- function(path, trace = TRUE, ...) {
    for (nm in list.files(path, pattern = "\\.[RrSsQq]$")) {
        if (trace)
            cat(nm, ":")
        source(file.path(path, nm), ...)
        if (trace)
            cat("\n")
    }
}
#Read in all function files.
sourceDir("src/")


##   Reading station information ######

base_url <- "https://gbfs.urbansharing.com/edinburghcyclehire.com"

station_information <-
    get_api_data_edinburgh_cycle_hire("diarmuid lloyd - toy dash",
                                      base_url,
                                      "station_information.json")

station_status <-
    get_api_data_edinburgh_cycle_hire("diarmuid lloyd - toy dash", base_url, "station_status.json")

station_info_status <-
    left_join(station_information, station_status, by = "station_id")

## Reading pre-computed data

load("data_for_upload/data_for_app.Rdata")




#### Pin colours for map, and adding bike icon.

getColor <- function(.station_info) {
    sapply(.station_info$num_bikes_available, function(num_bikes_available) {
        if (num_bikes_available == 0) {
            "lightgray"
        } else if (num_bikes_available <= 2) {
            "red"
        } else if (num_bikes_available <= 3) {
            "orange"
        } else {
            "green"
        }
    })
}

icons <- awesomeIcons(
    icon = 'fa-bicycle',
    iconColor = 'black',
    library = 'fa',
    markerColor = getColor(station_info_status)
)

# Plot themes ----
# Absolute panel plots
theme_panel <-
    theme(
        panel.background = element_rect(fill = "transparent", colour = NA),
        plot.background = element_rect(fill = "transparent", colour = NA),
        legend.position = "none"
    )

# Main server function ----
function(input, output, session) {
    # MAP ----
    
    # Create the map
    output$map <- renderLeaflet({
        leaflet() %>%
            addTiles() %>%
            addProviderTiles(providers$Stamen.TonerLite) %>%
            setView(lng = -3.21049,
                    lat = 55.94714,
                    zoom = 12) %>%
            addAwesomeMarkers(
                lng = station_info_status$lon ,
                lat = station_info_status$lat ,
                layerId = station_info_status$station_id,
                icon = icons,
                popup = paste0(
                    "<b>"
                    ,
                    station_info_status$name
                    ,
                    "</b>",
                    "<br>",
                    "Available bikes: ",
                    station_info_status$num_bikes_available,
                    "<br>",
                    "Parking spaces: ",
                    station_info_status$num_docks_available
                )
            )
        
        
    })
    
    # OBSERVATION EVENTS ----
    
    observeEvent(input$map_marker_click, {
        click <- input$map_marker_click
        station_clicked <-
            station_info_status[which(station_info_status$station_id == click$id),]
        
        # print(click)
        print(click)
        
    })
    
    # REACTIVE DATASETS ----
    
    map_selected_station_reactive <- reactive({
        if (!is.null(input$map_marker_click$id)) {
            station_info_status %>% dplyr::filter(station_id == input$map_marker_click$id)
        } else{
            station_info_status %>%  filter(station_id == min(station_id))
        }
    })
    
    map_data_react_trips_in <- reactive({
        if (!is.null(input$map_marker_click$id)) {
            trip_counts_in %>% dplyr::filter(end_station_id == input$map_marker_click$id)
        } else{
            trip_counts_in %>% filter(end_station_id == min(end_station_id))
        }
        
    })
    
    
    map_data_react_trips_out <- reactive({
        if (!is.null(input$map_marker_click$id)) {
            trip_counts_out %>% dplyr::filter(start_station_id == input$map_marker_click$id)
        } else{
            trip_counts_out %>% filter(start_station_id == min(start_station_id))
        }
        
    })
    
    
    # PLOTS ----
    
    output$outward_counts <- renderPlotly({
        outward_trips_plot <-
            map_data_react_trips_out() %>% filter(day_of_week == (today() %>% weekdays())) %>%
            ggplot(aes(
                hour_trip_started,
                median_n_outward_trip,
                fill = ifelse(hour_trip_started == hour_now, "highlighted", "normal")
            )) +
            geom_col() +
            scale_x_continuous(limits = c(0, 24), name = "Hour") +
            scale_y_continuous(name = "Median leavng trips") +
            scale_fill_manual(name = "hour_trip_started",
                              values = c("#18BC9C", "grey50")) +
            theme_panel
        
        ggplotly(outward_trips_plot) %>% plotly::config(displayModeBar = F)
        
    })
    
    
    
    output$inward_counts <- renderPlotly({
        inward_trips_plot <-
            map_data_react_trips_in() %>% filter(day_of_week == (today() %>% weekdays())) %>%
            ggplot(aes(
                hour_trip_ended,
                median_n_inward_trip,
                fill = ifelse(hour_trip_ended == hour_now, "highlighted", "normal")
            )) +
            geom_col() +
            scale_x_continuous(limits = c(0, 24), name = "Hour") +
            scale_fill_manual(name = "hour_trip_ended",
                              values = c("#18BC9C", "grey50")) +
            scale_y_continuous(name = "Median arriving trips") +
            theme_panel
        
        ggplotly(inward_trips_plot) %>% plotly::config(displayModeBar = F)
        
    })
    
    
    # TEXT  ----
    
    output$counts_header <- renderUI({
        HTML(
            "These plots give an overview of bike hire demand. They summarise, by hour, the median number of outward bound trips, inward bound trips, and capacity for the selected hire station on a <b>",
            today() %>% weekdays(),
            "</b>",
            ". <hr>"
        )
    })
    
    output$counts_station_selected_title <- renderUI({
        HTML("<h2>", map_selected_station_reactive() %>% pull(name), "</h2>")
    })
    
    output$outbound_counts_header <- renderUI({
        HTML("<h4>Trips leaving station </h4>",
            "Between ",
            current_hour_interval_as_string(),
            " there are on average  ",
            map_data_react_trips_out() %>% filter(
                day_of_week == (today() %>% weekdays()),
                hour_trip_started == hour_now
            ) %>% pull(median_n_outward_trip),
            " trips starting here.<br>"
        )
    })
    
    output$inbound_counts_header <- renderUI({
        HTML("<h4>Trips arriving at station </h4>",
            "Between ",
            current_hour_interval_as_string(),
            " there are on average  ",
            map_data_react_trips_in() %>% filter(
                day_of_week == (today() %>% weekdays()),
                hour_trip_ended == hour_now
            ) %>% pull(median_n_inward_trip),
            " trips finishing here.<br>"
        )
    })
    
    output$counts_note <- renderText({
        paste0(
            "<br>Average number of trips based on data between ",
            trip_counts_date_ranges$min_date %>% as.Date() %>%  min(),
            " and ",
            trip_counts_date_ranges$max_date %>% as.Date() %>% max(),
            "."
        )
    })
    
    
}