# Word2Vec yahoo news
201601−201606までの本文記事を利用    
[word2vec](https://github.kabumap.tokyo/utsubo/sentiment/tree/master/word2vec)    

#### データ作成
記事本文を全て分かち書きにし、１つのファイルにする
```
bash news_w2v.sh 201601
..

cat ../../data/data/news_w2v/* > ../../data/data/news_w2v/all.txt
```

#### word2vec
Word2Vecプログラムを実行　
```
R --slave < news_w2v_all.R
```
#### 確認
```
> word2vec_model <- read.vectors("model_all.txt",binary=TRUE)
Reading a word2vec binary file of 233447 rows and 200 columns
  |======================================================================| 100%
> nearest_to(word2vec_model,word2vec_model[["地震"]])
        地震       大地震      震度6強         揺れ         本震      震度6弱
5.551115e-16 1.125427e-01 1.794618e-01 1.839541e-01 1.847952e-01 2.011106e-01
    巨大地震        震度7         強震        震度6
2.045213e-01 2.065930e-01 2.176735e-01 2.198738e-01
> nearest_to(word2vec_model,word2vec_model[["トヨタ"]])
       トヨタ        ホンダ          日産      ダイハツ  トヨタ自動車
-2.220446e-16  1.748162e-01  1.916586e-01  2.107053e-01  2.246865e-01
       スバル      レクサス  ダイハツ工業        スズキ        いすゞ
 2.503347e-01  2.583443e-01  2.821189e-01  2.828938e-01  2.927947e-01
> nearest_to(word2vec_model,word2vec_model[["LINE"]])
                              LINE                     公式アカウント
                      8.881784e-16                       2.055126e-01
          コミュニケーションアプリ                         ライブ配信
                      2.953254e-01                       3.128079e-01
アカウントメディアプラットフォーム                      spaceshowertv
                      3.591694e-01                       3.718593e-01
                          Appstore             コミュケーションアプリ
                      3.790565e-01                       3.815773e-01
            クリエイターズスタンプ                       フリーコイン
                      3.822130e-01                       3.921213e-01

```
なんとなく特徴は出ている

#### デモ
[サンプル](http://a003.kabumap.tokyo/shiny/w2v/)　　　　　
遅いのでPythonの方がいいかも。とりあえずWikipediaデータの方で作成する
