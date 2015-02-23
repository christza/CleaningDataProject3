library(dplyr)

#downlink="https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
#download.file(downlink,"data.zip")
#unzip("data.zip")

setwd("UCI HAR Dataset")

#EXTRACT DESCRIPTIVE NAMES
measurName=read.table("features.txt",nrow=561,colClasses="character") #reads the descriptive file
activName=read.table("activity_labels.txt")

# TEST
setwd("test")
personID_test=read.table("subject_test.txt")
activityID_test=read.table("y_test.txt")
measurements_test=read.table("X_test.txt")
setwd("..")

#TRAIN
setwd("train")
personID_train=read.table("subject_train.txt")
activityID_train=read.table("y_train.txt")
measurements_train=read.table("X_train.txt")
setwd("..")

# MERGE
personID=rbind(personID_test,personID_train)
activityID=rbind(activityID_test,activityID_train)
measurements=rbind(measurements_test,measurements_train)
overall=cbind(personID,activityID,measurements)
names(overall)[1:2]=c("personID","activityID")
# names(overall)[3:ncol(overall)]=measurName[,2]

# LOCATE mean, std MEASUREMENTS
mean_location=setdiff((grep("mean",measurName[,2])),(grep("meanF",measurName[,2]))) #locates mean string
# meanF_location=grep("meanFr",measurName[,2]) #locates mean string
std_location=grep("std",measurName[,2]) #locates std string
location=c(mean_location,std_location) # location of both mean and std values

# EXTRACT ONLY mean and std VALUES 
overall_subset=select(overall,1,2,2+location) #obtain dataframe with subjectID, activityID and mean&std values

# NAME COLUMNS and ACTIVITIES
names(overall_subset)[3:ncol(overall_subset)]=measurName[location,2]
overall_subset=arrange(overall_subset,personID,activityID)
overall_subset$activityID=activName[overall_subset$activityID,2]
names(overall_subset)[2]="activity"

###################################################

# NEW DATASET
dataset=overall_subset
dataset_grouped=group_by(dataset,personID,activity)
dataset_new=summarise_each(dataset_grouped,funs(mean))
###########################################
# EXPORT TO TXT
write.table(dataset_new,"TidyDataset.txt",row.name=F)