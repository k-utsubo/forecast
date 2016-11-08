#!/bin/sh 

cd /home/ubuntu/sentiment/bottle
bash ./stop.sh

rm -rf /var/log/bottle/*log
python main.py > /var/log/bottle/access.log 2>&1  &
