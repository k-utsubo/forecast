#!/bin/env ruby
# coding:utf-8

require  "rsruby"
require "rsruby/dataframe"

r=RSRuby.instance
r.class_table["data.frame"]=lambda{|x| DataFrame.new(x)}
RSRuby.set_default_mode(RSRuby::CLASS_CONVERSION)

x=[1,2,3]
y=[2,4,6]
df=r.as_data_frame(:x=>{'x'=>x,'y'=>y})
r.assign('df',df)
res=r.eval_R(<<R_COMMAND)
  summary(lm(y ~ x ,df))
R_COMMAND
p res["r.squared"]

r.assign("x",x)
res=r.eval_R(<<R_COMMAND)
  summary(x)
R_COMMAND
p res
