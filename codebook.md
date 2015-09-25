Code Book
=========

This Codebook is automatically  generated as part of the process for generating the clean tidy dataset.

## Variable list and descriptions


Variable name    | Description
-----------------|------------
subject          | ID the subject who performed the activity for each window sample. Its range is from 1 to 30.
activity         | Activity name
featDomain       | Feature: Time domain signal or frequency domain signal (Time or Freq)
featInstrument   | Feature: Measuring instrument (Accelerometer or Gyroscope)
featAcceleration | Feature: Acceleration signal (Body or Gravity)
featVariable     | Feature: Variable (Mean or SD)
featJerk         | Feature: Jerk signal
featMagnitude    | Feature: Magnitude of the signals calculated using the Euclidean norm
featAxis         | Feature: 3-axial signals in the X, Y and Z directions (X, Y, or Z)
featCount        | Feature: Count of data points used to compute `average`
featAverage      | Feature: Average of each variable for each activity and each subject

## Dataset structure


```r
library(data.table)

pathIn <- file.path("UCI/UCI HAR Dataset/")
# pathIn <- file.path("UCI")
tidy <- read.table(file.path(pathIn, "tidyset.txt"), header = TRUE)
str(tidy)
```

```
## 'data.frame':	11880 obs. of  11 variables:
##  $ subject         : int  1 1 1 1 1 1 1 1 1 1 ...
##  $ activity        : Factor w/ 6 levels "LAYING","SITTING",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ featDomain      : Factor w/ 2 levels "Freq","Time": 2 2 2 2 2 2 2 2 2 2 ...
##  $ featAcceleration: Factor w/ 2 levels "Body","Gravity": NA NA NA NA NA NA NA NA NA NA ...
##  $ featInstrument  : Factor w/ 2 levels "Accelerometer",..: 2 2 2 2 2 2 2 2 2 2 ...
##  $ featJerk        : Factor w/ 1 level "Jerk": NA NA NA NA NA NA NA NA 1 1 ...
##  $ featMagnitude   : Factor w/ 1 level "Magnitude": NA NA NA NA NA NA 1 1 NA NA ...
##  $ featVariable    : Factor w/ 2 levels "Mean","SD": 1 1 1 2 2 2 1 2 1 1 ...
##  $ featAxis        : Factor w/ 3 levels "X","Y","Z": 1 2 3 1 2 3 NA NA 1 2 ...
##  $ count           : int  50 50 50 50 50 50 50 50 50 50 ...
##  $ average         : num  -0.0166 -0.0645 0.1487 -0.8735 -0.9511 ...
```


## Show some of the dataset entries


```r
head(tidy, 5)
```

```
##   subject activity featDomain featAcceleration featInstrument featJerk
## 1       1   LAYING       Time             <NA>      Gyroscope     <NA>
## 2       1   LAYING       Time             <NA>      Gyroscope     <NA>
## 3       1   LAYING       Time             <NA>      Gyroscope     <NA>
## 4       1   LAYING       Time             <NA>      Gyroscope     <NA>
## 5       1   LAYING       Time             <NA>      Gyroscope     <NA>
##   featMagnitude featVariable featAxis count     average
## 1          <NA>         Mean        X    50 -0.01655309
## 2          <NA>         Mean        Y    50 -0.06448612
## 3          <NA>         Mean        Z    50  0.14868944
## 4          <NA>           SD        X    50 -0.87354387
## 5          <NA>           SD        Y    50 -0.95109044
```

## Summary of variables

```r
summary(tidy)
```

```
##     subject                   activity    featDomain  featAcceleration
##  Min.   : 1.0   LAYING            :1980   Freq:4680   Body   :5760    
##  1st Qu.: 8.0   SITTING           :1980   Time:7200   Gravity:1440    
##  Median :15.5   STANDING          :1980               NA's   :4680    
##  Mean   :15.5   WALKING           :1980                               
##  3rd Qu.:23.0   WALKING_DOWNSTAIRS:1980                               
##  Max.   :30.0   WALKING_UPSTAIRS  :1980                               
##        featInstrument featJerk      featMagnitude  featVariable
##  Accelerometer:7200   Jerk:4680   Magnitude:3240   Mean:5940   
##  Gyroscope    :4680   NA's:7200   NA's     :8640   SD  :5940   
##                                                                
##                                                                
##                                                                
##                                                                
##  featAxis        count          average        
##  X   :2880   Min.   :36.00   Min.   :-0.99767  
##  Y   :2880   1st Qu.:49.00   1st Qu.:-0.96205  
##  Z   :2880   Median :54.50   Median :-0.46989  
##  NA's:3240   Mean   :57.22   Mean   :-0.48436  
##              3rd Qu.:63.25   3rd Qu.:-0.07836  
##              Max.   :95.00   Max.   : 0.97451
```

