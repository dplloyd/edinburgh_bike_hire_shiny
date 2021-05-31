#

library(tidyverse)
library(lubridate)

trips_df <-
  read.csv('data_record_level/edinburgh_hire_all_record_data.csv') %>%
  select(started_at:start_station_id, end_station_id)

glimpse(trips_df)


## Number of outward bound trips for each hour by day #####

trip_counts_out <- trips_df %>%
  mutate(
    day_of_week = weekdays(started_at %>%  as.Date),
    hour_trip_started = hour(started_at)
  ) %>%
  group_by(start_station_id,
           (started_at %>% as.Date()),
           day_of_week,
           hour_trip_started) %>%
  summarise(n_outward_trips = n()) %>%
  ungroup() %>%
  group_by(start_station_id, day_of_week, hour_trip_started) %>%
  summarise(
    mean_n_outward_trip = mean(n_outward_trips),
    median_n_outward_trip = median(n_outward_trips),
    stddev_n_outward_trip = sd(n_outward_trips)
  ) %>%
  ungroup()


trip_counts_in <- trips_df %>%
  mutate(
    day_of_week = weekdays(ended_at %>%  as.Date),
    hour_trip_ended = hour(ended_at)
  ) %>%
  group_by(end_station_id,
           (ended_at %>% as.Date()),
           day_of_week,
           hour_trip_ended) %>%
  summarise(n_inward_trips = n()) %>%
  ungroup() %>%
  group_by(end_station_id, day_of_week, hour_trip_ended) %>%
  summarise(
    mean_n_inward_trip = mean(n_inward_trips),
    median_n_inward_trip = median(n_inward_trips),
    stddev_n_inward_trip = sd(n_inward_trips)
  ) %>%
  ungroup()

trip_counts

# Record the date ranges for trip counts
trip_counts_date_ranges <-
  tibble(
    trip_direction = c("outward", "inward"),
    min_date = c(min(trips_df$started_at), min(trips_df$ended_at)),
    max_date = c(max(trips_df$started_at), max(trips_df$ended_at))
  )


save(trip_counts_in,
     trip_counts_out,
     trip_counts_date_ranges,
     file = "data_for_upload/data_for_app.Rdata")
