#!/bin/env python
# coding:utf-8

import MySQLdb
import sys
import datetime
import numpy as np
import datetime
import re

class TextConverter:
    def __init__(self, file, outfile):
        self.file=file
        self.outfile=outfile
        return

    def execute(self):
        pattern=r"（.*）"
        lines=[]
        is_start=0
        is_kakuron=0
        f=open(self.file,"r")
        for lin in f:
            l=lin.strip().replace(" ","")
            print(l)
            #if l == "月例経済報告":
            #    is_start=1

            if l.decode("utf-8").find("各論".decode("utf-8"))==0:
                is_kakuron=1

            if is_kakuron==1:
                hd=l.decode("utf-8")
                if hd.find("各論".decode("utf-8"))==0 or hd.find("１".decode("utf-8"))==0 or hd.find("２".decode("utf-8"))==0 or hd.find("３".decode("utf-8"))==0 or hd.find("４".decode("utf-8"))==0:
                    continue
                if len(lin)>1 and lin[1]!= " " and lin[0]!="\f":
                    lines.append(l.replace("¥f", "").replace("¥n", "").replace("。", '\n'))

            #else:
            #    if is_start==1:
            #        if re.match(pattern,l):
            #            continue
            #        lines.append(l.replace("¥f","").replace("¥n","").replace("。",'\n'))
        f.close()
        f=open(self.outfile,"w")
        for l in lines:
            f.write(l)
        f.close()
        return



if __name__ == "__main__":
    argvs = sys.argv
    argc = len(argvs)
    file=argvs[1]
    #file="txt/200804.txt"
    outfile=argvs[2]
    TextConverter(file,outfile).execute()

