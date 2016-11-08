#!/bin/env ruby
# coding:utf-8

require "nkf"
require "natto"
require "json"
require "sqlite3"
require "mysql"



class MakeBOW
  def initialize
    @natto = Natto::MeCab.new 
    @mysql=Mysql.connect("zcod4md.qr.com","root","","live")
    stmt=@mysql.prepare("set names utf8")
    stmt.execute()
    @db=Mysql.connect("zaaa16d.qr.com","root","","fintech")
    stmt=@db.prepare("set names utf8")
    stmt.execute()
    @db2=Mysql.connect("zaaa16d.qr.com","root","","fintech")
    @db2.prepare("set names utf8").execute()
    @db3=Mysql.connect("zaaa16d.qr.com","root","","fintech")
    @db3.prepare("set names utf8").execute()

    @db.prepare("delete from tk_bow").execute()
    @db.prepare("delete from tk_tf").execute()
    @db.prepare("delete from tk_idf").execute()
    @db.prepare("delete from tk_tfidf").execute()
  end

  def exec
    news_all
    sokuho_all
    tfidf_all
  end
  def news_all
    stmt=@mysql.prepare("select n.kijiId,n.content,s.stockCode from tkNewsXml n,tkNewsXmlStock s where n.kijiId=s.kijiId and length(n.content)!=0 and n.pubDate>='2015-01-01' and n.pubDate<='2015-12-31'")
    res=stmt.execute()
    res.each do |tuple|
      stockCode=tuple[2].to_s
      line=NKF.nkf("-w",tuple[1]).gsub(/<.*?>/,"").gsub(/&.*?;/,"").gsub(/\n/,"")
        wakati(stockCode,line)
    end
  end
  def sokuho_all
    stmt=@mysql.prepare("select kijiNo,storytext,stockCode from tkShikihoSokuho where length(storytext)!=0 and date>='2015-01-01' and date<='2015-12-31'")
    res=stmt.execute()
    res.each do |tuple|
      stockCode=tuple[2].to_s
      line=NKF.nkf("-w",tuple[1])
      wakati(stockCode,line)
    end  
  end

  def wakati(stockCode,line)
p line
begin
          @natto.parse(line) do |n|
            word=n.feature.split(',')[6]
            word=n.surface if word=="*"
p word
            hinshi=n.feature.split(',')[0]
            bunrui=n.feature.split(',')[1]
p "--"+hinshi+","+bunrui
            next if !(hinshi=="名詞" or hinshi=="形容詞")
            next if hinshi=="名詞" and (bunrui!="一般" and bunrui!="固有名詞")
            next if word.length<=1
            next if word =~ /^[0-9a-zA-Z@_\-%=]+$/
            next if word =~ /\d.*月/
            next if word =~ /\d.*日/
            next if word =~ /\./
            next if word =~ /,/
            analyze(word,stockCode)
          end
rescue => e
p $!
p e 
end
  end


  def analyze(word,stockCode)
p word.to_s
p stockCode.to_s
p "===="
    cursor=@db.prepare("select count from tk_bow where stockCode=? and word=?").execute(stockCode,word)
    cnt=0
    cursor.each do |tuple|
      cnt=tuple[0]
    end
p "replace into tk_bow :stockCode="+stockCode+",word="+word+",cnt="+cnt.to_s
    @db.prepare("delete from tk_bow where stockCode=? and word=?").execute(stockCode,word)
    @db.prepare("replace into tk_bow values(?,?,?)").execute(stockCode,word,cnt+1)
  end

  def tfidf_all
    stockCode=""
    cur=@db.prepare("select distinct stockCode from tk_bow").execute()
    cur.each do |tuple|
      stockCode=tuple[0]

      cur2=@db2.prepare("select sum(count) from tk_bow where stockCode=?").execute(stockCode)
      count_sum=0
      cur2.each do |tuple2|
        count_sum=tuple2[0]
      end

      cur2=@db2.prepare("select word,count from tk_bow where stockCode=?").execute(stockCode)
      cur2.each do |tuple2|
        word=tuple2[0]
        count=tuple2[1]
        tf=count.to_f/count_sum.to_f
p "replace into tk_tf :stockCode="+stockCode+",word="+word+",tf="+tf.to_s
        @db3.prepare("replace into tk_tf values(?,?,?)").execute(stockCode,word,tf)
      end
    end

    stockCode_sum=0
    cur=@db.prepare("select count(distinct(stockCode)) from tk_bow").execute()
    cur.each do |tuple|
      stockCode_sum=tuple[0]
    end 
    
    cur=@db.prepare("select distinct word from tk_bow").execute()
    cur.each do |tuple|
      word=tuple[0]
      cur2=@db2.prepare("select count(distinct(stockCode)) from tk_bow where word=?").execute(word)
      count=0
      cur2.each do |tuple2|
        count=tuple2[0]
      end
      idf=Math.log(stockCode_sum.to_f/count.to_f)
p "replace into tk_idf :word="+word+",idf="+idf.to_s
      @db2.prepare("replace into tk_idf values (?,?)").execute(word,idf)
    end
    
    cur=@db.prepare("select stockCode,word,tf from tk_tf").execute()
    cur.each do |tuple|
      stockCode=tuple[0]
      word=tuple[1]
      tf=tuple[2]

      cur2=@db2.prepare("select idf from tk_idf where word=?").execute(word)
      idf=0
      cur2.each do |tuple|
        idf=tuple[0]
      end
      tfidf=tf*idf
p "replace into tk_tfidf :stockCode="+stockCode+",word="+word+",tfidf="+tfidf.to_s
      @db2.prepare("replace into tk_tfidf values (?,?,?)").execute(stockCode,word,tfidf)
    end

  end
end 

if __FILE__ == $0 then
  MakeBOW.new.exec
  #MakeBOW.new.analyze("キーワード","あたいです")
end
