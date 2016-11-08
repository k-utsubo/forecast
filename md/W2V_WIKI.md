# word2vec Wikipedia
Wikipediaの本文をダウンロードし辞書作成

## データ
[参考](http://qiita.com/wwacky/items/8a9eb543171afea90c0a)    
[参考２](http://taka-say.hateblo.jp/entry/2016/05/20/221817)    

[source](https://github.kabumap.tokyo/utsubo/sentiment/tree/master/wikipedia)   

```
$ python WikiExtractor.py -b 500K -o extracted jawiki-latest-pages-articles.xml.bz2
$ find . -name 'wiki*' -exec cat {} \; > text.xml
```
これからタグを取り除く
```
ruby to_text.rb
```


## 計算１
Rのライブラリ
[source](https://github.kabumap.tokyo/utsubo/sentiment/tree/master/word2vec)   

#### 全部

```
bash wiki_w2v.sh 1
...

cat ../../data/wikipedia/*wakati > ../../data/wikipedia/wiki.txt

```
Word2Vecプログラムを実行　
```
R --slave < wiki_w2v.R
```
失敗

#### 名詞のみ
```
bash wiki_w2v_n.sh

~/data/wikipedia$ cat *wakati  > wiki2.txt
```
word2vec
```
bash wiki_w2v_go.sh
```
失敗

#### 落ちていたプログラム
[参考](https://github.com/iinm/jawiki_word2vec)

#### 結果
Rだとどうもうまくいかない上に計算時間がかかる

## 計算２
Pythonライブラリ
[source](https://github.kabumap.tokyo/utsubo/sentiment/tree/master/word2vec)   

#### 実行
```
wiki_w2v.py
```
計算時間数時間
#### モデル
```
s3://qrfintech/sentiment/model_py.data
```
#### 結果ファイル
以下の３ファイルが必要
- s3://qrfintech/sentiment/model_py.data    
- s3://qrfintech/sentiment/model_py.data.syn0.npy    
- s3://qrfintech/sentiment/model_py.data.syn1neg.npy

#### 結果
```
>>> from gensim.models import word2vec
>>> import logging
>>> import sys
>>> model = word2vec.Word2Vec.load("model_py.data")
>>> out=model.most_similar(positive=[u"経済",u"為替"])
>>> for x in out:
...   print x[0],x[1]
...
金融 0.796755313873
金融市場 0.781036019325
物価 0.770957171917
為替相場 0.72740906477
金融政策 0.721997022629
世界経済 0.716591060162
財政政策 0.709719121456
国際貿易 0.701799631119
労働市場 0.699704527855
相場 0.698793530464
```

そこそこ良さそうなので他のコンテンツに基本辞書として応用する

## デモ
[デモ](http://a003.kabumap.tokyo/bottle/w2v)
