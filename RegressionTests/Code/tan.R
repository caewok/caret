library(caret)
timestamp <- format(Sys.time(), "%Y_%m_%d_%H_%M")

model <- "tan"

#########################################################################

set.seed(2)
training <- LPH07_1(100, factors = TRUE, class = TRUE)
testing  <- LPH07_1(100, factors = TRUE, class = TRUE)
trainX <- training[, -ncol(training)]
trainY <- training$Class

cctrl1 <- trainControl(method = "cv", number = 3, returnResamp = "all",
                       classProbs = TRUE, 
                       summaryFunction = twoClassSummary)
cctrl2 <- trainControl(method = "LOOCV",
                       classProbs = TRUE, summaryFunction = twoClassSummary)
cctrl3 <- trainControl(method = "none",
                       classProbs = TRUE, summaryFunction = twoClassSummary)
cctrlR <- trainControl(method = "cv", number = 3, returnResamp = "all", search = "random")

set.seed(849)
test_class_cv_model <- train(trainX, trainY, 
                             method = "tan", 
                             trControl = cctrl1,
                             metric = "ROC")

test_class_pred <- predict(test_class_cv_model, testing[, -ncol(testing)])
test_class_prob <- predict(test_class_cv_model, testing[, -ncol(testing)], type = "prob")

set.seed(849)
test_class_rand <- train(trainX, trainY, 
                         method = "tan", 
                         trControl = cctrlR,
                         tuneLength = 4)

set.seed(849)
test_class_loo_model <- train(trainX, trainY, 
                              method = "tan", 
                              trControl = cctrl2,
                              metric = "ROC")

set.seed(849)
test_class_none_model <- train(trainX, trainY, 
                               method = "tan", 
                               trControl = cctrl3,
                               tuneGrid = test_class_cv_model$bestTune,
                               metric = "ROC")

test_class_none_pred <- predict(test_class_none_model, testing[, -ncol(testing)])
test_class_none_prob <- predict(test_class_none_model, testing[, -ncol(testing)], type = "prob")

test_levels <- levels(test_class_cv_model)
if(!all(levels(trainY) %in% test_levels))
  cat("wrong levels")

#########################################################################

test_class_predictors1 <- predictors(test_class_cv_model)

#########################################################################

test_class_imp <- varImp(test_class_cv_model)

#########################################################################

tests <- grep("test_", ls(), fixed = TRUE, value = TRUE)

sInfo <- sessionInfo()

save(list = c(tests, "sInfo", "timestamp"),
     file = file.path(getwd(), paste(model, ".RData", sep = "")))

q("no")


