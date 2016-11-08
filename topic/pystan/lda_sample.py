import pystan
import numpy as np
import sys
from optparse import OptionParser

np.random.seed(10)

def gen1dvec_o(vec):
        docid=[]
        vec1d=[]
        for i,v in enumerate(vec):
                vd=v.todense()
                l=vd.shape[1]
                vv=np.array(vd).reshape(l)*65536
                vec1d=np.hstack([vec1d,vv])
                docid=np.hstack([np.repeat(i,l),docid])

        vec1d=vec1d.astype(int)+1
        docid=docid.astype(int)
        return vec1d,docid

def toarray1d(spvec):
    vd=spvec.todense()
    l=vd.shape[1]
    return np.array(vd).reshape(l)

def gen1dvec(vec,idfrom1=True):
        docid=[]
        vec1d=[]
        freq=[]
        for j,doc in enumerate(vec):#docs
            for i,v in enumerate(toarray1d(doc)):#words
                if(v!=0):
                    freq.append(v)
                    if(idfrom1):
                            vec1d.append(i+1)
                            docid.append(j+1)
                    else:
                            vec1d.append(i)
                            docid.append(j)

        return vec1d,map(int,freq),docid

def genoffset(docid,idfrom1=True):
        offset=[]
        pi=0

        if(idfrom1):
                pd=1
        else:
                pd=0

        for i,d in enumerate(docid):
                if(pd!=d):
                        if(idfrom1):
                                offset.append([pi+1,i])
                        else:
                                offset.append([pi,i-1])
                        pi=i
                pd=d
        offset.append([pi,len(docid)-1])
        return offset

categories = ['alt.atheism', 'talk.religion.misc','comp.graphics', 'sci.space']

def getwordvec_Tfidf(num):
        from sklearn.datasets import fetch_20newsgroups
        from sklearn.feature_extraction.text import TfidfVectorizer
        newsgroups_train = fetch_20newsgroups(subset='train',
                                              categories=categories)

        newsgroups_traindatas=np.random.choice(newsgroups_train.data,num,\
                                                 replace=False)
        vectorizer = TfidfVectorizer()
        return  vectorizer.fit_transform(newsgroups_traindatas)

def getwordvec_count(num):
        from sklearn.datasets import fetch_20newsgroups
        from sklearn.feature_extraction.text import CountVectorizer
        newsgroups_train = fetch_20newsgroups(subset='train',
                                              categories=categories)
#        newsgroups_traindatas=np.random.choice(newsgroups_train.data,num,replace=False)
        datas=[]
        topics=[]

        inds=np.random.choice(range(len(newsgroups_train.data)),
                              num,replace=False)

        for i in inds:
                datas.append(newsgroups_train.data[i])
                topics.append(newsgroups_train.target[i])

        vectorizer = CountVectorizer(stop_words='english')

        return  vectorizer.fit_transform(datas),topics
#        return  vectorizer.fit_transform(newsgroups_traindatas)


#docnum=100
itenum=500

docnum=40
#itenum=2000

# parser = OptionParser()
# parser.add_option("-d",dest="docnum",help="document num")
# parser.add_option("-i",dest="itenum",help="iteration number")
# (options, args) = parser.parse_args()

print "document num:"+str(docnum)+" iteration number:"+str(itenum)

#LDA from  Stan User's Guide and Reference Manual page 128
#https://github.com/stan-dev/stan/releases/download/v2.0.1/stan-reference-2.0.1.pdf
#http://heartruptcy.blog.fc2.com/blog-entry-124.html
model_lda=open("lda_freq.stan").read()

vec,topicans=getwordvec_count(docnum)
#print vec.shape

vec1d,freq,docid=gen1dvec(vec)
offset=genoffset(docid)

M=vec.shape[0]
V=vec.shape[1]
N=len(vec1d)
K=len(categories)

alpha=np.repeat(0.8,K)
beta=np.repeat(0.2,V)

#print vec1d
#print docid
#print offset

print "M:",M," V:",V," N:",N," K:",K

fname="log_lda20newsgroups_doc"+str(docnum)+"ite"+str(itenum)\
        +"a"+str(alpha[0])+"b"+str(beta[0])

with open(fname+"_topic"+".txt",'w') as ft:
        print >>ft ,topicans

#sys.exit()
print "run stan"
fit = pystan.stan(model_code=model_lda,
                  data={
                      'K':K,
                      'V':V,
                      'M':M,
                      'N':N,
                      'W':vec1d,
                      'Offset':offset,
#                      'doc':docid,
                      'Freq':freq,
                      'alpha':alpha,
                      'beta': beta
                  },
                  iter=itenum,
                  chains=1)

print(fit)
with open(fname+".log",'w') as f:
        print >>f, fit



# import matplotlib
# matplotlib.use('pdf')
# import pylab as py
# fit.plot()
# py.savefig(fname+'pdf')