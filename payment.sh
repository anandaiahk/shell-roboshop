#!/bin/bash
USER_ID=$(id -u)
LOGS_FOLDER="/var/log/shell-script"
LOGS_FILE="/var/log/shell-script/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD
MYSQL_HOST=mysql.anand88b.online
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

 dnf install python3 gcc python3-devel -y &>>$LOGS_FILE
 VALIDATE $? "installing pythonf"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
     VALIDATE $? "add system user"
else
     echo  -e "alredy system user exited....$Y skipping $N "    
fi
 
mkdir  -p /app 
VALIDATE $? "create app directory"

curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$LOGS_FILE
VALIDATE $? "download the code"

cd /app
VALIDATE $? "moving app directory"

rm -rf /app/* &>>$LOGS_FILE
VALIDATE $? "removing exited code"

unzip /tmp/payment.zip &>>$LOGS_FILE
VALIDATE $? "unzip the payment code"

cd /app 
pip3 install -r requirements.txt &>>$LOGS_FILE
VALIDATE $? "installing depences"

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service
VALIDATE $? "service file copied"

systemctl daemon-reload &>>$LOGS_FILE
systemctl enable payment &>>$LOGS_FILE
systemctl start payment
VALIDATE $? "payment enable start the service"