#!/bin/env python
# coding:utf-8

from gensim.models import word2vec
import sys

class W2V:
    def __init__(self,infile):
        self.infile=infile
        return
    def execute(self):
        data = word2vec.Text8Corpus(self.infile)
        model = word2vec.Word2Vec(data, size=1000)

        out = model.most_similar(positive=['消費'])
        for x in out:
            print x[0], x[1]

if __name__ == "__main__":
    argvs = sys.argv
    argc = len(argvs)
    W2V("txt/conv.txt").execute()
