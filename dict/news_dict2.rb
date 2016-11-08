#!/bin/env ruby
# coding:utf-8
# topix , beta 


require "json"
require "cabocha"
require "nkf"
require "mysql2"
require "date"
require "time"
require "./abst_dict.rb"
require "./utils_dict.rb"

class NewsDictCreator < AbstDictCreator
  include UtilsDictCreator
  def initialize
    super("../news/data/news")
  end
  def exec
    Dir.glob(@top_dir+"/2014*").each do |dr| day_analyze(dr) end
    Dir.glob(@top_dir+"/2015*").each do |dr| day_analyze(dr) end
#    Dir.glob(@top_dir+"/201601*").each do |dr| day_analyze(dr) end
#    Dir.glob(@top_dir+"/201602*").each do |dr| day_analyze(dr) end
#    Dir.glob(@top_dir+"/201603*").each do |dr| day_analyze(dr) end
#    Dir.glob(@top_dir+"/201604*").each do |dr| day_analyze(dr) end
#    Dir.glob(@top_dir+"/201605*").each do |dr| day_analyze(dr) end

    #write_to_file("news_dict.txt")
  end

  private
  def get_mysql
    mysql=Mysql2::Client.new(:host=>"zcod4md.qr.com",:username=>"root",:password=>"",:databae=>"live")
    return mysql
  end

  def day_analyze(dr)
    Dir.glob(dr+"/*/*").each do |file|
p file
      open(file) do |io|
        json=JSON.load(io)
        mc=json["body"].scan(/<\d{4}>/)
        if mc.size==1 then
          code=mc[0].gsub(/</,"").gsub(/>/,"")
          score=get_score(code,json["time"])
          bodys=json["body"].gsub(/<\d{4}>/,"").split("。")
          bodys.each do |body|
            body_analyze(body,score)
          end
        end
      end
    end
  end

#  def prev_date(dt)
#    mysql=get_mysql()
#    ret=""
#    mysql.query("call live.sp_prevdate('"+dt.strftime('%Y%m%d')+"')").each do |item|
#      ret=item["fname"]
#    end
#    mysql.close
#    return ret
#  end
#  def next_date(dt)
#    mysql=get_mysql()
#    ret=""
#    mysql.query("call live.sp_nextdate('"+dt.strftime('%Y%m%d')+"')").each do |item|
#      ret= item["fname"]
#    end
#    mysql.close
#    return ret
#  end

  def get_score(code,time)
    ret=get_ret_adj(code,time)
    return 1 if ret>=0.5
    return -1 if ret<=-0.5
    return 0
  end
#  def get_ret(code,time)
#    tm=Time.parse(time)
#    dt=Date.parse(time)
#    from_day=to_day=nil
#    ## 15:00で区切る
#    if tm.hour>=15 and tm.hour<=23 then
#      from_day=dt.strftime("%Y%m%d")
#      to_day=next_date(dt)
#
#    else
#      from_day=prev_date(dt)
#      to_day=dt.strftime("%Y%m%d")
#    end
#    sql="select s.date,s.cprice as stock,i.cprice as topix from live.ST_priceHistAdj s,live.indexHist i where s.stockCode='"+code+"' and i.indexCode='751' and i.date=s.date and i.date>='"+from_day+"' and i.date<='"+to_day+"' order by i.date asc"
#    mysql=get_mysql()
#    res=mysql.query(sql)
#    prev_item=next_item=nil
#    res.each do |item|
#      if prev_item==nil then
#        prev_item=item
#      else
#        next_item=item
#      end
#    end
#    mysql.close
#    return 0 if prev_item==nil or next_item==nil
#
#    # get beta
#    mysql=get_mysql()
#    sql="select beta from live.stockFactorHist where stockCode='"+code+"' and date=(select max(date) from live.stockFactorHist where date<='"+from_day+"')"
#    res=mysql.query(sql)
#    beta=1
#    res.each do |item|
#      beta=item["beta"].to_f
#    end
#    mysql.close
#p "code="+code.to_s+",beta="+beta.to_s
#
#    stock_ret=(next_item["stock"].to_f-prev_item["stock"].to_f)/prev_item["stock"].to_f
#    topix_ret=(next_item["topix"].to_f-prev_item["topix"].to_f)/prev_item["topix"].to_f
#    return stock_ret-topix_ret*beta
#  end

end

if __FILE__ == $0 then
  ndc=NewsDictCreator.new
  ndc.exec
  ndc.write_to_file("news_dict2.txt")
end
