#!/bin/bash
## Script to setup MySQL database server
echo "Setting up MySQL Repo"

echo '[mysql57-community]
name=MySQL 5.7 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.7-community/el/7/$basearch/
enabled=1
gpgcheck=0' > /etc/yum.repos.d/mysql.repo
if [ $? = 0 ]; then
	  echo "Install MySQL components"
	  yum install mysql-community-server -y >/dev/null
	  if [ $? = 0 ]; then
		    echo "Start MySQL service"
		    systemctl enable mysqld >/dev/null && systemctl start mysqld >/dev/null && systemctl status mysqld >/dev/null
	  fi
fi

echo "Check and Change default root password from MYSQL"
DEFAULT_PASSWORD=$(grep 'A temporary password' /var/log/mysqld.log  | awk '{print $NF}')

echo "show databases;" | mysql -uroot -pRoboShop@1
if [ $? != 0 ]; then
    echo "ALTER USER 'root'@'localhost' IDENTIFIED BY 'RoboShop@1';" | mysql --connect-expired-password -uroot -p${DEFAULT_PASSWORD}
fi

echo "TO remove the SQL password policy."
echo "uninstall plugin validate_password;" | mysql -uroot -pRoboShop@1
if [ $? = 0 ]; then
    echo "uninstall plugin validate_password;" | mysql -uroot -pRoboShop@1
fi

echo "load that schema into the database"

curl -s -L -o /tmp/mysql.zip "https://github.com/roboshop-devops-project/mysql/archive/main.zip"
if [ $? = 0 ]; then
    echo "uninstall plugin validate_password;" | mysql -uroot -pRoboShop@1
fi

echo "Load the schema for Services."

cd /tmp && unzip -o mysql.zip >/dev/null && cd mysql-main && mysql -uroot -pRoboShop@1 <shipping.sql
if [ $? = 0 ]; then
    echo "MySQL DB configuration success"
fi