#!/bin/sh


for ff in txt/*conv;do
  f=`basename $ff`
  yyyy=${f:0:4}
  mm=${f:4:2}
  echo $yyyy $mm

  echo "python 04_bow.py txt/${yyyy}${mm}.txt.conv txt/${yyyy}${mm}.txt.bow"
  python 04_bow.py txt/${yyyy}${mm}.txt.conv txt/${yyyy}${mm}.txt.bow
done
