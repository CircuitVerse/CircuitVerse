from sklearn.decomposition import LatentDirichletAllocation
from sklearn.feature_extraction.text import CountVectorizer
import pandas as pd
import numpy as np


DATA_DIR = r'C:\Users\devan\OneDrive\Desktop\Results\datasetcleaned.json'
df = pd.read_json(DATA_DIR)
df[['name', 'description']] = df[['name', 'description']].fillna('')
df['index'] = df.index
cv = CountVectorizer(max_df=0.95, min_df=2, stop_words='english')
df = cv.fit_transform(df["combined"])
print(df)
df_feature_names = cv.get_feature_names()
cvtest = CountVectorizer(max_df=0.95, min_df=1, stop_words='english')
text = ["This is a project about the sevensegment display seven-segment_display",
        "assignment 1", "ripple carry adder"]
test = cvtest.fit_transform(text)
print(test)
# print(df_feature_names)
no_topics = 3
lda = LatentDirichletAllocation( n_components=no_topics, random_state=0, learning_method= 'online')
lda.fit(df)

for index, topic in enumerate(lda.components_):
    print(f'Top 15 words for Topic #{index}')
    print([cv.get_feature_names()[i] for i in topic.argsort()[-15:]])
    print('\n')


lda.predict_proba(test)
