# 四季報データ辞書

四季報記事データで、[Yahooニュース](DICT.md)と同様に辞書作成する

## データ
記事本文と速報を使用
[四季報ソース](https://github.kabumap.tokyo/utsubo/sentiment/tree/master/dict)

#### 辞書作成
```
ruby tk_dict.rb
```
極性辞書が作成される

#### sqlite3
```
ruby tk_import.rb
```

## 検証
```
R --vanilla < tk_dict.R
```
```
> res<-dbSendQuery(con,"select count(*) from dict")
> data.dict<-fetch(res,-1)
> data.dict
  count(*)
1   751269
> par(mfrow=c(2,2))
>
> res<-dbSendQuery(con,"select * from dict where cnt>1")
> data.dict<-fetch(res,-1)
> length(data.dict$cnt)
[1] 63127
> hist(log10(data.dict$cnt),main="cnt>1")
> hist(data.dict$score,main="cnt>1")
> summary(data.dict$cnt)
    Min.  1st Qu.   Median     Mean  3rd Qu.     Max.
   2.000    2.000    2.000    4.976    4.000 1928.000
> # 3rd Qu.で切る
> res<-dbSendQuery(con,"select * from dict where cnt>4")
> data.dict<-fetch(res,-1)
> length(data.dict$cnt)
[1] 12413
> hist(log10(data.dict$cnt),main="cnt>4")
> hist(data.dict$score,main="cnt>4")
> summary(data.dict$cnt)
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
   5.00    6.00    8.00   15.52   13.00 1928.00
```
![](../images/tk_hist.png)



## 結果
あまり景気ウオッチャーと変わらないのでは、５％以上の増減で離散的にスコアをつけるのではなく実際のリターンでつけるか？
