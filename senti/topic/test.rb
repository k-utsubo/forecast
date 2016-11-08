#!/bin/env ruby
# coding:utf-8

require "natto"
require "json"

@natto = Natto::MeCab.new 
@natto.parse("ラブライブとデレステを行った") do |n|
p n.feature
p n.surface
end

s="　これから冬に向けてインフルエンザの流行期がやってくる"
@natto.parse(s) do |n|
p n.feature
p n.surface
end
