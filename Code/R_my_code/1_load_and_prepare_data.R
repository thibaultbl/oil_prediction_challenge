library(dplyr, warn.conflicts=FALSE)
library(randomForest)
library(ROCR)
library(mice)
library(caret)
library(e1071)

#------------------------------
# I set the working directory.
#------------------------------

setwd("/home/thibault/Documents/oilprediction_challenge/")

#---------------------------------------------------------------
# Load train and test set
#---------------------------------------------------------------

dataset <- read.csv("./Data/Train.csv", sep = ";",stringsAsFactors = FALSE)
Y_dataset <- read.csv("./Data/Y_train.csv", sep = ";",stringsAsFactors = FALSE)
validation <- read.csv("./Data/Test.csv", sep = ";",stringsAsFactors = FALSE)

SAMPLE_SIZE_TRAIN = as.integer(0.75 * nrow(dataset))

<<<<<<< HEAD
variables_in_model <- names(dataset)[!(names(dataset) %in% c("ID", "Target"))]

=======
>>>>>>> e4d33e8f27f01e87af581dae781e08d315112dd1
#--------------------------------
# We combine the two datasets.
#--------------------------------

full_dataset <- rbind(dataset, validation)

#--------------------------------
<<<<<<< HEAD
# Check variables
#--------------------------------

# A) correlations
correlation_matrix <- cor(full_dataset[, c(variables_in_model)], use="pairwise.complete.obs")
row_better_tha_threshold <- apply(correlation_matrix, 1, function(x){any(abs(x) > 0.8 & abs(x) != 1)})
col_better_tha_threshold <- apply(correlation_matrix, 2, function(x){any(abs(x) > 0.8 & abs(x) != 1)})

head(correlation_matrix[row_better_tha_threshold, col_better_tha_threshold])

# B) Create new variable as difference between export and import 
for(i in 1:12){
  print(i)
  dif <- full_dataset[, paste("X", i, "_diffExports.kmt.", sep="")] - full_dataset[, paste("X", i, "_diffImports.kmt.", sep="")]
  names_dif <- paste("X", i, "_diff_import_export", sep="")
  full_dataset <- cbind(full_dataset, dif)
  names(full_dataset)[length(names(full_dataset))] <- names_dif
  variables_in_model <- c(variables_in_model, names_dif)
}

head(full_dataset)

#--------------------------------
# Fill missing value
#--------------------------------

mice_dataset <- mice(full_dataset,m=1, maxit=1,meth='pmm',seed=500)
=======
# Fill missing value
#--------------------------------

mice_dataset <- mice(full_dataset,m=1, maxit=2,meth='pmm',seed=500)
>>>>>>> e4d33e8f27f01e87af581dae781e08d315112dd1

full_dataset_complete <- complete(mice_dataset)

# Split again test and dataset
dataset <- left_join(full_dataset_complete[full_dataset_complete$ID %in% dataset$ID, ], Y_dataset)
validation <- full_dataset_complete[full_dataset_complete$ID %in% validation$ID, ]


#--------------------------------
# Modeling
#--------------------------------
<<<<<<< HEAD
set.seed(42)
=======

>>>>>>> e4d33e8f27f01e87af581dae781e08d315112dd1
train_ID <- base::sample(dataset$ID, size = SAMPLE_SIZE_TRAIN)
train <- dataset[dataset$ID %in% train_ID, ]
test <- dataset[!(dataset$ID %in% train_ID), ]

<<<<<<< HEAD
variables_in_model_formula <- paste(variables_in_model, collapse="+")

# tune mtry
set.seed(0.42)
bestmtry <- tuneRF(train[, variables_in_model], train$Target, stepFactor=1.5, improve=1e-5, ntree=150)
print(bestmtry)

=======
variables_in_model <- names(full_dataset)[!(names(full_dataset) %in% c("ID", "Target"))]
variables_in_model_formula <- paste(variables_in_model, collapse="+")

>>>>>>> e4d33e8f27f01e87af581dae781e08d315112dd1
formula_rf <- as.formula(paste("as.factor(Target) ~", variables_in_model_formula, sep=""))

rf_output <- randomForest(formula_rf,
                          data=train, 
<<<<<<< HEAD
                          importance=FALSE, 
                          ntree=150,
                          mtry=2,
                          nodesize = 5)
=======
                          importance=TRUE, 
                          ntree=200,
                          mtry=bestmtry)
>>>>>>> e4d33e8f27f01e87af581dae781e08d315112dd1

#--------------------------------
# Evaluation
#--------------------------------
<<<<<<< HEAD

# AUC and ROC curve
=======
>>>>>>> e4d33e8f27f01e87af581dae781e08d315112dd1
prediction_test <- predict(rf_output, test, type="prob")

predictions=as.vector(prediction_test[,2])
pred = prediction(predictions, test$Target)

perf_AUC=performance(pred,"auc") #Calculate the AUC value
AUC=perf_AUC@y.values[[1]]

perf_ROC=performance(pred,"tpr","fpr") #plot the actual ROC curve
plot(perf_ROC, main="ROC plot")
text(0.5,0.5,paste("AUC = ",format(AUC, digits=5, scientific=FALSE)))

<<<<<<< HEAD
# Plot RF
plot(rf_output)

=======
>>>>>>> e4d33e8f27f01e87af581dae781e08d315112dd1
#--------------------------------
# Write CSV
#--------------------------------
final_predictions <- as.numeric(as.character(predict(rf_output, validation)))
final_predictions <- data.frame(cbind(validation$ID, final_predictions))
colnames(final_predictions) <- c("ID", "Target")
final_predictions$Target <- as.integer(as.character(final_predictions$Target))
final_predictions$ID <- as.character(final_predictions$ID)

write.csv(final_predictions, file = "./Result/result.csv", sep = ";", row.names = FALSE)
<<<<<<< HEAD
=======

nrow(final_predictions)
>>>>>>> e4d33e8f27f01e87af581dae781e08d315112dd1
