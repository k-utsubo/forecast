#!/bin/sh

R --vanilla < wiki_w2v_py.R
aws s3 cp ../../data/model_wiki_text_new.txt s3://qrfintech/sentiment/.

