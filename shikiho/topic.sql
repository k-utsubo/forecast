drop table if exists tk_kiji_bow
;
drop table if exists tk_kiji_idf
;
drop table if exists tk_kiji_tf
;
drop table if exists tk_kiji_tfidf
;
drop table if exists tk_kiji_word
;


CREATE TABLE tk_kiji_bow(
doc varchar(32) not null,
word varchar(255) not null,
count int not null
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE tk_kiji_idf(
word varchar(255) not null,
idf real null
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE tk_kiji_tf(
doc varchar(32) not null,
word varchar(255) not null,
tf real null
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE tk_kiji_tfidf(
doc varchar(32) not null,
word varchar(255) not null,
tfidf real null
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE tk_kiji_word(
`id` int not null,
word varchar(255) not null
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE UNIQUE INDEX idx_tk_kiji_bow on tk_kiji_bow(doc,word);
CREATE UNIQUE INDEX idx_tk_kiji_idf on tk_kiji_idf(word);
CREATE UNIQUE INDEX idx_tk_kiji_tf on tk_kiji_tf(doc,word);
CREATE UNIQUE INDEX idx_tk_kiji_tfidf on tk_kiji_tfidf(doc,word);
CREATE UNIQUE INDEX idx_tk_kiji_word on tk_kiji_word(id);

