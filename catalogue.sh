#!/bin/bash
USER_ID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.anand88b.online
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

dnf module disable nodejs -y &>>$LOGS_FILE
VALIDATE $? "disable noddejs" 

dnf module enable nodejs:20 -y &>>$LOGS_FILE
VALIDATE $? "enable node js 20"

dnf install nodejs -y &>>$LOGS_FILE
VALIDATE $? "enable node js 20"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
     VALIDATE $? "add system user"
else
     echo  -e "alredy system user exited....$Y skipping $N "    
fi

mkdir  -p /app 
VALIDATE $? "create app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOGS_FILE
VALIDATE $? "download the code"

cd /app
VALIDATE $? "moving app directory"

rm -rf /app/*
VALIDATE $? "removing exited code"

unzip /tmp/catalogue.zip &>>$LOGS_FILE
VALIDATE $? "unzip the catalogue code"

npm install &>>$LOGS_FILE
VALIDATE $? "install dependdency"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "create systemd service"

systemctl daemon-reload
systemctl enable catalogue  &>>$LOGS_FILE
systemctl start catalogue
VALIDATE $? "enable and start the catalogue"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo

dnf install mongodb-mongosh -y &>>$LOGS_FILE
VALIDATE $? "install mongodb mongosh"

INDEX=$(mongosh --host $MONGODB_HOST --quiet --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $INDEX -le 0 ]; then

   mongosh --host $MONGODB_HOST </app/db/master-data.js
   VALIDATE $? " loading products"
else
    echo -e " products already loading.......$Y skipping $N"
fi    

systemctl restart catalogue
VALIDATE $? "restart the cataslogue"

