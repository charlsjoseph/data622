euclideanDist <- function(a, b){
  d = 0
  for(i in c(1:(length(a)) ))
  {
    d = d + (a[[i]]-b[[i]])^2
  }
  d = sqrt(d)
  return(d)
}


knn_predict2 <- function(test_data, train_data, k_value, labelcol){
  pred <- c()  #empty pred vector 
  #LOOP-1
  for(i in c(1:nrow(test_data))){   #looping over each record of test data
    eu_dist =c()          #eu_dist & eu_char empty  vector
    eu_char = c()
    good = 0              #good & bad variable initialization with 0 value
    bad = 0
    
    #LOOP-2-looping over train data 
    for(j in c(1:nrow(train_data))){
      
      #adding euclidean distance b/w test data point and train data to eu_dist vector
      eu_dist <- c(eu_dist, euclideanDist(test_data[i,-c(labelcol)], train_data[j,-c(labelcol)]))
      
      #adding class variable of training data in eu_char
      eu_char <- c(eu_char, as.character(train_data[j,][[labelcol]]))
    }
    
    eu <- data.frame(eu_char, eu_dist) #eu dataframe created with eu_char & eu_dist columns
    
    eu <- eu[order(eu$eu_dist),]       #sorting eu dataframe to gettop K neighbors
    eu <- eu[1:k_value,]               #eu dataframe with top K neighbors
    
    tbl.sm.df<-table(eu$eu_char)
    cl_label<-  names(tbl.sm.df)[[as.integer(which.max(tbl.sm.df))]]
    
    pred <- c(pred, cl_label)
  }
  return(pred) #return pred vector
}


accuracy <- function(test_data,labelcol,predcol){
  correct = 0
  for(i in c(1:nrow(test_data))){
    if(test_data[i,labelcol] == test_data[i,predcol]){ 
      correct = correct+1
    }
  }
  accu = (correct/nrow(test_data)) * 100  
  return(accu)
}

#load data
library("knitr")
library("ggplot2")
knn.df <- read.csv('C:\\Users\\Charls\\Documents\\CunyMSDS\\Data622\\Assignments\\HW1\\Qn3\\icu.csv')
labelcol <-5
knn.df$COMA <- ifelse(knn.df$LOC==2, 1, 0)

#The formula to fit is "STA ~ TYP + COMA + AGE + INF"
knn.df <- subset(knn.df, select=c("TYP", "COMA", "AGE", "INF" ,"STA" ))

predictioncol<-6
# create train/test partitions
set.seed(2)
n<-nrow(knn.df)
knn.df<- knn.df[sample(n),]

train.df <- knn.df[1:as.integer(0.7*n),]

K = c(3,5,7,15,25,50) # number of neighbors to determine the class
test.df <- knn.df[as.integer(0.7*n +1):n,]
# create a temp dataframe variable 
test.df1 <- test.df
table(test.df[,labelcol])

# define a df to hold the accuray for each K, one column hold K val and other will hold accuracy metrics
knnMetrics <- data.frame(matrix(ncol = 2, nrow = 0) ,stringsAsFactors = FALSE)
for (k in K){ 
  predictions <- knn_predict2(test.df1, train.df, k,labelcol) #calling knn_predict()
  
  test.df[,predictioncol] <- predictions #Adding predictions in test data as 7th column
  acc <- accuracy(test.df,labelcol,predictioncol)
  print(acc)
  print(paste('The confusion metric when k = ', toString(k)))
  print(table(test.df[[predictioncol]],test.df[[labelcol]]))
  knnMetrics <- rbind(knnMetrics, c(k, acc), stringsAsFactors = FALSE)
}
metrics <- c("k", "accuracy")
colnames(knnMetrics) <- metrics


kable(knnMetrics)

ggplot() +
  geom_line(data = knnMetrics, aes(x = k, y = accuracy), size = .5)+
  xlab("K - Value") +
  ylab("Accuracy") +
  ylim(0, 105) + scale_x_continuous(breaks=seq(0,106,5)) 

