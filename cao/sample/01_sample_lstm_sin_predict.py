#!/usr/bin/env python
# -*- coding: utf-8 -*-


import cPickle
import numpy as np
from chainer import optimizers, cuda
import chainer
import chainer.links as L
import chainer.functions as F
import math
import random

MODEL_PATH = "./01_sin.model"
PREDICTION_LENGTH = 75
PREDICTION_PATH = "./prediction.txt"
INITIAL_PATH = "./initial.txt"
MINI_BATCH_SIZE = 100
LENGTH_OF_SEQUENCE = 100
STEPS_PER_CYCLE = 50
NUMBER_OF_CYCLES = 100
#xp = cuda.cupy


class LSTM(chainer.Chain):
    def __init__(self, in_units=1, hidden_units=2, out_units=1, train=True):
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
        self.loss = F.mean_squared_error(y, t)
        if self.train:
            return self.loss
        else:
            self.prediction = y
            return self.prediction

    def reset_state(self):
        self.l2.reset_state()



class DataMaker(object):
    def __init__(self, steps_per_cycle, number_of_cycles):
        self.steps_per_cycle = steps_per_cycle
        self.number_of_cycles = number_of_cycles

    def make(self):
        return np.array([math.sin(i * 2 * math.pi / self.steps_per_cycle) for i in
                         range(self.steps_per_cycle)] * self.number_of_cycles)

    def make_mini_batch(self, data, mini_batch_size, length_of_sequence):
        sequences = np.ndarray((mini_batch_size, length_of_sequence), dtype=np.float32)
        for i in range(mini_batch_size):
            index = random.randint(0, len(data) - length_of_sequence)
            sequences[i] = data[index:index + length_of_sequence]
        return sequences


def predict_sequence(model, input_seq, output_seq, dummy):
    sequences_col = len(input_seq)
    model.reset_state()
    for i in range(sequences_col):
        x = chainer.Variable(np.asarray(input_seq[i:i + 1], dtype=np.float32)[:, np.newaxis])
        future = model(x, dummy)
    cpu_future = chainer.cuda.to_cpu(future.data)
    return cpu_future


def predict(seq, model, pre_length, initial_path, prediction_path):
    # initial sequence
    input_seq = np.array(seq[:seq.shape[0] / 4])

    output_seq = np.empty(0)

    # append an initial value
    output_seq = np.append(output_seq, input_seq[-1])

    model.train = False
    dummy = chainer.Variable(np.asarray([0], dtype=np.float32)[:, np.newaxis])

    for i in range(pre_length):
        future = predict_sequence(model, input_seq, output_seq, dummy)
        input_seq = np.delete(input_seq, 0)
        input_seq = np.append(input_seq, future)
        output_seq = np.append(output_seq, future)

    with open(prediction_path, "w") as f:
        for (i, v) in enumerate(output_seq.tolist(), start=input_seq.shape[0]):
            f.write("{i} {v}\n".format(i=i - 1, v=v))

    with open(initial_path, "w") as f:
        for (i, v) in enumerate(seq.tolist()):
            f.write("{i} {v}\n".format(i=i, v=v))


if __name__ == "__main__":
    # load model
    model = cPickle.load(open(MODEL_PATH))

    # make data
    data_maker = DataMaker(steps_per_cycle=STEPS_PER_CYCLE, number_of_cycles=NUMBER_OF_CYCLES)
    data = data_maker.make()
    sequences = data_maker.make_mini_batch(data, mini_batch_size=MINI_BATCH_SIZE, length_of_sequence=LENGTH_OF_SEQUENCE)

    sample_index = 45
    predict(sequences[sample_index], model, PREDICTION_LENGTH, INITIAL_PATH, PREDICTION_PATH)
