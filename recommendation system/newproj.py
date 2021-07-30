from sklearn.neighbors import KDTree
import joblib
import json
import sys
import time
from scipy.sparse import data
import pandas as pd
import gensim
from nltk.stem import WordNetLemmatizer
start = time.time()

combined = "BCD TO 7 Segment"

DATA_DIR = r'C:\Users\devan\OneDrive\Desktop\Results\datasetcleaned.json'
f1 = open(DATA_DIR, 'r', encoding="utf8")
dat = json.load(f1)

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


# data = preprocess(combined)
# data_words = pd.Series(data)
data_words = pd.Series(combined)

loaded_vector = joblib.load(r'C:\Users\devan\OneDrive\Desktop\Results\models\CVfitted.pkl')
data_vectorized = loaded_vector.transform(data_words)

loaded_vector_10 = joblib.load(r'C:\Users\devan\OneDrive\Desktop\Results\models\ldafitted10.pkl')
# loaded_vector_100 = joblib.load(r'C:\Users\devan\OneDrive\Desktop\Results\models\ldafitted100.pkl')
data_vectorized = loaded_vector_10.transform(data_vectorized)

print(data_vectorized)
loaded_tree = joblib.load(r'C:\Users\devan\OneDrive\Desktop\Results\models\fintree.pkl')

dist, ind = loaded_tree.query(data_vectorized, k = 50)

print(dist)
print(ind)

wr = open(r'C:\Users\devan\OneDrive\Desktop\Results\new_proj_recom_without_processing.txt','w', encoding="utf8")
original_stdout = sys.stdout

sys.stdout = wr
print("Testing Circuit Text: {}". format(combined))
print()
count = 0
split = 5  # to change the number of distance and
li = []
for i in ind[0].tolist():
    count += 1
    if count < split:
        print("Recommendation {}". format(count))
        print("https://circuitverse.org/users/{}/projects/{}".format(dat[i]["author_id"], dat[i]["id"]))
        print()
    else:
        li.append((dat[i]["star_count"]+dat[i]["view"], i))

count = split - 1
li.sort(reverse=True)
num_of_recom = 10  # the total number of recomendations
for index, tuple in enumerate(li):
    count += 1
    print("Recommendation {}". format(count))
    print("https://circuitverse.org/users/{}/projects/{}".format(dat[tuple[1]]["author_id"], dat[tuple[1]]["id"]))
    print()
    if count > num_of_recom:
        break
sys.stdout = original_stdout

end = time.time()
print(end - start)
