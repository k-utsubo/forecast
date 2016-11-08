#!/bin/env python
# coding:utf-8

import sys

import re
import os
# 各論の本文を抽出

class TextConverter:
    def __init__(self, file, outfile):
        self.file=file
        self.outfile=outfile
        return

    def sanitize(self,line):
        s = line

        if s.find("各論") == 0 or s.find("１") == 0 or s.find("２") == 0 or s.find("３") == 0 or s.find("４") == 0:
            return ""

        s = s.replace("「", "").replace("」", "")
        # TODO 「」削除、数字を００へ
        # s = re.sub(u"[0-9０-９]", "0", s)
        s = re.sub(re.compile(r"[0-9]"), "0", s)
        s = s.replace("０", "0").replace("１", "0").replace("２", "0").replace("３", "0").replace("４", "0").replace("５","0").replace("６", "0").replace("７", "0").replace("８", "0").replace("９", "0")
        s = s.replace("（", "(").replace("）", ")")
        s = re.sub(re.compile(r"\(.*?\)"), "", s)
        s = re.sub(re.compile(r"-[0-9]-"), "", s)
        return s

    def execute(self):
        lines=[]
        is_start=0
        is_kakuron=0
        f=open(self.file,"r")
        for lin in f:
            l=lin.strip().replace(" ","")
            #print(l)
            #if l == "月例経済報告":
            #    is_start=1

            if l.decode("utf-8").find("各論".decode("utf-8"))==0:
                is_kakuron=1

            if is_kakuron!=1:
                continue

            hd=l.decode("utf-8")
            #if hd.find("各論".decode("utf-8"))==0 or hd.find("１".decode("utf-8"))==0 or hd.find("２".decode("utf-8"))==0 or hd.find("３".decode("utf-8"))==0 or hd.find("４".decode("utf-8"))==0:
            #    continue

            if len(l)==0:
                continue

            s=l.replace("\f", "").replace("\n", "")
            lines.append(s)


        s=""
        for l in lines:
            s = s + l
        strs=s.split("。")

        strs=map(lambda n:self.sanitize(n),strs)


        f.close()
        check={}
        f=open(self.outfile,"w")
        for l in strs:

            if check.has_key(l)== False:
                print l
                f.write(l+os.linesep)
                check[l] = 1
        f.close()
        return



if __name__ == "__main__":
    argvs = sys.argv
    argc = len(argvs)
    #file=argvs[1]
    file="txt/200804.txt"
    #outfile=argvs[2]
    outfile="txt/200804.txt.conv"
    TextConverter(file,outfile).execute()

