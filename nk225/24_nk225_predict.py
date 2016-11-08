#!/usr/bin/env python
# -*- coding: utf-8 -*-

import MySQLdb
import argparse
import cPickle
import numpy as np
from chainer import optimizers, cuda
import chainer
import chainer.links as L
import chainer.functions as F
import numpy as np
import math
import random
import matplotlib.pyplot as plt



random.seed(0)



MODEL_PATH = "./24_model.bin"
IN_UNITS = 4  # close,usdjpy,eurjpy,dj
HIDDEN_UNITS = 5
OUT_UNITS = 1
TRAINING_EPOCHS = 1000
DISPLAY_EPOCH = 10
MINI_BATCH_SIZE = 100
LENGTH_OF_SEQUENCE = 100
STEPS_PER_CYCLE = 50
NUMBER_OF_CYCLES = 100


parser = argparse.ArgumentParser()
parser.add_argument('--gpu', '-g', default=-1, type=int, help='GPU ID (negative value indicates CPU)')
args = parser.parse_args()
if args.gpu >= 0:
    cuda.check_cuda_available()
xp = cuda.cupy if args.gpu >= 0 else np



#class LSTM(chainer.Chain):
#    def __init__(self, in_units=1, hidden_units=2, out_units=1, train=True):
#        super(LSTM, self).__init__(
#            l1=L.Linear(in_units, hidden_units),
#            l2=L.LSTM(hidden_units, hidden_units),
#            l3=L.Linear(hidden_units, out_units),
#        )
#        self.train = True
#
#    def __call__(self, x):
#        h = self.l1(x)
#        h = self.l2(h)
#        y = self.l3(h)
#        #self.loss = F.mean_squared_error(y, t)
#        #if self.train:
#        #    return self.loss
#        #else:
#        self.prediction = y
#        return self.prediction
#
#    def reset_state(self):
#        self.l2.reset_state()

class LSTM(chainer.Chain):
    def __init__(self, in_units=IN_UNITS, hidden_units=HIDDEN_UNITS, out_units=OUT_UNITS, train=True):
        super(LSTM, self).__init__(
            l1=L.Linear(in_units, hidden_units),
            l2=L.LSTM(hidden_units, hidden_units),
            l3=L.Linear(hidden_units, out_units),
        )
        self.train = True

    def __call__(self, x, t):
        h = self.l1(x)
        h = self.l2(h)
        y = self.l3(h)

        #if self.train:
        #    self.loss = F.mean_squared_error(y, t)
        #    return self.loss
        #else:
        self.prediction = y
        return self.prediction

    def reset_state(self):
        self.l2.reset_state()


class DataMaker(object):
    def __init__(self):
        self.con=MySQLdb.connect(host="zcod4md.qr.com",db="live",user="root",passwd="")
        self.fromDate="2012-01-01"
        self.toDate="2015-12-31"

    def make(self):
        cursor=self.con.cursor()
        cursor.execute("select i.cprice/10000,u.price/100,e.price/100,d.cl/10000 from indexHist i,otherHist u,otherHist e,idcStockDaily d where i.date=u.date and i.date=e.date and i.date=d.date and i.indexCode='101' and u.otherCode='FEXCH' and e.otherCode='EURO' and d.indexCode='I_DJI' and i.date>=%s and i.date<=%s order by i.date asc",[self.fromDate,self.toDate])
        result = cursor.fetchall()
        cursor.close()
        items = xp.asarray(result, np.float32)
        return ((items[1:] - items[:-1]) / items[:-1])*100.0

def predict(model, x_data):
    model.reset_state()
    x = chainer.Variable(xp.asarray([x_data], dtype=np.float32))
    dummy=x
    future = model(x,dummy)
    return future.data

def main():
    # load model
    model = cPickle.load(open(MODEL_PATH))

    # make data
    data_maker = DataMaker()
    data = data_maker.make()

    i=0
    x=[]
    real_prices=[]
    predict_prices=[]
    for i in range(1,len(data)-1):
        now_price=data[i]
        next_price=data[i+1]
        pprice=predict(model,now_price)
        print(str(i)+",predict price="+str(pprice[0][0])+",real price="+str(next_price[0]))
        predict_prices.append(pprice[0][0])
        real_prices.append(data[i+1])
        x.append(i)
        i+=1

if __name__ == "__main__":
    main()


