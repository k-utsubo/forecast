#!/bin/env ruby
# coding:utf-8

require "natto"
require "json"
require "mysql"



class MakeBOW
  def initialize
    @mysql=Mysql.connect("zcod4md.qr.com","root","","live")
    stmt=@mysql.prepare("set names utf8")
    stmt.execute()
  end

  def exec
    sokuho_all
  end
  def news_all
    stmt=@mysql.prepare("select kijiId,title,subTitle,description,content from tkNewsXml ")
    res=stmt.execute()
    res.each do |tuple|
      kijiId=tuple[0]
      stocks=get_stock(kijiId)
      line=tuple[1]+" "+tuple[2]+" "+tuple[3]+" "+tuple[4].gsub(/<.*?>/,"").gsub(/&.*?;/,"").gsub(/\n/,"")
      stocks.each do |stockCode|
        wakati(stockCode,line)
      end
    end
  end
  def get_stock(kijiId)
    stocks=[]
    stmt=@mysql2.prepare("select stockCode from tkNewsXmlStock where kijiId=?")
    res=stmt.execute(kijiId)
    res.each do |tuple|
      stocks.push(tuple[0])
    end
    return stocks
  end
  def sokuho_all
    stmt=@mysql.prepare("select stockCode,headline,storytext from tkShikihoSokuho ")
    res=stmt.execute()
    res.each do |tuple|
      stockCode=tuple[0]
      line=tuple[1]+" "+tuple[2]
      write(line)
    end
  end
  def wakati(stockCode,line)
    @natto.parse(line) do |n|
begin
      word=n.feature.split(',')[6]
      word=n.surface if word=="*"
      hinshi=n.feature.split(',')[0]
      bunrui=n.feature.split(',')[1]
      next if hinshi!="名詞"
      next if hinshi=="名詞" and (bunrui!="一般" and bunrui!="固有名詞")
      next if word.length<=1
      next if word =~ /^[0-9a-zA-Z@_\-%=]+$/
      analyze(word,stockCode)
rescue => e
p $!
p e
end
    end
  end


  def analyze(word,stockCode)
p word.to_s
p stockCode.to_s
p "===="
    cursor=@db.execute("select count from kiji_bow where stockCode=? and word=?",[stockCode,word])
    cnt=0
    cursor.each do |tuple|
      cnt=tuple[0]
    end
p "insert into kiji_bow :stockCode="+stockCode+",word="+word+",cnt="+cnt.to_s
    @db.execute("delete from kiji_bow where stockCode=? and word=?",[stockCode,word])
    @db.execute("insert into kiji_bow values(?,?,?)",[stockCode,word,cnt+1])
  end

  def tfidf_all
    stockCode=""
    cur=@db.execute("select distinct stockCode from kiji_bow")
    cur.each do |tuple|
      stockCode=tuple[0]

      cur2=@db2.execute("select sum(count) from kiji_bow where stockCode=?",[stockCode])
      count_sum=0
      cur2.each do |tuple2|
        count_sum=tuple2[0]
      end

      cur2=@db2.execute("select word,count from kiji_bow where stockCode=?",[stockCode])
      cur2.each do |tuple2|
        word=tuple2[0]
        count=tuple2[1]
        tf=count.to_f/count_sum.to_f
p "insert into kiji_tf :stockCode="+stockCode+",word="+word+",tf="+tf.to_s
        @db3.execute("insert into kiji_tf values(?,?,?)",[stockCode,word,tf])
      end
    end

    stockCode_sum=0
    cur=@db.execute("select count(distinct(stockCode)) from kiji_bow")
    cur.each do |tuple|
      stockCode_sum=tuple[0]
    end

    cur=@db.execute("select distinct word from kiji_bow")
    cur.each do |tuple|
      word=tuple[0]
      cur2=@db2.execute("select count(distinct(stockCode)) from kiji_bow where word=?",[word])
      count=0
      cur2.each do |tuple2|
        count=tuple2[0]
      end
      idf=Math.log(stockCode_sum.to_f/count.to_f)
p "insert into kiji_idf :word="+word+",idf="+idf.to_s
      @db2.execute("insert into kiji_idf values (?,?)",[word,idf])
    end

    cur=@db.execute("select stockCode,word,tf from kiji_tf")
    cur.each do |tuple|
      stockCode=tuple[0]
      word=tuple[1]
      tf=tuple[2]

      cur2=@db2.execute("select idf from kiji_idf where word=?",[word])
      idf=0
      cur2.each do |tuple|
        idf=tuple[0]
      end
      tfidf=tf*idf
p "insert into kiji_tfidf :stockCode="+stockCode+",word="+word+",tfidf="+tfidf.to_s
      @db2.execute("insert into kiji_tfidf values (?,?,?)",[stockCode,word,tfidf])
    end

  end
end

if __FILE__ == $0 then
  MakeBOW.new.exec
  #MakeBOW.new.analyze("キーワード","あたいです")
end
