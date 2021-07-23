#!/bin/bash
## To configure redis server

[ ! -d /var/tmp ] && mkdir /var/tmp
chmod 755 /var/tmp
[ ! -f /var/tmp/roboshop.log ] && touch /var/tmp/roboshop.log
chmod 755 /var/tmp/roboshop.log

LOG=/var/tmp/roboshop.log

echo "Installing Redis redis"

yum install epel-release yum-utils http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y >>$LOG && yum install redis -y --enablerepo=remi >>$LOG

echo "Update the BindIP from 127.0.0.1 to 0.0.0.0 in config file /etc/redis.conf & /etc/redis/redis.conf"

sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis.conf /etc/redis/redis.conf >>$LOG
if [ $? = 0 ]; then
	echo "enable & start redis services"
	systemctl enable redis >/dev/null && systemctl start redis >/dev/null && systemctl restart redis && systemctl status redis >/dev/null
fi