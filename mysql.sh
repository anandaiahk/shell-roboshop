#!/bin/bash
USER_ID=$(id -u)
LOGS_FOLDER="/var/log/shell-script"
LOGS_FILE="/var/log/shell-script/$0.log"
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

dnf install mysql-server -y &>>$LOGS_FILE
VALIDATE $? "installing mysql"

systemctl enable mysqld &>>$LOGS_FILE
systemctl start mysqld  
VALIDATE $? "enable and start the mysqld"

mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "setup root passwd"