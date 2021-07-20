#!/bin/sh
## Script to create and configure Mongodb in the server && Run this script as root

#Changing hostname
sudo hostnamectl set-hostname mongodb
sudo hostname

echo "Setting up MongoDB repos."

echo '[mongodb-org-4.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.2/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.2.asc' >/etc/yum.repos.d/mongodb.repo
if [ $? = 0 ];then
	ehco  "Install Mongo DB & Start Service."
	sudo yum install -y mongodb-org >/dev/null
	if [ $? = 0 ]; then
		echo "Enabling mongodb default startup"
		sudo systemctl enable mongod >/dev/null
		sudo systemctl start mongod >/dev/null
	fi
fi

echo "Update Liste IP address from 127.0.0.1 to 0.0.0.0 in config file : /etc/mongod.conf"
##Config file: /etc/mongod.conf

sudo sed -i -e 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
if [ $? = 0 ];then
	echo "Restarting mongodb services"
	sudo systemctl restart mongod
fi

echo "Download the mongodb schema and load it"

curl -s -L -o /tmp/mongodb.zip "https://github.com/roboshop-devops-project/mongodb/archive/main.zip"
if [ $? = 0 ];then
	cd /tmp && sudo unzip -o mongodb.zip && cd mongodb-main && sudo mongo < catalogue.js && sudo mongo < users.js
fi
