library(data.table)
library(tree)
library(tidyverse)
mydata <- fread('https://goo.gl/At238b') #Import the dataset
mydata$survived = as.factor(mydata$survived) #Set survival to a factor (1 for survived and 0 for did not survive)
TitanicData = mydata %>% select(survived, embarked, sex, sibsp, parch, fare) #Pull only the relevant data we want
TitanicData = mydata %>% mutate(embarked = factor(embarked), sex = factor(sex))
tree.titanic <- tree(survived~ embarked+sex+sibsp+parch+fare, TitanicData) #Create our first tree

plot(tree.titanic)
text(tree.titanic, pretty = 0)
title("Feature Tree for Survival")
summary(tree.titanic)


set.seed(2)
train.titanic <- sample(1:nrow(TitanicData), nrow(TitanicData)/2) #Split data into testing and training
titanic.test <- TitanicData[-train.titanic,] 
survived.test <- TitanicData$survived[-train.titanic]
tree.titanic.train <- tree(survived ~ embarked+sex+sibsp+parch+fare,TitanicData, subset = train.titanic) #Train a tree on only training data
plot(tree.titanic.train)
text(tree.titanic.train, pretty = 0)
title("Primary Features for Survival on Titanic")

cv.titanic <- cv.tree(tree.titanic.train, FUN = prune.misclass) #Apply K-fold cross validation on the tree
cv.titanic

prune.titanic_4 <- prune.misclass(tree.titanic.train, best = 4) #Prune the tree for 4 main features

tree.pred_4 <- predict(prune.titanic_4, titanic.test, type = "class") #Use the pruned tree for prediction
conf_matrix = table(tree.pred_4, survived.test) #Create the confusion matrix to evaulate accuracy

acc = (conf_matrix[1,1] + conf_matrix[2,2])/sum(conf_matrix) #Calculate the accuracy of our model given our confusion matrix
print(acc) #Print our accuracy

plot(prune.titanic_4)
text(prune.titanic_4, pretty = 0)
title("4 Primary Features of Survival on Titanic")
