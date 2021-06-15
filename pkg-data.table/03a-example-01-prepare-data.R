# *** Uses data.table package to prepare taxi data ***
# https://www.kaggle.com/c/new-york-city-taxi-fare-prediction
# (needs painless registration)
# The code avoids any copying of data

# ==== Initialization ====
library(data.table)
library(lubridate)

# ==== Reads train or test data from csv ====
system.time(
  df <- fread("pkg-data.table/input/train.csv", drop = c(1, 8), 
              nrows = 20e6, nThread = 8))

# user  system elapsed 
# 24.192   2.073  31.731 
str(df) # 20 Mi observations
head(df)

# ==== Prepare data ====

# Functions ====
#' dist_km
#' @description Function to calculate distance in km between two geo coordinates
#' 
#' @param lat1 latitude of the starting point
#' @param lon1 latitude of the starting point
#' @param lat2 latitude of the ending point
#' @param lon2 latitude of the ending point
#' 
#' @examples
#' # Test: Distance from jfk to statue of liberty
#' jfk_coord_lat <- 40.639722; jfk_coord_long <- -73.778889
#' liberty_statue_lat <- 40.6892; liberty_statue_long <- -74.0445
#' dist_km(jfk_coord_lat, jfk_coord_long, liberty_statue_lat, liberty_statue_long)
#' 
dist_km <- function(lat1, lon1, lat2, lon2){
  p <- pi / 180
  a <- 0.5 - cos((lat2 - lat1) * p) / 2 + cos(lat1 * p) * cos(lat2 * p) * 
    (1 - cos((lon2 - lon1) * p)) / 2
  12742 * asin(sqrt(a))
}

# Pre processing of date/time info ====
df[, pickup_datetime := ymd_hms(pickup_datetime)]

system.time({
  df[, `:=`(year = lubridate::year(pickup_datetime), 
            month = lubridate::month(pickup_datetime), 
            day = lubridate::day(pickup_datetime), 
            wday = lubridate::wday(pickup_datetime, week_start = 6), 
            hour = lubridate::hour(pickup_datetime), 
            pickup_datetime = NULL)]
  })

# user  system elapsed 
# 6.141   1.054   7.192 

# Pre processing of lat/long info ====
system.time({
  df[, `:=`(
    dist_l2 = dist_km(pickup_latitude, pickup_longitude, dropoff_latitude, dropoff_longitude),
    dist_liberty = pmin(dist_km(liberty_statue_lat, liberty_statue_long, dropoff_latitude, dropoff_longitude),
                        dist_km(pickup_latitude, pickup_longitude, liberty_statue_lat, liberty_statue_long)), 
    dist_jfk = pmin(dist_km(jfk_coord_lat, jfk_coord_long, dropoff_latitude, dropoff_longitude), 
                    dist_km(pickup_latitude, pickup_longitude, jfk_coord_lat, jfk_coord_long)))]})
      
# user  system elapsed 
# 5.186   1.159   6.351 

df[, c("pickup_longitude", "pickup_latitude", 
       "dropoff_longitude", "dropoff_latitude") := NULL]

head(df)

# data cleaning/applying filters ====

# Average fare per trip
df[, list(Mean = mean(fare_amount)), keyby = "year"]

# Pick valid rows
.s <- with(df, !is.na(dist_l2) & 
                dist_l2 > 0 & 
                dist_l2 < 100 & 
                dist_liberty < 50 &
                dist_jfk < 100 &
                fare_amount %between% c(2.5, 500))

sum(.s)

# Train/valid/test split ====
set.seed(345)
ind <- sample(1:3, sum(.s), replace = TRUE, prob = c(8, 1, 1))

# ==== Save ====
fwrite(df[.s][ind == 1], file = "pkg-data.table/data/train.csv", nThread = 8)
fwrite(df[.s][ind == 2], file = "pkg-data.table/data/valid.csv", nThread = 8)
fwrite(df[.s][ind == 3], file = "pkg-data.table/data/test.csv", nThread = 8)

