#!/bin/env ruby
# coding:utf-8

require "natto"
require "json"
require "sqlite3"
require "mysql"



class MakeBOW
  def initialize

    @natto = Natto::MeCab.new
    @files=[]
    @db=Mysql.connect("zaaa16d.qr.com","root","","fintech")
    stmt=@db.prepare("set names utf8")
    stmt.execute()
    @db2=Mysql.connect("zaaa16d.qr.com","root","","fintech")
    stmt=@db2.prepare("set names utf8")
    stmt.execute()
    @db3=Mysql.connect("zaaa16d.qr.com","root","","fintech")
    stmt=@db3.prepare("set names utf8")
    stmt.execute()

    @db.prepare("delete from tk_kiji_bow").execute()
    @db.prepare("delete from tk_kiji_tf").execute()
    @db.prepare("delete from tk_kiji_idf").execute()
    @db.prepare("delete from tk_kiji_tfidf").execute()
    @mysql=Mysql.connect("zcod4md.qr.com","root","","live")
    stmt=@mysql.prepare("set names utf8")
    stmt.execute()
    @mysql2=Mysql.connect("zcod4md.qr.com","root","","live")
    stmt=@mysql2.prepare("set names utf8")
    stmt.execute()
  end

  def exec
    sokuho_all
    news_all
    tfidf_all
  end
  def news_all
    stmt=@mysql.prepare("select kijiId,content from tkNewsXml where length(content)!=0 and pubDate>='2015-01-01' and pubDate<='2015-12-31'")
    res=stmt.execute()
    res.each do |tuple|
      doc="news"+tuple[0].to_s
      line=tuple[1].gsub(/<.*?>/,"").gsub(/&.*?;/,"").gsub(/\n/,"")
        wakati(doc,line)
    end
  end
  def sokuho_all
    stmt=@mysql.prepare("select kijiNo,storytext from tkShikihoSokuho where length(storytext)!=0 and date>='2015-01-01' and date<='2015-12-31'")
    res=stmt.execute()
    res.each do |tuple|
      doc="sokuho"+tuple[0].to_s
      line=tuple[1]
      wakati(doc,line)
    end
  end
  def wakati(doc,line)
    @natto.parse(line) do |n|
begin
      word=n.feature.split(',')[6]
      word=n.surface if word=="*"
      hinshi=n.feature.split(',')[0]
      bunrui=n.feature.split(',')[1]
      next if hinshi!="名詞" and hinshi!="形容詞"
      next if hinshi=="名詞" and (bunrui!="一般" and bunrui!="固有名詞")
      next if word.length<=1
      next if word =~ /^[0-9a-zA-Z@_\-%=]+$/
      next if word =~ /\d.*月/
      next if word =~ /\d.*日/
      next if word =~ /\./
      next if word =~ /,/
      analyze(word,doc)
rescue => e
p $!
p e
end
    end
  end


  def analyze(word,doc)
p word.to_s
p doc.to_s
p "===="
    cursor=@db.prepare("select count from tk_kiji_bow where doc=? and word=?").execute(doc,word)
    cnt=1
    cursor.each do |tuple|
      cnt=tuple[0]
    end
p "insert into tk_kiji_bow :doc="+doc+",word="+word+",cnt="+cnt.to_s
    @db.prepare("delete from tk_kiji_bow where doc=? and word=?").execute(doc,word)
    @db.prepare("insert into tk_kiji_bow values(?,?,?)").execute(doc,word,cnt+1)
  end

  def tfidf_all
    doc=""
    cur=@db.prepare("select distinct doc from tk_kiji_bow").execute()
    cur.each do |tuple|
      doc=tuple[0]

      cur2=@db2.prepare("select sum(count) from tk_kiji_bow where doc=?").execute(doc)
      count_sum=0
      cur2.each do |tuple2|
        count_sum=tuple2[0]
      end

      cur2=@db2.prepare("select word,count from tk_kiji_bow where doc=?").execute(doc)
      cur2.each do |tuple2|
        word=tuple2[0]
        count=tuple2[1]
        tf=count.to_f/count_sum.to_f
p "insert into tk_kiji_tf :doc="+doc+",word="+word+",tf="+tf.to_s
        @db3.prepare("insert into tk_kiji_tf values(?,?,?)").execute(doc,word,tf)
      end
    end

    doc_sum=0
    cur=@db.prepare("select count(distinct(doc)) from tk_kiji_bow").execute()
    cur.each do |tuple|
      doc_sum=tuple[0]
    end

    cur=@db.prepare("select distinct word from tk_kiji_bow").execute()
    cur.each do |tuple|
      word=tuple[0]
      cur2=@db2.prepare("select count(distinct(doc)) from tk_kiji_bow where word=?").execute(word)
      count=0
      cur2.each do |tuple2|
        count=tuple2[0]
      end
      idf=Math.log(doc_sum.to_f/count.to_f)
p "insert into tk_kiji_idf :word="+word+",idf="+idf.to_s
      @db2.prepare("insert into tk_kiji_idf values (?,?)").execute(word,idf)
    end

    cur=@db.prepare("select doc,word,tf from tk_kiji_tf").execute()
    cur.each do |tuple|
      doc=tuple[0]
      word=tuple[1]
      tf=tuple[2]

      cur2=@db2.prepare("select idf from tk_kiji_idf where word=?").execute(word)
      idf=0
      cur2.each do |tuple|
        idf=tuple[0]
      end
      tfidf=tf*idf
p "insert into tk_kiji_tfidf :doc="+doc+",word="+word+",tfidf="+tfidf.to_s
      @db2.prepare("insert into tk_kiji_tfidf values (?,?,?)").execute(doc,word,tfidf)
    end

  end
end

if __FILE__ == $0 then
  MakeBOW.new.exec
  #MakeBOW.new.analyze("キーワード","あたいです")
end
