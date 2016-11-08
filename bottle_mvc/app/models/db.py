#!/bin/env python
# coding:utf-8
import MySQLdb
import ConfigParser

config = ConfigParser.ConfigParser()
config.read('config/db.cnf')

live_dbhandle = MySQLdb.connect(
  host = config.get('live_db', 'host'),
  port = config.getint("live_db","port"), 
  user = config.get('live_db', 'user'),
  passwd = config.get('live_db', 'password'),
  db = config.get('live_db', 'database'),
  charset = "sjis",
  use_unicode=1
)
live_con = live_dbhandle.cursor(MySQLdb.cursors.DictCursor)
#live_con.execute("set names utf8")

## fintech
fintech_dbhandle = MySQLdb.connect(
  host = config.get('fintech_db', 'host'),
  port = config.getint("fintech_db","port"), 
  user = config.get('fintech_db', 'user'),
  passwd = config.get('fintech_db', 'password'),
  db = config.get('fintech_db', 'database'),
  use_unicode=1
)
fintech_con = fintech_dbhandle.cursor(MySQLdb.cursors.DictCursor)
fintech_con.execute("set names utf8")



#live_handler = MySQLdb.connect(host="zcod4md.qr.com",db="live",user="root",passwd="")
#live_con=live_handler.cursor()
#live_con.execute("set names utf8")
#
#fintech_handler = MySQLdb.connect(host="zaaa16d.qr.com",db="fintech",user="root",passwd="")
#fintech_con=fintech_handler.cursor()
#fintech_con.execute("set names utf8")
