# Function returns string of the current hour interval we are in

current_hour_interval_as_string <- function() {
  hour_now <- lubridate::hour(Sys.time())
  
  if (hour_now == 23) {
    hour_next = 0
  } else{
    hour_next = hour_now + 1
  }
  
  paste0( stringr::str_pad(hour_now,width =  2, pad = "0",side = "left"),":00-",
          stringr::str_pad(hour_next,width =  2, pad = "0",side = "left"),":00")
  
}
