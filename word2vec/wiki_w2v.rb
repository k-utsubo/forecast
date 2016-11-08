#!/bin/env ruby
# coding:utf-8
require 'natto'
require "json"

class W2V
  def initialize(outfile)
    @natto = Natto::MeCab.new
    @outfile=outfile
    File.unlink @outfile if File.exists?(@outfile)
  end
  def exec(file)
    p file
    open(file) do |io|
      while text=io.gets
        line=""
        next if text==nil
        @natto.parse(text) do |n|
          keyword=n.feature.split(',')[6]
          #keyword=n.surface if keyword=="*"
          next if keyword=="*"
          hinshi=n.feature.split(',')[0]
          bunrui=n.feature.split(',')[1]
          next if hinshi!="名詞"
          next if hinshi=="名詞" and (bunrui!="一般" and bunrui!="固有名詞")
          next if keyword.length<=1
          next if keyword =~ /^[0-9a-zA-Z@_\-%=]+$/
          next if keyword =~ /^[0-9]+年$/
          next if keyword =~ /^[0-9]+年[0-9]+月$/
          next if keyword =~ /^[0-9]+年[0-9]+月[0-9]+日$$/
          next if keyword =~ /^[0-9]+月$/
          next if keyword =~ /^[0-9]+月[0-9]+日$/
          next if keyword =~ /^[0-9]+日$/
          line=line+" " if line!=""
          line=line+keyword
        end
        write(line)
      end
    end
  end

  def write(line)
    open(@outfile,"a") do |f|
      f.puts line
    end
  end
end

if __FILE__ == $0 then
  if ARGV[1] == nil or ARGV[0] == nil then
    p "usage:"+$0+" infile outfile"
    exit(0)
  end
  W2V.new(ARGV[1]).exec(ARGV[0])
end
