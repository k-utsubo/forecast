#!/bin/sh

R --vanilla < tk_w2v.R
aws s3 cp ../../data/model_tk.txt s3://qrfintech/sentiment/
