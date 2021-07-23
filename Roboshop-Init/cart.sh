#!/bin/bash
##Script to deploy cart server
[ ! -d /var/tmp ] && mkdir /var/tmp
chmod 755 /var/tmp
[ ! -f /var/tmp/roboshop.log ] && touch /var/tmp/roboshop.log
chmod 755 /var/tmp/roboshop.log

LOG=/var/tmp/roboshop.log

echo "Installing nodejs and GCC compiler"

yum install nodejs make gcc-c++ -y >>LOG
if [ $? = 0 ]; then
   id roboshop >>LOG
   if [ $? != 0 ]; then
		  echo "roboshop cart creation"
		  useradd roboshop
	fi
fi

echo "Downloading the installing nodejs depnendencies"

id roboshop >/dev/null
if [ $? = 0 ]; then
	curl -s -L -o /tmp/cart.zip "https://github.com/roboshop-devops-project/cart/archive/main.zip" >>LOG
	if [ $? = 0 ]; then
		  cd /home/roboshop && unzip -o /tmp/cart.zip >>LOG && rm -rf cart && mv cart-main cart && cd /home/roboshop/cart && npm install --unsafe-perm >>LOG && chown -R roboshop:roboshop /home/roboshop
	fi
fi

echo "REDIS_HOST and MONGO_URL in cart service configuration file"

cp -pr /home/roboshop/cart/systemd.service mv /home/roboshop/cart/systemd.service_BKP
sed -i -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' -e 's/CATALOGUE_ENDPOINT/catalogue.roboshop.internal/' /home/roboshop/cart/systemd.service >>LOG
if [ $? = 0 ]; then
    mv /home/roboshop/cart/systemd.service /etc/systemd/system/cart.service >/dev/null && systemctl daemon-reload && systemctl start cart && systemctl enable cart
fi