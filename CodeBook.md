Written by Carlos Padron (padron.ca@gmail.com, carlos.florez.16@ucl.ac.uk)
#tidyData.txt

The resulting tidy data set consists of 5 columns:

subject: integer representing the observational unit.
activity: the activity performed by the subject. Can be any of the following:
  "laying", 
  "sitting", 
  "standing",
  "walking", 
  "walking downstairs", 
  "walking upstairs".
variable: the variable measured. Can be any of the following:
  "body acceleration magnitude ",
  "body acceleration on X",                                     
  "body acceleration on Y",                                      
  "body acceleration on Z",                                      
  "body angular acceleration on X",                              
  "body angular acceleration on Y",                              
  "body angular acceleration on Z",                              
  "body angular jerk magnitude ",                                
  "body angular jerk on X",                                      
  "body angular jerk on Y",                                      
  "body angular jerk on Z",                                      
  "body angular velocity magnitude ",                            
  "body linear jerk magnitude ",                                 
  "body linear jerk on X",                                       
  "body linear jerk on Y",                                       
  "body linear jerk on Z",                                       
  "fourier transformed body acceleration magnitude ",            
  "fourier transformed body acceleration on X",                  
  "fourier transformed body acceleration on Y",                  
  "fourier transformed body acceleration on Z",                  
  "fourier transformed body angular acceleration on X",          
  "fourier transformed body angular acceleration on Y",          
  "fourier transformed body angular acceleration on Z",          
  "fourier transformed body linear jerk on X",                   
  "fourier transformed body linear jerk on Y",                   
  "fourier transformed body linear jerk on Z",                   
  "fourier transformed squared body angular jerk magnitude ",    
  "fourier transformed squared body angular velocity magnitude ",
  "fourier transformed squared body linear jerk magnitude ",     
  "gravity acceleration on X",                                   
  "gravity acceleration on Y",                                   
  "gravity acceleration on Z",                                   
  "gravity magnitude ". 
avg_mean: the average of the mean for each variable.
avg_std: the average of the std for each variable.

# Data processing

The script run_analysis.R does all the work and is fully commented so it should be clear enough. 
After loading, merging the data sets and extracting the mean and std columns, 
the script uses various dplyr commands to transform the data set into a tidy version.
The first change is the replacement of the numeric values for descriptive labes in the "activity" column as shown below:

```R
har <- mutate(har, activity = recode(activity, 
                       "1" = "walking",
                       "2" = "walking upstairs",
                       "3" = "walking downstairs",
                       "4" = "sitting",
                       "5" = "standing",
                       "6" = "laying"))
```
                 
The next step is a chain of commands to rearrange the data. The original data set measures the mean and the standard 
deviation for various variables and produces a column for each possible combination. The approach taken in this assignment
is to reduce the amount of columns ending with the columns "subject", "variable", "mean" and "std" which can be grouped to form a summary table. The summary table is saved here as tidyData.txt.
The first command just adds an ID column required afterward by the spread function.

```R
tidyHar <- mutate(har, id = 1:n()) %>% #add an id column to the table
```

The second command gather all the variables into a "variable" and "value" column.

```R     
gather(variable, value, 3:68) %>% #gather all variables
```

The third command separates the spatial dimension. Actually this step is not desired as not all variables have spatial dimentions and some will end with "NA" values. The reason fot the separation is to make easier the separation of the mean and std columns in the next step. Once the "mean" and "std" columns are extracted, the spatial dimension is returned to the variable.

```R
          separate(variable,
                c("variable", "dimension"),
                sep = "\\.(?=[XYZ])") %>% #creates a temporary column for spatial dimension
```
                
The fourth command separate the std and mean measurement into a temporary column called "fun".

```R
          separate(variable,
                c("variable",
                  "fun"),
                sep = "\\.(?=[sm])")  %>% #creates a column for function (mean or std)
```

The fifth command recode the column "fun" to remove points after the function name and recodes the variables in the "variable" column to make them descriptive. The descriptions come from the documentation of the original data.
 
```R
          mutate(fun = recode(fun,
                           "mean.." = "mean",
                          "std.." = "std"),
              variable = recode(variable, #recodes variables for better reading
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
                                "fBodyBodyGyroMag" = "fourier transformed squared body angular velocity magnitude")) %>% 
```
The sixth command spreads the "fun" column into the columns "mean" and "std" 
 
```R
          spread(fun, value) %>% #separates fun column into mean and std 
```

The seventh and eight commands merge the spatial dimension back to the variable and recode the variables with no spatial dimension.

```R
       unite(variable, variable, dimension, sep = " on ") %>%  #brings back spatial dimension to variable
       mutate(variable = gsub("on NA", "", variable)) #renames variables without spatial dimension
```

The resulting dataset is easy to group and summarise with the group_by and summarise function.

```R
#group the table by subject, activity and variable
tidyGroup <- group_by(tidyHar, subject, activity, variable) 
#produce summary table with average values
tidySummary <- summarise(tidyGroup, avg_mean = mean(mean), avg_std = mean(std))
```
