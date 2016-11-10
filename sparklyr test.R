#The purpose of this script is to test the sparklyr framework
#http://stackoverflow.com/questions/39494484/sparkr-vs-sparklyr
#Since sparklyr translates R to SQL, you can only use very small set of functions in mutate statements:
#That deficiency is somewhat alleviated by Extensions 
library(sparklyr)
library(dplyr)
library(ggplot2)
#spark_install(version = "2.0.0")
#uncomment when running the first time
#it will then provide instructions how to run
setwd('C:\\Users\\Joonas Papoonas\\Google Drive\\Magister\\Seminar\\Practice')
sc <- spark_connect(master = "local")


#read input file
#wine <- spark_read_csv(sc, "mydata", "binary.csv", FALSE)

mydata <- read.csv("binary.csv")
mydata$rank <- factor(mydata$rank)
#overwrite TRUE only because of testing, no actual need when running one time
mydata_tbl <- copy_to(sc, mydata, overwrite = TRUE)
#generalized linear model

mylogit <- mydata_tbl %>% ml_linear_regression(response = admit ~ gre + gpa + rank, family = "binomial")



# newdata1 <- with(mydata, data.frame(gre = mean(gre), 3), rank = factor(1:4))
# 
# newdata1$rankP <- predict(mylogit, newdata = newdata1, type = "response")
# 
# newdata2 <- with(mydata,
#                  data.frame(gre = rep(seq(from = 200, to = 800, length.out = 100), 4),
#                             gpa = 3, rank = factor(rep(1:4, each = 100))))
# 
# newdata3 <- cbind(newdata2, predict(mylogit, newdata = newdata2, type="link", se=TRUE))
# 
# newdata3 <- within(newdata3, {
#   PredictedProb <- plogis(fit)
#   LL <- plogis(fit - (1.96 * se.fit))
#   UL <- plogis(fit + (1.96 * se.fit))
# })
# 
# 
# ggplot(newdata3, aes(x = gre, y = PredictedProb)) +
#   geom_ribbon(aes(ymin = LL, ymax = UL, fill = rank), alpha = .2) +
#   geom_line(aes(colour = rank), size=1)
