#The purpose of this script is to find if only reading the data using sparkr offers better performance
#initial R script from
#http://www.ats.ucla.edu/stat/r/dae/logit.htm

#binary.csv
#r 0.52s
#this 1.18 s(spark already running)

#uus.csv (1mil rows)
#r 13.2925 s
#this 1.316651 min (conversion took the most time)

#uus10mil.csv
#r - crashed r-studio
#this caused java.lang.OutOfMemoryError: Java heap space
#and a lot of other errors, no result
start.time <- Sys.time()

library(aod)
library(ggplot2)
library(Rcpp)
library(SparkR, lib.loc = "/home/madis/spark2/R/lib")

setwd('/home/madis/seminar')
Sys.setenv(SPARK_HOME=paste("/home/madis/spark2"))
.libPaths(c(file.path(Sys.getenv("SPARK_HOME"), "R", "lib"), .libPaths()))
sparkR.session(spark.sql.crossJoin.enabled = TRUE)

#read data into sparkR dataframe
mydata <- read.df('uus10mil.csv', "csv", header = "true", inferSchema = "true", na.strings = "NA")

#now convert it to R data.frame and let R handle the calculations
mydata <- as.data.frame(mydata)

mydata$rank <- factor(mydata$rank)
mylogit <- glm(admit ~ gre + gpa + rank, data = mydata, family = "binomial")


newdata1 <- with(mydata, data.frame(gre = mean(gre), gpa = mean(gpa), rank = factor(1:4)))
newdata1$rankP <- predict(mylogit, newdata = newdata1, type = "response")

newdata2 <- with(mydata,
                 data.frame(gre = rep(seq(from = 200, to = 800, length.out = 100), 4),
                            gpa = mean(gpa), rank = factor(rep(1:4, each = 100))))

newdata3 <- cbind(newdata2, predict(mylogit, newdata = newdata2, type="link", se=TRUE))
newdata3 <- within(newdata3, {
  PredictedProb <- plogis(fit)
  LL <- plogis(fit - (1.96 * se.fit))
  UL <- plogis(fit + (1.96 * se.fit))
})


ggplot(newdata3, aes(x = gre, y = PredictedProb)) +
  geom_ribbon(aes(ymin = LL, ymax = UL, fill = rank), alpha = .2) +
  geom_line(aes(colour = rank), size=1)

end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken