CREATE TABLE tk_tf(
stockCode text not null,
word text not null,
tf real null
);
CREATE UNIQUE INDEX idx_tk_tf on tk_tf(stockCode,word);
CREATE TABLE tk_idf(
word text not null,
idf real null
);
CREATE UNIQUE INDEX idx_tk_idf on tk_idf(word)
;
CREATE TABLE tk_tfidf(
stockCode text not null,
word text not null,
tfidf real null
);
CREATE UNIQUE INDEX idx_tk_tfidf on tk_tfidf(stockCode,word)
;
CREATE TABLE tk_bow(
stockCode text not null,
word text not null,
count int not null
);
CREATE UNIQUE INDEX idx_tk_bow on tk_bow(stockCode,word);


----
CREATE TABLE tk_tf(
stockCode varchar(8) not null,
word varchar(255) not null,
tf real null
)ENGINE=InnoDB DEFAULT CHARSET=utf8
;
CREATE UNIQUE INDEX idx_tk_tf on tk_tf(stockCode,word);
CREATE TABLE tk_idf(
word varchar(255) not null,
idf real null
)ENGINE=InnoDB DEFAULT CHARSET=utf8
;
CREATE UNIQUE INDEX idx_tk_idf on tk_idf(word)
;
CREATE TABLE tk_tfidf(
stockCode varchar(8) not null,
word varchar(255) not null,
tfidf real null
)ENGINE=InnoDB DEFAULT CHARSET=utf8
;
CREATE UNIQUE INDEX idx_tk_tfidf on tk_tfidf(stockCode,word)
;
CREATE TABLE tk_bow(
stockCode varchar(8) not null,
word varchar(255) not null,
count int not null
)ENGINE=InnoDB DEFAULT CHARSET=utf8
;
CREATE UNIQUE INDEX idx_tk_bow on tk_bow(stockCode,word);



