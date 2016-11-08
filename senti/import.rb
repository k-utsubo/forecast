#!/bin/env ruby
# coding:utf-8
# import yahoonews to db

require "json"
require "cabocha"
require "nkf"
require "mysql"
require "date"
require "time"
require "../dict/abst_dict.rb"
require "../dict/utils_dict.rb"


class Import < AbstDictCreator
  include UtilsDictCreator
  def initialize
    super("../news/data/news")
  end
  def get_mysql
    mysql=Mysql.connect("zaaa16d.qr.com","root","","fintech")
    return mysql
  end
  def exec
    Dir.glob(@top_dir+"/201601*").each do |dr| day_analyze(dr) end
    Dir.glob(@top_dir+"/201602*").each do |dr| day_analyze(dr) end
    Dir.glob(@top_dir+"/201603*").each do |dr| day_analyze(dr) end
    Dir.glob(@top_dir+"/201604*").each do |dr| day_analyze(dr) end
    Dir.glob(@top_dir+"/201605*").each do |dr| day_analyze(dr) end
  end

  def day_analyze(dr)
    Dir.glob(dr+"/*/*").each do |file|
#p file
      open(file) do |io|
        json=JSON.load(io)
        mc=json["body"].scan(/<\d{4}>/)
        if mc.size==1 then
          code=mc[0].gsub(/</,"").gsub(/>/,"")

          mysql=get_mysql()
          stmt=mysql.prepare("replace into fintech.yahooStockNews values(?,?,?,?,?,?)")
          stmt.execute(json["time"],code,NKF.nkf("-w",json["title"]),NKF.nkf("-w",json["body"]),json["href"],NKF.nkf("-w",json["source"]))
p json
          mysql.close()
        end
      end
    end
  end

end

if __FILE__ == $0 then
  Import.new.exec
end
