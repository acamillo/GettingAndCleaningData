library(data.table)

projectPath = "UCI"
## Create the required working folder.
pathIn <- file.path(projectPath)
if(!file.exists(pathIn)) {
  dir.create(pathIn)
} 

url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zipFileName  <- paste0(pathIn, "/UCI-HAR-dataset.zip")

##
## Download the database if not already present
##
if ( !file.exists(zipFileName)) {
  download.file( url, zipFileName, mode = "wb")
  message("Unzipping  database...")
  unzip(zipFileName, exdir = pathIn)
}

pathIn <- file.path("UCI/UCI HAR Dataset/")
list.files(pathIn, recursive = TRUE)

## Read and merge the training and test subject dataset
dtSubjectTrain <- fread(file.path(pathIn, "train", "subject_train.txt"))
dtSubjectTest <- fread(file.path(pathIn, "test", "subject_test.txt"))
dtSubject <- rbind(dtSubjectTrain, dtSubjectTest)
setnames(dtSubject, "V1", "subject")

## Read and merge the train and test dataset
dtActivityTrain <- fread(file.path(pathIn, "train", "y_train.txt"))
dtActivityTest <- fread(file.path(pathIn, "test", "y_test.txt"))
dtActivity <- rbind(dtActivityTrain, dtActivityTest)
setnames(dtActivity, "V1", "activityNum")

## Read and merge the X dataset to create one data table
dtTrain <- data.table(read.table(file.path(pathIn, "train", "X_train.txt")))
dtTest  <- data.table(read.table(file.path(pathIn, "test", "X_test.txt")))
dt <- rbind(dtTrain, dtTest)

## ds <- cbind(dtSubject, dtActivity)
ds <- cbind(dtSubject, dtActivity, dt)

setkey(ds, subject, activityNum)
key(ds)

# Extracts only the measurements on the mean and standard deviation for each measurement. 
dtFeatures <- fread(file.path(pathIn, "features.txt"))
setnames(dtFeatures, names(dtFeatures), c("featureNum", "featureName"))

dtFeatures <- dtFeatures[grepl("mean\\(\\)|std\\(\\)", featureName)]

# Convert the column numbers to a vector of variable names matching columns
dtFeatures$featureCode <- dtFeatures[, paste0("V", featureNum)]

ss <- c(key(ds), dtFeatures$featureCode)
ds <- ds[, ss, with = FALSE]

# Uses descriptive activity names to name the activities in the data set
dtActivityNames <- fread(file.path(pathIn, "activity_labels.txt"))
setnames(dtActivityNames, names(dtActivityNames), c("activityNum", "activityName"))

ds <- merge(ds, dtActivityNames, by = "activityNum", all.x = TRUE)
setkey(ds, subject, activityNum, activityName)

## Now we change the shape of the data.table and merge the activity names.
library(reshape2)
tt <- data.table(melt(ds, key(ds), variable.name = "featureCode"))
tt <- merge(tt, dtFeatures[, list(featureNum, featureCode, featureName)], 
            by = "featureCode", 
            all.x = TRUE)

tt$activity <- factor(tt$activityName)
tt$feature <- factor(tt$featureName)

### Seperate features from featureName.
grepthis <- function(regex) {
  grepl(regex, tt$feature)
}


## Features with 2 categories
n <- 2
y <- matrix(seq(1, n), nrow = n)
x <- matrix(c(grepthis("^t"), grepthis("^f")), ncol = nrow(y))
tt$featDomain <- factor(x %*% y, labels = c("Time", "Freq"))
x <- matrix(c(grepthis("Acc"), grepthis("Gyro")), ncol = nrow(y))
tt$featInstrument <- factor(x %*% y, labels = c("Accelerometer", "Gyroscope"))
x <- matrix(c(grepthis("BodyAcc"), grepthis("GravityAcc")), ncol = nrow(y))
tt$featAcceleration <- factor(x %*% y, labels = c(NA, "Body", "Gravity"))
x <- matrix(c(grepthis("mean()"), grepthis("std()")), ncol = nrow(y))
tt$featVariable <- factor(x %*% y, labels = c("Mean", "SD"))

## Features with 1 category
tt$featJerk <- factor(grepthis("Jerk"), labels = c(NA, "Jerk"))
tt$featMagnitude <- factor(grepthis("Mag"), labels = c(NA, "Magnitude"))

## Features with 3 categories
n <- 3
y <- matrix(seq(1, n), nrow = n)
x <- matrix(c(grepthis("-X"), grepthis("-Y"), grepthis("-Z")), ncol = nrow(y))
tt$featAxis <- factor(x %*% y, labels = c(NA, "X", "Y", "Z"))

setkey(tt, subject, activity, featDomain, featAcceleration, featInstrument, 
       featJerk, featMagnitude, featVariable, featAxis)
dtTidy <- tt[, list(count = .N, average = mean(value)), by = key(tt)]

write.table(dtTidy, file.path(pathIn, "tidyset.txt"), 
            ##            quote = FALSE, 
            ##            sep = ",", 
            row.names = FALSE)
## xx <- read.table(file.path(pathIn, "tidyset.txt"))
## str(xx)

## Compile the  codebook.
library(knitr)
library(markdown)

knit( "codebook.Rmd",  output= "codebook.md", encoding="ISO8859-1", quiet=TRUE)
markdownToHTML( "codebook.md", "codebook.html")
