#!/bin/sh

codes=`mysql -uroot -hzaaa16d.qr.com << Eof
use fintech
;
select distinct stockCode as "" from tk_bow
;
Eof
`

for code in $codes;do
  echo $code
  python tkwc.py $code
done
