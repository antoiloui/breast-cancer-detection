# Set current directory
setwd("~/Documents/INGE/MASTER/1ère\ MASTER/1er\ QUADRI/HDDA/Projects/Breast-cancer-supervised-classification/")


# Load quantitative data
data <- read.table("data.csv", header=TRUE, sep=',')
data <- data[,1:9]
attach(data)
View(data)


#*******************QUESTION_1***************************
# Mahalanobis depth function
compute_maha_depth <- function(x, mu=colMeans(x), sigma=cov(x), robust=FALSE){
  if(robust == TRUE){
    #Robust estimation of the covariance matrix
    library(MASS)
    estimator <- cov.rob(x, method = "mcd")
    mu <- estimator$center 
    sigma <- estimator$cov
  }
  1/(1 + mahalanobis(x, mu,sigma))
}

# Compute depth
maha_ND_ranks <- compute_maha_depth(data, robust=TRUE)
View(maha_ND_ranks)

# Compute PCA with an estimated covariance matrix
pca <- princomp(data, cor=TRUE)

# Represent data on first principal plane with different ranks
color_pal <- colorRampPalette(c('green','red'))
grad_col <- color_pal(length(unique(maha_ND_ranks)))[as.factor(maha_ND_ranks)]
plot(pca$scores[,1], pca$scores[,2],
					main="Quantitative data on first principal plane",
					xlab="First component",
					ylab= "Second component",
          pch=20,
					col=grad_col)
legend("topright", title="Depth",
       legend=c("Small", "Medium", "Big"),
       col=color_pal(3),
       pch=20)

# Add the Mahalanobis depths to the data
detach(data)
data$Depth <- maha_ND_ranks
attach(data)
View(data)

# Analysis of the deepest point and extreme cases
summary(data$Depth)
quantile(data$Depth, probs = c(0.05, 0.95))
summary(data[which(Depth > quantile(data$Depth, probs=0.95)),])
summary(data[which(Depth < quantile(data$Depth, probs=0.05)),])


#*******************QUESTION_2***************************
# Depth function using center-outward procedure from median
compute_1D_center_depth <- function(x){
  # Get the median value of vector x
  med <- median(x)
  # Substract the median to each value of vector x
  abs(x-med)
}

# Take the two most important variables
var1 <- data$Insulin
var2 <- data$Leptin

# Compute the 1D-ranks
OneD_ranks_var1 <- compute_1D_center_depth(var1)
OneD_ranks_var2 <- compute_1D_center_depth(var2)


#*******************QUESTION_3***************************
# Bagplot
library(aplpack)
bag <- bagplot(Insulin,Leptin,main = "Bagplot", xlab = "Insulin", ylab = "Leptin")

# Get the 2D rankings
TwoD_ranks <- bag$hdepths

# Measure the discrepancy between the 2D-ranking and the
# multivariate ranking of Q1 with Spearman rank correlation
library(MASS)
corr_2D_ND <- cor(TwoD_ranks, maha_ND_ranks, method='spearman')
corr_2D_ND

# Measure the discrepancy between the 2D-ranking and the
# 1D rankings of Q2 with Spearman rank correlation
corr_2D_1D_var1 <- cor(TwoD_ranks, OneD_ranks_var1, method='spearman')
corr_2D_1D_var2 <- cor(TwoD_ranks, OneD_ranks_var2, method='spearman')
corr_2D_1D_var1
corr_2D_1D_var2

# Scatter plots
plot(TwoD_ranks, maha_ND_ranks, main="Scatterplot", 
     xlab="2D-rankings ", ylab="Multivariate rankings ", pch=16)

plot(TwoD_ranks, OneD_ranks_var1, main="Scatterplot", 
     xlab="2D-rankings ", ylab="1D-rankings for Insulin", pch=16)
abline(lm(TwoD_ranks~OneD_ranks_var1), col="red")

plot(TwoD_ranks, OneD_ranks_var2, main="Scatterplot", 
     xlab="2D-rankings ", ylab="1D-rankings for Leptin", pch=16)
abline(lm(TwoD_ranks~OneD_ranks_var2), col="red")


