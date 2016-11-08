#!/bin/env python
# coding:utf-8

#
#http://esu-ko.hatenablog.com/entry/2016/03/02/%E3%80%90%E3%83%87%E3%82%A3%E3%83%BC%E3%83%97%E3%83%A9%E3%83%BC%E3%83%8B%E3%83%B3%E3%82%B0%E3%80%9110%E6%99%82%E9%96%93%E3%81%A7Chainer%E3%81%AE%E5%9F%BA%E6%9C%AC%E3%82%92%E8%BA%AB%E3%81%AB%E3%81%A4

import matplotlib.pyplot as plt
import numpy as np
from sklearn.datasets import fetch_mldata
from chainer import cuda, Variable, FunctionSet, optimizers
import chainer.functions  as F
import chainer.links as L
import sys
import random


def iris_to_number(iris):
    if iris == "Iris-setosa":
        return 0
    elif iris=="Iris-versicolor":
        return 1
    else:
        return 2

#  確率的勾配降下法で学習させる際の１回分のバッチサイズ
batchsize = 100

# 学習の繰り返し回数
n_epoch   = 20

# 中間層の数
n_units   = 1000



# 学習用データを N個、検証用データを残りの個数と設定
iris_data=[]
iris_target=[]

file=open("01_study_chainer.dat","r")
for line in file:
    l = line.strip().replace(" ", "").split(",")
    iris_data.append(np.asfarray(l[0:4]))
    iris_target.append(iris_to_number(l[4]))


# sampling
# http://www.lifewithpython.com/2014/04/python-pick-up-elements-from-lists.html
N = 100

iris_no=range(len(iris_data))
iris_sampling=random.sample(iris_no,N)

x_train=[]
x_test=[]
y_train=[]
y_test=[]
for i in iris_no:
    if i in iris_sampling:
        x_train.append(iris_data[i])
        y_train.append(iris_target[i])
    else:
        x_test.append(iris_data[i])
        y_test.append(iris_target[i])

x_train=np.asfarray(x_train)
y_train=np.asfarray(y_train)
x_test=np.asfarray(x_test)
y_test=np.asfarray(y_test)
N_test = y_test.size



# Prepare multi-layer perceptron model
# 多層パーセプトロンモデルの設定
# 入力 4次元、出力 3次元
model = FunctionSet(l1=L.Linear(4, n_units),
                    l2=L.Linear(n_units, n_units),
                    l3=L.Linear(n_units, 3))




# Neural net architecture
# ニューラルネットの構造
def forward(x_data, y_data, train=True):
    x, t = Variable(x_data), Variable(y_data)

    h1 = F.dropout(F.relu(model.l1(x)),  train=train)
    h2 = F.dropout(F.relu(model.l2(h1)), train=train)
    y  = model.l3(h2)
    # 多クラス分類なので誤差関数としてソフトマックス関数の
    # 交差エントロピー関数を用いて、誤差を導出
    return F.softmax_cross_entropy(y, t), F.accuracy(y, t)





# Setup optimizer
optimizer = optimizers.Adam()
optimizer.setup(model.collect_parameters())



train_loss = []
train_acc  = []
test_loss = []
test_acc  = []

l1_W = []
l2_W = []
l3_W = []

# Learning loop
for epoch in xrange(1, n_epoch+1):
    print 'epoch', epoch

    # training
    # N個の順番をランダムに並び替える
    perm = np.random.permutation(N)
    sum_accuracy = 0
    sum_loss = 0
    # 0〜Nまでのデータをバッチサイズごとに使って学習
    for i in xrange(0, N, batchsize):
        x_batch = x_train[perm[i:i+batchsize]]
        y_batch = y_train[perm[i:i+batchsize]]

        # 勾配を初期化
        optimizer.zero_grads()
        # 順伝播させて誤差と精度を算出
        loss, acc = forward(x_batch, y_batch)
        # 誤差逆伝播で勾配を計算
        loss.backward()
        optimizer.update()

        train_loss.append(loss.data)
        train_acc.append(acc.data)
        sum_loss     += float(cuda.to_cpu(loss.data)) * batchsize
        sum_accuracy += float(cuda.to_cpu(acc.data)) * batchsize

    # 訓練データの誤差と、正解精度を表示
    print 'train mean loss={}, accuracy={}'.format(sum_loss / N, sum_accuracy / N)

    # evaluation
    # テストデータで誤差と、正解精度を算出し汎化性能を確認
    sum_accuracy = 0
    sum_loss     = 0
    for i in xrange(0, N_test, batchsize):
        x_batch = x_test[i:i+batchsize]
        y_batch = y_test[i:i+batchsize]

        # 順伝播させて誤差と精度を算出
        loss, acc = forward(x_batch, y_batch, train=False)

        test_loss.append(loss.data)
        test_acc.append(acc.data)
        sum_loss     += float(cuda.to_cpu(loss.data)) * batchsize
        sum_accuracy += float(cuda.to_cpu(acc.data)) * batchsize

    # テストデータでの誤差と、正解精度を表示
    print 'test  mean loss={}, accuracy={}'.format(sum_loss / N_test, sum_accuracy / N_test)

    # 学習したパラメーターを保存
    l1_W.append(model.l1.W)
    l2_W.append(model.l2.W)
    l3_W.append(model.l3.W)

# 精度と誤差をグラフ描画
plt.figure(figsize=(8,6))
plt.plot(range(len(train_acc)), train_acc)
plt.plot(range(len(test_acc)), test_acc)
plt.legend(["train_acc","test_acc"],loc=4)
plt.title("Accuracy of digit recognition.")
plt.plot()