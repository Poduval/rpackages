# ==== Initialization ====
library(data.table)
library(moderndive) # For data 

# Setup ====
df <- house_prices

# data operations ====
setDT(df) # Add data.table class in-place
dim(df)

# Select & filter ====
df[1:2]
df[grade == 1]
df[1:2, lat:long] #

# Create new variables in-place/transformations ====
df[, log_sqft_lot := log(sqft_lot)]
df

# Sort in-place/ ORDER BY ====
setorder(df, grade)
df

# Grouped stats and side effects ====
avg_grade <- df[, .(grade_N = .N, grade_Mean = mean(price)), 
                keyby = grade]
avg_grade

# alternatively
rollup(df, .(grade_N = .N, grade_Mean = mean(price)), by = "grade")

df[, as.list(summary(price)), keyby = grade] 
df[, c(N = .N, as.list(summary(price))), keyby = grade]

# Plots ====
hst <- df[, hist(price, breaks = "FD", xlim = c(0, 3e6))]

# Reshaping ====
df_long <- melt(df, id.vars = c("id", "condition"), 
                measure.vars = c("sqft_living", "sqft_lot"))
df_long

dcast(df_long, condition ~ variable, fun.aggregate = c(mean, sd))

# Left join ====
df_joined <- avg_grade[df, on = "grade"]
df_joined
