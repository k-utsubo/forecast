#!/bin/sh

R --vanilla < tk_lda.R
aws s3 cp tk_lda.RData s3://qrfintech/sentiment/ 
