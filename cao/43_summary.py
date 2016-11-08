#!/bin/env python
# coding:utf-8

# deplacated
import sys

import re
import os
import CaboCha
# 要約する

class TextSummary:
    def __init__(self, file, outfile):
        self.file=file
        self.outfile=outfile
        self.cabocha=CaboCha.Parser()
        return

    def modifier(self,word_idx,nexts,bodys):
        # 目的語にかかる名詞修飾語
        obj_mod_all = []
        if word_idx>=0:

            mod_idxs=word_idx  # 主語に段階的にかかる修飾名詞は名詞に近い順に拾う
            for i in range(word_idx - 1, -1, -1):
                mod = ""
                mod_flg = 0
                joshi_flg=0  # 助詞で繋がる場合には含める。
                if nexts[i] == mod_idxs:
                    for body in bodys[i]:
                        mod = mod + body.split("\t")[0]
                        hinshi=body.split("\t")[1].split(",")[0]
                        if hinshi == "名詞" or hinshi == "動詞" or hinshi == "形容詞":
                            mod_flg = 1
                            mod_idxs=i
                        elif hinshi == "助詞":
                            joshi_flg=1
                    if mod_flg == 1:
                        if joshi_flg==0:
                            break
                        obj_mod_all.append(mod)
                    mod = ""
        return obj_mod_all

    def select_subject(self,subs,nexts,bodys):
        sub_list=[]
        for sub in subs:
            if nexts[nexts[sub]] == -1:
                sub_list.append(sub)
        if len(sub_list)==0:
            return -1

        if len(sub_list)==1:
            return sub_list[0]

        sub_pnt=[0]*len(sub_list)
        for i in range(0,len(sub_list)):
            for str in bodys[sub_list[i]]:
                if str.split("\t")[1].split(",")[1]=="固有名詞":
                    sub_pnt[i]=sub_pnt[i]+1
        #http://qiita.com/kiyoya@github/items/60cddad0c5619622b11d
        return max(xrange(len(sub_pnt)), key=lambda i: sub_pnt[i])

    def analyze(self,line):
        tree=self.cabocha.parse(line.rstrip())
        s=tree.toString(CaboCha.FORMAT_LATTICE)
        items=s.split("\n")
        #print(items)

        bodys=[]
        nexts=[]
        buf=[]
        subs=[]
        objs=[]
        prev_hinshi=""
        for item in items:
            if item == "EOS":
                break
            if item.find("*") == 0 :
                if len(buf)>0:
                    bodys.append(buf)
                    buf=[]
                n=item.split(" ")[2].replace("D","")
                nexts.append(int(n))
            else:
                buf.append(item)
                ay=item.split(",")
                if ay[1] == "係助詞" and prev_hinshi!="格助詞":
                    subs.append(len(bodys))
                elif ay[1] == "係助詞" and prev_hinshi=="格助詞":
                    objs.pop()
                elif ay[1] == "格助詞":
                    objs.append(len(bodys))
                prev_hinshi=ay[1]

        if len(buf)>0:
            bodys.append(buf)

        # 主語、目的語選択 文末を優先
        #sub_idx=-1
        obj_idx=-1
        #for sub in subs:
        #    if nexts[nexts[sub]] == -1:
        #        sub_idx=sub
        sub_idx=self.select_subject(subs,nexts,bodys)

        for obj in objs:
            if nexts[nexts[obj]] == -1:
                if obj == len(nexts)-1:  # verbとobjectが一緒
                    continue
                obj_idx=obj



        if sub_idx == -1:
            return ("","","")

        '''
        # 主語にかかる名詞修飾語
        sub_mod_all=[]
        mod=""
        mod_flg=0
        mod_idxs=sub_idx  # 主語に段階的にかかる修飾名詞は名詞に近い順に拾う
        for i in range(sub_idx-1,-1,-1):
            if nexts[i] == mod_idxs :
                for body in bodys[i]:
                    mod=mod+body.split("\t")[0]
                    if body.split("\t")[1].split(",")[0]=="名詞":
                        mod_flg=1
                        mod_idxs=i
                if mod_flg==1:
                    sub_mod_all.append(mod)
                mod=""

        # 目的語にかかる名詞修飾語
        if obj_idx>=0:
            obj_mod_all=[]
            mod = ""
            mod_flg = 0
            mod_idxs=obj_idx  # 主語に段階的にかかる修飾名詞は名詞に近い順に拾う
            for i in range(obj_idx - 1, -1, -1):
                if nexts[i] == mod_idxs:
                    for body in bodys[i]:
                        mod = mod + body.split("\t")[0]
                        if body.split("\t")[1].split(",")[0] == "名詞":
                            mod_flg = 1
                            mod_idxs=i
                    if mod_flg == 1:
                        obj_mod_all.append(mod)
                    mod = ""
        '''
        sub_mod_all=self.modifier(sub_idx,nexts,bodys)
        obj_mod_all=self.modifier(obj_idx,nexts,bodys)

        sub_str=""
        obj_str=""
        verb_str=""
        if len(sub_mod_all)>0:
            for m in range(len(sub_mod_all)-1,-1,-1):
                sub_str=sub_str+sub_mod_all[m]
        for body in bodys[sub_idx]:
            sub_str=sub_str+body.split("\t")[0]

        if obj_idx>=0:
            if len(obj_mod_all) > 0:
                for m in range(len(obj_mod_all) - 1, -1, -1):
                    obj_str = obj_str + obj_mod_all[m]

            for body in bodys[obj_idx]:
                obj_str=obj_str+body.split("\t")[0]

        for body in bodys[-1]:
            verb_str=verb_str+body.split("\t")[0]
        return (sub_str,obj_str,verb_str)

    def execute(self):

        f=open(self.file,"r")
        for lin in f:
            l=lin.strip().replace(" ","")
            print "--"
            print l
            v = self.analyze(l)
            print_analyze(v)

