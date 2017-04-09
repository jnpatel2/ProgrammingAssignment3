#Import packages
library(downloader)
library(dplyr)
library(quantmod)
library(lubridate)
library(stringr)

# Step 0 : Download Zip and Unzip dataset
#Check if zip file is not downloaded, then download and unzip

zurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

if(!file.exists("data/dataset.zip")) {
  dir.create("./data")
  download(zurl, dest="./data/dataset.zip", mode="wb") 

}
if(!file.exists("data/UCI HAR Dataset")) {
  unzip ("./data/dataset.zip", exdir = "./data")
}

#Read Training Data set
trn_dataX <- read.table("./data/UCI HAR Dataset/train/X_train.txt",header = FALSE)
trn_dataY <- read.table("./data/UCI HAR Dataset/train/Y_train.txt",header = FALSE)
trn_sub   <- read.table("./data/UCI HAR Dataset/train/subject_train.txt",header = FALSE)

#Read Test Data set
tst_dataX <- read.table("./data/UCI HAR Dataset/test/X_test.txt",header = FALSE)
tst_dataY <- read.table("./data/UCI HAR Dataset/test/Y_test.txt",header = FALSE)
tst_sub   <- read.table("./data/UCI HAR Dataset/test/subject_test.txt",header = FALSE)

# Step : 1
# Merge Training and Test Data Set
colnames(tst_dataX) <- colnames(trn_dataX)
merged_dataX   <- rbind(trn_dataX,tst_dataX)
merged_dataY   <- rbind(trn_dataY,tst_dataY)
merged_dataSub <- rbind(trn_sub,tst_sub)

colnames(merged_dataY) <- "Activity"
colnames(merged_dataSub) <- "Subject"
# Merging Activity details with measurement
merged_data <- cbind(merged_dataX,merged_dataY,merged_dataSub)
print("Step 1 : Printing Merged Training and Test Data Set")
#str(merged_data)

# Step : 2
# Extracts only the measurements on the mean 
# and standard deviation for each measurement

# Sub Steps :-
# To collect all mean and std, we need to first parse Feature list
# and get colmn name which represent mean or std
#Read Training Data set
ftr_list <- read.table("./data/UCI HAR Dataset/features.txt",header = FALSE)

# Column Number which has mean data
mean_col_list <- grep("mean",ftr_list[,2])
# Column Number which has Standar Deviation data
std_col_list <- grep("std",ftr_list[,2])

#Convert to Data Table
merged_data <- tbl_df(merged_data)

#Select Required column with Mean and STD values
mean_std_data <- select(merged_data,Activity,Subject,mean_col_list,std_col_list)
print("Step 2 : Printing collected mean and std variables")
#str(mean_std_data)

# Step : 3
# Uses descriptive activity names to name the activities in the data set
# Sub Steps :-
# Read Activity Names from File
activity_list <- read.table("./data/UCI HAR Dataset/activity_labels.txt",header = FALSE)

# Replace Activity Number with Activity Name
mean_std_data$Activity <- gsub("1",activity_list[1,2],mean_std_data$Activity)
mean_std_data$Activity <- gsub("2",activity_list[2,2],mean_std_data$Activity)
mean_std_data$Activity <- gsub("3",activity_list[3,2],mean_std_data$Activity)
mean_std_data$Activity <- gsub("4",activity_list[4,2],mean_std_data$Activity)
mean_std_data$Activity <- gsub("5",activity_list[5,2],mean_std_data$Activity)
mean_std_data$Activity <- gsub("6",activity_list[6,2],mean_std_data$Activity)

# Required Data Set with Acitivity Details
print("Step 3 : Printing processed data set with activity names")
#str(mean_std_data)

# Step : 4
# Appropriately labels the data set with descriptive variable names
# Sub Step :-
# Collect Column names from ftr_list and apply on mean_std_data

col_names <- c(as.character(ftr_list[mean_col_list,2]),as.character(ftr_list[std_col_list,2]))
colnames(mean_std_data) <- c("Activity","Subject",col_names)

# Required Data  Set with Detailed Variable Names
print("Step 4 : Printing processed data set with variable names")
#str(mean_std_data)

# Step : 5
# From the data set in step 4, creates a second, independent tidy data set with 
# the average of each variable for each activity and each subject.

# Sub Step:-
# Arrange Data with Activity and then Subject to allow easy averaging
mean_std_data <- arrange(mean_std_data,Activity,Subject)

# Looping per Activity per Subject to create mean of each Variable

for(act in activity_list[1:6,2]){
  for(sbj in 1:30){
    t_dt <- filter(mean_std_data,Activity==act) %>% filter(Subject==sbj)
    t_dt <- matrix(c(act,sbj,sapply(t_dt[3:81],mean)),1,81)
    colnames(t_dt) <- colnames(mean_std_data)
    t_dt <- tbl_df(t_dt)
    if(act == activity_list[1,2] && sbj == 1) {
      mean_per_var_act_sub <- t_dt
    }
    else{
      mean_per_var_act_sub <- rbind(mean_per_var_act_sub,t_dt)
    }
  }
}

# Tidy Data Set Mean per Variable per Activity per Subject
if(!file.exists("data/output")) {
  dir.create("./data/output")
}
write.table(mean_per_var_act_sub,file="./data/output/mean_per_var_act_sub.txt", row.name = FALSE)
print("Step 5 : Writing Data Set ./data/output/mean_per_var_act_sub.txt with Mean per Variable per Activity per Subject")
