#!/bin/bash
USER_ID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
if [ $USER_ID -ne 0 ]; then
echo -e "$R please run the script in root aceess $N"
exit 1
fi
mkdir -p $LOGS_FOLDER

VALIDATE()
{
    if [ $1 -ne 0 ]; then
      echo -e "$2.......$R FAILURE $N" | tee -a $LOGS_FILE
      exit 1
     else
       echo -e "$2........$G SUCESS $N" | tee -a $LOGS_FILE
     fi

}

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying mongo repo"

dnf install mongodb-org -y &>>$LOGS_FILE
VALIDATE $? "installing mongodb server"

systemctl enable mongod &>>$LOGS_FILE
VALIDATE $? "enable mongod service"

systemctl start mongod 
VALIDATE $? "start mongod service"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "allowing remote connections"

systemctl restart mongod
VALIDATE $? "restart the mongod service"


