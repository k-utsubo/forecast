#!/bin/sh
# https://github.com/iinm/jawiki_word2vec
python script/WikiExtractor.py -c -o ../data/wikipedia/extracted ../data/wikipedia/jawiki-latest-pages-articles.xml.bz2
#for f in ../data/wikipedia/extracted;do
#  fn=`basename $f`
#  aws s3 cp $fn s3://qrfintech/sentiment/wikipedia/.
#done

python script/learn.py ../data/wikipedia/jawiki_word2vec.pkl.gz

#aws s3 cp data/jawiki_word2vec.pkl.gz s3://qrfintech/sentiment/.

