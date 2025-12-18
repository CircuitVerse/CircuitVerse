#importing libraries
from sklearn.decomposition import LatentDirichletAllocation
from sklearn.feature_extraction.text import CountVectorizer
import pandas as pd
import numpy as np
import gensim
from nltk.stem import WordNetLemmatizer
from sklearn.neighbors import KDTree
import nltk
import time
import joblib

start = time.time()

#opening the  cleaned file
DATA_DIR = r'.\Results\datasetcleaned.json'
df = pd.read_json(DATA_DIR)
np.random.seed(2018)
nltk.download('wordnet')

#lemmitization and stemming before LDA

wnl = WordNetLemmatizer()


def lemmatize_stemming(text):
    lemmatized_words = wnl.lemmatize(text)
    return lemmatized_words


def preprocess(text):
    result = ""
    for token in gensim.utils.simple_preprocess(text):
        if token not in gensim.parsing.preprocessing.STOPWORDS and len(token) >= 3:
            result += lemmatize_stemming(token) + " "
    return result

#pre-processing the combined values (name + description)
data_words = df['combined'].map(preprocess)
print(data_words)

# Feature extraction using CountVectorizer
vectorizer = CountVectorizer(max_df=0.90, min_df=1, stop_words='english')
joblib.dump(vectorizer.fit(data_words), r'.\Models\CVfitted.pkl')
print("vectorizer fitted")
data_vectorized = vectorizer.fit_transform(data_words)

#number  of  topics for LDA model
no_topics = 10
lda = LatentDirichletAllocation(n_components=no_topics, random_state=0, learning_method='online')
lda_fitted = lda.fit(data_vectorized)
lda_output = lda.fit_transform(data_vectorized)

# storing the LDA models 
joblib.dump(lda_fitted, r'.\Models\ldafitted.pkl') 
joblib.dump(lda_output, r'.\Models\ldamodel.pkl')
print("lda model made")

# K-D Tree created post - LDA
tree = KDTree(lda_output, leaf_size = 2)
joblib.dump(tree, r'.\Models\finaltree.pkl')

#Printing the runtime
end = time.time()
print(end - start)
