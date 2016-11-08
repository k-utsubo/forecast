#!/bin/env python
# coding:utf-8

import sys
import MeCab
import re

class TextConverter:
    def __init__(self, file, outfile):
        self.file=file
        self.outfile=outfile
        return

    def execute(self):
        ym=re.sub("^.*\/","",str(self.file))
        ym=re.sub("\..*$","",ym)
        f=open(self.file,"r")
        idx=100
        result=[]  # docno word
        for lin in f:
            print "---"
            print lin
            dict = {}

            lin=lin.strip().replace(" ","")
            mt=MeCab.Tagger("~/.mecabrc")

            lin=lin.replace(".","").replace(",","")
            lin=re.sub("\d{1,2}年","",lin)
            lin=re.sub("\d{1,2}月","",lin)
            lin=re.sub("\d{1,2}日","",lin)
            res = mt.parseToNode(lin)


            while res:
                if len(res.surface)>0:
                    hinshi1=res.feature.split(",")[0]
                    hinshi2=res.feature.split(",")[1]
                    if (hinshi1=="名詞" and (hinshi2=="サ変接続" or hinshi2=="一般" or hinshi2=="固有名詞" or hinshi2=="形容動詞語幹")) or  hinshi1=="形容詞" or (hinshi1=="副詞" and hinshi2=="一般") or (hinshi1=="動詞" and hinshi2=="自立"):

                        word=res.feature.split(",")[6]
                        if word=="*":
                            word=res.surface

                        if dict.has_key(word):
                            dict[word]+=1
                        else:
                            dict[word]=1


                res = res.next
            docno = int(ym) * 1000 + idx
            for key in dict.keys():
                result.append(str(docno) + "\t" + key+"\t"+ str(dict[key]))

            idx=idx+1
        f.close()


        f = open(self.outfile, "w")
        for r in result:

            f.write(r+"\n")
        f.close()
        return



if __name__ == "__main__":
    argvs = sys.argv
    argc = len(argvs)
    file=argvs[1]
    outfile=argvs[2]
    #file="txt/200804.txt.conv"
    #outfile="txt/200804.txt.bow"
    TextConverter(file,outfile).execute()

