#================================================================
# Uses data.table package to prepare taxi data 
# https://www.kaggle.com/c/new-york-city-taxi-fare-prediction
# (needs painless registration)
#
# The code avoids any copying of data
#================================================================

library(data.table)
library(lubridate)

#================================================================
# Reads train or test data from csv
#================================================================

system.time(
  dat <- fread("input/train.csv", drop = c(1, 8), nrows = 20e6, nThread = 8)
)
dim(dat)
head(dat)


#================================================================
# Data preparation
#================================================================

# Distance in km between two geocoordinates
dist_km <- function(lat1, lon1, lat2, lon2){
  p <- pi / 180
  a <- 0.5 - cos((lat2 - lat1) * p) / 2 + cos(lat1 * p) * cos(lat2 * p) * 
    (1 - cos((lon2 - lon1) * p)) / 2
  
  12742 * asin(sqrt(a))
}

jfk_coord_lat <- 40.639722
jfk_coord_long <- -73.778889
liberty_statue_lat <- 40.6892
liberty_statue_long <- -74.0445

# Test: Distance from jfk to statue of liberty
dist_km(jfk_coord_lat, jfk_coord_long, liberty_statue_lat, liberty_statue_long)

# Preprocessing of date/time info
dat[, pickup_datetime := ymd_hms(pickup_datetime)]

system.time({
  dat[, `:=`(year = lubridate::year(pickup_datetime), 
             month = lubridate::month(pickup_datetime), 
             day = lubridate::day(pickup_datetime), 
             wday = lubridate::wday(pickup_datetime, week_start = 6), 
             hour = lubridate::hour(pickup_datetime), 
             pickup_datetime = NULL)]
  })

# Preprocessing of lat/long info
system.time({
  dat[, `:=`(dist_l2 = dist_km(pickup_latitude, pickup_longitude, 
                            dropoff_latitude, dropoff_longitude),
             dist_liberty = pmin(dist_km(liberty_statue_lat, liberty_statue_long, 
                                      dropoff_latitude, dropoff_longitude),
                                 dist_km(pickup_latitude, pickup_longitude, 
                                      liberty_statue_lat, liberty_statue_long)), 
             dist_jfk = pmin(dist_km(jfk_coord_lat, jfk_coord_long, 
                                  dropoff_latitude, dropoff_longitude),
                             dist_km(pickup_latitude, pickup_longitude, 
                                  jfk_coord_lat, jfk_coord_long)))]})
      
dat[, c("pickup_longitude", "pickup_latitude", 
        "dropoff_longitude", "dropoff_latitude") := NULL]

head(dat)

# Average fare per trip
dat[, list(Mean = mean(fare_amount)), keyby = "year"]

# Pick valid rows
.s <- with(dat, !is.na(dist_l2) & 
                dist_l2 > 0 & 
                dist_l2 < 100 & 
                dist_liberty < 50 &
                dist_jfk < 100 &
                fare_amount %between% c(2.5, 500))

sum(.s)

# Train/valid/test split
set.seed(345)
ind <- sample(1:3, sum(.s), replace = TRUE, prob = c(8, 1, 1))


#================================================================
# Export
#================================================================

fwrite(dat[.s][ind == 1], file = "data/train.csv", nThread = 8)
fwrite(dat[.s][ind == 2], file = "data/valid.csv", nThread = 8)
fwrite(dat[.s][ind == 3], file = "data/test.csv", nThread = 8)

