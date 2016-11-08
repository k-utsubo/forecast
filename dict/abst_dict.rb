#!/bin/env ruby
# coding:utf-8


require "json"
require "cabocha"
require "nkf"
require "mysql2"
require "date"
require "time"
class WordItem
  attr_reader:word,:hinshi
  def initialize(word,hinshi)
    @word=word
    @hinshi=hinshi
  end
end
class KakariItem
  attr_reader:next_id
  attr_reader:word_items
  def initialize(next_id)
    @next_id=next_id
    @word_items=[]
  end
  def push(word_item)
    @word_items.push(word_item)
  end

  def to_word
    word=""
    @word_items.each do |word_item|
      if word_item.hinshi[6]!="*" then
        word=word+word_item.hinshi[6]
      else
        word=word+word_item.word
      end
    end
    return word
  end
  def to_raw_word
    word=""
    @word_items.each do |word_item|
      word=word+word_item.word
    end
    return word
  end


  def top_ok
    @word_items.each do |word_item|
      if word_item.hinshi[0]=="動詞"or word_item.hinshi[0] == "助動詞" or (word_item.hinshi[0]=="名詞" and word_item.hinshi[1]=="非自立") then
        return false
      end
    end
    return true
  end
  def next_ok
    @word_items.each do |word_item|
      if word_item.hinshi[0]=="動詞" or word_item.hinshi[0] == "助動詞" then
        return false
      end
    end
    return true
  end
end

class Kakari

  def exec(s)
    kakari_items=[]
    keys=nil
    s.split("\n").each do |line|
      #if line.index("* ")==0 then
      if line =~ /^\* \d/ then
        keys=line.split(" ")
#p keys[1].to_s+","+keys[2].to_s
      else
        words=line.split("\t")
        next if words[1]==nil
        hinshi=words[1].split(",")

        # 助動詞、否定を考慮。
        next if hinshi[0]!="名詞" and hinshi[0]!="動詞" and hinshi[0]!="形容詞" and !(hinshi[0]=="接続詞" and hinshi[1]=="名詞接続") and hinshi[0]!="助動詞"
        next if hinshi[0]=="名詞" and !( hinshi[1]=="サ変接続" or hinshi[1]=="ナイ形容詞語幹" or hinshi[1]=="形容動詞語幹" or hinshi[1]=="一般" or hinshi[1]=="固有名詞" or hinshi[1]=="非自立" )
        next if hinshi[0]=="動詞" and (hinshi[1]=="接尾" or hinshi[1]=="非自立")

        next if words[0] =~ /\d.*月/
        next if words[0] =~ /\d.*日/
        next if words[0] =~ /\./
        next if words[0] =~ /,/

        # 形容詞、動詞で終了、動詞は頭に来ない
        item=kakari_items[keys[1].to_i]
        item=KakariItem.new(keys[2].to_i) if item==nil
        item.push(WordItem.new(words[0],hinshi))
        kakari_items[keys[1].to_i]=item
      end
#p keys
    end


    dicts=[]
    return dicts if kakari_items.size<=2
    kakari_items.each do |kakari_item|
      next if kakari_item==nil
      next if !kakari_item.top_ok
#p "----"
#p kakari_item.to_word
      dict=dict_create(kakari_items,kakari_item)
      dicts.push(dict.reverse!) if dict.size>1
    end
    # 配列の配列。dictはキーワードの配列
    return dicts
  end

  def dict_create(kakari_items,kakari_item)
#p kakari_item
    return [] if kakari_item==nil
    if !kakari_item.next_ok or kakari_item.next_id<0 then
      return [kakari_item]
    end

#p "next_id="+kakari_item.next_id.to_s
    tmp=dict_create(kakari_items,kakari_items[kakari_item.next_id])
    tmp.push(kakari_item)
    return tmp

  end
end

class AbstDictCreator
  attr_reader:dict
  def initialize(top_dir)
    @top_dir=top_dir
    @cabocha=CaboCha::Parser.new
    @dict={}
  end
  def set_dict(dict)
    @dict=dict
  end
  def write_to_file(filename)
    open(filename,"w") do |f|
      @dict.each do |k,v|
        l=""
        for i in 0...9 do
          l=l+"\t"
          if k.size>i then
            l=l+k[i]
          end
        end
        #f.write v.join("\t")+"\t"+k.join("\t")+"\n"
        f.write v.join("\t")+"\t"+l+"\n"
      end
    end
  end

  def body_analyze(body,score)
    #return if score==nil
    body=body.gsub(/「/,"").gsub(/」/,"").gsub(/（.*）/,"")
    tree=@cabocha.parse(body)
    dict=Kakari.new.exec(NKF.nkf("-w",tree.toString(CaboCha::FORMAT_LATTICE)))
    dict.each do |keyitem|
      key_score=[0,0]
      key=[]
      keyitem.each do |k| key.push( k.to_word ) end

      if @dict.has_key?(key) then
        key_score=@dict[key]
      end
      key_score[0]=(key_score[0].to_f*key_score[1].to_f+score).to_f/(key_score[1]+1).to_f
      key_score[1]=key_score[1]+1
      @dict[key]=key_score
    end
  end

end

if __FILE__ == $0 then
#  body="* 前日比変動率（％）は、小数第３位四捨五入当日の指数値＝前日の指数値×（１＋２倍×ＴＯＰＩＸ（配当なし）の前日比変動率）※ＴＯＰＩＸレバレッジ（２倍）指数については、以下のＨＰをご覧ください"
  body="Active accounts are the accounts withbalance or the accounts which havetraded more than once (includingwithdrawal) in the past 1 year0%5%10%15%20%25%30%35%Under2020s30s40s50s60sOver70Corp"
  body="Kindle Fire HD 8.9ガンホー・オンライン・エンターテイメント株式会社『パズル＆ドラゴンズ』が万ダウンロードを突破！ガンホー・オンライン・エンターテイメント株式会社（本社所在地：東京都千代田区、代表取締役社長Android™/Kindle Fireが 、累 計 900の国と地域の皆様にお楽しみ頂いております"
  body=body.gsub(/「/,"").gsub(/」/,"").gsub(/（.*?）/,"")
#p body
  cabocha=CaboCha::Parser.new
  tree=cabocha.parse(body)
#print NKF.nkf("-w",tree.toString(CaboCha::FORMAT_LATTICE))
#  keys=Kakari.new.exec(NKF.nkf("-w",tree.toString(CaboCha::FORMAT_LATTICE)))
#p keys

  body="機械学習も統計もあまり勉強進んでいませんゴメンナサイ。"
  
  dc=AbstDictCreator.new(nil)
  dc.body_analyze(body,1)

end
