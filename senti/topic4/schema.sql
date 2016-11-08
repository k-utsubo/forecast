CREATE TABLE news_tf(
doc text not null,
word text not null,
tf real null
);
CREATE UNIQUE INDEX idx_news_tf on news_tf(doc,word);
CREATE TABLE news_idf(
word text not null,
idf real null
);
CREATE UNIQUE INDEX idx_news_idf on news_idf(word)
;
CREATE TABLE news_tfidf(
doc text not null,
word text not null,
tfidf real null
);
CREATE UNIQUE INDEX idx_news_tfidf on news_tfidf(doc,word)
;
CREATE TABLE news_bow(
doc text not null,
word text not null,
count int not null
);
CREATE UNIQUE INDEX idx_news_bow on news_bow(doc,word);
