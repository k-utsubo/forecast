#!/bin/env python
# coding:utf-8

import sys
import MeCab
import re
import glob
import math

class Tfidf:
    def __init__(self):

        self.doc_list=[]   # 配列の添字がDOCID
        self.word_list=[]
        self.doc_hash={}   # doc_hash{"200804101"}=DOCID
        self.word_hash={}

        self.bow=[]        # [(docid,wordid,count),]
        self.tf=[]
        self.idf=[]
        self.tfidf=[]

        for fname in glob.glob("txt/*bow"):
            f=open(fname,"r")
            for row in f:
                items=row.replace("\n","").split("\t")
                if self.doc_hash.has_key(items[0]) == False:    # doc
                    self.doc_hash[items[0]]=len(self.doc_list)
                    self.doc_list.append(items[0])
                if self.word_hash.has_key(items[1]) == False:   # word
                    self.word_hash[items[1]]=len(self.word_list)
                    self.word_list.append(items[1])
                self.bow.append([self.doc_hash[items[0]],self.word_hash[items[1]],int(items[2])])

        return

    def execute(self):
        self.calc_tf()
        self.calc_idf()
        self.calc_tfidf()

        self.write()
        return

    def write(self):
        f=open("txt/bow.txt","w")
        for w in self.bow:
            f.write(str(w[0])+"\t"+str(w[1])+"\t"+str(w[2])+"\n")
        f.close()

        f=open("txt/tf.txt","w")
        for t in self.tf:
            f.write(str(t[0])+"\t"+str(t[1])+"\t"+str(t[2])+"\n")
        f.close()

        f=open("txt/idf.txt","w")
        for i in self.idf:
            f.write(str(i[0])+"\t"+str(i[1])+"\n")
        f.close()

        f=open("txt/tfidf.txt","w")
        for d in self.tfidf:
            f.write(str(d[0])+"\t"+str(d[1])+"\t"+str(d[2])+"\n")
        f.close()

        f=open("txt/word.txt","w")
        for i in range(len(self.word_list)):
            f.write(str(i)+"\t"+str(self.word_list[i])+"\n")
        f.close()

        f=open("txt/doc.txt","w")
        for i in range(len(self.doc_list)):
            f.write(str(i)+"\t"+str(self.doc_list[i])+"\n")
        f.close()


    def calc_tf(self):
        docid=0
        word_freq_count=0
        bow_start_idx=0
        bow_now_idx=0
        for b in self.bow:
            self.tf.append([b[0],b[1],b[2]])

            if b[0]!=docid:
                for i in range(bow_start_idx,bow_now_idx):
                    self.tf[i][2]=float(self.tf[i][2])/float(word_freq_count)

                word_freq_count=b[2]
                bow_start_idx=bow_now_idx
                docid=docid+1
            else:
                word_freq_count=word_freq_count+b[2]
            bow_now_idx=bow_now_idx+1

    def calc_idf(self):
        for w in range(len(self.word_list)):
            doc_num=0
            for b in self.bow:
                if b[1]==w:
                    doc_num=doc_num+1
            self.idf.append([w,math.log(len(self.doc_list)/doc_num)])

    def calc_tfidf(self):
        for t in self.tf:
            for i in self.idf:
                if i[0]==t[1]:
                    self.tfidf.append([t[0],t[1],t[2]*i[1]])
                    break

if __name__ == "__main__":
    argvs = sys.argv
    argc = len(argvs)

    Tfidf().execute()