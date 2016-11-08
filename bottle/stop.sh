#!/bin/sh

pid=`ps xa|grep python|grep main.py|awk '{print $1}'`
if [ "$pid" != "" ];then
  kill -9 $pid
fi


