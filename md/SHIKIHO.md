# 四季報データ

## データ
#### 会社データ
tkShimenProfile    
tkShimenHonbun    

#### 記事データ

tkShikihoSokuho    
tkNewsXml    

## 計算
[ソース](https://github.kabumap.tokyo/utsubo/sentiment/tree/master/shikiho)    

#### 会社データ
BOW作成
```
sqlite3 tk_prof.db < tk.sql
ruby tk_prof.rb
ruby tk_bow.rb
```
Word2Vec
```
bash tk_lda.sh
```
#### 記事データ
BOW作成
```
ruby kiji_bow.rb
```


## 感情極性辞書
[四季報辞書](SHIKIHO_DICT.md)

## WordCloud
面白そうなので、四季報会社プロフィールで作成してみる
[WordCloud](SHIKIHO_WC.md)

## トピックモデル
[Topic](SHIKIHO_TOPIC.md)

## 日経平均
日経平均との関連性を調べる
[Nikkei](SHIKIHO_NIKKEI.md)
