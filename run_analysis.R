#Enable libraries
library(plyr)
library(data.table)

#Create a folder
if(!file.exists("./data")) {
        dir.create("./data")
}

#Download and unzip
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "./data/Dataset.zip")
unzip(zipfile = "./data/Dataset.zip", exdir = "./data")

#Read data
yTest  <- read.table(file = "./data/UCI HAR Dataset/test/Y_test.txt", header = FALSE)
xTest  <- read.table(file = "./data/UCI HAR Dataset/test/X_test.txt", header = FALSE)
yTrain <- read.table(file = "./data/UCI HAR Dataset/train/Y_train.txt", header = FALSE)
xTrain <- read.table(file = "./data/UCI HAR Dataset/train/X_train.txt", header = FALSE)
SubjectTest <- read.table(file = "./data/UCI HAR Dataset/test/subject_test.txt", header = FALSE)
SubjectTrain <- read.table(file = "./data/UCI HAR Dataset/train/subject_train.txt", header = FALSE)
Features <- read.table(file = "./data/UCI HAR Dataset/features.txt", header = FALSE)
activityLabels <- read.table(file = "./data/UCI HAR Dataset/activity_labels.txt", header = FALSE)

#Merge data
MergeSubject <- rbind(SubjectTrain, SubjectTest)
MergeY <- rbind(yTrain, yTest)
MergeX <- rbind(xTrain, xTest)
names(MergeSubject) <- c("subject")
names(MergeY) <- c("activity")
names(MergeX) <- Features$V2
Combine <- cbind(MergeSubject, MergeY)
Data <- cbind(MergeX, Combine)

#Extract the measurements
subFeatures <- Features$V2[grep("mean\\(\\)|std\\(\\)", Features$V2)]
selNames <- c(as.character(subFeatures), "subject", "activity")
Data <- subset(Data, select = selNames)

#Name the activities in the data set
Data$activity <- factor(Data$activity)
Data$activity <- factor(Data$activity, labels = as.character(activityLabels$V2))

#Appropriately label the data set
names(Data) <- gsub("^t", "time", names(Data))
names(Data) <- gsub("^f", "frequency", names(Data))
names(Data) <- gsub("Acc", "Accelerometer", names(Data))
names(Data) <- gsub("Gyro", "Gyroscope", names(Data))
names(Data) <- gsub("Mag", "Magnitude", names(Data))
names(Data) <- gsub("BodyBody", "Body", names(Data))

#Create a second, independent tidy data set
Final <- aggregate(. ~subject + activity, Data, mean)
Final <- Final[order(Final$subject, Final$activity),]
write.table(Final, file = "./data/tidydata.txt", row.name = FALSE)
