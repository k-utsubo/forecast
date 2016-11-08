#!/bin/env python
# coding:utf-8

import sys
import MeCab

class TextConverter:
    def __init__(self, file, outfile):
        self.file=file
        self.outfile=outfile
        return

    def execute(self):
        dict={}

        f=open(self.file,"r")
        for lin in f:
            l=lin.strip().replace(" ","")
            mt=MeCab.Tagger("~/.mecabrc")
            res = mt.parseToNode(l)

            while res:
                if len(res.surface)>0:
                    hinshi=res.feature.split(",")[0]
                    if hinshi=="名詞" or hinshi=="形容詞":
                        if dict.has_key(res.surface):
                            dict[res.surface]+=1
                        else:
                            dict[res.surface]=1
                        print res.surface
                        print res.feature
                res = res.next

        f.close()
        f=open(self.outfile,"w")
        for key in dict.keys():
            f.write(key+"\t"+str(dict[key])+"\n")
        f.close()
        return



if __name__ == "__main__":
    argvs = sys.argv
    argc = len(argvs)
    file=argvs[1]
    outfile=argvs[2]
    #file="txt/200804.txt.conv"
    #outfile="/tmp/a"
    TextConverter(file,outfile).execute()

