#!/bin/env ruby 
# coding:utf-8

require "./news_dict.rb"
require "./watcher_dict.rb"
class AllDictCreator
  def initialize
    ndc=NewsDictCreator.new
    ndc.exec
    wdc=WatcherDictCreator.new
    wdc.set_dict(ndc.dict)
    wdc.exec
    wdc.write_to_file("all_dict.txt")
  end
end


if __FILE__ == $0 then
  AllDictCreator.new
end
