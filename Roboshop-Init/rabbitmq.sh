#!/bin/bash
## To install & configure RabbitMQ server

[ ! -d /var/tmp ] && mkdir /var/tmp
chmod 755 /var/tmp
[ ! -f /var/tmp/roboshop.log ] && touch /var/tmp/roboshop.log
chmod 755 /var/tmp/roboshop.log

LOG=/var/tmp/roboshop.log

echo "Erlang is a dependency which is needed for RabbitMQ."

yum install https://github.com/rabbitmq/erlang-rpm/releases/download/v23.2.6/erlang-23.2.6-1.el7.x86_64.rpm -y &>>$LOG
if [ $? = 0 ]; then
    echo "Setup YUM repositories for RabbitMQ."
    curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash  &>>$LOG
    if [ $? = 0 ]; then
	      echo "Install RabbitMQ & Start RabbitMQ"
	      yum install rabbitmq-server -y &>>$LOG && systemctl enable rabbitmq-server && systemctl start rabbitmq-server
    else
	      exit 1
	  fi
else
    exit 1
fi

echo "Create App User in RabbitMQ"
rabbitmqctl  list_users | grep roboshop &>>$LOG
if [ $? != 0 ]; then
  rabbitmqctl add_user roboshop roboshop123 &>>$LOG
fi
rabbitmqctl set_user_tags roboshop administrator &>>$LOG && rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
