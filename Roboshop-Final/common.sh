#!/bin/bash

USER_ID=$(id -u)
if [ $USER_ID -ne 0 ]; then
  echo -e "\e[31mYou should be root user / sudo user to run this script\e[0m"
  exit 2
fi

LOG=/tmp/roboshop.log
rm -f $LOG

STAT_CHECK() {
  if [ $1 -eq 0 ]; then
    echo -e "\e[32m done\e[0m"
  else
    echo -e "\e[31m fail\e[0m"
    echo -e "\e[33m Check the log file for more details, Log File - $LOG\e[0m"
    exit 1
  fi
}

PRINT() {
  echo -e "\n###########################\t$1\t###########################" &>>$LOG
  echo -n -e "$1\t\t..."
}
