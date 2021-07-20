#!/bin/sh
##Script to deploy catalogue server

echo "Installing nodejfs and GCC compiler"

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
	sudo su - roboshop -c 'cd /home/roboshop'
	sudo su - roboshop -c 'unzip -o /tmp/catalogue.zip'
	sudo su - roboshop -c 'mv catalogue-main catalogue'
	sudo su - roboshop -c 'cd /home/roboshop/catalogue'
	sudo su - roboshop -c 'npm install'
fi

echo "Adding Mongo DB URL to catalogue configuration file"

sudo sed -i -e 's/MONGO_DNSNAME/mongodb.roboshop.internal/g' /home/roboshop/catalogue/systemd.service
if [ $? = 0 ]; then
then
	sudo mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service
	sudo systemctl daemon-reload
	sudo systemctl start catalogue
	sudo systemctl enable catalogue
fi
