#!/bin/bash
##Script to deploy Shipping server
[ ! -d /var/tmp ] && mkdir /var/tmp
chmod 755 /var/tmp
[ ! -f /var/tmp/roboshop.log ] && touch /var/tmp/roboshop.log
chmod 755 /var/tmp/roboshop.log

LOG=/var/tmp/roboshop.log

echo "Install Maven & Java"

yum install maven -y >>$LOG
if [ $? = 0 ]; then
   id roboshop >/dev/null
   if [ $? != 0 ]; then
		  echo "roboshop user creation"
		  useradd roboshop >>$LOG
	fi
fi

echo "Downloading the Repo"

id roboshop >/dev/null
if [ $? = 0 ]; then
	cd /home/roboshop
	curl -s -L -o /tmp/shipping.zip "https://github.com/roboshop-devops-project/shipping/archive/main.zip" &>>$LOG
	if [ $? = 0 ]; then
		cd /home/roboshop && rm -rf shipping && unzip -o /tmp/shipping.zip &>>$LOG && mv shipping-main shipping && cd shipping && mvn clean package && mv target/shipping-1.0.jar shipping.jar && chown -R roboshop:roboshop /home/roboshop
	fi
fi

echo "CART and MySQLDB DNS in shipping service configuration file"

cp -pr /home/roboshop/shipping/systemd.service /home/roboshop/shipping/systemd.service_BKP
sed -i -e 's/CARTENDPOINT/cart.roboshop.internal/' -e 's/DBHOST/mysql.roboshop.internal/' /home/roboshop/shipping/systemd.service
if [ $? = 0 ]; then
	mv /home/roboshop/shipping/systemd.service /etc/systemd/system/shipping.service
	systemctl daemon-reload >/dev/null && systemctl start shipping >/dev/null && systemctl enable shipping >/dev/null && systemctl status shipping >/dev/null
fi
