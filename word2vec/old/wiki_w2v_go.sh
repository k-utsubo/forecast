#!/bin/sh

R --vanilla < wiki_w2v_n.R
aws s3 cp ../../data/model_wiki2.txt s3://qrfintech/sentiment/.

