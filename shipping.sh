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

 dnf install maven -y &>>$LOGS_FILE
 VALIDATE $? "installing maven"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
     VALIDATE $? "add system user"
else
     echo  -e "alredy system user exited....$Y skipping $N "    
fi
 
mkdir  -p /app 
VALIDATE $? "create app directory"

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOGS_FILE
VALIDATE $? "download the code"

cd /app
VALIDATE $? "moving app directory"

rm -rf /app/* &>>$LOGS_FILE
VALIDATE $? "removing exited code"

unzip /tmp/shipping.zip &>>$LOGS_FILE
VALIDATE $? "unzip the shipping code"

cd /app 
mvn clean package &>>$LOGS_FILE
VALIDATE $? "installing and building shipping"

mv target/shipping-1.0.jar shipping.jar 
VALIDATE $? "moving and renaming shipping"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service
VALIDATE $? "create systemd service"

dnf install mysql -y &>>$LOGS_FILE
VALIDATE $? "install mysql"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e 'use cities'
if[ $? -ne 0 ]; then

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql 

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql
VALIDATE $? "loaded data into mysql"
else
echo -e "data is already loaded.......$Y skipping $N"
fi

systemctl daemon-reload
systemctl enable shipping &>>$LOGS_FILE
systemctl start shipping
VALIDATE $? "shipping enable and start"