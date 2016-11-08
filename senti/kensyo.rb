#!/bin/env ruby
# coding:utf-8

require "json"
require "cabocha"
require "nkf"
require "mysql"
require "date"
require "time"
require "../dict/abst_dict.rb"
require "../dict/utils_dict.rb"

#http://d.hatena.ne.jp/riocampos+tech/20130611/p1
module Enumerable

    def sum
      inject(0){ |accum, i| accum + i }
    end

    def mean
      sum / length.to_f
    end

    def variance
      m = mean
      sum = inject(0){ |accum, i| accum + ( i - m ) ** 2 }
      sum / (length - 1).to_f
    end

    def standard_deviation
      return Math::sqrt(variance)
    end
end

class NewsEvaluation < AbstDictCreator
  include UtilsDictCreator
  def initialize(dict)
    super("../news/data/news")
    @dict=dict
  end
  def exec
    Dir.glob(@top_dir+"/201601*").each do |dr| day_analyze(dr) end
    Dir.glob(@top_dir+"/201602*").each do |dr| day_analyze(dr) end
    Dir.glob(@top_dir+"/201603*").each do |dr| day_analyze(dr) end
    Dir.glob(@top_dir+"/201604*").each do |dr| day_analyze(dr) end
    Dir.glob(@top_dir+"/201605*").each do |dr| day_analyze(dr) end
  end

  def get_mysql_fintech
    mysql=Mysql.connect("zaaa16d.qr.com","root","","fintech")
    return mysql
  end


  def day_analyze(dr)
    Dir.glob(dr+"/*/*").each do |file|
#p file
      open(file) do |io|
        json=JSON.load(io)
        mc=json["body"].scan(/<\d{4}>/)
        if mc.size==1 then
          code=mc[0].gsub(/</,"").gsub(/>/,"")
          score,ret=get_score(code,json["time"])
          #bodys=json["body"].gsub(/<\d{4}>/,"").split("。")
          bodys=json["body"].split("。")
          score_all=0
          score_ary=[]
          bodys.each do |body|
            calc_score,cnt=wakati_analyze(body,score,json["href"])
            if cnt>0 then
              score_all=(calc_score*cnt+score_all*score_ary.length)/(cnt+score_ary.length)
              score_ary.push(calc_score)
            end
          end

          std=0
          # reliability
          if score_ary.length>1 then
            std=score_ary.standard_deviation
          end

          if score_ary.length>0 then
            mysql=get_mysql_fintech()
            stmt=mysql.prepare("replace into fintech.yahooStockNewsSentiment values(?,?,?,?,?,?,?,?)")
            stmt.execute(json["href"],json["time"],code,score_all,score_ary.length,std,ret,score)
            mysql.close()
#p "code="+code.to_s+",time="+json["time"].to_s+",score_all="+score_all.to_s+",cnt_all="+score_ary.length.to_s+",score="+score.to_s+",ret="+ret.to_s+",std="+std.to_s
p json
            # from "time" to 5 days after 
            stock,topix=get_price(code,json["time"],5)
            
            mysql=get_mysql_fintech()
            stmt=mysql.prepare("replace into fintech.yahooStockNewsPrice values(?,?,?,?,?,?,?,?,?,?,?,?,?)")
            stmt.execute(json["href"],stock[0],stock[1],stock[2],stock[3],stock[4],stock[5],topix[0],topix[1],topix[2],topix[3],topix[4],topix[5])
            mysql.close()
          end
        end
      end
    end
  end

  def wakati_analyze(body,score,href)
    #body=body.gsub(/「/,"").gsub(/」/,"").gsub(/（.*?）/,"")
    tree=@cabocha.parse(body)
    keys=Kakari.new.exec(NKF.nkf("-w",tree.toString(CaboCha::FORMAT_LATTICE)))

    calc_score=0
    cnt=0
    keys.each do |keyitem|
      key=keyitem.map do |k| k.to_word end
      keyorg=keyitem.map do |k| k.to_raw_word end
      if @dict.has_key?(key) and @dict[key][0].to_f!=0  then

        word=Array.new(9,"")
        i=0
        keyorg.each do |k|
          word[i]=k
          i=i+1
        end
        mysql=get_mysql_fintech()
        stmt=mysql.prepare("replace into fintech.yahooStockNewsKeyword values(?,?,?,?,?,?,?,?,?,?,?)")
        stmt.execute(href,word[0],word[1],word[2],word[3],word[4],word[5],word[6],word[7],word[8],@dict[key][0])
        mysql.close()
p body
p key
p keyorg
p +@dict[key][0].to_s
        calc_score=(calc_score*cnt+@dict[key][0].to_f)/(cnt+1)
        cnt=cnt+1
      end
    end
#p "score="+calc_score.to_s+",cnt="+cnt.to_s+",score="+score.to_s
    return calc_score,cnt
  end

  def get_score(code,time)
    ret=get_ret(code,time)
#p "code="+code.to_s+",ret="+ret.to_s
    return 1,ret if ret>=0.05
    return -1,ret if ret<=-0.05
    return 0,ret
  end
end


class Kensyo
  include UtilsDictCreator
  def initialize
    @dict={}
    filename="../dict/all_dict.txt"
    open(filename,"r") do |f|
      while line=f.gets
        ary=line.chomp.split("\t")
        score=[ary[0],ary[1]]
        next if ary[1].to_i<5
        ary.shift(2)
        @dict[ary]=score
      end
    end
  end

  def exec
    NewsEvaluation.new(@dict).exec
  end
end


if __FILE__ == $0 then
  Kensyo.new.exec
end
