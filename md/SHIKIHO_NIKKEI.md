# 日経平均と四季報記事
四季報記事のキーワードと日経平均の騰落を調査    
WikipediaのWord2Vec辞書をうまく使う

----

## Word2Vec
[ソース](https://github.kabumap.tokyo/utsubo/sentiment/tree/master/word2vec)
#### WikipediaのWord2Vec辞書
[辞書作成方法](W2V_WIKI.md)      
読み込んで確認
```
$ aws s3 cp s3://qrfintech/sentiment/model_py.data .
$ aws s3 cp s3://qrfintech/sentiment/model_py.data.syn0.npy  .
$ aws s3 cp s3://qrfintech/sentiment/model_py.data.syn1neg.npy .
```
```
$ python
>>> from gensim.models import word2vec
>>> import logging
>>> import sys
>>> model=word2vec.Word2Vec.load("model_py.data")
>>> out = model.most_similar(positive=[u"野球"])
>>> for x in out:
...   print x[0],x[1]
...
サッカー 0.75195235014
アメフト 0.744313001633
ソフトボール 0.7386328578
プロ野球 0.730953216553
バスケットボール 0.709499835968
少年野球 0.704337477684
ラグビー 0.694683372974
バスケ 0.683065891266
リトルリーグ 0.676698446274
フットボール 0.6714194417
```

----

## 計算
#### 記事をファイル
```
ruby kiji_file.rb
```
