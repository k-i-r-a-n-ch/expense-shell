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

dnf install nginx -y &>>LOG_FILE
VALIDATE $? "Installing Nginx..."

systemctl enable nginx &>>LOG_FILE
VALIDATE $? "Enabling Nginx..."

systemctl start nginx &>>LOG_FILE
VALIDATE $? "Started Nginx..."

rm -rf /usr/share/nginx/html/* &>>LOG_FILE
VALIDATE $? "Removing default website..."

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>LOG_FILE
VALIDATE $? "Downloading Frontend code..."

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>LOG_FILE
VALIDATE $? "Extracting Frontend code..."

cp /home/ec2-user/expense-shell/frontend.conf /etc/nginx/default.d/expense.conf 
VALIDATE $? "copied expense conf..."

systemctl restart nginx &>>LOG_FILE
VALIDATE $? "Restarted Nginix"


