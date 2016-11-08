CREATE TABLE kiji_tf(
stockCode text not null,
word text not null,
tf real null
);
CREATE UNIQUE INDEX idx_kiji_tf on kiji_tf(stockCode,word);
CREATE TABLE kiji_idf(
word text not null,
idf real null
);
CREATE UNIQUE INDEX idx_kiji_idf on kiji_idf(word)
;
CREATE TABLE kiji_tfidf(
stockCode text not null,
word text not null,
tfidf real null
);
CREATE UNIQUE INDEX idx_kiji_tfidf on kiji_tfidf(stockCode,word)
;
CREATE TABLE kiji_bow(
stockCode text not null,
word text not null,
count int not null
);
CREATE UNIQUE INDEX idx_kiji_bow on kiji_bow(stockCode,word);
