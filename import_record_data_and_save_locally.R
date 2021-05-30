# Script creates a local version of the edinburgh hire data in its entirety.
# Only downloads what is missing.
#--------


library(tidyverse)
library(readr)
library(jsonlite)
library(lubridate)
library(zoo)

# Paths to bike trip data, updated daily.
base_url <-
  c("https://data.urbansharing.com/edinburghcyclehire.com/trips/v1/")


dates_to_now <-
  seq.Date(from = as.Date("2018-09-01"),
           to = Sys.Date(),
           by = "month")  %>% as_tibble()

dates_to_now <-
  dates_to_now %>%  mutate(months = month(value) %>% str_pad(2, pad = 0),
                           years = year(value))

urls_to_read <-
  glue::glue(base_url,
             "{dates_to_now$years}",
             "/",
             "{dates_to_now$months}",
             ".csv")


# Check if a data file holding record level data exists. If not, read in all the 
# records

if (file.exists('data_record_level/edinburgh_hire_all_record_data.csv')) {
  #read in started_at column to find latest trip
  mycols <- rep("NULL", 13)
  mycols[2] <- NA
  latest_trip_saved <-
    read.csv('data_record_level/edinburgh_hire_all_record_data.csv',
             colClasses = mycols) %>%
    tail(1) %>%
    mutate(started_at = as.Date(started_at))
  
  # Keep only urls to read which are equal to or greater in date than the latest
  # currently saved trip
  
  dates_to_now_filtered <-
    dates_to_now %>% filter(zoo::as.yearmon(value) >= zoo::as.yearmon(latest_trip_saved$started_at))
  
  urls_to_read <-
    glue::glue(
      base_url,
      "{dates_to_now_filtered$years}",
      "/",
      "{dates_to_now_filtered$months}",
      ".csv"
    )
  
  missing_data <- lapply(urls_to_read, read.csv)
  
  missing_data_df <- do.call(rbind.data.frame, missing_data)
  
  all_data_df <-
    read.csv('data_record_level/edinburgh_hire_all_record_data.csv') %>%
    filter(as.Date(started_at) < (dates_to_now$value %>% tail(1))) %>% select(-X)
  
  all_data_df = rbind(all_data_df, missing_data_df)
  
} else{
  # we read in everything from scratch
  all_data <- lapply(urls_to_read, read.csv)
  
  all_data_df <- do.call(rbind.data.frame, all_data)
  
  
}

# Write data frame
write.csv(all_data_df, file = "data_record_level/edinburgh_hire_all_record_data.csv")
