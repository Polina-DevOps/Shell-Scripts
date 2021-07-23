#!/bin/bash
## Script to setup MySQL database server
[ ! -d /var/tmp ] && mkdir /var/tmp
chmod 755 /var/tmp
[ ! -f /var/tmp/roboshop.log ] && touch /var/tmp/roboshop.log
chmod 755 /var/tmp/roboshop.log

LOG=/var/tmp/roboshop.log

echo "Setting up MySQL Repo"

echo '[mysql57-community]
name=MySQL 5.7 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.7-community/el/7/$basearch/
enabled=1
gpgcheck=0' > /etc/yum.repos.d/mysql.repo
if [ $? = 0 ]; then
	  echo "Install MySQL components"
	  yum install mysql-community-server -y >>$LOG
	  if [ $? = 0 ]; then
		    echo "Start MySQL service"
		    systemctl enable mysqld >/dev/null && systemctl start mysqld >/dev/null && systemctl status mysqld >>$LOG
	  fi
fi

echo "Check and Change default root password from MYSQL"
DEFAULT_PASSWORD=$(grep 'A temporary password' /var/log/mysqld.log  | awk '{print $NF}') &>>$LOG

echo "show databases;" | mysql -uroot -pRoboShop@1
if [ $? != 0 ]; then
    echo "ALTER USER 'root'@'localhost' IDENTIFIED BY 'RoboShop@1';" | mysql --connect-expired-password -uroot -p${DEFAULT_PASSWORD} &>>$LOG
fi

echo "TO remove the SQL password policy."
echo SHOW PLUGINS | mysql -uroot -pRoboShop@1 2>>$LOG | grep -i validate_password &>>$LOG
if [ $? = 0 ]; then
    echo "uninstall plugin validate_password;" | mysql -uroot -pRoboShop@1 &>>$LOG
fi

echo "load that schema into the database"

curl -s -L -o /tmp/mysql.zip "https://github.com/roboshop-devops-project/mysql/archive/main.zip" &>>$LOG
if [ $? = 0 ]; then
  echo "Load the schema for Services."
  cd /tmp && unzip -o mysql.zip &>>$LOG && rm -rf mysql && cd mysql-main && mysql -uroot -pRoboShop@1 <shipping.sql &>>$LOG
  if [ $? = 0 ]; then
     echo "MySQL DB configuration success"
  fi
fi

