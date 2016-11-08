#!/bin/sh

ym=$1
for dr in `ls -d ../../data/data/news/${ym}*`;do
#  echo $dr
  f=`basename $dr`
  echo "ruby news_w2v.rb $dr ../../data/data/news_w2v/${f}.txt"
  ruby news_w2v.rb $dr ../../data/data/news_w2v/${f}.txt 
done
