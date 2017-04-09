#Getting and Cleaning Data - Course Project

##Introduction

This repo contain my course project to Coursera "Getting and Cleaning Data" course that is part of Data Science specialization.

There is just a script called run_analysis.R. It contain code to perform below steps:

* Download and Unzip UCI HAR Zip
* Merge Training and Test Data Set
* Extract only mean and standard deviation measurement
* Provide valid descriptive name to Activity
* Provide valid column names to each variable
* Create tidy dataset with only mean per variable per activty per subject
* Write tidy dataset to mean_per_var_act_sub.txt

The [CodeBook.md] (www.github.com) explain processed dataset and its variables.

##Run from command line

* Clone this repo

* Run the script:

  $ Rscript run_analysis.R

* Look for the final dataset at data/output/mean_per_var_act_sub.txt
