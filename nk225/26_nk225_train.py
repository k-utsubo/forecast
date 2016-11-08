#!/usr/bin/env python
# -*- coding: utf-8 -*-


# yesterday's dj,dax,eurjpy,oil input , today's nk225 output

#http://seiya-kumada.blogspot.jp/2016/07/lstm-chainer.html

import chainer
import chainer.links as L
import chainer.functions as F
import math
import random

import numpy as np
from chainer import optimizers, cuda
import time
import sys
import cPickle
import argparse
import MySQLdb


random.seed(0)

IN_UNITS = 4  # dj,dax,eurjpy,oil
HIDDEN_UNITS = 20
OUT_UNITS = 1
TRAINING_EPOCHS = 1000
DISPLAY_EPOCH = 100
MINI_BATCH_SIZE = 100
LENGTH_OF_SEQUENCE = 200
#STEPS_PER_CYCLE = 50
#NUMBER_OF_CYCLES = 100

parser = argparse.ArgumentParser()
parser.add_argument('--gpu', '-g', default=-1, type=int, help='GPU ID (negative value indicates CPU)')
args = parser.parse_args()
if args.gpu >= 0:
    cuda.check_cuda_available()
xp = cuda.cupy if args.gpu >= 0 else np


class LSTM(chainer.Chain):
    def __init__(self, in_units=IN_UNITS, hidden_units=HIDDEN_UNITS, out_units=OUT_UNITS, train=True):
        super(LSTM, self).__init__(
            l1=L.Linear(in_units, hidden_units),
            l2=L.LSTM(hidden_units, hidden_units),
            l3=L.LSTM(hidden_units, hidden_units),
            l4=L.Linear(hidden_units, out_units),
        )
        self.train = True

    def __call__(self, x, t):
        h = self.l1(x)
        h = self.l2(h)
        h = self.l3(h)
        y = self.l4(h)
        if self.train:
            self.loss = F.mean_squared_error(y, t)
            return self.loss
        else:
            self.prediction = y
            return self.prediction

    def reset_state(self):
        self.l2.reset_state()
        self.l3.reset_state()


class DataMaker(object):
    def __init__(self):
        self.con=MySQLdb.connect(host="zcod4md.qr.com",db="live",user="root",passwd="")
        self.fromDate="2001-01-01"
        self.toDate="2011-12-31"

    def make(self):
        cursor=self.con.cursor()
        cursor.execute("select i.cprice,d.cl,x.cl,e.price,o.price from indexHist i,idcStockDaily d,idcStockDaily x,otherHist e,otherHist o where i.date=x.date and  i.date=d.date and i.date=o.date and i.date=e.date and i.indexCode='101' and d.indexCode='I_DJI' and x.indexCode='DAX' and e.otherCode='EURO' and o.otherCode='OIL' and i.date>=%s and i.date<=%s order by i.date asc",[self.fromDate,self.toDate])

        result = cursor.fetchall()
        cursor.close()
        items=xp.asarray(result, np.float32)
        return((items[1:]-items[:-1])/items[:-1]) #%


    # http://qiita.com/hikobotch/items/d8ff5bebcf70083de089
    def make_mini_batch(self, data, mini_batch_size, length_of_sequence):
        sequences = xp.ndarray(( mini_batch_size, length_of_sequence,len(data[0])), dtype=np.float32)
        for i in range(mini_batch_size):
            index = random.randint(0, len(data) - length_of_sequence)
            sequences[i] = data[index:index + length_of_sequence]
        return sequences



def compute_loss(model, sequences):
    loss = 0
    rows, cols ,in_unit= sequences.shape
    length_of_sequence = cols
    for i in range(cols - 1):
        x = chainer.Variable(
            xp.asarray(
                [sequences[j, i + 0, 1:5] for j in range(rows)],
                dtype=np.float32
            )
        )
        t = chainer.Variable(
            xp.asarray(
                [sequences[j, i + 1, 0] for j in range(rows)],
                dtype=np.float32
            )[:, np.newaxis]
        )
        loss += model(x, t)
    return loss


if __name__ == "__main__":

    # make training data
    data_maker = DataMaker()
    train_data = data_maker.make()

    # setup model
    model = LSTM(IN_UNITS, HIDDEN_UNITS, OUT_UNITS)
    for param in model.params():
        data = param.data
        data[:] = np.random.uniform(-0.1, 0.1, data.shape)

    if args.gpu >= 0:
        model.to_gpu()

    # setup optimizer
    optimizer = optimizers.Adam()
    optimizer.setup(model)

    start = time.time()
    cur_start = start
    for epoch in range(TRAINING_EPOCHS):
        sequences = data_maker.make_mini_batch(train_data, mini_batch_size=MINI_BATCH_SIZE,
                                               length_of_sequence=LENGTH_OF_SEQUENCE)
        model.reset_state()
        model.zerograds()
        loss = compute_loss(model, sequences)
        loss.backward()
        optimizer.update()

        if epoch % DISPLAY_EPOCH == 0:
            cur_end = time.time()
            # display loss
            print(
                "[{j}]training loss:\t{i}\t{k}[sec/epoch]".format(
                    j=epoch,
                    i=loss.data / (sequences.shape[1] - 1),
                    k=(cur_end - cur_start) / DISPLAY_EPOCH
                )
            )
            cur_start = time.time()
            sys.stdout.flush()

    end = time.time()

    # save model
    cPickle.dump(model, open("./26_model.bin", "wb"))

    print("{}[sec]".format(end - start))
