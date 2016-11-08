# トピックモデル
四季報記事でトピックモデルを計算する

## データ
tkShikihoSokuho      
tkNewsXml   

## 計算方法
pystanを使う、Rstanは遅いしエラーになる。メモリも多く使うので    

[参考1](http://xiangze.hatenablog.com/entry/2014/03/03/012744)    
[参考2](http://qiita.com/tmnck/items/049fd98ba2dc7d08c1f3)     
[参考3](http://breakbee.hatenablog.jp/entry/2014/08/10/042440)     

## 前準備
bow作成
記事単位で

[ソース](https://github.kabumap.tokyo/utsubo/sentiment/tree/master/shikiho)
```
ruby tk_kiji_bow.rb
```

重くて計算できねぇ
