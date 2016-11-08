#!/bin/env ruby
# coding:utf-8
# consider topix and  beta


require "nkf"
require "sqlite3"

class NewsImport
  def initialize
    @db=SQLite3::Database.new("../../data/tk_dict.db")
    @db.execute("delete from dict")
  end
  def exec
    open("../../data/tk_dict.txt") do |file|
      while line=file.gets
        p line
        line=line.chomp.split("\t")
        sql="insert into dict values(?,?,?,?,?,?,?,?,?,?,?,?)"
        @db.execute(sql,line)
        
      end
    end
  end

end

if __FILE__ == $0 then
  NewsImport.new.exec
end
