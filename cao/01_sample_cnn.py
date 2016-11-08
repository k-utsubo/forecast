#!/bin/env python
# coding:utf-8

import numpy as np
import sklearn.datasets
import matplotlib
import matplotlib.pyplot as plt

import chainer
from chainer import cuda, Function, gradient_check, Variable, optimizers, serializers, utils
from chainer import Link, Chain, ChainList
import chainer.functions as F
import chainer.links as L

np.random.seed(0)
X,y=sklearn.datasets.make_moons(200,noise=0.20)

#fig = plt.figure()
#ax = fig.add_subplot(1,1,1)
#ax.scatter(X[:,0], X[:,1], s=40, c=y, cmap=plt.cm.Spectral)

#fig.show()


n_units = 3

class Model(Chain):
    def __init__(self):
        super(Model, self).__init__(
            l1=L.Linear(2, n_units),
            l2=L.Linear(n_units, 2),
        )

    def __call__(self, x):
        h1 = F.tanh(self.l1(x))
        y = self.l2(h1)
        return y

model = L.Classifier(Model())
optimizer = optimizers.Adam()
optimizer.setup(model)
x = Variable(X.astype(np.float32))
t = Variable(y.astype(np.int32))

for _ in range(20000):
    optimizer.update(model, x, t)

def predict(model, x_data):
    x = Variable(x_data.astype(np.float32))
    y = model.predictor(x)
    return np.argmax(y.data, axis=1)

