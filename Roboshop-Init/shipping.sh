#!/bin/bash
##Script to deploy Shipping server

echo "Install Maven, This will install Java too"

yum install maven -y >/dev/null
if [ $? = 0 ]; then
   id roboshop >/dev/null
   if [ $? != 0 ]; then
		  echo "roboshop user creation"
		  useradd roboshop
	fi
fi

echo "Downloading the Repo"

id roboshop >/dev/null
if [ $? = 0 ]; then
	cd /home/roboshop
	curl -s -L -o /tmp/shipping.zip "https://github.com/roboshop-devops-project/shipping/archive/main.zip"
	if [ $? = 0 ]; then
		cd /home/roboshop && rm -rf shipping-main shipping && unzip -o /tmp/shipping.zip >/dev/null && rm -rf shipping && mv shipping-main shipping && cd shipping && mvn clean package && mv target/shipping-1.0.jar shipping.jar && chown -R roboshop:roboshop /home/roboshop
	fi
fi

echo "CART and MySQLDB DNS in shipping service configuration file"

cp -pr /home/roboshop/shipping/systemd.service /home/roboshop/shipping/systemd.service_BKP
sed -i -e 's/CART_ENDPOINT/cart.roboshop.internal/' -e 's/DBHOST/mysql.roboshop.internal/' /home/roboshop/shipping/systemd.service
if [ $? = 0 ]; then
	mv /home/roboshop/shipping/systemd.service /etc/systemd/system/shipping.service
	systemctl daemon-reload >/dev/null && systemctl start shipping >/dev/null && systemctl enable shipping >/dev/null && systemctl status shipping >/dev/null
fi
