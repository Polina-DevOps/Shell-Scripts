#!/bin/bash
## Script to deploy payment server

echo "Install Python 3"

yum install python36 gcc python3-devel -y >/dev/null
if [ $? = 0 ]; then
   id roboshop >/dev/null
   if [ $? != 0 ]; then
		echo "roboshop user creation"
		 useradd roboshop
		 echo "roboshop:roboshop" | chpasswd
	fi
fi
echo "Download the repo."
cd /home/roboshop
curl -L -s -o /tmp/payment.zip "https://github.com/roboshop-devops-project/payment/archive/main.zip"
if [ $? = 0 ]; then
	unzip -o /tmp/payment.zip >/dev/null && mv payment-main payment && cd payment
	echo "Install the dependencies"
	cd /home/roboshop/payment && pip3 install -r requirements.txt >/dev/null
fi

echo  "Update the roboshop user and group id in payment.ini file."

userID=$(id -u roboshop)
groupID=$(id -g roboshop)
sed -i -e "/uid/ c uid = ${userID}" -e "/gid/ c gid = ${groupID}" /home/roboshop/payment/payment.ini
if [ $? = 0 ];then
	echo "updating DNS entries in payment systemd.service"
	sed -i -e 's/CARTHOST/cart.roboshop.internal/' -e 's/USERHOST/user.roboshop.internal/' -e 's/AMQPHOST/rabbitmq.roboshop.internal/' /home/roboshop/payment/systemd.service
	if [ $? = 0 ];then
		echo "Setup the service"
		mv /home/roboshop/payment/systemd.service /etc/systemd/system/payment.service
		systemctl daemon-reload && systemctl enable payment && systemctl start payment
	fi
else
	echo "updating uid and gid failed"
fi
