# トピックモデル

極性辞書方式では特徴がでづらかったので、
トピックモデルで文書のクラスタリングを行ってみる

### 参考　
[トピックモデルシリーズ](http://statmodeling.hatenablog.com/entry/topic-model-2)

## データ
#### データソース        
ヤフーニュース     
#### 期間    
2016-06-01 - 2016-06-30      

## 方法1
1. キーワード（名詞・一般、名詞・固有名詞、形容詞・自立、副詞、２文字以上、数字記号以外）を抜き出しTFIDF
1. TFIDF値の高い方からキーワードを絞り込む
#### ソースコード      
[topic2](../senti/topic2)    
#### 実行環境
r2.x4largeのスポットインスタンス

#### 実行
```
ruby news_bow2.rb
ruby news_tidf2.rb
R --slave < news.lda2.R
```
#### 結果
何回実行しても落ちてしまう。ロジックが悪いのかデータ量が多いのかちょっとわからない

## 方法2
1. キーワード（名詞・一般、名詞・固有名詞、２文字以上、数字記号以外）を抜き出しTFIDF
1. IDF値でキーワードを下位２００くらい抜き出す
1. TOPICモデル
#### ソースコード      
[topic3](../senti/topic3)   
#### 実行
```
ruby news_bow3.rb
```
#### 確認
```
sqlite> select count(*) from news_idf where idf<3.8;
205
sqlite> select count(distinct doc) from news_bow where word in (select word from news_idf where idf<3.8);
85011
```
どうも文書数が多い感じ
とりあえずstanで計算
