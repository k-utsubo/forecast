#!/usr/bin/env python
# -*- coding: utf-8 -*-


import chainer
import chainer.links as L
import chainer.functions as F

# http://kivantium.hateblo.jp/entry/2016/01/31/222050
# LSTMのネットワーク定義
class LSTM(chainer.Chain):
    def __init__(self, in_size, n_units, train=True):
        super(LSTM, self).__init__(
            l1=L.Linear(in_size, n_units),
            l2=L.LSTM(n_units, n_units),
            l3=L.Linear(n_units, in_size),
        )
        self.train = train

    def __call__(self, x):
        h0 = self.l1(x)
        h1 = self.l2(h0)
        y = self.l3(h1)
        return y

    def reset_state(self):
        self.l2.reset_state()

