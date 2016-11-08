#!/bin/env python
# coding:utf-8
import pystan
import numpy as np
import matplotlib.pyplot as plt
import pickle

mean1 = 10
mean2 = -10
mean3 = 0
num1 = 200
num2 = 300
num3 = 500

X = np.concatenate([
 np.random.normal(loc=mean1, scale=1, size=num1),
 np.random.normal(loc=mean2, scale=1, size=num2),
 np.random.normal(loc=mean3, scale=1, size=num3)
 ])

np.random.shuffle(X)

N = X.shape[0]
k = 3

stan_data = {'N': N, 'k': k, 'X': X}

fit = pystan.stan(file='gmm_mcmc.stan', data=stan_data, iter=10000, chains=1)

print('Sampling finished.')

#fit.plot()
#plt.show()



#http://dackdive.hateblo.jp/entry/2014/09/16/112404

with open('gmm_mcmc.txt', 'wb') as f:
  pickle.dump(fit, f)



#with open('gmm_mcmc.txt', 'rb') as f:
#  fit = pickle.load(f)
