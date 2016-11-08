#!/bin/env ruby
# coding:utf-8

require "natto"
require "json"
require "sqlite3"



class MakeBOW
  def initialize
    @dr="../../../data/data/news"
    #@docs=Hash.new  # key:doc, value:vector ,word count
    #@keys=Hash.new  # key:word , value:docs vector index
    @natto = Natto::MeCab.new 
    @files=[]
    @db=SQLite3::Database.new("../../../data/news_topic4.db")
    @db2=SQLite3::Database.new("../../../data/news_topic4.db")
    @db3=SQLite3::Database.new("../../../data/news_topic4.db")

    @db.execute("delete from news_bow")
    @db.execute("delete from news_tf")
    @db.execute("delete from news_idf")
    @db.execute("delete from news_tfidf")
  end

  def exec
    make_file("/201601*/*/*")
    make_file("/201602*/*/*")
    make_file("/201603*/*/*")
    make_file("/201604*/*/*")
    make_file("/201605*/*/*")
    make_file("/201606*/*/*")
    exec_all
    tfidf_all
  end
  def make_file(path)
    Dir.glob(@dr+path).each do |file|
      @files.push(file)
    end 
  end
  def exec_all
    @files.each do |file|
p file
      open(file) do |io|
        json=JSON.load(io)
        doc=json["href"]  #http://headlines.yahoo.co.jp/hl?a=20160511-00050080-yom-peo
        doc.gsub!(/^.*\?a=/,"")
#p doc
        lines=json["body"].split("。")
        lines.each do |line|
          @natto.parse(line) do |n|
            word=n.feature.split(',')[6]
            word=n.surface if word=="*"
            hinshi=n.feature.split(',')[0]
            bunrui=n.feature.split(',')[1]
            next if hinshi!="名詞"
            next if hinshi=="名詞" and (bunrui!="一般" and bunrui!="固有名詞")
            next if word.length<=1
            next if word =~ /^[0-9a-zA-Z@_\-%=]+$/
            analyze(word,doc)
          end
        end
      end
    end
  end


  def analyze(word,doc)
    cursor=@db.execute("select count from news_bow where doc=? and word=?",[doc,word])
    cnt=0
    cursor.each do |tuple|
      cnt=tuple[0]
    end
p "insert into news_bow :doc="+doc+",word="+word+",cnt="+cnt.to_s
    @db.execute("delete from news_bow where doc=? and word=?",[doc,word])
    @db.execute("insert into news_bow values(?,?,?)",[doc,word,cnt+1])
  end

  def tfidf_all
    docs=Array.new
    cur=@db.execute("select distinct doc from news_bow")
    cur.each do |tuple|
      doc=tuple[0]

      cur2=@db2.execute("select sum(count) from news_bow where doc=?",[doc])
      count_sum=0
      cur2.each do |tuple2|
        count_sum=tuple2[0]
      end

      cur2=@db2.execute("select word,count from news_bow where doc=?",[doc])
      cur2.each do |tuple2|
        word=tuple2[0]
        count=tuple2[1]
        tf=count.to_f/count_sum.to_f
p "insert into news_tf :doc="+doc+",word="+word+",tf="+tf.to_s
        @db3.execute("insert into news_tf values(?,?,?)",[doc,word,tf])
      end
    end

    doc_sum=0
    cur=@db.execute("select count(distinct(doc)) from news_bow")
    cur.each do |tuple|
      doc_sum=tuple[0]
    end 
    
    cur=@db.execute("select distinct word from news_bow")
    cur.each do |tuple|
      word=tuple[0]
      cur2=@db2.execute("select count(distinct(doc)) from news_bow where word=?",[word])
      count=0
      cur2.each do |tuple2|
        count=tuple2[0]
      end
      idf=Math.log(doc_sum.to_f/count.to_f)
p "insert into news_idf :word="+word+",idf="+idf.to_s
      @db2.execute("insert into news_idf values (?,?)",[word,idf])
    end
    
    cur=@db.execute("select doc,word,tf from news_tf")
    cur.each do |tuple|
      doc=tuple[0]
      word=tuple[1]
      tf=tuple[2]

      cur2=@db2.execute("select idf from news_idf where word=?",[word])
      idf=0
      cur2.each do |tuple|
        idf=tuple[0]
      end
      tfidf=tf*idf
p "insert into news_tfidf :doc="+doc+",word="+word+",tfidf="+tfidf.to_s
      @db2.execute("insert into news_tfidf values (?,?,?)",[doc,word,tfidf])
    end

  end
end 

if __FILE__ == $0 then
  MakeBOW.new.exec
  #MakeBOW.new.analyze("キーワード","あたいです")
end
