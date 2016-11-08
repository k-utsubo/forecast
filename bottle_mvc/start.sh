#!/bin/sh

cd ~/sentiment/bottle_mvc

./stop.sh
gunicorn -b 127.0.0.1:8081 -c gunicorn.conf.py -w 1 index:app -D --reload  
