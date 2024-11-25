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


dnf module disable nodejs -y &>>LOG_FILE
VALIDATE $? "Disable Default NODEJS ...."

dnf module enable nodejs:20 -y &>>LOG_FILE
VALIDATE $? "Enabling NODEJS:20 ...."

dnf install nodejs -y &>>LOG_FILE
VALIDATE $? "Installing Nodejs..."

id expense &>>LOG_FILE
if [ $? -ne 0 ]
then
    echo -e "expense user not exists...$G Creating $N"
    useradd expense &>>LOG_FILE
    VALIDATE $? "Creating Expense User..."
else
    echo -e "expense user already exists.... $Y Skipping $N"
fi

mkdir -p /app
VALIDATE $? "Creating /app folder..."

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>LOG_FILE
VALIDATE $? "Downloading Backend Application code..."

cd /app
rm -rf /app/*  #remove the existing code
unzip /tmp/backend.zip &>>LOG_FILE
VALIDATE $? "Extracting Backend Application code..."


npm install &>>LOG_FILE
cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service

#load the data before running backend

dnf install mysql -y &>>LOG_FILE
VALIDATE $? "Installing MYSQL client..."

mysql -h mysql.devopsdragon.fun -uroot -pExpenseApp@1 < /app/schema/backend.sql
VALIDATE $? "Schema Loading..."

systemctl daemon-reload &>>LOG_FILE
VALIDATE $? "Deamon re-load..."

systemctl enable backend &>>LOG_FILE
VALIDATE $? "Enabling backend..."

systemctl restart backend &>>LOG_FILE
VALIDATE $? "restarted backend..."












