#!/bin/env ruby
# coding:utf-8


require "json"
require "cabocha"
require "nkf"
require "mysql2"
require "date"
require "time"

module UtilsDictCreator
  def get_mysql
    mysql=Mysql2::Client.new(:host=>"zcod4md.qr.com",:username=>"root",:password=>"",:databae=>"live")
    return mysql
  end

  def prev_date(dt)
    mysql=get_mysql()
    ret=nil
    mysql.query("call live.sp_prevdate('"+dt+"')").each do |item|
      ret=item["fname"]
      break
    end
    mysql.close
    return ret
  end
  def next_date(dt)
    mysql=get_mysql()
    ret=nil
    mysql.query("call live.sp_nextdate('"+dt+"')").each do |item|
      ret=item["fname"]
      break
    end
    mysql.close
    return ret
  end

  def prev_n_date(dt,n)
    tmp=dt
    for i in 0..n
      tmp=prev_date(tmp)
    end
    return tmp
  end
  def next_n_date(dt,n)
    tmp=dt
    for i in 0..n
      tmp=next_date(tmp)
    end
    return tmp
  end

  def get_from_to_day(time,interval=0)
    tm=Time.parse(time)
    dt=Date.parse(time).strftime("%Y%m%d")
    from_day=to_day=nil
    ## 15:00で区切る
    if tm.hour>=15 and tm.hour<=23 then
      from_day=dt
      to_day=next_n_date(dt,interval)

    else
      from_day=prev_n_date(dt,interval)
      to_day=dt
    end
    return from_day,to_day
  end

  def get_price(code,time,interval)
    from_day,to_day=get_from_to_day(time,interval)
    sql="select s.date,s.cprice as stock,i.cprice as topix from live.ST_priceHistAdj s,live.indexHist i where s.stockCode='"+code+"' and i.indexCode='751' and i.date=s.date and i.date>='"+from_day+"' and i.date<='"+to_day+"' order by i.date asc"
    mysql=get_mysql()
    res=mysql.query(sql)
    stock=Array.new(interval+1)
    topix=Array.new(interval+1)
    idx=0
    res.each do |item|
      stock[idx]=item["stock"]
      topix[idx]=item["topix"]
      idx=idx+1
    end
    mysql.close
    return stock,topix
  end
  def get_ret(code,time)
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
    from_day,to_day=get_from_to_day(time)
    sql="select s.date,s.cprice as stock,i.cprice as topix from live.ST_priceHistAdj s,live.indexHist i where s.stockCode='"+code+"' and i.indexCode='751' and i.date=s.date and i.date>='"+from_day+"' and i.date<='"+to_day+"' order by i.date asc"
#p sql
    mysql=get_mysql()
    res=mysql.query(sql)
    prev_item=next_item=nil
    res.each do |item|
      if prev_item==nil then
        prev_item=item
      else
        next_item=item
      end
    end
    mysql.close
    return 0 if prev_item==nil or next_item==nil
    stock_ret=(next_item["stock"].to_f-prev_item["stock"].to_f)/prev_item["stock"].to_f
    topix_ret=(next_item["topix"].to_f-prev_item["topix"].to_f)/prev_item["topix"].to_f
    return stock_ret-topix_ret
  end

  module_function :get_from_to_day
  module_function :next_date
  module_function :prev_date
  module_function :next_n_date
  module_function :prev_n_date
  module_function :get_price,:get_ret
  module_function :get_mysql
end

if __FILE__ == $0 then
p  UtilsDictCreator.get_from_to_day("2016-05-25 20:00:00",4)
p  UtilsDictCreator.get_from_to_day("2016-05-25 20:00:00")
p  UtilsDictCreator.get_ret("6758","2016-05-25 20:00:00")
p  UtilsDictCreator.get_price("6758","2016-05-25 20:00:00",4)
end
