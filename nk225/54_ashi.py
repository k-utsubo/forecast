#!/bin/env python
# coding:utf-8
# convert 1min to 5min

import datetime
import MySQLdb
import numpy as np

class DateCreator:
    def __init__(self,fmDate,toDate):
        self.fmDate=fmDate
        self.toDate=toDate
        self.con=MySQLdb.connect(host="zaaa16d.qr.com",db="live",user="root",passwd="")


    def convert(self):
        cursor = self.con.cursor()
        dateList=[]
        fmTime = datetime.datetime.strptime(self.fmDate, '%Y-%m-%d %H:%M:%S')
        toTime = datetime.datetime.strptime(self.toDate, '%Y-%m-%d %H:%M:%S')
        nowTime=fmTime
        while True:
            if nowTime>toTime:
                break
            nowToTime=nowTime + datetime.timedelta(minutes=5)

            cursor.execute( "select oprice,high,low,cprice from real.kmPriceHist1min0Long where market='0002' and stockCode='OSE54' and date>=%s and date<%s order by date asc",[nowTime, nowToTime])

            result = cursor.fetchall()
            items = np.asarray(result, np.float32)
            nowTimeOrg=nowTime
            nowTime = nowToTime
            if len(result)==0:
                continue
            o=items[0,0]
            c=items[-1,3]
            h=max(items[:,1:2])[0]
            l=min(items[:,2:3])[0]
            cursor.execute("replace into real.kmPriceHist5min0Long values(%s,'0002','OSE54',%s,%s,%s,%s,0,0,0)",[nowTimeOrg,o,h,l,c])
            self.con.commit()


        cursor.close()



if __name__ == "__main__":
    dateList=DateCreator("2016-09-14 00:00:00","2016-10-14 15:00:00").convert()
