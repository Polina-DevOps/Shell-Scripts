#!/bin/bash
##Script to deploy catalogue server

echo "Installing nodejfs and GCC compiler"

yum install nodejs make gcc-c++ -y >/dev/null
if [ $? = 0 ]; then
   id roboshop >/dev/null
   if [ $? != 0 ]; then
	    echo "roboshop user creation"
	    useradd roboshop
	fi
fi

echo "Downloading the installing nodejs depnendencies"

id roboshop >/dev/null
if [ $? = 0 ]; then
	  curl -s -L -o /tmp/catalogue.zip "https://github.com/roboshop-devops-project/catalogue/archive/main.zip"
	  cd /home/roboshop && 	unzip -o /tmp/catalogue.zip && rm -rf catalogue && mv catalogue-main catalogue &&	cd /home/roboshop/catalogue && npm install --unsafe-perm && chown -R roboshop.roboshop /home/roboshop
fi

echo "Adding Mongo DB URL to catalogue configuration file"
cp -pr /home/roboshop/catalogue/systemd.service /home/roboshop/catalogue/systemd.service_BKP
sed -i -e 's/MONGO_DNSNAME/mongodb.roboshop.internal/g' /home/roboshop/catalogue/systemd.service
if [ $? = 0 ]; then
	  mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service && systemctl daemon-reload >/dev/null && systemctl start catalogue >/dev/null && systemctl enable catalogue
fi