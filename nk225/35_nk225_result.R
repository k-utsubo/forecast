library(RMySQL)
setwd("~/Documents/workspace/deeplearning/nk225/")

plot_price<-function(predict_file,title){
  nk225.predict<-read.table(predict_file,sep=",",header=T)
  ylim.max<-ceiling(max(nk225.predict$predict_price,nk225.predict$real_price))
  ylim.min<-floor(min(nk225.predict$predict_price,nk225.predict$real_price))
  plot(nk225.predict$X,nk225.predict$predict_price,col=1,type="l",ylim=c(ylim.min,ylim.max),ylab="price",main=title)
  par(new=T)
  plot(nk225.predict$X,nk225.predict$real_price,col=2,type="l",ylim=c(ylim.min,ylim.max),ylab="")
  par(new=F)
  legend("topleft",legend=c("predict_price","real_price"),col=c(1,2),lty=c(1,1))
}
plot_loss<-function(train_file,title){
  nk225.train<-read.table(train_file,sep=",",header=T)
  plot(nk225.train$X,nk225.train$loss,type="l",main=title)
}

title<-"epoch=20000,hidden_units=400,sequence=100"
plot_loss("35_nk225_400_100_train.csv",title)
plot_price("35_nk225_400_100_predict.csv",title)

title<-"epoch=20000,hidden_units=100,sequence=300"
plot_loss("35_nk225_100_300_train.csv",title)
plot_price("35_nk225_100_300_predict.csv",title)


title<-"epoch=20000,hidden_units=800,sequence=100"
plot_loss("35_nk225_800_100_train.csv",title)
plot_price("35_nk225_800_100_predict.csv",title)

title<-"epoch=20000,hidden_units=100,sequence=20"
plot_loss("35_nk225_100_20_train.csv",title)
plot_price("35_nk225_100_20_predict.csv",title)


