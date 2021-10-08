# Setup ====

# _check java version ====
system("java -version")

# java version "1.8.0_301"
# Java(TM) SE Runtime Environment (build 1.8.0_301-b09)
# Java HotSpot(TM) 64-Bit Server VM (build 25.301-b09, mixed mode)

# _check R package version ====
packageVersion("sparklyr") # 1.7.2

# _install spark ====
library(sparklyr)
spark_available_versions() # pick the lates one
spark_install(version = "3.1")
spark_installed_versions()

# spark hadoop                                                   dir
# 1 3.1.1    3.2 /Users/rakesh_poduval/spark/spark-3.1.1-bin-hadoop3.2

# spark_uninstall(version = "1.6.3", hadoop = "2.6")

# Initialize ==== 

library(sparklyr)
sc <- spark_connect(master = "local", version = "3.1")
df <- copy_to(sc, mtcars)
df

spark_web(sc) # web interface
spark_log(sc, filter = "sparklyr")

# Analysis ==== 
library(DBI)
library(dplyr)

dbGetQuery(sc, "SELECT count(*) FROM mtcars")
count(df) 
count(df) %>% show_query()

select(df, hp, mpg) %>%
  sample_n(100) %>%
  collect() %>%
  plot()

df %>% spark_apply(~round(.x))



# Modelling ==== 
model <- ml_linear_regression(df, mpg ~ hp)
model

model %>%
  ml_predict(copy_to(sc, data.frame(hp = 250 + 10 * 1:10))) %>%
  transmute(hp = hp, mpg = prediction) %>%
  full_join(select(df, hp, mpg), by = c("hp", "mpg")) %>%
  collect() %>%
  plot()


spark_disconnect(sc)
