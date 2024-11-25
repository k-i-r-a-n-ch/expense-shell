#!/bin/bash

LOGS_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"

mkdir -p $LOGS_FOLDER

userid=$(id -u)

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"


CHECK_ROOT(){
    if [ $userid -ne 0 ]
    then
       echo -e "$R please run this script through root priviliges $N" | tee -a $LOG_FILE
       exit 1     #shell script will come out of the program
    fi
}

VALIDATE(){
     if [ $1 -ne 0 ]
     then  
         echo -e "$2 is ...$R failed $N" | tee -a $LOG_FILE
         exit 1
     else 
         echo -e "$2 is ....$G success $N" | tee -a $LOG_FILE
     fi
}


echo "Script started executing at $(date)" | tee -a $LOG_FILE

CHECK_ROOT


dnf module disable nodejs -y
VALIDATE $? "Disable Default NODEJS ...."

dnf module enable nodejs:20 -y
VALIDATE $? "Enabling NODEJS:20 ...."

dnf install nodejs -y
VALIDATE $? "Installing Nodejs..."

useradd expense
VALIDATE $? "Creating Expense User..."




