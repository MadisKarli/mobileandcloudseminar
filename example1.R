#The purpose of this script is to find if trying to convert every line from sparkR to R offers better performance
#initial R script from
#http://www.ats.ucla.edu/stat/r/dae/logit.htm
start.time <- Sys.time()

library(aod)
library(ggplot2)
library(Rcpp)
library(SparkR, lib.loc = "/home/madis/spark2/R/lib")

setwd('/home/madis/seminar')
Sys.setenv(SPARK_HOME=paste("/home/madis/spark2"))
.libPaths(c(file.path(Sys.getenv("SPARK_HOME"), "R", "lib"), .libPaths()))
sparkR.session(spark.sql.crossJoin.enabled = TRUE)

mydata <- read.df('binary.csv', "csv", header = "true", inferSchema = "true", na.strings = "NA")

mylogit <- glm(admit ~ gre + gpa + rank, data = mydata, family = "binomial")

newdata1a <- join(agg(mydata, gre = mean(mydata$gre), gpa = mean(mydata$gpa)), createDataFrame(list(0,1,2,3), schema = list("rank")))

#1 - viia kõik sparkR'i
#2 - vaadata kas on ikka kõike sparkRS vaja. osad asjad on parem R-is teha
newdata1 <- SparkR::predict(mylogit, newdata1a)
#prediction: 1 - prediction

#with -> agg
#not completely the same because factor and it's levels
newdata2 <- join(agg(mydata, gpa = mean(mydata$gpa)),createDataFrame(as.list(rep(seq(from = 200, to = 800, length.out = 100), 4)), schema = list("gre")))
newdata2 <- join(newdata2, createDataFrame(as.list(1:4), schema = list("rank")))

#seq saab listist ja siis 3 kordne join
#mis on s4 funktsioon
#newdata2 <- with(mydata,
#data.frame(gre = rep(seq(from = 200, to = 800, length.out = 100), 4),
#           gpa = mean(gpa), rank = factor(rep(1:4, each = 100))))
newdata2$rank = as.integer(newdata2[,"rank"])
newdata2 <- createDataFrame(newdata2, list("gre", "gpa", "rank")) 


#newdata3 <- cbind(newdata2, stats::predict(mylogit, newdata = newdata2, type="link", se=TRUE))
newdata2predict <- SparkR::predict(mylogit, newdata2)
#we cannot plot dataframes


newdata3 <- as.data.frame(newdata2predict)



#ewdata3 <- within(newdata3, {
#  PredictedProb <- plogis(fit)
#  LL <- plogis(fit - (1.96 * se.fit))
#  UL <- plogis(fit + (1.96 * se.fit))
#})

ggplot(newdata3, aes(x = gre, y = prediction)) + 
  geom_line(aes(color = rank), size = 1)

end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken
