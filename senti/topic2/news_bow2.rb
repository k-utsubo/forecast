#!/bin/env ruby
# coding:utf-8

require "natto"
require "json"

class MakeBOW
  def initialize
    @dr="../../../data/data/news"
    @docs=Hash.new  # key:href, value:vector ,word count
    @keys=Hash.new  # key:keyword , value:docs vector index
    @natto = Natto::MeCab.new 
    @keystr=""
    @files=[]
  end

  def exec
#    make_file("/201601*/*/*")
#    make_file("/201602*/*/*")
#    make_file("/201603*/*/*")
#    make_file("/201604*/*/*")
#    make_file("/201605*/*/*")
    make_file("/20160606/*/*")
    exec_all
  end
  def make_file(path)
    Dir.glob(@dr+path).each do |file|
      @files.push(file)
    end 
  end
  def exec_all
    #Dir.glob(@dr+"/*/*").each do |file|
    @files.each do |file|
p file
      open(file) do |io|
        json=JSON.load(io)
        #mc=json["body"].scan(/<\d{4}>/)
        #next if mc.size!=1
        href=json["href"]  #http://headlines.yahoo.co.jp/hl?a=20160511-00050080-yom-peo
        href.gsub!(/^.*\?a=/,"")
p href
        #lines=json["body"].gsub(/<\d{4}>/,"").split("。")
        lines=json["body"].split("。")
        lines.each do |line|
          #@natto.parse(json["body"].gsub(/<\d{4}>/,"")) do |n|
          @natto.parse(line) do |n|
            keyword=n.feature.split(',')[6]
            keyword=n.surface if keyword=="*"
            hinshi=n.feature.split(',')[0]
            bunrui=n.feature.split(',')[1]
#p "Hinshi="+hinshi
#p "Bunrui="+bunrui
#            next if hinshi!="名詞" and hinshi!="形容詞" and hinshi!="副詞"
            next if hinshi!="名詞"
#p "======="
            next if hinshi=="名詞" and (bunrui!="一般" and bunrui!="固有名詞")
#            next if hinshi=="形容詞" and bunrui!="自立"
            next if keyword.length<=1
            next if keyword =~ /^[0-9a-zA-Z@_\-%=]+$/
#p keyword
            analyze(keyword,href)
          end
        end
      end
#      break if @docs.length>5
    end
    make_matrix
  end
  def to_str(ary)
    ret=""
    umeru=@keys.size-ary.length
    ary.each do |s|
      ret=ret+"\t" if ret!="" 
      if s == nil then
        ret=ret+"0"
      else
        ret=ret+s.to_s
      end
    end
p "keys.size="+@keys.size.to_s+",ary.length="+ary.length.to_s+",umeru="+umeru.to_s
    for i in 0...umeru do
      ret=ret+"\t" if ret!="" 
      ret=ret+"0"
    end
    return ret
  end
  def make_matrix()
p @keys
    open("../../../data/data/news/docmat2.txt","w") do |f|
      f.puts @keystr
      @docs.each do |k,v|
        f.puts k.to_s+"\t"+to_str(v)
      end
    end
  end
  def analyze(keyword,href)
    bow=Array.new # bow
    bow=@docs[href] if @docs.has_key?(href)


    if @keys.has_key?(keyword) then
      idx=@keys[keyword]
    else
      idx=@keys.size
      @keys[keyword]=idx
      @keystr=@keystr+"\t"+keyword
    end
#p "href="+href.to_s+",keyword="+keyword+",idx="+idx.to_s
#p bow

    if bow[idx]==nil then
      bow[idx]=1
    else
      bow[idx]=bow[idx]+1
    end
    @docs[href]=bow
  end
end 

if __FILE__ == $0 then
  MakeBOW.new.exec
end
