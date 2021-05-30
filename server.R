library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)
source('src/get_api_data_edinburgh_cycle_hire.R')


##   Reading station information ######

station_information <- get_api_data_edinburgh_cycle_hire("diarmuid lloyd - toy dash", base_url,"station_information.json")

station_status <- get_api_data_edinburgh_cycle_hire("diarmuid lloyd - toy dash", base_url,"station_status.json")

station_info_status <- left_join(station_information,station_status, by = "station_id")



#### ICON colours

getColor <- function(.station_info) {
    sapply(.station_info$num_bikes_available, function(num_bikes_available) {
        if(num_bikes_available <= 4) {
            "red"
        } else if(num_bikes_available <= 6) {
            "orange"
        } else {
            "green"
        } })
}

icons <- awesomeIcons(
    icon = 'fa-bicycle',
    iconColor = 'black',
    library = 'fa',
    markerColor = getColor(station_info_status)
)


function(input, output, session) {
    
    ## Interactive Map ###########################################
    
    # Create the map
    output$map <- renderLeaflet({
        leaflet() %>%
            addTiles() %>%
            addProviderTiles(providers$Stamen.TonerLite) %>% 
            setView(lng = -3.21049, lat = 55.94714, zoom = 12) %>% 
            addAwesomeMarkers(lng = station_info_status$lon ,lat = station_info_status$lat ,
                       layerId = station_info_status$station_id, icon = icons)
    })
    
    observeEvent(input$map_marker_click, { 
        click <- input$map_marker_click  
        station_clicked <- station_info_status[which(station_info_status$station_id == click$id), ]
        
        # print(click)
        print(station_clicked$name)

        
        
        
    })

}