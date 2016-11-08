#!/bin/sh

R --vanilla < kiji_lda.R
aws s3 cp kiji_lda.RData s3://qrfintech/sentiment/ 
