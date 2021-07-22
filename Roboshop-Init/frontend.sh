#!/bin/sh
## Script to deploy frontend nginx server.

#Changing hostname
sudo hostnamectl set-hostname frontend
sudo hostname

echo "Install nginx server using yum utility"
sudo yum install nginx -y 1>/tmp/nginxinstallsuccess.out 2>/tmp/nginxinstallfail.out
if [ $? = 0 ]; then
  echo "Enabling nginx default startup"
  sudo systemctl enable nginx
  echo "Starting nginx default startup"
  sudo systemctl start nginx >/dev/null
  sudo systemctl status nginx >/dev/null
fi

Download the HTDOCS content
curl -s -L -o /tmp/frontend.zip "https://github.com/roboshop-devops-project/frontend/archive/main.zip"
if [ $? = 0 ]; then
  echo "Removing default nginx web page content"
  cd /usr/share/nginx/html && sudo rm -rf * && sudo unzip /tmp/frontend.zip >/dev/null && sudo mv frontend-main/* . && sudo mv static/* . && sudo rm -rf frontend-master static && sudo mv localhost.conf /etc/nginx/default.d/roboshop.conf
  sed -i -e '/catalogue/ s/localhost/catalogue.roboshop.internal/' -e '/user/ s/localhost/user.roboshop.internal/'  -e '/cart/ s/localhost/cart.roboshop.internal/' -e '/shipping/ s/localhost/shipping.roboshop.internal/' -e '/payment/ s/localhost/payment.roboshop.internal/' /etc/nginx/default.d/roboshop.conf
  echo "Restarting nginx web server"
  sudo systemctl restart nginx
fi
sudo sed -i -e '/catalogue/ s/localhost/catalouge.roboshop.internal/' /etc/nginx/default.d/roboshop.conf && sudo systemctl restart nginx