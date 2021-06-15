# ==== Initialization ====
library(data.table)
library(moderndive) # For data 

# ==== Get data ====
hp <- house_prices
setDT(hp) # Add data.table class in-place
dim(hp)

# ==== data operations ====

# Select/filter ====
hp[1:2]
hp[grade == 1]
hp[1:2, lat:long] #

# Create new variables in-place/transformations ====
hp[, log_sqft_lot := log(sqft_lot)]
hp

# Sort in-place/ ORDER BY ====
setorder(hp, grade)
hp

# Grouped stats and side effects ====
avg_grade <- hp[, .(grade_N = .N, grade_Mean = mean(price)), keyby = grade]
avg_grade

# alternatively
rollup(hp, .(grade_N = .N, grade_Mean = mean(price)), by = "grade")

hp[, as.list(summary(price)), keyby = grade] 
hp[, c(N = .N, as.list(summary(price))), keyby = grade]

# Plots ====
hst <- hp[, hist(price, breaks = "FD", xlim = c(0, 3e6))]

# Reshaping ====
hp_long <- melt(hp, id.vars = c("id", "condition"), 
                measure.vars = c("sqft_living", "sqft_lot"))
hp_long

dcast(hp_long, condition ~ variable, fun.aggregate = c(mean, sd))

# Left join ====
hp_joined <- avg_grade[hp, on = "grade"]
hp_joined
