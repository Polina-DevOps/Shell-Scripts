#!/bin/sh
##Script to deploy cart server

echo "Installing nodejfs and GCC compiler"

yum install nodejs make gcc-c++ -y >/dev/null
if [ $? = 0 ]; then
   id roboshop >/dev/null
   if [ $? != 0 ]; then
		  echo "roboshop cart creation"
		  useradd roboshop
		  echo "roboshop:roboshop" | chpasswd
	fi
fi

echo "Downloading the installing nodejs depnendencies"

id roboshop >/dev/null
if [ $? = 0 ]; then
	  curl -s -L -o /tmp/cart.zip "https://github.com/roboshop-devops-project/cart/archive/main.zip"
	  if [ $? = 0 ]; then
		    cd /home/roboshop && unzip -o /tmp/cart.zip && rm -rf cart && mv cart-main cart && cd /home/roboshop/cart && npm install --unsafe-perm=true -g now && chown -R roboshop:roboshop /home/roboshop && chmod 755 /home/roboshop
	  fi
fi

echo "REDIS_HOST and MONGO_URL in cart service configuration file"

##sed -i -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' -e 's/MONGO_ENDPOINT/mongodb.roboshop.internal/' /etc/systemd/system/cart.service
if [ $? = 0 ]; then
	 mv /home/roboshop/cart/systemd.service /etc/systemd/system/cart.service
	 systemctl daemon-reload
	 systemctl start cart
	 systemctl enable cart
fi