
# ==== Initialization ====
library(dplyr)
library(data.table)

# ==== Prepare data for testing ====
# Reference: https://github.com/Rdatatable/data.table/wiki/Benchmarks-:-Grouping

N <- 1e8
set.seed(1)

DT <- data.table(id = sample(10000, N, TRUE), v = runif(N))
dim(DT)
object.size(DT)
DT # data.table has a nice print method


# ==== Quick speed/performance checks ====

# Calculation of mean of 100 mio floats is fast in base R as well ====
system.time(mean(DT[["v"]]))
system.time(DT[, mean(v)])

# GROUP BY & LEFT JOIN: Indirect and direct ====

## 1. With Base R ====

# Indirect: aggregate & merge, it crashes: DO NOT EXECUTE
if (FALSE) {
  system.time({
    means_baseR <- aggregate(DT[["v"]], list(id = DT[["id"]]), FUN = mean)
    out <- merge.data.frame(DT, means_baseR, by = "id", all.x = TRUE)
  }) 
}

# Indirect: split & lapply & match, faster approach
system.time({
  means_baseR <- lapply(split(DT[["v"]], DT[["id"]]), mean)
  DT[["means_rbase"]] <- means_baseR[match(DT[["id"]], names(means_baseR))]
})

# user  system elapsed 
# 30.328   1.719  32.054 

# Direct & much faster
system.time({out <- ave(DT[["v"]], DT[["id"]], FUN = mean)})

# user  system elapsed 
# 27.632   2.010  29.638 

## 2. With dplyr ====

# Indirect: group_by & summarize & left_join
system.time({
  means_dplyr <- DT %>% group_by(id) %>% summarize(vmean = mean(v))
  DT <- DT %>% left_join(means_dplyr, by = "id")
})

# user  system elapsed 
# 14.116   2.339  16.481

# Direct: grouped mutate (some improvement in speed)
DT[, vmean := NULL]
system.time({DT <- DT %>% group_by(id) %>% mutate(vmean = mean(v))})

# user  system elapsed 
# 7.274   1.090   8.361

## 3. with data.table ====
setDT(DT)
DT[, vmean := NULL]

# Indirect
system.time({
  means_datatable <- DT[, .(vmean = mean(v)), keyby = "id"]
  DT[means_datatable, vmean := vmean, on = "id"]
})

# user  system elapsed 
# 6.350   1.603   7.957

# Direct (faster)
DT[, vmean := NULL]
system.time({DT[, vmean := mean(v), by = "id"]})

# user  system elapsed 
# 5.178   0.587   5.768

# With some trick: Keyed data.table (fastest, the best)
setkey(DT, id)  
system.time({DT[, vmean := mean(v), by = "id"]})

# user  system elapsed 
# 1.212   0.005   1.219 
