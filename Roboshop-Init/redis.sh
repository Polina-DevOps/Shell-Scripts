#!/bin/bash
## To configure redis server

echo "Installing Redis redis"

yum install epel-release yum-utils -y && yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y && yum-config-manager --enable remi && yum install redis -y

echo "Update the BindIP from 127.0.0.1 to 0.0.0.0 in config file /etc/redis.conf & /etc/redis/redis.conf"

sed -i -e 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf /etc/redis/redis.conf
if [ $? = 0 ]; then
	echo "enable & start redis services"
	systemctl enable redis
	systemctl start redis
	systemctl restart redis
fi