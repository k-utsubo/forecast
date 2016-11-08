#!/usr/bin/python
# coding: utf-8
import CaboCha
import sys
import codecs

sys.stdout = codecs.getwriter('utf_8')(sys.stdout)

c = CaboCha.Parser ()

#sentence = "太郎と花子は２００３年、奈良先端大を卒業した。"
#sentence = "この本はとても難しいので、読むのをあきらめた。"
#sentence = raw_input('>')
#print sentence
sentence="防衛省に入った連絡によると、２９日午前１１時２４分頃、航空自衛隊松島基地（宮城県）の南東約４５キロの太平洋上で、訓練飛行をしていた空自のＴ４練習機２機が空中で接触した。"

tree =  c.parse (sentence)
size = tree.size()
#print tree.toString(2)    # 適当にフォーマット2で全体を書いてみる（本論とは関係 せず）

print "=================="    # ここから

myid = 0        # 項目のカウンター
ku_list = []
ku = ''
ku_id = 0
ku_link = 0
kakari_joshi = 0
kaku_joshi = 0

for i in range (0, size):
    token = tree.token (i)

    if token.chunk:
        if (ku!=''):
            ku_list.append((ku, ku_id, ku_link, kakari_joshi, kaku_joshi))  #前 の句をリストに追加
        kakari_joshi = 0
        kaku_joshi = 0

        ku = token.normalized_surface
        ku_id = myid
        ku_link = token.chunk.link
        myid=myid+1
    else:
        ku = ku + token.normalized_surface
    m = (token.feature).split(',')
    if (m[1] == '係助詞'):
       kakari_joshi = 1
    if (m[1] == '格助詞'):
       kaku_joshi = 1

ku_list.append((ku, ku_id, ku_link, kakari_joshi, kaku_joshi))  # 最後にも前の句をリストに追加

print "--------"
for k in ku_list:
    print k[1], k[0].decode("utf-8"), k[2], k[3], k[4]
    if (k[2]==-1):  # link==-1?      # 述語である
        jutsugo_id = ku_id  # この時のidを覚えておく

print "述語句".decode("utf-8")
for k in ku_list:
    if (k[1]==jutsugo_id):  # jutsugo_idと同じidを持つ句を探す
        print k[1], k[0].decode("utf-8"), k[2], k[3], k[4]
print "--------"
print "述語句に係る句".decode("utf-8")
for k in ku_list:
    if (k[2]==jutsugo_id):  # jutsugo_idと同じidをリンク先に持つ句を探す
        print k[1], k[0].decode("utf-8"), k[2], k[3], k[4]

print "--------"
print "その中から、主語句と目的語句を選ぶ".decode("utf-8")
for k in ku_list:
    if (k[2]==jutsugo_id):  # jutsugo_idと同じidをリンク先に持つ句を探す
        #print k[0], k[1], k[2], k[3], k[4]
        if (k[3] == 1):
             print "主語".decode("utf-8"), k[0].decode("utf-8")
        if (k[4] == 1):
             print "目的語".decode("utf-8"), k[0].decode("utf-8")
    if (k[1] == jutsugo_id):
         print "述語".decode("utf-8"), k[0].decode("utf-8")