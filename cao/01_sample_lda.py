#!/bin/env python
# coding:utf-8

# http://sucrose.hatenablog.com/entry/2013/10/29/001041


import gensim
import subprocess


class JapaneseTextCorpus(gensim.corpora.TextCorpus):
    def __init__(self, input, coding, segmenter):
        self.segmenter = segmenter
        self.coding = coding
        gensim.corpora.TextCorpus.__init__(self, input)

    def get_texts(self):
        segment = self.segmenter(self.input)
        for s in segment:
            yield s


class JapaneseSegmenter:
    @staticmethod
    def mecab(coding):
        def segmentWithMeCab(input):
            ret = []
            result = subprocess.check_output(u'mecab {0}'.format(input).encode(coding), shell=True)
            result = unicode(result, coding)
            for doc in result.split('EOS'):
                docret = []
                for line in doc.split('\n'):
                    if u'名詞' in line and u'接尾' not in line and u'接頭' not in line and u'非自立' not in line and u'代名詞' not in line and u'数' not in line:
                        docret.append(line.split(',')[6])
                if docret != []:
                    ret.append(docret)
            return ret

        return segmentWithMeCab


if __name__ == '__main__':
    corpus = JapaneseTextCorpus('txt/conv.txt', 'utf-8', JapaneseSegmenter.mecab('utf-8'))


    lda = gensim.models.ldamodel.LdaModel(corpus=corpus, num_topics=10, id2word=corpus.dictionary)
    for topic in lda.show_topics(-1):
        print str(topic[0])+" "+topic[1]
    #for topics_per_document in lda[corpus]:
    #    print topics_per_document
