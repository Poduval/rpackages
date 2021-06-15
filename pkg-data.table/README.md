# pkg-data.table
Exploring and testing it's various features.

## Installation 
CRAN: `install.packages('data.table')` or `install.packages("data.table", repos="https://Rdatatable.gitlab.io/data.table")`

With MacOS `library(data.table)` shows the following message:

data.table _<< version >>_ using 1 threads (see ?getDTthreads).  Latest news: `r-datatable.com`

This installation of data.table has not detected **OpenMP** support. It should still work but in single-threaded mode. This is a Mac. Please read _`https://mac.r-project.org/openmp/`_. Please engage with Apple and ask them for support. Check _`r-datatable.com`_ for updates, and our Mac instructions here: https://github.com/Rdatatable/data.table/wiki/Installation. After several years of many reports of installation problems on Mac, it's time to gingerly point out that there have been no similar problems on Windows or Linux.

## Data

The data used in the example is taken from a kaggle competetion: _`https://www.kaggle.com/c/new-york-city-taxi-fare-prediction`_

New York City Taxi Fare Prediction

The objective here is to predict the fare amount (inclusive of tolls) for a taxi ride in New York City given the pickup and drop off locations. While we can get a basic estimate based on just the distance between the two points, this will result in an RMSE of `$5-$8`, depending on the model used (see the starter code for an example of this approach in Kernels). Our challenge is to do better than this using Machine Learning techniques!

Note: The data is not pushed in the repository. One need to download this from the above link provided. 