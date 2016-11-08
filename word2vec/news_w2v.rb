#!/bin/env ruby
# coding:utf-8
require 'natto'
require "json"

class W2V
  def initialize(outfile)
    @natto = Natto::MeCab.new
    @outfile="../../data/data/news/w2vdoc.txt"
    if outfile != nil then
      @outfile=outfile
    end
    File.unlink @outfile if File.exists?(@outfile)
  end
  def exec(dr)
    path=dr
    if dr == nil then
      path="../../data/data/news/20160601"
    end
    Dir.glob(path+"/*/*").each do |file|
      parse(file)
    end
  end
  def parse(file)
    p file
    line=""
    open(file) do |io|
      json=JSON.load(io)
      text=json["body"]
      next if text==nil
      @natto.parse(text) do |n|
        keyword=n.feature.split(',')[6]
        keyword=n.surface if keyword=="*"
        #hinshi=n.feature.split(',')[0]
        #bunrui=n.feature.split(',')[1]
        #next if hinshi!="名詞"
        #next if hinshi=="名詞" and (bunrui!="一般" and bunrui!="固有名詞")
        #next if keyword.length<=1
        #next if keyword =~ /^[0-9a-zA-Z@_\-%=]+$/
        line=line+" " if line!=""
        line=line+keyword
      end
    end
    write(line)
  end

  def write(line)
    open(@outfile,"a") do |f|
      f.puts line
    end
  end
end

if __FILE__ == $0 then
  W2V.new(ARGV[1]).exec(ARGV[0])
end
