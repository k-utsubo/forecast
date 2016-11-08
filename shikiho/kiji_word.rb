#!/bin/env ruby
# coding:utf-8


# create table kiji_word(
#   id int not null,
#   word text not null
# );
# create unique index idx_kiji_word on kiji_word(id)
# ;

require "sqlite3"

class Kiji
  def initialize
    @db=SQLite3::Database.new("../../data/kiji.db")
  end

  def exec
    stmt=@db.prepare("select word from kiji_idf")
    res=stmt.execute()
    cnt=0
    res.each do |tuple|
      stmt2=@db.prepare("insert into kiji_word values(?,?)")
      stmt2.execute([tuple[0].to_s,cnt])
p "word="+tuple[0].to_s+",cnt="+cnt.to_s
      cnt=cnt+1
    end
  end
  
end

if __FILE__ == $0 then
  Kiji.new.exec
end

