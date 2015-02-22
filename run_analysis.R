# Make sure data.table and reshape2 packages are downloaded
if(!require("data.table")){
  install.packages("data.table")
}

if(!require("reshape2")){
  install.packages("reshape2")
}

require("data.table")
# 1.  Merges the training and the test sets to create one data set.
# If the zip file is not already downloaded 
if(!file.exists("dataset")){
  temp <- tempfile()
  download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", temp, method="curl")
  unzip(zipfile = temp, exdir = "dataset")
}

# Read data into R
features <- read.table("./dataset/UCI HAR Dataset/features.txt")[,2]

# Read training data
subjectTrain <- read.table("./dataset//UCI HAR Dataset/train/subject_train.txt")
xTrain <- read.table("./dataset/UCI HAR Dataset/train/X_train.txt")
yTrain <- read.table("./dataset/UCI HAR Dataset/train/y_train.txt")
yTrain[,2] <- vector()
names(yTrain) <- c("Activity_ID", "Activity_Label")
names(xTrain) <- features


# Red test datat
subjectTest <- read.table("./dataset/UCI HAR Dataset/test/subject_test.txt")
xTest <- read.table("./dataset/UCI HAR Dataset/test/X_test.txt")
yTest <- read.table("./dataset/UCI HAR Dataset/test/y_test.txt")
yTest[,2] <- vector()
names(yTest) <- c("Activity_ID", "Activity_Label")
names(xTest) <- features

#  2.	Extracts only the measurements on the mean and standard deviation for each measurement.
mean_std_features <- which(grepl("mean|std", features))
xTrain <- xTrain[,mean_std_features]
trainData <- cbind(subjectTrain, yTrain, xTrain)

xTest <- xTest[,mean_std_features]
testData <- cbind(subjectTest, yTest, xTest)
workingDataSet <- rbind(testData, trainData)

#  3.	Uses descriptive activity names to name the activities in the data set
activity_labels <- read.table("./dataset/UCI HAR Dataset/activity_labels.txt")[,2]
workingDataSet[,3] <- activity_labels[workingDataSet[,2]]

#  4.	Appropriately labels the data set with descriptive variable names.
colnames(workingDataSet)[1] <- "subject"

# 5.	From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
id_labels <- c("subject", "Activity_ID", "Activity_Label")
value_labels <- setdiff(colnames(workingDataSet), id_labels)
secondDataSet = melt(workingDataSet, id = id_labels, measure.vars = value_labels)

tidy_data   = dcast(secondDataSet, subject + Activity_Label ~ variable, mean)

write.table(tidy_data, 'tidy_data.txt', row.names=FALSE)