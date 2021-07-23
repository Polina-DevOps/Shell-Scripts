#!/bin/bash
## Script to deploy frontend nginx server.
[ ! -d /var/tmp ] && mkdir /var/tmp
chmod 755 /var/tmp
[ ! -f /var/tmp/roboshop.log ] && touch /var/tmp/roboshop.log
chmod 755 /var/tmp/roboshop.log

LOG=/var/tmp/roboshop.log
#Changing hostname
hostnamectl set-hostname frontend
hostname

echo "Install nginx server using yum utility"
yum install nginx -y >>$LOG
if [ $? = 0 ]; then
  echo "Enabling nginx default startup"
  systemctl enable nginx >>$LOG && systemctl start nginx >>$LOG && systemctl status nginx >>$LOG
fi

Download the HTDOCS content
curl -s -L -o /tmp/frontend.zip "https://github.com/roboshop-devops-project/frontend/archive/main.zip"
if [ $? = 0 ]; then
  echo "Removing default nginx web page content"
  cd /usr/share/nginx/html && rm -rf * && unzip /tmp/frontend.zip >/dev/null && mv frontend-main/* . && mv static/* . && rm -rf frontend-master static && mv localhost.conf /etc/nginx/default.d/roboshop.conf
  sed -i -e '/catalogue/ s/localhost/catalogue.roboshop.internal/' -e '/user/ s/localhost/user.roboshop.internal/'  -e '/cart/ s/localhost/cart.roboshop.internal/' -e '/shipping/ s/localhost/shipping.roboshop.internal/' -e '/payment/ s/localhost/payment.roboshop.internal/' /etc/nginx/default.d/roboshop.conf
  echo "Restarting nginx web server"
  systemctl restart nginx
fi