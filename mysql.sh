#!/bin/bash

USER_ID=$(id -u)
LOGS_FOLDER='/var/log/shell-roboshop'
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER

if [ $USER_ID -ne 0 ]; then
    echo -e " $R the user is not in root path $N" | tee -a $LOGS_FILE
    exit 1
fi

VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo -e "$2 is .. $R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else 
        echo -e "$2 is .. $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

dnf install mysql-server -y
VALIDATE $? "MYSQL Server installation"

systemctl enable mysqld
systemctl start mysqld  
VALIDATE $? "Start and enabling system "

mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "Password initiation "
