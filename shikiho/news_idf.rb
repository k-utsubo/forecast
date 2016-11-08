#!/bin/env ruby
# coding:utf-8

#create table news_word(
#id int not null,
#word text not null
#);
#create unique index idx_news_word on news_word(id)
#;

# make word id

require "sqlite3"

db=SQLite3::Database.new("../../data/news_topic3.db")
db2=SQLite3::Database.new("../../data/news_topic3.db")


db.execute("delete from news_word")
cur=db.execute("select word from news_idf order by idf ")
cnt=1
cur.each do |tuple|
  tuple[0]
  #query="insert into news_word values("+cnt.to_s+",'"+tuple[0]+"')"
  #p query
  #db.execute(query)
  p "cnt="+cnt.to_s+",word="+tuple[0]
  db2.execute("insert into news_word values(?,?)",cnt.to_s,tuple[0])
  cnt=cnt+1
end 





db2.close
db.close
