#!/bin/env ruby
# coding:utf-8

require "mysql"
require "natto"
require "nkf"
class Profile
  def initialize(dir)
    @mysql=Mysql.connect("zcod4md.qr.com","root","","live")
    stmt=@mysql.prepare("set names utf8")
    stmt.execute()
    @dir=dir
    @natto = Natto::MeCab.new

    Dir.glob(@dir+"/*").each do |file|
      File.unlink(file)
    end
  end
  def exec
    profile()
    honbun()
    @mysql.close
  end
  def honbun
    stmt=@mysql.prepare("select stockCode,date,honbun1,honbun2 from tkShimenHonbun where date=(select max(date) from tkShimenHonbun)")
    res=stmt.execute()
    res.each do |tuple|
      stockCode=tuple[0]
p stockCode
      honbun1=NKF.nkf("-w",tuple[2]).gsub(/【.*?】/,"")
      honbun2=NKF.nkf("-w",tuple[3]).gsub(/【.*?】/,"")
      text=honbun1+" "+honbun2
      line=wakati(text)
      write(stockCode,line)
    end
  end
  def profile
    stmt=@mysql.prepare("select stockCode,date,name,kanaName,tokusyoku,jigyou,sectorName from tkShimenProfile where date=(select max(date) from tkShimenProfile)")
    res=stmt.execute()
    res.each do |tuple|
      stockCode=tuple[0]
p stockCode
      name=NKF.nkf("-w",tuple[2]).gsub(/\(.*?\)/,"")
      kana=NKF.nkf("-w",tuple[3])
      tokusyoku=NKF.nkf("-w",tuple[4]).gsub(/【.*?】/,"")
      jigyou=NKF.nkf("-w",tuple[5]).gsub(/【.*?】/,"").gsub(/\(.*?\)/,"").gsub(/<.*?>/,"")
      text=name+" "+kana+" "+tokusyoku+" "+jigyou
      line=wakati(text)
      write(stockCode,line)
    end

  end
  def wakati(text)
    line=""
    @natto.parse(text) do |n|
      keyword=n.feature.split(',')[6]
      keyword=n.surface if keyword=="*"
      line=line+" " if line!=""
      line=line+keyword
    end
    return line
  end
  def write(stockCode,line)
p line
    open(@dir+"/"+stockCode+".txt","a") do |f|
      f.puts line
    end
  end
end

if __FILE__ == $0 then
  Profile.new("../../data/shikiho").exec
end
