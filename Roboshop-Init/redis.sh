#!/bin/bash
## To configure redis server

echo "Installing Redis redis"

sudo yum install epel-release yum-utils -y && sudo yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y && sudo yum-config-manager --enable remi && sudo yum install redis -y

echo "Update the BindIP from 127.0.0.1 to 0.0.0.0 in config file /etc/redis.conf & /etc/redis/redis.conf"

sudo sed -i -e 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf /etc/redis/redis.conf
if [ $? = 0 ]; then
	echo "enable & start redis services"
	sudo systemctl enable redis
	sudo systemctl start redis
	sudo systemctl restart redis
	sudo systemctl status redis
fi