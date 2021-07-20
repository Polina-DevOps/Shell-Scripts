#!/bin/sh
##Script to deploy catalogue server

echo "Installing nodejfs and GCC compiler"
hostnamectl set-hostname catalogue
hostnamectl

sudo yum install nodejs make gcc-c++ -y >/dev/null
if [ $? = 0 ]; then
   id roboshop >/dev/null
   if [ $? != 0 ]; then
		echo "roboshop user creation"
		sudo useradd roboshop
		sudo echo "roboshop:roboshop" | chpasswd
	fi
fi

echo "Downloading the installing nodejs depnendencies"

id roboshop >/dev/null
if [ $? = 0 ]; then
	sudo su - roboshop -c 'curl -s -L -o /tmp/catalogue.zip "https://github.com/roboshop-devops-project/catalogue/archive/main.zip"'
	cd /home/roboshop
	sudo su - roboshop -c 'unzip -o /tmp/catalogue.zip'  >/dev/null
	sudo su - roboshop -c 'mv catalogue-main catalogue'
	cd /home/roboshop/catalogue
	sudo su - roboshop -c 'npm install /home/roboshop/catalogue'  >/dev/null
fi

echo "Adding Mongo DB URL to catalogue configuration file"

sudo sed -i -e 's/MONGO_DNSNAME/mongodb.roboshop.internal/g' /home/roboshop/catalogue/systemd.service
if [ $? = 0 ]; then
	sudo mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service
	sudo systemctl daemon-reload >/dev/null
	sudo systemctl start catalogue >/dev/null
	sudo systemctl enable catalogue >/dev/null
	sudo systemctl status catalogue >/dev/null
fi
