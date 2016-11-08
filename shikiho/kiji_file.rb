#!/bin/env ruby
# coding:utf-8

require "date"
require "mysql"
require "fileutils"
require "nkf"


class Kiji
  def initialize
    @mysql=Mysql.connect("zcod4md.qr.com","root","","live")
    stmt=@mysql.prepare("set names utf8")
    stmt.execute()
    @news_dir="../../data/shikiho/"
    @sokuho_dir="../../data/shikiho/"
  end

  def exec
    news_all
    sokuho_all
  end
  def news_all
begin
    stmt=@mysql.prepare("select pubDate,content,kijiId,description from tkNewsXml ")
    res=stmt.execute()
    res.each do |tuple|
      kiji=tuple[1]
      kiji=tuple[3] if kiji==nil or kiji.size()==0 
      next if kiji==nil or kiji.size()==0
      s=""
      stockCode=get_stock(tuple[2])
      s=stockCode.join("\t") if s!=nil
      line=tuple[0].to_s+"\n"+s+"\n"+NKF.nkf("-w",kiji).gsub(/<.*?>/,"").gsub(/&.*?;/,"").gsub(/\n/,"")
p line
      dt=DateTime.parse(tuple[0].to_s).strftime("%Y%m%d")
      FileUtils.mkdir_p(@news_dir+dt)
      open(@news_dir+dt+"/news"+tuple[2]+".txt","w") do |f|
        f.puts(line)
      end
    end
rescue => e
p e 
end
  end
  def sokuho_all
begin
    stmt=@mysql.prepare("select date,storytext,kijiNo,stockCode from tkShikihoSokuho ")
    res=stmt.execute()
    res.each do |tuple|
      line=tuple[0].to_s+"\n"+tuple[3]+"\n"+NKF.nkf("-w",tuple[1]).gsub(/<.*?>/,"").gsub(/&.*?;/,"").gsub(/\n/,"")
p line
      dt=DateTime.parse(tuple[0].to_s).strftime("%Y%m%d")
      FileUtils.mkdir_p(@sokuho_dir+dt)
      open(@sokuho_dir+dt+"/sokuho"+tuple[2]+".txt","w") do |f|
        f.puts(line)
      end
    end
rescue => e
p e 
end
  end

  def get_stock(kijiId)
    stocks=[]
    stmt=@mysql.prepare("select stockCode from tkNewsXmlStock where kijiId=?")
    res=stmt.execute(kijiId)
    res.each do |tuple|
      stocks.push(tuple[0])
    end
    return stocks
  end

end

if __FILE__ == $0 then
  Kiji.new.exec
end
