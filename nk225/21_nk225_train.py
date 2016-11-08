#!/usr/bin/env python
# -*- coding: utf-8 -*-

# do not use this program, 20160916

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
from nk225_lstm import LSTM

# パラメータ設定
n_units = 4    # 隠れ層のユニット数
n_training = 10000
n_batchsize = 100

random.seed(0)


parser = argparse.ArgumentParser()
parser.add_argument('--gpu', '-g', default=-1, type=int, help='GPU ID (negative value indicates CPU)')
args = parser.parse_args()
if args.gpu >= 0:
    cuda.check_cuda_available()
xp = cuda.cupy if args.gpu >= 0 else np



class DataMaker(object):
    def __init__(self):
        self.con=MySQLdb.connect(host="zcod4md.qr.com",db="live",user="root",passwd="")
        self.fromDate="2001-01-01"
        self.toDate="2011-12-31"

    def make(self):
        cursor=self.con.cursor()
        cursor.execute("select cprice/10000 from indexHist where indexCode='101' and date>=%s and date<=%s",[self.fromDate,self.toDate])
        result = cursor.fetchall()
        cursor.close()
        prices=np.asarray(map(lambda x:x[0],result),np.float32)
        return xp.asarray( np.diff(prices)/prices[:-1])

    # http://qiita.com/hikobotch/items/d8ff5bebcf70083de089
    def make_mini_batch(self, data, mini_batch_size, length_of_sequence):
        sequences = xp.ndarray((mini_batch_size, length_of_sequence), dtype=np.float32)
        for i in range(mini_batch_size):
            index = random.randint(0, len(data) - length_of_sequence)
            sequences[i] = data[index:index + length_of_sequence]
        return sequences



def main():
    # make training data
    data_maker = DataMaker()
    train_data = data_maker.make()

    # モデルの準備
    lstm = LSTM(1, n_units)

    # http://studylog.hateblo.jp/entry/2016/01/05/212830
    # このようにすることで分類タスクを簡単にかける
    # 詳しくはドキュメントを読むとよい
    model = L.Classifier(lstm)
    model.compute_accuracy = False
    for param in model.params():
        data = param.data
        data[:] = np.random.uniform(-0.2, 0.2, data.shape)

    # cuda環境では以下のようにすればよい
    if args.gpu >= 0:
        model.to_gpu()

    # setup optimizer
    optimizer = optimizers.Adam()
    optimizer.setup(model)
    total_loss=0
    display= 10
    jump=50
    whole_len = len(train_data)
    for seq in range(n_training):
        #print ("training %d" % seq)

        #index=np.random.randint(len(train_data)-n_batchsize)
        #for j in xrange(n_batchsize):
        #    print ("x_batch.idx={},y_batch.idx={}".format(index+j,index+1+j))


        lstm.reset_state()
        x_batch = xp.array([train_data[(jump * j + seq) % whole_len]
                            for j in xrange(n_batchsize)])
        y_batch = xp.array([train_data[(jump * j + seq + 1) % whole_len]
                            for j in xrange(n_batchsize)])


        x = chainer.Variable(x_batch)  # 前の文字の配列を入力に
        t = chainer.Variable(y_batch)  # 次の文字の配列を正解に

        loss = model( x, t)  # lossの計算
        # 出力する時はlossを記憶
        if seq % display == 0:
            total_loss += loss.data

        # 最適化の実行
        model.zerograds()
        loss.backward()
        optimizer.update()

        # lossの表示
        if seq % display == 0:
            print("sequence:{}, loss:{}".format(seq, total_loss))
            total_loss = 0



    # save model
    cPickle.dump(lstm, open('%s/21_model.bin' % args.model_dir, 'wb'))




if __name__ == "__main__":
    main()



