#Written by Carlos Padron (padron.ca@gmail.com, carlos.florez.16@ucl.ac.uk)
#Description:
#This script prepares and analyses a dataset as part of the 
#Getting and Cleaning Data Course Project.
#The data comes from the following publication:
#Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and 
#Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones 
#using a Multiclass Hardware-Friendly Support Vector Machine. 
#International Workshop of Ambient Assisted Living (IWAAL 2012). 
#Vitoria-Gasteiz, Spain. Dec 2012 
######################################################3
#load libraries
library(dplyr)
library(tidyr)

#download data
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
              "data.zip")
#unzip data
unzip("data.zip")
#load training and test data sets including subjects and features
features <- read.table("UCI HAR Dataset/features.txt")
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt",
                         col.names = "subject")
x_test <- read.table("UCI HAR Dataset/test/X_test.txt",
                     col.names = features[,2])
y_test <- read.table("UCI HAR Dataset/test/y_test.txt",
                   col.names = "activity")

subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt",
                          col.names = "subject")
x_train <- read.table("UCI HAR Dataset/train/X_train.txt",
                      col.names = features[,2])
y_train <- read.table("UCI HAR Dataset/train/y_train.txt",
                    col.names = "activity")
#merge data sets
har_test <- cbind(subject_test, x_test, y_test)
har_train <- cbind(subject_train, x_train, y_train)
har <- rbind(har_test, har_train)
#Extracts measurements on the mean and standard deviation
#We are interested in the mean and std values followed by (). 
har <- tbl_df(har)
har <- select(har, "subject",
            "activity",
            contains("mean..", 
                     ignore.case = FALSE), #the double point refer to the symbol ()
            contains("std..",
                     ignore.case = FALSE) #the double point refer to the symbol ()
            )
#Replace numeric values in column "activity" with descriptive labels
har <- mutate(har, activity = recode(activity, 
                       "1" = "walking",
                       "2" = "walking upstairs",
                       "3" = "walking downstairs",
                       "4" = "sitting",
                       "5" = "standing",
                       "6" = "laying"))
#Label data set with descriptive variable names. 
#there are several values stored within the the variable names which need
#to be extracted into their own columns.

tidyHar <- mutate(har, id = 1:n()) %>% #add an id column to the table
       gather(variable, value, 3:68) %>% #gather all variables
       separate(variable,
                c("variable", "dimension"),
                sep = "\\.(?=[XYZ])") %>% #creates a temporary column for spatial dimension
       separate(variable,
                c("variable",
                  "fun"),
                sep = "\\.(?=[sm])")  %>% #creates a column for function (mean or std) 
       mutate(fun = recode(fun,
                           "mean.." = "mean",
                          "std.." = "std"),
              variable = recode(variable,
                                "tBodyAcc" = "body acceleration",
                                "tGravityAcc" = "gravity acceleration",
                                "tBodyGyro" = "body angular acceleration",
                                "tBodyAccJerk" = "body linear jerk",
                                "tBodyGyroJerk" = "body angular jerk",
                                "tBodyAccMag" = "body acceleration magnitude",
                                "tGravityAccMag" = "gravity magnitude",
                                "tBodyAccJerkMag" = "body linear jerk magnitude",
                                "tBodyGyroMag" = "body angular velocity magnitude",
                                "tBodyGyroJerkMag" = "body angular jerk magnitude",
                                "fBodyAcc" = "fourier transformed body acceleration",
                                "fBodyAccJerk" = "fourier transformed body linear jerk",
                                "fBodyGyro" = "fourier transformed body angular acceleration",
                                "fBodyAccMag" = "fourier transformed body acceleration magnitude",
                                "fBodyBodyAccJerkMag" = "fourier transformed squared body linear jerk magnitude",
                                "fBodyBodyGyroJerkMag" = "fourier transformed squared body angular jerk magnitude",
                                "fBodyBodyGyroMag" = "fourier transformed squared body angular velocity magnitude")) %>% #recodes variables for better reading
       spread(fun, value) %>% #separates fun column into mean and std 
       unite(variable, variable, dimension, sep = " on ") %>%  #brings back spatial dimension to variable
       mutate(variable = gsub("on NA", "", variable)) #renames variables without spatial dimension

#group the table by subject, activity and variable
tidyGroup <- group_by(tidyHar, subject, activity, variable) 
#produce summary table with average values
tidySummary <- summarise(tidyGroup, avg_mean = mean(mean), avg_std = mean(std)) 