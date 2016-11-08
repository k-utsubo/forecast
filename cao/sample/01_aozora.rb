#!/bin/env ruby 

org_file="bocchan.txt"

open(org_file,"r") do |f|
  while l = f.gets
    print l.chomp.gsub(/《[^》]+》/,"").gsub(/｜/,"").gsub(/(\r|\n)/,"")+"\n"
  end
end

