# WordCloudで遊んでみる
[これ](http://qiita.com/kenmatsu4/items/9b6ac74f831443d29074)を参考に     

会社四季報の会社プロフィールをTFIDF法で会社別に特徴を出した

## 環境整備
ubuntu14.04
#### python
```
git clone https://github.com/amueller/word_cloud
cd word_cloud
python setup.py install
pip install beautifulsoup4
pip install requests
```
#### mecab
```
apt-get install mecab
apt-get install mecab-ipadic
```
neologdも追加する[リポジトリ](https://github.kabumap.tokyo/utsubo/dictionary)    

.mecabrc
```
dicdir =  /var/lib/mecab/dic/ipadic-utf8
userdic = /home/ubuntu/dictionary/neologd/neologd.dic
```
#### フォント追加
```
sudo apt-get install fonts-ipafont-gothic fonts-ipafont-mincho
```

## 計算

TFIDF値の100倍の単語数をWordCloudに入力として与えて作成する
```
bash tkwc.sh
```

## サンプル
[サンプル](http://a003.kabumap.tokyo/shiny/tk/)
