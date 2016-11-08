#!/bin/env ruby
require "nkf"
require "natto"
infile="/home/ubuntu/data/wikipedia/data/text.xml"
outfile="/home/ubuntu/data/wikipedia/data/text_new.txt"
natto=Natto::MeCab.new
File.unlink(outfile) if File.exists?(outfile)
open(infile) do |f|
  while l=f.gets
    l=l.chomp
p l
    next if /^<doc/ =~ l or /^<\/doc/ =~l 
    natto.parse(l) do |n|
      open(outfile,"a") do |ff|
        ff.write NKF.nkf("-w",n.surface)+" "
      end
    end  
    open(outfile,"a") do |ff|
      ff.puts ""
    end
  end
end


