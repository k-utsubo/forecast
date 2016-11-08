#!/bin/env python
# coding:utf-8

#http://tjo.hatenablog.com/entry/2014/06/19/233949

from gensim.models import word2vec
data = word2vec.Text8Corpus("../../data/data/news/w2vdoc.txt")
model=word2vec.Word2Vec(data,size=200)
out=model.most_similar(positive=[u"経済",u"為替"])
for x in out:
  print x[0],x[1]
