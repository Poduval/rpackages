#================================================================
# Demo of data.tables
#================================================================

# CRAN or install.packages("data.table", repos="https://Rdatatable.gitlab.io/data.table")
library(dplyr)
library(data.table)

#================================================================
# It is fast!
#================================================================

# Code adapted from https://github.com/Rdatatable/data.table/wiki/Benchmarks-:-Grouping

N <- 1e8
set.seed(1)

DT <- data.table(
  id = sample(10000, N, TRUE),
  v = runif(N) 
)
DT
dim(DT)
object.size(DT)

# Calculation of mean of 100 mio floats is fast in base R as well
system.time(
  mean(DT[["v"]])
)
system.time(
  DT[, mean(v)]
)


#================================================================
# GROUP BY & LEFT JOIN: Indirect and direct
#================================================================

# Base R (crashes)
# system.time({
#   # Indirect: aggregate & merge
#   means_baseR <- aggregate(DT[["v"]], list(id = DT[["id"]]), FUN = mean)
#   out <- merge.data.frame(DT, means_baseR, by = "id", all.x = TRUE)
# })

# Base R (faster)
system.time({
  # Indirect: split & lapply & match
  means_baseR <- lapply(split(DT[["v"]], DT[["id"]]), mean)
  DT[["means_rbase"]] <- means_baseR[match(DT[["id"]], names(means_baseR))]

  # # Direct & much faster: ave
  # out <- ave(DT[["v"]], DT[["id"]], FUN = mean)
})
setDT(DT)
DT[, vmean := NULL]

# dplyr
system.time({
  # Indirect: group_by & summarize & left_join
  means_dplyr <- DT %>% 
    group_by(id) %>% 
    summarize(vmean = mean(v))
  DT <- DT %>% 
    left_join(means_dplyr, by = "id")
  
  # # Direct: grouped mutate (same speed)
  # DT <- DT %>% 
  #   group_by(id) %>% 
  #   mutate(vmean = mean(v))
})
setDT(DT)
DT[, vmean := NULL]

# data.table
system.time({
  # indirect
  means_datatable <- DT[, .(vmean = mean(v)), keyby = "id"]
  DT[means_datatable, vmean := vmean, on = "id"]
  
  # # Direct (faster)
  # DT[, vmean := mean(v), by = "id"]
})
DT[, vmean := NULL]

# Keyed data.table
setkey(DT, id)  

system.time({
  # Indirect
  means_datatable <- DT[, .(vmean = mean(v)), keyby = "id"]
  DT[means_datatable, vmean := vmean, on = "id"]
   
  # # Direct
  # DT[, vmean := mean(v), by = "id"]
})


#================================================================
# It is flexible!
#================================================================

library(moderndive) # For data 

# Add data.table class in-place
hp <- house_prices
setDT(hp)
hp

# Select/filter
hp[1:2]
hp[grade == 1]
hp[1:2, lat:long] #

# Create new variables in-place
hp[, log_sqft_lot := log(sqft_lot)]

# Sort in-place
setorder(hp, grade)
hp

# Grouped stats and side effects
(avg_grade <- hp[, .(grade_N = .N, grade_Mean = mean(price)), keyby = grade])
rollup(hp, .(grade_N = .N, grade_Mean = mean(price)), by = "grade")
hp[, as.list(summary(price)), keyby = grade] 
hp[, c(N = .N, as.list(summary(price))), keyby = grade]
hst <- hp[, hist(price, breaks = "FD", xlim = c(0, 3e6))]

# Reshaping
hp_long <- melt(hp, 
                id.vars = c("id", "condition"), 
                measure.vars = c("sqft_living", "sqft_lot"))
dcast(hp_long, condition ~ variable, fun.aggregate = c(mean, sd))

# Left join
hp_joined <- avg_grade[hp, on = "grade"]
hp_joined



     