#!/bin/sh
## Script to deploy frontend nginx server.

echo "Install nginx server using yum utility"
yum install nginx -y 1>/tmp/nginxinstallsuccess.out 2>/tmp/nginxinstallfail.out
echo $?
if [ $? = 0 ]; then
  echo "Enabling nginx default startup"
  systemctl enable nginx
  echo "Starting nginx default startup"
  systemctl start nginx
  systemctl status nginx
fi

Download the HTDOCS content
curl -s -L -o /tmp/frontend.zip "https://github.com/roboshop-devops-project/frontend/archive/main.zip"
echo $?
if [ $? = 0 ]; then
  echo "Removing default nginx web page content"
  cd /usr/share/nginx/html && rm -rf * && unzip /tmp/frontend.zip && mv frontend-main/* . && mv static/* . && rm -rf frontend-master static && mv localhost.conf /etc/nginx/default.d/roboshop.conf
  echo "Restarting nginx web server"
  systemctl restart nginx
fi

