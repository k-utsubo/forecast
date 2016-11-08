#https://abicky.net/2012/03/24/211818/

library(RMeCab)

# 文書間の類似度を算出する関数
sim <- function(mat) {
  mat <- t(mat)
  ret <- list()
  for (i in seq(length = ncol(mat) - 1)) {
    a <- mat[, i]
    b <- mat[, -(1:i), drop = FALSE]
    ret[[i]] <- colSums(a * b) / sqrt(sum(a^2) * colSums(b^2))
  }
  ret <- unlist(ret)
  attr(ret, "Size") <- ncol(mat)
  attr(ret, "Labels") <- colnames(mat)
  class(ret) <- "dist"
  ret
}

makeDocMatrix <- function(doc, pos) {
  D <- docMatrixDF(doc, pos = pos)
  colnames(D) <- paste("d", seq(along = doc), sep = "")
  D
}

lsi <- function(D, k) {
  docsvd <- svd(D)
  index <- 1:k
  Dk <- docsvd$d[index]
  Uk <- docsvd$u[, index, drop = FALSE]
  Vk <- docsvd$v[, index, drop = FALSE]
  list(Dk = Dk, Uk = Uk, Vk = Vk)
}


docs <- c("会場には車で行きます。",
          "会場には自動車で行きます。",
          "会場には自転車で行きます。",
          "お店には自転車で行きます。")
pos <- c("形容詞", "動詞", "副詞", "名詞", "連体詞")
D <- makeDocMatrix(docs, pos)

cat("単語・文書行列\n")
print(D)

k <- 2
ret <- lsi(D, k)

cat("\n検索クエリq「会場 車」との類似度\n")
q <- (rownames(D) %in% c("会場", "車")) + 0

cat("元々の文書の類似度\n")
print(sim(t(cbind(D, q))))

cat("\nランク削減版の類似度\n")
lsi.rank <- t(t(ret$Uk) * ret$Dk) %*% t(ret$Vk)
dimnames(lsi.rank) <- dimnames(D)
print(sim(t(cbind(lsi.rank, q))))

cat("\n次元削減版の類似度\n")
lsi.dim <- t(ret$Uk) %*% D
print(sim(t(cbind(lsi.dim, q = c(t(ret$Uk) %*% q)))))