#!/bin/env python
# cooding:utf-8

import pystan
import numpy as np
import matplotlib.pyplot as plt

import sqlite3

class NewsData:
  def __init__(self):
    self.docs=[]
    self.freqs=[]
    self.words=[]
    self.offset=[]
  def set_offset(self):
    if(len(self.words)==0):
      return
    st=1
    doc=self.docs[0]
    for i in range(1,len(self.docs)):
      if doc!=self.docs[i]:
        self.offset.append([st,i-1])
        st=i
        doc=self.docs[i]
    self.offset.append([st,len(self.docs)])


data=NewsData()
conn = sqlite3.connect('../../data/news_topic3.db')
cur = conn.cursor()
idf_limit=2.5
cur.execute("select b.doc,w.id as word,b.count from news_bow b,news_word w where b.word=w.word and b.word in (select word from news_idf where idf<?) order by b.doc limit 1000",[idf_limit])
for doc,word,count in cur.fetchall():
  data.docs.append(doc)
  data.words.append(word)
  data.freqs.append(count)
cur.execute("select count(*) as v from news_idf where idf<?",[idf_limit])
V=0
for v in cur.fetchall():
  V=int(v[0])
conn.close()
#http://xiangze.hatenablog.com/entry/2014/03/03/012744
data.set_offset()
K=10   # num of topics
M=len(data.offset) # num of documents
N=len(data.words)
print "M="+str(M)+",V="+str(V)+",N="+str(N)
stan_data = {'K': K, 'M': M, 'V': V, 'N':N,'W':data.words, 'Freq':data.freqs, 'Offset':data.offset,'Alpha':np.repeat(1, K),'Beta':np.repeat(0.5, V)}
fit = pystan.stan(file='news_lda.stan', data=stan_data, iter=10000, chains=4)
print('Sampling finished.')

