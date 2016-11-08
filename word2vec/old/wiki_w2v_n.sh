#!/bin/sh
# for noun

NO=$1
for f in ../../data/wikipedia/jawiki-latest-pages-articles.xml-${NO}*.txt;do
  rm -rf ${f}.wakati
  ruby  wiki_w2v.rb $f ${f}.wakati
done
