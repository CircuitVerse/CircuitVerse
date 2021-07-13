# arithematic
import pyLDAvis.gensim_models
import sys
from pprint import pprint
from gensim import corpora, models
import nltk
import os
import numpy as np
import pandas as pd
import gensim
from gensim.models import CoherenceModel
import matplotlib.pyplot as plt
from gensim.utils import simple_preprocess
from gensim.parsing.preprocessing import STOPWORDS
from nltk.stem import WordNetLemmatizer, SnowballStemmer
from nltk.stem.porter import *
import numpy as np

from gensim.models.ldamulticore import LdaModel
from gensim.corpora import Dictionary
from gensim.models import Phrases
from collections import Counter
from gensim.models import Word2Vec
#clustering and decomposition
# from sklearn.cluster import MiniBatchKMeans
from sklearn.feature_extraction.text import TfidfVectorizer
from wordcloud import WordCloud

# import parallelTestModule

# if __name__ == '__main__':
#     extractor = parallelTestModule.ParallelExtractor()
#     extractor.runInParallel(numProcesses=2, numThreads=4)

# reading the dataset
DATA_DIR = r'C:\Users\devan\OneDrive\Desktop\Results\datasetcleaned.json'
df = pd.read_json(DATA_DIR)
df[['name', 'description']] = df[['name', 'description']].fillna('')
df['index'] = df.index
documents = df
def makecloud(s):

    long_desc = ""
    for val in s:

        # typecaste each val to string
        val = str(val)

        # split the value
        tokens = val.split()

        # Converts each token into lowercase
        for i in range(len(tokens)):
            tokens[i] = tokens[i].lower()

        long_desc += " ".join(tokens)+" "

    wordcloud = WordCloud(background_color="white", max_words=5000,contour_width=3, contour_color='steelblue')
    wordcloud.generate(long_desc)
    plt.figure(figsize=(8, 8), facecolor=None)
    plt.imshow(wordcloud)
    plt.axis("off")
    plt.tight_layout(pad=0)

    plt.show()


# print(len(documents))
# print(documents[:5])
# print(STOPWORDS)
np.random.seed(2018)
nltk.download('wordnet')

#lemmitization and stemming

wnl = WordNetLemmatizer()

def lemmatize_stemming(text):
    lemmatized_words = wnl.lemmatize(text)
    return lemmatized_words


def preprocess(text):
    result = []
    # print(gensim.utils.simple_preprocess(text))
    for token in gensim.utils.simple_preprocess(text):
        if token not in gensim.parsing.preprocessing.STOPWORDS and len(token) >= 3:
            result.append(token)
    return result


# doc_sample = documents[documents['index'] == 11].values[0][2]
# print('original document: ')
# words = []
# for word in doc_sample.split(' '):
#     words.append(word)
# # print(words)
# print('\n\n tokenized and lemmatized document: ')
# print(doc_sample)
# print(preprocess(doc_sample))
processed_docs = documents['combined'].map(preprocess) 
# print(processed_docs[:20])
unseen_document = "A Seven Segment Decoder"



dictionary = gensim.corpora.Dictionary(processed_docs)
count = 0
# for k, v in dictionary.iteritems():
#     print(k, v)
#     count += 1
#     if count > 10:
#         break

dictionary.filter_extremes(no_below = 5, no_above=0.75, keep_n=100000)
bow_corpus = [dictionary.doc2bow(doc) for doc in processed_docs] #words and its frequencies
bow_vector = dictionary.doc2bow(preprocess(unseen_document))
# print(bow_corpus)
# print(bow_corpus[11])

# bow_doc_11 = bow_corpus[11]
# for i in range(len(bow_doc_11)):
#     print("Word {} (\"{}\") appears {} time.".format(
#         bow_doc_11[i][0], dictionary[bow_doc_11[i][0]], bow_doc_11[i][1]))

tfidf = models.TfidfModel(bow_corpus)
corpus_tfidf = tfidf[bow_corpus]
# print(tfidf)

# count = 0
# for doc in corpus_tfidf:
#     pprint(doc)
#     count = count +1
#     if count>10:
#         break

# lda_model_tfidf = gensim.models.LdaModel(corpus_tfidf, num_topics=60, id2word=dictionary)
lda_model_tfidf = gensim.models.LdaModel(bow_corpus, num_topics=100, id2word=dictionary)

# Saving the reference of the standard output
original_stdout = sys.stdout
f = open(r'C:\Users\devan\OneDrive\Desktop\demo1.txt', 'w')
sys.stdout = f
for idx, topic in lda_model_tfidf.print_topics(-1):
    
    print('Topic: {} Word: {}'.format(idx, topic))
    # Reset the standard output
sys.stdout = original_stdout


# print(lda_model_tfidf[bow_vector])

for index, score in sorted(lda_model_tfidf[bow_vector], key=lambda tup: tup[1], reverse=True):
    print("Topic: {} \n Words: {}\t ".format(index, lda_model_tfidf.print_topic(index, 10)))
