#!/bin/bash
##Script to deploy cart server

echo "Installing nodejfs and GCC compiler"

yum install nodejs make gcc-c++ -y >/dev/null
if [ $? = 0 ]; then
   id roboshop >/dev/null
   if [ $? != 0 ]; then
		  echo "roboshop cart creation"
		  useradd roboshop
	fi
fi

echo "Downloading the installing nodejs depnendencies"

id roboshop >/dev/null
if [ $? = 0 ]; then
	curl -s -L -o /tmp/cart.zip "https://github.com/roboshop-devops-project/cart/archive/main.zip"
	if [ $? = 0 ]; then
		  cd /home/roboshop && unzip -o /tmp/cart.zip && rm -rf cart && mv cart-main cart && cd /home/roboshop/cart && npm install --unsafe-perm && chown -R roboshop:roboshop /home/roboshop
	fi
fi

echo "REDIS_HOST and MONGO_URL in cart service configuration file"

cp -pr /home/roboshop/cart/systemd.service mv /home/roboshop/cart/systemd.service_BKP
sed -i -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' -e 's/CATALOGUE_ENDPOINT/catalogue.roboshop.internal/' /home/roboshop/cart/systemd.service
if [ $? = 0 ]; then
    mv /home/roboshop/cart/systemd.service /etc/systemd/system/cart.service >/dev/null && systemctl daemon-reload && systemctl start cart && systemctl enable cart
fi