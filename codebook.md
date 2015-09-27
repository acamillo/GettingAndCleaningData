Code Book
=========

This Codebook is automatically  generated as part of the process for generating the clean tidy dataset. The run_analysis.R script uses the $codebook.Rmd$ template to compile a codebook.md file.

## Variable list and descriptions


Variable name    | Description
-----------------|------------
subject          | ID the subject who performed the activity for each window sample. Its range is from 1 to 30.
activity         | Activity name
Domain           | Feature: Time domain signal or frequency domain signal (Time or Freq)
Instrument       | Feature: Measuring instrument (Accelerometer or Gyroscope)
Acceleration     | Feature: Acceleration signal (Body or Gravity)
Variable         | Feature: Variable (Mean or SD)
Jerk             | Feature: Jerk signal
Magnitude        | Feature: Magnitude of the signals calculated using the Euclidean norm
Axis             | Feature: 3-axial signals in the X, Y and Z directions (X, Y, or Z)
count            | Feature: Count of data points used to compute `average`
average          | Feature: Average of each variable for each activity and each subject

## Dataset structure

This codebook expects to have the tidy dataset in the output directory
created by run_analsys.R script. It is then imperative to run the run_analysis.R script before opening the coodbook.md file, or it will not work.

```r
library(data.table)

pathIn <- file.path("UCI/UCI HAR Dataset/")
tidy <- data.table(read.table(file.path(pathIn, "tidyset.txt"), header = TRUE))

setkey(tidy, subject, activity, Domain, Acceleration, Instrument, 
       Jerk, Magnitude, Variable, Axis)

str(tidy)
```

```
## Classes 'data.table' and 'data.frame':	11880 obs. of  11 variables:
##  $ subject     : int  1 1 1 1 1 1 1 1 1 1 ...
##  $ activity    : Factor w/ 6 levels "LAYING","SITTING",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ Domain      : Factor w/ 2 levels "Freq","Time": 1 1 1 1 1 1 1 1 1 1 ...
##  $ Acceleration: Factor w/ 2 levels "Body","Gravity": NA NA NA NA NA NA NA NA NA NA ...
##  $ Instrument  : Factor w/ 2 levels "Accelerometer",..: 2 2 2 2 2 2 2 2 2 2 ...
##  $ Jerk        : Factor w/ 1 level "Jerk": NA NA NA NA NA NA NA NA 1 1 ...
##  $ Magnitude   : Factor w/ 1 level "Magnitude": NA NA NA NA NA NA 1 1 1 1 ...
##  $ Variable    : Factor w/ 2 levels "Mean","SD": 1 1 1 2 2 2 1 2 1 2 ...
##  $ Axis        : Factor w/ 3 levels "X","Y","Z": 1 2 3 1 2 3 NA NA NA NA ...
##  $ count       : int  50 50 50 50 50 50 50 50 50 50 ...
##  $ average     : num  -0.85 -0.952 -0.909 -0.882 -0.951 ...
##  - attr(*, ".internal.selfref")=<externalptr> 
##  - attr(*, "sorted")= chr  "subject" "activity" "Domain" "Acceleration" ...
```


## Show some of the dataset entries


```r
head(tidy, 5)
```

```
##    subject activity Domain Acceleration Instrument Jerk Magnitude Variable
## 1:       1   LAYING   Freq           NA  Gyroscope   NA        NA     Mean
## 2:       1   LAYING   Freq           NA  Gyroscope   NA        NA     Mean
## 3:       1   LAYING   Freq           NA  Gyroscope   NA        NA     Mean
## 4:       1   LAYING   Freq           NA  Gyroscope   NA        NA       SD
## 5:       1   LAYING   Freq           NA  Gyroscope   NA        NA       SD
##    Axis count    average
## 1:    X    50 -0.8502492
## 2:    Y    50 -0.9521915
## 3:    Z    50 -0.9093027
## 4:    X    50 -0.8822965
## 5:    Y    50 -0.9512320
```

## Summary of variables

```r
summary(tidy)
```

```
##     subject                   activity     Domain      Acceleration 
##  Min.   : 1.0   LAYING            :1980   Freq:4680   Body   :5760  
##  1st Qu.: 8.0   SITTING           :1980   Time:7200   Gravity:1440  
##  Median :15.5   STANDING          :1980               NA's   :4680  
##  Mean   :15.5   WALKING           :1980                             
##  3rd Qu.:23.0   WALKING_DOWNSTAIRS:1980                             
##  Max.   :30.0   WALKING_UPSTAIRS  :1980                             
##          Instrument     Jerk          Magnitude    Variable      Axis     
##  Accelerometer:7200   Jerk:4680   Magnitude:3240   Mean:5940   X   :2880  
##  Gyroscope    :4680   NA's:7200   NA's     :8640   SD  :5940   Y   :2880  
##                                                                Z   :2880  
##                                                                NA's:3240  
##                                                                           
##                                                                           
##      count          average        
##  Min.   :36.00   Min.   :-0.99767  
##  1st Qu.:49.00   1st Qu.:-0.96205  
##  Median :54.50   Median :-0.46989  
##  Mean   :57.22   Mean   :-0.48436  
##  3rd Qu.:63.25   3rd Qu.:-0.07836  
##  Max.   :95.00   Max.   : 0.97451
```

