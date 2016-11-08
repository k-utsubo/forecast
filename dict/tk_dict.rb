#!/bin/env ruby
# coding:utf-8
# consider topix and  beta


require "json"
require "cabocha"
require "nkf"
require "mysql2"
require "mysql"
require "date"
require "time"
require "./abst_dict.rb"
require "./utils_dict.rb"

class NewsDictCreator < AbstDictCreator
  include UtilsDictCreator
  def initialize
    super(nil)
    @mysql=Mysql.connect("zcod4md.qr.com","root","","live")
    stmt=@mysql.prepare("set names utf8")
    stmt.execute()
  end
  def exec
    #news_all
    sokuho_all
  end

  private
  def news_all
    stmt=@mysql.prepare("select kijiId,title,subTitle,description,content,pubDate from tkNewsXml ")
    res=stmt.execute()
    res.each do |tuple|
      kijiId=tuple[0]
      stocks=get_stock(kijiId)
      line=NKF.nkf("-w",tuple[1])+" "+NKF.nkf("-w",tuple[2])+" "+NKF.nkf("-w",tuple[3])+" "+NKF.nkf("-w",tuple[4]).gsub(/<.*?>/,"").gsub(/&.*?;/,"").gsub(/\n/,"")
      date=tuple[5].to_s
      stocks.each do |stockCode|
        analyze(stockCode,line,date)
      end
    end
  end
  def get_stock(kijiId)
    stocks=[]
    stmt=@mysql.prepare("select stockCode from tkNewsXmlStock where kijiId=?")
    res=stmt.execute(kijiId)
    res.each do |tuple|
      stocks.push(tuple[0].to_s)
    end
    return stocks
  end
  def sokuho_all
    stmt=@mysql.prepare("select stockCode,headline,storytext,date from tkShikihoSokuho ")
    res=stmt.execute()
    res.each do |tuple|
      stockCode=tuple[0].to_s
      line=NKF.nkf("-w",tuple[1])+" "+NKF.nkf("-w",tuple[2])
      date=tuple[3].to_s
      analyze(stockCode,line,date)
    end
  end


  def analyze(stockCode,line,date)
    score=get_score(stockCode,date)
    body_analyze(line,score)
  end

  def get_score(code,time)
    ret=get_ret(code,time)
    return 1 if ret>=0.05
    return -1 if ret<=-0.05
    return 0
  end

end

if __FILE__ == $0 then
  ndc=NewsDictCreator.new
  ndc.exec
  ndc.write_to_file("tk_dict.txt")
end
