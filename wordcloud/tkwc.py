#!/bin/env python
# coding:utf-8

# http://stackoverflow.com/questions/2801882/generating-a-png-with-matplotlib-when-display-is-undefined
import MySQLdb
from wordcloud import WordCloud
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import sys



def make_png(stockCode,con,fpath):
  #print stockCode
  cur=con.cursor()
  cur.execute("select word,tfidf from tk_tfidf where stockCode=%s" % stockCode)
  res=cur.fetchall()

  exit
  text=""
  for j in range(0,len(res)):
    tfidf=res[j][1]
    cnt=int(tfidf*100)
    #print "tfidf="+str(tfidf)+",cnt="+str(cnt)
    for k in range(0,cnt):
      w=res[j][0]
      text=text+" "+w

  cur.close()
  #print text
  wordcloud = WordCloud(background_color="white",font_path=fpath, width=400, height=250  ).generate(text)
  plt.figure(figsize=(15,12))
  plt.imshow(wordcloud)
  plt.axis("off")
  plt.show()
  plt.draw()
  fig=plt.gcf()
  fig.savefig("images/"+stockCode+".png",dpi=100)




fpath = "/usr/share/fonts/opentype/ipafont-gothic/ipag.ttf"
fpath=" /usr/share/fonts/ja/TrueType/kochi-gothic-subst.ttf"
#fpath = "/Library/Fonts/Osaka.ttf"
con=MySQLdb.connect(host="zaaa16d.qr.com",db="fintech",user="root",passwd="",charset="utf8")
#cur=con.cursor()
#cur.execute("select distinct stockCode from tk_bow")
#stockCodes=cur.fetchall()
#cur.close()


argvs = sys.argv
stockCode=argvs[1]
#for i in range(0,len(stockCodes)):
#  stockCode=stockCodes[i][0]

make_png(stockCode,con,fpath)
con.close()
