#!/bin/env python
# coding:utf-8

import urllib
from bottle import get,post,request
import re
from gensim.models import word2vec
model=word2vec.Word2Vec.load("/home/ubuntu/data/wikipedia/model_py.data")
import MySQLdb
connection = MySQLdb.connect(host="zcod4md.qr.com",db="live",user="root",passwd="")

import logging
logging.basicConfig(filename="/var/log/bottle/debug.log",level=logging.DEBUG)

def get():
  kijiId=request.query.kijiId
  print "kijiId="+kijiId
  if (kijiId==""):
    return show_list()
  else:
    return show_kiji(kijiId)

def show_kiji(kijiId):
  cursor=connection.cursor()
  cursor.execute("set names utf8")
  cursor.execute("select kijiId,title,pubDate,content from tkNewsXml where kijiId='"+kijiId+"'")
  result=cursor.fetchall()
  kijiId=title=pubDate=content=""
  for row in result:
    kijiId=str(row[0])
    title=str(row[1])
    pubDate=str(row[2])
    content=str(row[3])
    content=re.sub("\<.*?\>","",content)
    content=re.sub("&.*?;","",content)
  s="<table border='1'><tr><td>kijiId</td><td>"+kijiId+"</td></tr>"
  s=s+"<tr><td>title</td><td>"+title+"</td></tr>"
  s=s+"<tr><td>pubDate</td><td>"+pubDate+"</td></tr>"
  s=s+"<tr><td>content</td><td>"+content+"</td></tr>"
  s=s+"</table>"
  return s

  
def show_list():
  cursor=connection.cursor()
  cursor.execute("set names utf8")
  cursor.execute("select kijiId,title,pubDate from tkNewsXml where length(content)!=0 and  pubDate<now() order by pubDate desc limit 100")
  result=cursor.fetchall()
  s="<table border='1'><tr><td>kijiId</td><td>title</td><td>pubDate</td></tr>"
  for row in result:
    s=s+"<tr><td>"+str(row[0])+"</td><td><a href='tkd2v?kijiId="+str(row[0])+"'>"+str(row[1])+"</a></td><td>"+str(row[2])+"</td></tr>"
  s=s+"</table>"
  return s


def post(request):
  posi_text=request.forms.get("posi_text")
  nega_text=request.forms.get("nega_text")
  posi_text=urllib.unquote(posi_text)
  nega_text=urllib.unquote(nega_text)
  #posi_text=unicode(posi_text,"utf-8")
  #nega_text=unicode(nega_text,"utf-8")
  logging.debug(type(posi_text))
  logging.debug(posi_text)
  #posi_text=urllib2.unquote(posi_text).encode('raw_unicode_escape').decode('utf-8')
  #return posi_text
  #nega_text=urllib2.unquote(nega_text).encode('raw_unicode_escape').decode('utf-8')
  posi=[]
  nega=[]
  for t in posi_text.split(" "):
    print(t)
    posi.append(unicode(t,"utf-8"))
  for t in nega_text.split(" "):
    nega.append(unicode(t,"utf-8"))

  logging.debug(posi)
  logging.debug(nega)
  logging.debug(len(nega))
  logging.debug(len(nega_text))

  if len(posi_text)==0:
    return "invalid positive text"

  err_str=""
  out=None
  try:
    if len(nega_text)>0:
      out=model.most_similar(positive=posi,negative=nega)
    else:
      out=model.most_similar(positive=posi)
    logging.debug(out)
  except KeyError:
    err_str="Keyword Error"
    
  ret=get()
  ret=ret+"<br><br>Wikipedia keyword"
  ret=ret+"<br><br>"
  ret=ret+"positive text:"+posi_text+"<br>"
  ret=ret+"negative text:"+nega_text+"<br>"

  if len(err_str)>0:
    ret=ret+"<font color='red'><b>"+err_str+"</b></font><br><br>"
  else:
    ret=ret+"<table border='1'><tr><th>word</th><th>score</th></tr>"
    for x in out:
      ret=ret+"<tr>"
      ret=ret+"<td>"+str(x[0].encode('utf-8'))+"</td>"
      ret=ret+"<td>"+str(x[1])+"</td>"
      ret=ret+"</tr>"
    ret=ret+"</table>"
  return ret
