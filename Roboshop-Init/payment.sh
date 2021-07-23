#!/bin/bash
## Script to deploy payment server
[ ! -d /var/tmp ] && mkdir /var/tmp
chmod 755 /var/tmp
[ ! -f /var/tmp/roboshop.log ] && touch /var/tmp/roboshop.log
chmod 755 /var/tmp/roboshop.log

LOG=/var/tmp/roboshop.log

echo "Install Python 3"

yum install python36 gcc python3-devel -y &>>$LOG
if [ $? = 0 ]; then
   id roboshop >/dev/null
   if [ $? != 0 ]; then
		  echo "roboshop user creation"
		  useradd roboshop &>>$LOG
	fi
fi
echo "Download the repo."
cd /home/roboshop
curl -L -s -o /tmp/payment.zip "https://github.com/roboshop-devops-project/payment/archive/main.zip" &>>$LOG
if [ $? = 0 ]; then
	  unzip -o /tmp/payment.zip &>>$LOG && rm -rf payment && mv payment-main payment && cd payment
	  echo "Install the dependencies"
	  cd /home/roboshop/payment && pip3 install -r requirements.txt &>>$LOG
fi

echo  "Update the roboshop user and group id in payment.ini file."

userID=$(id -u roboshop)
groupID=$(id -g roboshop)
sed -i -e "/uid/ c uid = ${userID}" -e "/gid/ c gid = ${groupID}" /home/roboshop/payment/payment.ini &>>$LOG
if [ $? = 0 ]; then
	  echo "updating DNS entries in payment systemd.service"
	  cp -pr  /home/roboshop/payment/systemd.service  /home/roboshop/payment/systemd.service_BKP
	  sed -i -e 's/CARTHOST/cart.roboshop.internal/' -e 's/USERHOST/user.roboshop.internal/' -e 's/AMQPHOST/rabbitmq.roboshop.internal/' /home/roboshop/payment/systemd.service &>>$LOG
	  if [ $? = 0 ]; then
		    echo "Setup the service"
		    mv /home/roboshop/payment/systemd.service /etc/systemd/system/payment.service &>>$LOG
		    systemctl daemon-reload && systemctl enable payment && systemctl start payment
	  fi
else
	  echo "updating uid and gid failed"
fi
