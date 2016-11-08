#!/bin/env ruby
# coding:utf-8

require "natto"
require "json"
require "rsruby"
require "rsruby/dataframe"

class Tfidf
  def initialize
    @dr="../../../data/data/news"
    @keys=Array.new
    @docs=Array.new
    @mat=Array.new

    @rs=RSRuby.instance
    @rs.class_table["data.frame"]=lambda{|x| DataFrame.new(x)}
    RSRuby.set_default_mode(RSRuby::CLASS_CONVERSION)
  end

  def exec
    Dir.glob(@dr+"/docmat2.txt").each do |file|
p file
      open(file) do |io|
        while line =io.gets
          if @keys.size==0 then
            @keys=line.chomp.split("\t")
            @keys.shift
          else
            tmp=line.chomp.split("\t")
            @docs.push(tmp.shift)
            @mat.push(tmp)
          end
        end
      end
    end
    calc_bow
    calc_tfidf
  end
  def calc_bow
    bow=Array.new
    for i in 0...@mat.size do 
      vec=@mat[i]
      for j in 0...vec.size do 
        v=vec[j]
        next if v.to_i==0
        bow.push([@docs[i],@keys[j],v.to_i])
      end
    end
    open(@dr+"/bow2.txt","w") do |f|
      bow.each do |tmp|
        s=tmp.join("\t")+"\n"
        f.puts s
      end
    end
  end

  def calc_tfidf
    tf=Array.new
    for i in 0...@mat.size do 
      vec=@mat[i]
#p vec
      #sum=vec.inject do |sum,n| sum.to_i+1 if n.to_i > 0  end
      sum=vec.count do |n| n.to_i>0 end
#p "sum="+sum.to_s
      for j in 0...vec.size do 
        v=vec[j]
        next if v.to_i==0
        tf.push([@docs[i],@keys[j],v.to_f/sum.to_f])
      end
    end
    open(@dr+"/tf2.txt","w") do |f|
      tf.each do |tmp|
        s=tmp.join("\t")+"\n"
        f.puts s
      end
    end


    df=Array.new(@keys.length,0)
    idf=Array.new(@keys.length,0)
    for i in 0...@keys.length do
      @mat.each do |vec|
        if vec[i].to_i > 0 then
          df[i]=df[i]+1
        end
      end
      idf[i]=[@keys[i],Math.log(@docs.size.to_f/df[i].to_f)]
#p "idf["+i.to_s+"]="+idf[i].to_s
    end
    open(@dr+"/idf2.txt","w") do |f|
      idf.each do |tmp|
        f.puts tmp.join("\t")+"\n"
      end
    end

    tfidf=Array.new
    tf.each do |vec|
      tmp=idf.find do |item| item[0]==vec[1] end
      tfidf.push([vec[0],vec[1],tmp[1]])
    end

    open(@dr+"/tfidf2.txt","w") do |f|
      tfidf.each do |tmp|
        f.puts tmp.join("\t")
      end
    end


#    @rs.assign('tfidf',tfidf_val)
#    res=r.eval_R(<<R_COMMAND)
#summary(tfidf))
#R_COMMAND
#p res["3rd Qu."]
    

#    tf=Hash.new
#    @docs.each do |href,bow|
#      tfary=Array.new
#      sum = bow.inject do |sum,n| sum+n end
#      bow.each do |v|
#        tfary.push(v.to_f/sum.to_f)
#      end
#      tf[href]=tfary
#    end
#
#    idf=Array.new
#    @keys.each do |keyword,idx|
#      idfval=0
#      @docs.each do |href,bow|
#        if bow[idx]>0 then
#          idfval=idfval+1
#        end
#      end
#      idf[idx]=Math.log(@docs.size/idfval)
#    end
#
#    tfidf=Hash.new
#    tf.each do |href,tfary|
#      tfidfary=Array.new
#      for i in 0...tfary.length do
#        tfidfary[i]=tfary[i]*idf[i]
#      end
#      tfidf[href]=tfidfary
#    end
  end
end 

if __FILE__ == $0 then
  Tfidf.new.exec
end
