# arithematic
import numpy as np
import pandas as pd
import json
import collections
import matplotlib.pyplot as plt
import scipy as sp
#clustering and decomposition
from sklearn.cluster import MiniBatchKMeans
from sklearn.feature_extraction.text import TfidfVectorizer

# reading the dataset
DATA_DIR = r'C:\Users\devan\OneDrive\Desktop\Results\datasetcleaned.json'
df = pd.read_json(DATA_DIR)

split = 0.5

# feature extraction
vec = TfidfVectorizer(stop_words='english')
# df['description'] = df['description'].fillna('')
# df['name'] = df['name'].fillna('')
# vec.fit_transform(df['description'])
# vec.fit_transform(df['name'])
# features1 = vec.transform(df['description'])
# features2 = vec.transform(df['name'])
# features = split * features1 + (1 - split) * features2
df['combined'] = df['combined'].fillna('')
vec.fit_transform(df['combined'])
features = vec.transform(df['combined'])
print(features)
print("The number of rows are: " + str(features.get_shape()[0]))
print("The number of columns are: " + str(features.get_shape()[1]))

clusters = MiniBatchKMeans(n_clusters=500, random_state= 1000, batch_size= 10000).fit_predict(features)
frequency = {}
for item in clusters:
   if item in frequency:
        frequency[item] += 1
   else:
        frequency[item] = 1
sorted_freq = dict(sorted(frequency.items(), key=lambda item: item[1],reverse=True))
print(sorted_freq)
#reassignment ratio
wr = open(r'C:\Users\devan\OneDrive\Desktop\Results\layer1.json','w', encoding="utf8")
f = open(r'C:\Users\devan\OneDrive\Desktop\Results\datasetcleaned.json', encoding="utf8")

data = json.load(f)
li = []




for j in range(len(data)):
    data[j]["Cluster Number"] = int(clusters[j])
    if(data[j]["star_count"]) == None:
        data[j]["star_count"] = 0
    data[j]["Score"] = data[j]["star_count"] + data[j]["view"]
    # data[j]["User id"] = findid(data[j]["id"])
    li.append(data[j])
json.dump(li, wr,ensure_ascii=True,indent=2)
wr.close()
#re-ranking the json file

f1 = open(r'C:\Users\devan\OneDrive\Desktop\Results\layer1.json','r', encoding="utf8")
dat = json.load(f1)


dat = sorted(dat, key=lambda i: i['Score'], reverse=True)
dat = sorted(dat, key=lambda i: i['Cluster Number'])

wr1 = open(r'C:\Users\devan\OneDrive\Desktop\Results\layer2.json','w', encoding="utf8")
json.dump(dat, wr1, ensure_ascii=True, indent=2)
