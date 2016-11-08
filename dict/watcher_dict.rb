#!/bin/env ruby
# coding:utf-8


require "json"
require "cabocha"
require "nkf"
require "mysql2"
require "date"
require "time"
require "./abst_dict.rb"


class WatcherDictCreator < AbstDictCreator
  def initialize
    super("../keiki_watcher/txt2/")
  end
  def exec
    Dir.glob(@top_dir+"/2010*").each do |dr| day_analyze(dr) end
    Dir.glob(@top_dir+"/2011*").each do |dr| day_analyze(dr) end
    Dir.glob(@top_dir+"/2012*").each do |dr| day_analyze(dr) end
    Dir.glob(@top_dir+"/2013*").each do |dr| day_analyze(dr) end
    Dir.glob(@top_dir+"/2014*").each do |dr| day_analyze(dr) end
    Dir.glob(@top_dir+"/2015*").each do |dr| day_analyze(dr) end

    #write_to_file("watcher_dict.txt")
  end

  private
  def get_mysql
    mysql=Mysql2::Client.new(:host=>"zcod4md",:username=>"root",:password=>"",:databae=>"live")
    return mysql
  end

  def day_analyze(dr)
    Dir.glob(dr+"/*").each do |file|
      p file
      open(file).each do |io|
        items=io.split("\t")
#p items

        score=get_score(items[1])

        items[5].split("。").each do |body|
          body_analyze(body,score)
        end
      end
    end
  end
  def get_score(key)
    return 1 if key.index("良く")==0
    return 1 if key.index("やや良く")==0
    return 0 if key=="変わらない"
    return -1 if key.index("やや悪く")==0
    return -1 if key.index("悪く")==0
  end
end

if __FILE__ == $0 then
  wdc=WatcherDictCreator.new
  wdc.exec
  wdc.write_to_file("watcher_dict.txt")
end
