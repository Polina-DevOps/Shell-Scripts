#!/bin/sh
##Script to deploy user server

echo "Installing nodejfs and GCC compiler"

yum install nodejs make gcc-c++ -y >/dev/null
if [ $? = 0 ]; then
   id roboshop >/dev/null
   if [ $? != 0 ]; then
		echo "roboshop user creation"
		 useradd roboshop
		 echo "roboshop:roboshop" | chpasswd
	fi
fi

echo "Downloading the installing nodejs depnendencies"

id roboshop >/dev/null
if [ $? = 0 ]; then
	curl -s -L -o /tmp/user.zip "https://github.com/roboshop-devops-project/user/archive/main.zip"
	if [ $? = 0 ]; then
		cd /home/roboshop && unzip -o /tmp/user.zip && mv user-main user && cd /home/roboshop/user && npm install --unsafe-perm=true -g now && chown -R roboshop:roboshop /home/roboshop
	fi
fi

echo "REDIS_HOST and MONGO_URL in user service configuration file"

sed -i -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' -e 's/MONGO_ENDPOINT/mongodb.roboshop.internal' /etc/systemd/system/user.service
if [ $? = 0 ]; then
	 mv /home/roboshop/user/systemd.service /etc/systemd/system/user.service
	 systemctl daemon-reload
	 systemctl start user
	 systemctl enable user
	 systemctl status user
fi
