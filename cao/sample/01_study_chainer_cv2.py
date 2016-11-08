#!/usr/bin/env python
# -*- coding: utf-8 -*-

# http://kivantium.hateblo.jp/entry/2016/02/04/213050

from __future__ import print_function
import cv2
import argparse

import chainer
from chainer import optimizers
import chainer.functions as F
import chainer.links as L

import numpy as np

# 引数の処理
#parser = argparse.ArgumentParser(
#    description='train convolution filters')
#parser.add_argument('org', help='Path to original image')
#args = parser.parse_args()
input_image="star.png"

# クラスの定義
class Conv(chainer.Chain):
    def __init__(self):
        super(Conv, self).__init__(
            # 入力・出力1ch, ksize=3
            conv1=L.Convolution2D(1, 1, 3, stride=1, pad=1),
        )

    def clear(self):
        self.loss = None
        self.accuracy = None

    def forward(self, x):
        self.clear()
        h = self.conv1(x)
        return h

    def calc_loss(self, x, t):
        self.clear()
        h = self.conv1(x)
        loss = F.mean_squared_error(h, t)
        return loss

# 画像の読み込み
train_image = chainer.Variable(np.asarray([[cv2.imread(input_image, 0)/255.0]], dtype=np.float32))

# 正解画像の作成
laplacian = Conv()
laplacian.conv1.W.data[0][0] = [[0, 1, 0],[1, -4, 1], [0, 1, 0]]
laplacian.conv1.b.data[0] = 0.0
target = laplacian.forward(train_image)
cv2.imwrite("target.jpg", target.data[0][0]*255)

# 学習対象のモデル作成
model = Conv()
initial = model.forward(train_image)
cv2.imwrite("initial.jpg", initial.data[0][0]*255)

# 最適化の設定
optimizer = optimizers.Adam()
optimizer.setup(model)

# 学習
for seq in range(20000):
    loss = model.calc_loss(train_image, target)
    if seq%100==0:
        print("{}: {}".format(seq, loss.data))
    model.zerograds()
    loss.backward()
    optimizer.update()

# 学習結果の表示
print(model.conv1.W.data[0][0])
trained = model.forward(train_image).data[0][0]*255
cv2.imwrite("trained.jpg", trained)