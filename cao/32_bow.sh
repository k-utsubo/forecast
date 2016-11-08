#!/bin/sh


for ff in txt/*conv;do
  f=`basename $ff`
  yyyy=${f:0:4}
  mm=${f:4:2}
  echo $yyyy $mm

  echo "python 31_bow.py txt/${yyyy}${mm}.txt.conv txt/${yyyy}${mm}.txt.bow"
  python 32_bow.py txt/${yyyy}${mm}.txt.conv txt/${yyyy}${mm}.txt.bow
done

python 32_tfidf.py