#!/bin/sh

# www5.cao.go.jp/keizai3/getsurei/2014/1125getsurei/main.pdf

get_year(){
  str=$1
  ruby << Eof
    print "${str}".split("/")[3]
Eof
}
get_month(){
  str=$1
  ruby << Eof
    print "${str}".split("/")[4][0,2]
Eof
}

files=`find www5.cao.go.jp -name "*.pdf"`
for f in $files;do
  yyyy=`get_year $f`
  mm=`get_month $f`
  echo $yyyy $mm
  
  pdftotext -layout $f txt/${yyyy}${mm}.txt
done
