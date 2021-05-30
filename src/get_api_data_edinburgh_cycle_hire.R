get_api_data_edinburgh_cycle_hire <- function(.client_id, .base_url , .data ){
  
  stations_get <-
    httr::GET(glue::glue("{.base_url}/{.data}"),
              httr::add_headers("Client-Identifier" = .client_id))
  
  stations_content <- httr::content(stations_get, "text", encoding = "UTF-8")
  
  stations_result <- jsonlite::fromJSON(stations_content)
  
  tibble::as_tibble(stations_result)
  
  stations_df <- stations_result$data$stations
  

  return(stations_df)
  
}
