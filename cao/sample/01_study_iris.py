#!/bin/env python
# coding:utf-8

# https://github.com/michitakaiida/chainer_my_iris/blob/master/iris.ipynb

from sklearn import datasets
import numpy as np
from chainer import cuda, Function, FunctionSet, gradient_check, Variable, optimizers
from chainer import computational_graph as c
import chainer.functions as F
from chainer import optimizers
import six

iris = datasets.load_iris()
X = iris.data
Y = iris.target
X = X.astype(np.float32)
Y = Y.flatten().astype(np.int32)


#入力層4,中間層10,出力層3のNN
n_units   = 10
model = FunctionSet(l1=F.Linear(4, n_units),
                    l2=F.Linear(n_units, n_units),
                    l3=F.Linear(n_units, 3))

#FeedForwardの関数定義
def forward(x_data, y_data, train=True):
    x, t = Variable(x_data), Variable(y_data)
    h1 = F.dropout(F.relu(model.l1(x)),  train=train)
    h2 = F.dropout(F.relu(model.l2(h1)), train=train)
    y  = model.l3(h2)
    return F.softmax_cross_entropy(y, t), F.accuracy(y, t)

N=75
import random
iris_no=range(len(X))
iris_sampling=random.sample(iris_no,N)

x_train=[]
x_test=[]
y_train=[]
y_test=[]
for i in iris_no:
    if i in iris_sampling:
        x_train.append(X[i])
        y_train.append(Y[i])
    else:
        x_test.append(X[i])
        y_test.append(Y[i])

x_train=np.asarray(x_train,np.float32)
y_train=np.asarray(y_train,np.int32)
x_test=np.asarray(x_test,np.float32)
y_test=np.asarray(y_test,np.int32)

#x_train, x_test = np.split(X,[75])
#y_train, y_test = np.split(Y,[75])
N_test = y_test.size

#optimizer = optimizers.SGD()
optimizer = optimizers.Adam()
optimizer.setup(model.collect_parameters())
optimizer.zero_grads()

#N = 75
batchsize = 5
n_epoch = 1000
n_units = 1000

for epoch in six.moves.range(1, n_epoch + 1):
    print('epoch', epoch)

    # training
    perm = np.random.permutation(N)
    sum_accuracy = 0
    sum_loss = 0
    for i in six.moves.range(0, N, batchsize):
        x_batch = x_train[perm[i:i + batchsize]]
        y_batch = y_train[perm[i:i + batchsize]]

        optimizer.zero_grads()
        loss, acc = forward(x_batch, y_batch)
        loss.backward()
        optimizer.update()

        if epoch == 1 and i == 0:
            with open("graph.dot", "w") as o:
                o.write(c.build_computational_graph((loss, )).dump())
            with open("graph.wo_split.dot", "w") as o:
                g = c.build_computational_graph((loss, ),
                                                remove_split=True)
                o.write(g.dump())
            print('graph generated')

        sum_loss += float(cuda.to_cpu(loss.data)) * len(y_batch)
        sum_accuracy += float(cuda.to_cpu(acc.data)) * len(y_batch)

    print('train mean loss={}, accuracy={}'.format(
        sum_loss / N, sum_accuracy / N))

    # evaluation
    sum_accuracy = 0
    sum_loss = 0
    for i in six.moves.range(0, N_test, batchsize):
        x_batch = x_test[i:i + batchsize]
        y_batch = y_test[i:i + batchsize]

        loss, acc = forward(x_batch, y_batch, train=False)

        sum_loss += float(cuda.to_cpu(loss.data)) * len(y_batch)
        sum_accuracy += float(cuda.to_cpu(acc.data)) * len(y_batch)

    print('test  mean loss={}, accuracy={}'.format(
        sum_loss / N_test, sum_accuracy / N_test))


#FeedForwardの関数定義
def predict_forward(x_data):
    x = Variable(x_data)
    h1 = F.relu(model.l1(x))
    h2 = F.relu(model.l2(h1))
    y  = model.l3(h2)
    return y

#test_x = np.array([[6 ,  4 ,  1.5,  0.2 ]],dtype=np.float32)

for i in range(y_test.size):
    y = predict_forward(np.array([x_test[i]],np.float32))
    result=F.softmax(y).data
    print(str(i)+",actual:"+str(y_test[i])+",predicted:"+str(result[0][0])+","+str(result[0][1])+","+str(result[0][2]))
