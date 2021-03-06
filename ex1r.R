#http://www.ats.ucla.edu/stat/r/dae/logit.htm
start.time <- Sys.time()

library(aod)
library(ggplot2)
library(Rcpp)

setwd('/home/madis/seminar')
mydata <- read.csv("binary.csv")


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