
# ==== Initialization ====
library(caret)
library(moderndive) # For data 

# ==== Get data ====
df <- house_prices
dim(df)
summary(df)

# ==== data operations ====

# Train-valid-test split ====

# createFolds() splits the data into k groups 
table(df$zipcode)

set.seed(12345)
.s <- createFolds(df[["zipcode"]], k = 10, list = FALSE)
str(.s)
table(.s)

dim(train <- df[.s >= 4, ])
dim(valid <- df[.s %in% 2:3, ])
dim(test <- df[.s == 1,])
