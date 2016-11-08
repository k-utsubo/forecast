#https://github.com/mukul13/rword2vec
# cannot execute this function!!!
library(rword2vec)

model<-word2vec(train_file = "../../data/wikipedia/data/text.txt", output_file = "../../data/model_wiki_rw2v.bin", num_threads = 14
)

