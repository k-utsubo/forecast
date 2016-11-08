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
    super("../../tdnet/data")
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
    Dir.glob(dr+"/*").each do |file|
#p file
      open(file) do |io|
        json=JSON.load(io)
        next if json==nil
        mysql=get_mysql()
        stmt=mysql.prepare("replace into fintech.tdnet values(?,?,?,?,?,?,?)")
        stmt.execute(json["id"],json["last_modified"],NKF.nkf("-w",json["title"]),NKF.nkf("-w",json["text"]),NKF.nkf("-w",json["cat"]),json["stockCode_t"],json["url"])
p json
        mysql.close()
      end
    end
  end

end

if __FILE__ == $0 then
  Import.new.exec
end
