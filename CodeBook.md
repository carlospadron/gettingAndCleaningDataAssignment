Written by Carlos Padron (padron.ca@gmail.com, carlos.florez.16@ucl.ac.uk)

#Description:
The script run_analysis.R does all the work and is fully commented so it should be clear enough. 
After loading, merging the data sets and extracting the mean and std columns, 
the script uses various dplyr commands to transform the data set into a tidy version.




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