def print_analyze(v):
    print v[0] + v[1] + v[2]
    print "subject:" + v[0]
    print "object:" + v[1]
    print "verb:" + v[2]


if __name__ == "__main__":
    argvs = sys.argv
    argc = len(argvs)
    #file=argvs[1]
    file="txt/200804.txt.conv"
    #outfile=argvs[2]
    outfile="txt/200804.txt.digest"
    TextSummary(file,outfile).execute()
    #TextSummary(file,outfile).analyze("賃貸、持家の着工はおおむね横ばいとなっている")
    #TextSummary(file,outfile).analyze("需要側統計と供給側統計を合成した消費総合指数は、うるう年による日数増の影響もあって、0月は前月に比べ増加したが、基調としておおむね横ばいとなっている")
    #TextSummary(file,outfile).analyze("ユーロ圏及び英国では、景気回復は緩やかになっている")
    #print_analyze(TextSummary(file,outfile).analyze("先行きについては、雇用情勢の改善に足踏みがみられ、所得がおおむね横ばいで推移していることから、当面、横ばい圏内の動きが続くと見込まれる"))
    #print TextSummary(file,outfile).analyze("先行きについては、在庫面からの生産下押し圧力は小さいと考えられるものの、今後の輸出の動向等には留意する必要がある")
    #print TextSummary(file,outfile).analyze("新車販売台数は、0月減少した後、0月も減少した")
    #TextSummary(file,outfile).analyze("個別の指標について、0月の動きをみると、家計調査では、実質消費支出は前月から減少した")
    #TextSummary(file,outfile).analyze("これを需要側統計である法人企業統計季報でみると、0000年0−0月期は増加したものの、00−00月期は減少している")
    #TextSummary(file,outfile).analyze("英国では、景気回復は緩やかになっている")
    #TextSummary(file,outfile).analyze("公共投資は、総じて低調に推移している")