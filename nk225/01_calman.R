# http://sinhrks.hatenablog.com/entry/2014/11/01/231333
set.seed(1)

# 観測系列のサンプルサイズ
n <- 120

# 真の値
actual <- 5

# 観測される値 (誤差は標準偏差2の正規分布とする)
observed <- rnorm(n, mean = actual, sd = 2)

# 結果保存用のvector
xhat <- rep(0, length.out = n)
P <- rep(0, length.out = n)
K <- rep(0, length.out = n)

# 誤差
Q = 1e-5
R = 0.1 ** 2

for (k in seq(2, n)) {
  # predict
  xhat.m <- xhat[k-1]
  P.m <- P[k-1] + Q
  
  # update
  S <- R + P.m
  K[k] <- P.m / S
  xhat[k] <- xhat.m + K[k] * (observed[k] - xhat.m)
  P[k] <- (1 - K[k]) * P.m
}

# 予測値の推移
xhat