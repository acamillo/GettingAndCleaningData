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

## MErge the global data.table with this activity name table.
ds <- merge(ds, dtActivityNames, by = "activityNum", all.x = TRUE)
setkey(ds, subject, activityNum, activityName)

## Now we change the shape of the data.table and merge the activity names.
## The objective is to reduce the number of columns. All the feature will be listed
## in a new column called "featureCode" and removed as single columns.
## After this reshaping process we merge once again the results data.table
## with feature description table, using, as join column, the new column
## produced as result of reshaping the table. the featureCode column.
library(reshape2)
tt <- data.table(melt(ds, key(ds), variable.name = "featureCode"))
tt <- merge(tt, dtFeatures[, list(featureNum, featureCode, featureName)], 
            by = "featureCode", 
            all.x = TRUE)

## Transform the activity name and feature name, from strings to factors.
tt$activity <- factor(tt$activityName)
tt$feature <- factor(tt$featureName)

### Seperate features from featureName.
grepthis <- function(regex) {
  grepl(regex, tt$feature)
}

## In the followin part we procude some temporary matrixes, one for each
## different kind of feature, or in other words, we classify the features
## in groups based on the number of categories used by each features.
## These groups are just three, since the feature in the dataset can be
## classified with one, two or category. For each of this group
## we extract the relavent factors and produce a temporary matrix "x".
## Once the temporary matrix are properly filled in, we trasform the matrix
## into a new column to be added to the final tidy dataset.

## Features with 2 categories
n <- 2
temp_column <- matrix(seq(1, n), nrow = n)
temp_mat <- matrix(c(grepthis("^t"), grepthis("^f")), ncol = nrow(temp_column))
tt$Domain <- factor(temp_mat %*% temp_column, labels = c("Time", "Freq"))
temp_mat <- matrix(c(grepthis("Acc"), grepthis("Gyro")), ncol = nrow(temp_column))
tt$Instrument <- factor(temp_mat %*% temp_column, labels = c("Accelerometer", "Gyroscope"))
temp_mat <- matrix(c(grepthis("BodyAcc"), grepthis("GravityAcc")), ncol = nrow(temp_column))
tt$Acceleration <- factor(temp_mat %*% temp_column, labels = c(NA, "Body", "Gravity"))
temp_mat <- matrix(c(grepthis("mean()"), grepthis("std()")), ncol = nrow(temp_column))
tt$Variable <- factor(temp_mat %*% temp_column, labels = c("Mean", "SD"))

## Features with 1 category
tt$Jerk <- factor(grepthis("Jerk"), labels = c(NA, "Jerk"))
tt$Magnitude <- factor(grepthis("Mag"), labels = c(NA, "Magnitude"))

## Features with 3 categories
n <- 3
temp_column <- matrix(seq(1, n), nrow = n)
temp_mat <- matrix(c(grepthis("-X"), grepthis("-Y"), grepthis("-Z")), ncol = nrow(temp_column))
tt$Axis <- factor(temp_mat %*% temp_column, labels = c(NA, "X", "Y", "Z"))


## The tidy dataset is almost ready. We now set the indexing key as a
## combination of the subject + the activity + all the features extracted.
setkey(tt, subject, activity, Domain, Acceleration, Instrument, 
       Jerk, Magnitude, Variable, Axis)

## We are ready. For each group of features, according to the definition of its key
## of the data.table, as set in the line above,  we count the elements and calculate
## the mean value thus reducing and reducing the number of raw observations from about
## 680K yo just 12K.
dtTidy <- tt[, list(count = .N, average = mean(value)), by = key(tt)]

# Finally we dump the tidy dateset to an output file. This process loose
# all the attributes created by this script such as factor, key etc.
# This is unavoidable since the assignment specification requires us
# to export the tidy dataset into a portable format as write.table does.
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
