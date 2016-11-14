library(SparkR, lib.loc = "/home/madis/spark2/R/lib")

setwd('/home/madis/seminar')
Sys.setenv(SPARK_HOME=paste("/home/madis/spark2"))
.libPaths(c(file.path(Sys.getenv("SPARK_HOME"), "R", "lib"), .libPaths()))
sparkR.session()

sparkIris <-  createDataFrame(iris)

kc <- spark.kmeans(sparkIris, Sepal_Length ~ Sepal_Width + Petal_Length + Petal_Width, k = 3, initMode = "k-means")

fitted = predict(kc, sparkIris)
kcsummary = summary(kc)

#head(select(fitted, "Sepal_length", "prediction"))
fitted$summary 
fittedR <- as.data.frame(fitted)
fittedR <- cbind(fittedR[1:6], apply(fittedR[7],2, function(x) x + 1))
plot(fittedR[c("Sepal_Length", "Sepal_Width")], col = fittedR$prediction)
points(kcsummary$centers[, c("Sepal.Length", "Sepal.Width")], col = 1:3, pch=8, cex=2)
doubled <- spark.lapply(1:10, function(x){2 * x})
