#!/bin/bash
##Script to deploy catalogue server

[ ! -d /var/tmp ] && mkdir /var/tmp
chmod 755 /var/tmp
[ ! -f /var/tmp/roboshop.log ] && touch /var/tmp/roboshop.log
chmod 755 /var/tmp/roboshop.log

LOG=/var/tmp/roboshop.log

echo "Installing nodejs and GCC compiler"

yum install nodejs make gcc-c++ -y >>$LOG
if [ $? = 0 ]; then
   id roboshop >>$LOG
   if [ $? != 0 ]; then
	    echo "roboshop user creation"
	    useradd roboshop >>$LOG
	fi
fi

echo "Downloading the installing nodejs dependencies"

id roboshop >/dev/null
if [ $? = 0 ]; then
	  curl -s -L -o /tmp/catalogue.zip "https://github.com/roboshop-devops-project/catalogue/archive/main.zip" >>$LOG
	  cd /home/roboshop && unzip -o /tmp/catalogue.zip >>$LOG && rm -rf catalogue && mv catalogue-main catalogue &&	cd /home/roboshop/catalogue && npm install --unsafe-perm >>$LOG && chown -R roboshop.roboshop /home/roboshop
fi

echo "Adding Mongo DB URL to catalogue configuration file"
cp -pr /home/roboshop/catalogue/systemd.service /home/roboshop/catalogue/systemd.service_BKP
sed -i -e 's/MONGO_DNSNAME/mongodb.roboshop.internal/' /home/roboshop/catalogue/systemd.service >>$LOG
if [ $? = 0 ]; then
	  mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service && systemctl daemon-reload >/dev/null && systemctl start catalogue >/dev/null && systemctl enable catalogue
fi