library(caret)
when <- data.frame(
  day = c("Mon", "Mon", "Mon", "Wed", "Wed", "Fri", "Sat", "Sat", "Fri"),
  time = c("afternoon", "night", "afternoon", "morning", "morning", "morning",
           "morning", "afternoon", "afternoon"),
  stringsAsFactors = TRUE)
str(when)

(timeDummy <- dummyVars(~ time, data = when))
cbind(when, predict(timeDummy, when))
