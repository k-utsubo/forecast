#!/bin/sh

#NO=$1
#for f in ../../data/wikipedia/jawiki-latest-pages-articles.xml-${NO}*.txt;do
#  cat $f|mecab -Owakati > ${f}.wakati  
#done

R --vanilla < wiki_w2v.R
aws s3 cp ../../data/model_wiki_new.txt s3://qrfintech/sentiment/
