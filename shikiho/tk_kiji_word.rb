#!/bin/env ruby
# coding:utf-8


# create table tk_word(
#   id int not null,
#   word text not null
# );
# create unique index idx_tk_word on tk_word(id)
# ;

require "sqlite3"
require "nkf"
require "mysql"

class Kiji
  def initialize
    #@db=SQLite3::Database.new("../../data/tk_kiji.db")
    @db=Mysql.connect("zaaa16d.qr.com","root","","fintech")
    stmt=@db.prepare("set names utf8")
    stmt.execute()
    @db2=Mysql.connect("zaaa16d.qr.com","root","","fintech")
    stmt=@db2.prepare("set names utf8")
    stmt.execute()

    stmt=@db.prepare("delete from tk_kiji_word")
    stmt.execute()
  end

  def exec
    stmt=@db.prepare("select word from tk_kiji_idf")
    res=stmt.execute()
    cnt=0
    res.each do |tuple|
p "word="+tuple[0].to_s+",cnt="+cnt.to_s
      stmt2=@db2.prepare("insert into tk_kiji_word values(?,?)")
      stmt2.execute(cnt,tuple[0].to_s)
      cnt=cnt+1
    end
  end
  
end

if __FILE__ == $0 then
  Kiji.new.exec
end

