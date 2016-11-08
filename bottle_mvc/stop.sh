#!/bin/sh


pid=`ps xa|grep gunicorn|grep -v grep|awk '{print $1}'`
if [ "$pid" != "" ];then
  for p in $pid;do
    kill -9 $pid
  done
fi
