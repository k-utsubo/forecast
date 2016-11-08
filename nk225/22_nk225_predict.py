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

# predict daily return

random.seed(0)



MODEL_PATH = "./22_model.bin"
PREDICTION_LENGTH = 75
#PREDICTION_PATH = "./20_prediction.txt"
#INITIAL_PATH = "./20_initial.txt"
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



class LSTM(chainer.Chain):
    def __init__(self, in_units=1, hidden_units=2, out_units=1, train=True):
        super(LSTM, self).__init__(
            l1=L.Linear(in_units, hidden_units),
            l2=L.LSTM(hidden_units, hidden_units),
            l3=L.Linear(hidden_units, out_units),
        )
        self.train = True

    def __call__(self, x):
        h = self.l1(x)
        h = self.l2(h)
        y = self.l3(h)
        #self.loss = F.mean_squared_error(y, t)
        #if self.train:
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
        cursor.execute("select cprice/10000 from indexHist where indexCode='101' and date>=%s and date<=%s",[self.fromDate,self.toDate])
        result = cursor.fetchall()
        cursor.close()
        prices=np.asarray(map(lambda x:x[0],result),np.float32)
        return xp.asarray( np.diff(prices)/prices[:-1])




def predict(model, x_data):
    model.reset_state()
    x = chainer.Variable(xp.asarray([[x_data]], dtype=np.float32))
    future = model(x)
    return future.data
    #sequences_col = len(input_seq)
    #model.reset_state()
    #for i in range(sequences_col):
    #    x = chainer.Variable(xp.asarray(input_seq[i:i + 1], dtype=np.float32)[:, np.newaxis])
    #    future = model(x, dummy)
    #cpu_future = chainer.cuda.to_cpu(future.data)
    #return cpu_future





if __name__ == "__main__":
    # load model
    model = cPickle.load(open(MODEL_PATH))

    # make data
    data_maker = DataMaker()
    data = data_maker.make()
    #sequences = data_maker.make_mini_batch(data, mini_batch_size=MINI_BATCH_SIZE, length_of_sequence=LENGTH_OF_SEQUENCE)

    i=0
    x=[]
    real_prices=[]
    predict_prices=[]
    for i in range(1,len(data)-1):
        rprice=data[i]
        pprice=predict(model,rprice)
        print(str(i)+",predict price="+str(pprice[0][0])+",real price="+str(rprice))
        predict_prices.append(pprice[0][0])
        real_prices.append(data[i+1])
        x.append(i)
        i+=1

    plt.plot(np.asarray(x),np.asarray(real_prices),label="nk225")
    plt.plot(np.asarray(x),np.asarray(predict_prices),label="predict")
    plt.legend()
