#!/bin/bash
##Script to deploy user server
[ ! -d /var/tmp ] && mkdir /var/tmp
chmod 755 /var/tmp
[ ! -f /var/tmp/roboshop.log ] && touch /var/tmp/roboshop.log
chmod 755 /var/tmp/roboshop.log

LOG=/var/tmp/roboshop.log

echo "Installing nodejs and GCC compiler"

yum install nodejs make gcc-c++ -y >>$LOG
if [ $? = 0 ]; then
   id roboshop >/dev/null
   if [ $? != 0 ]; then
		  echo "roboshop user creation"
		  useradd roboshop >>$LOG
	fi
fi

echo "Downloading the installing nodejs depnendencies"

id roboshop >>$LOG
if [ $? = 0 ]; then
	curl -s -L -o /tmp/user.zip "https://github.com/roboshop-devops-project/user/archive/main.zip" >>$LOG
	if [ $? = 0 ]; then
		  cd /home/roboshop && unzip -o /tmp/user.zip >>$LOG && rm -rf user >>$LOG && mv user-main user && cd /home/roboshop/user && npm install --unsafe-perm >>$LOG && chown -R roboshop:roboshop /home/roboshop
	fi
fi

echo "REDIS_HOST and MONGO_URL in user service configuration file"

sed -i -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' -e 's/MONGO_ENDPOINT/mongodb.roboshop.internal/' /home/roboshop/user/systemd.service
if [ $? = 0 ]; then
	 mv /home/roboshop/user/systemd.service /etc/systemd/system/user.service && systemctl daemon-reload >/dev/null && systemctl start user >/dev/null && systemctl enable user >/dev/null && systemctl restart user
fi
