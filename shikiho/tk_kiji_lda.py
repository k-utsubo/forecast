#!/bin/env python
# cooding:utf-8

import pystan
import numpy as np
import matplotlib.pyplot as plt

import sqlite3
import MySQLdb

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
#conn = sqlite3.connect('../../data/tk_kiji.db')
conn=MySQLdb.connect(host="zaaa16d.qr.com",db="fintech",user="root",passwd="",charset="utf8")
cur = conn.cursor()
cur.execute("select b.doc,w.id as word,b.count from tk_kiji_bow b ,tk_kiji_word w where b.word=w.word and b.word in (select word from tk_kiji_idf where idf<5)")
for doc,word,count in cur.fetchall():
  data.docs.append(doc)
  data.words.append(word)
  data.freqs.append(count)

cur.execute("select count(distinct(id)) from tk_kiji_bow b ,tk_kiji_word w where b.word=w.word and b.word in (select word from tk_kiji_idf where idf<5)")
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
fit = pystan.stan(file='tk_kiji_lda.stan', data=stan_data, iter=10000, chains=4)
print('Sampling finished.')

