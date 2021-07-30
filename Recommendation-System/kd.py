from sklearn.decomposition import LatentDirichletAllocation
from sklearn.feature_extraction.text import CountVectorizer
import pandas as pd
import numpy as np
import gensim
from nltk.stem import WordNetLemmatizer
from sklearn.neighbors import KDTree
import nltk
import sys
import time
import json
import joblib
start = time.time()


DATA_DIR = r'C:\Users\devan\OneDrive\Desktop\Results\datasetcleaned.json'
df = pd.read_json(DATA_DIR)
np.random.seed(2018)
nltk.download('wordnet')

#lemmitization and stemming

wnl = WordNetLemmatizer()


def lemmatize_stemming(text):
    lemmatized_words = wnl.lemmatize(text)
    return lemmatized_words


def preprocess(text):
    result = ""
    # print(gensim.utils.simple_preprocess(text))
    for token in gensim.utils.simple_preprocess(text):
        if token not in gensim.parsing.preprocessing.STOPWORDS and len(token) >= 3:
            result += lemmatize_stemming(token) + " "
    return result


data_words = df['combined'].map(preprocess)
print(data_words)

vectorizer = CountVectorizer(max_df=0.95, min_df=2, stop_words='english')
joblib.dump(vectorizer.fit(data_words), r'C:\Users\devan\OneDrive\Desktop\Results\models\CVfitted.pkl')
print("vectorizer fitted")
data_vectorized = vectorizer.fit_transform(data_words)

no_topics = 20
lda = LatentDirichletAllocation(n_components=no_topics, random_state=0, learning_method='online')
lda_fitted = lda.fit(data_vectorized)
lda_output = lda.fit_transform(data_vectorized)
joblib.dump(lda_fitted, r'C:\Users\devan\OneDrive\Desktop\Results\models\ldafitted20.pkl') # change the name of the files
joblib.dump(lda_output, r'C:\Users\devan\OneDrive\Desktop\Results\models\ldamodel20.pkl')

print("lda model made")
tree = KDTree(lda_output, leaf_size = 2)
joblib.dump(tree, r'C:\Users\devan\OneDrive\Desktop\Results\models\fintree20.pkl')
end = time.time()
print(end - start)
