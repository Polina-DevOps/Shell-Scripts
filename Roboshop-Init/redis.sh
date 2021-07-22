#!/bin/bash
## To configure redis server

echo "Installing Redis redis"

yum install epel-release yum-utils -y >/dev/null && yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y >/dev/null && yum install redis -y --enablerepo=remi >/dev/null

echo "Update the BindIP from 127.0.0.1 to 0.0.0.0 in config file /etc/redis.conf & /etc/redis/redis.conf"

sed -i -e 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf /etc/redis/redis.conf
if [ $? = 0 ]; then
	echo "enable & start redis services"
	systemctl enable redis >/dev/null && systemctl start redis >/dev/null && systemctl restart redis && systemctl status redis >/dev/null
fi