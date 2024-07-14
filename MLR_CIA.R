# Load necessary libraries
install.packages("caret")
library(readxl)
library(psych)
library(ggplot2)
library(DataExplorer)
library(car) # scatterplot, vif
library(lmtest) # autocorrelation
library(Metrics) # loss/cost functions
library(MASS) # stepAIC
library(caret)

# Load the data
df <- MLA
summary(df)

# Define dependent and independent variables
X <- df[, c('trip_duration', 'distance_traveled', 'num_of_passengers', 'tip', 'miscellaneous_fees')]
y <- df$total_fare

# Ensure all independent variables are numeric
X <- as.data.frame(lapply(X, as.numeric))

# Ensure the dependent variable is numeric
y <- as.numeric(y)

# Combine the independent and dependent variables into a single dataframe
data <- cbind(X, total_fare = y)

# Perform EDA
str(data)
summary(data)
plot_missing(data)

# Visualizations
pairs.panels(data)
plot_histogram(data)
plot_density(data)
plot_correlation(data)

# Split the dataset into training (70%) and testing (30%) sets
set.seed(1234)
trainIndex <- createDataPartition(data$total_fare, p = 0.7, list = FALSE)
trainData <- data[trainIndex, ]
testData <- data[-trainIndex, ]

# Build a full model
fullmodel <- lm(total_fare ~ ., data = trainData)
fullmodel_summary <- summary(fullmodel)
print(fullmodel_summary)

# Build a simple linear regression model with only trip_duration
slm_1  <- lm(total_fare ~ trip_duration, data = trainData)
slm_1_summary <- summary(slm_1)
print(slm_1_summary)

# Build a simple linear regression model with only trip_duration
slm_2  <- lm(total_fare ~ distance_traveled, data = trainData)
slm_2_summary <- summary(slm_2)
print(slm_2_summary)


# Predict and evaluate on test data
fullmodel_pred <- predict(fullmodel, newdata = testData)
slm_2_pred <- predict(slm_2 , newdata = testData)

# Calculate R-squared values for training and testing data
fullmodel_train_r2 <- fullmodel_summary$r.squared
fullmodel_test_r2 <- cor(testData$total_fare, fullmodel_pred)^2

slm_2_train_r2 <- slm_2_summary$r.squared
slm_2_test_r2 <- cor(testData$total_fare, slm_2_pred)^2

# Calculate Mean Squared Error (MSE)
fullmodel_mse <- mse(testData$total_fare, fullmodel_pred)
slm_2_mse <- mse(testData$total_fare, slm_2_pred)

# Compare R-squared values and MSE
cat("Full Model - Train R2:", fullmodel_train_r2, "Test R2:", fullmodel_test_r2, "MSE:", fullmodel_mse, "\n")
cat("Simple Model - Train R2:", slm_2_train_r2, "Test R2:", slm_2_test_r2, "MSE:", slm_2_mse, "\n")
