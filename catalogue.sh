#!/bin/bash

USER_ID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"



R='\e[31m'
G='\e[32m'
Y='\e[33m'
B='\e[34m'
N='\e[0m'

if [ $USER_ID -ne 0 ]; then
    echo -e " $R it is not a root user $N" | tee -a $LOGS_FILE
    exit 1
fi 

mkdir -p $LOGS_FOLDER

VALIDATE() {
    if [ $1 -eq 0 ]; then
        echo -e "$2 .. is $G SUCCESS $N" | tee -a $LOGS_FILE
    else
        echo -e "$2 .. is $R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    fi
}


dnf module disable nodejs -y &>>$LOGS_FILE
VALIDATE $? "Module disabling"

dnf module enable nodejs:20 -y &>>$LOGS_FILE
VALIDATE $? "module version change "

dnf install nodejs -y &>>$LOGS_FILE
VALIDATE $? "Installation of nodejs"

id roboshop &>>$LOGS_FILE
if [$? -ne 0]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "Adding application user"
else
    echo -e "roboshop user exist .. $Y SKIPPING"
fi

mkdir /app
VALIDATE $? "directory creation"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
VALIDATE $? "downloading catalogue logic"

cd /app
VALIDATE $? "changing directory"

unzip /tmp/catalogue.zip
VALIDATE $? "unzip catalogue logic"

npm install
VALIDATE $? "installation of npm"

cp catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "service configuration "

systemctl daemon-reload
VALIDATE $? "daemon reload "

systemctl enable catalogue 
systemctl start catalogue
VALIDATE $? "catalogue enable and start "

