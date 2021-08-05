#importing the libraries
from unicodedata import name
from sklearn.neighbors import KDTree
import joblib
import json
import gensim
from nltk.stem import WordNetLemmatizer
import pandas as pd
import time

# to get the run time of training 
start = time.time()

#text lemmitization for Name
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

#loading the cleaned dataset
DATA_DIR = r'.\Results\datasetcleaned.json'
f1 = open(DATA_DIR, 'r', encoding="utf8")
dat = json.load(f1)

#loading the stored models
loaded_tree = joblib.load(r'.\Models\finaltree.pkl')
loaded_model = joblib.load(r'.\Models\ldamodel.pkl')
loaded_vector = joblib.load(r'.\Models\CVfitted.pkl')
loaded_vector_name = joblib.load(r'.\Models\ldafitted.pkl')

#opening the json file for storing the pre-computed recommendations
f = open(r'.\Results\recommendations.json', 'w')
finli = []
for j in range(0,len(dat)):
    index = j
    # getting the top 50 similar items from the saved model
    dist, ind = loaded_tree.query([loaded_model[index]], k=50)

    # Preprocessing the names for the first 2 recommendations
    data = preprocess(dat[index]["name"] + " " + dat[index]["name"])
    data_words = pd.Series(data)
    data_vectorized = loaded_vector.transform(data_words)
    data_vectorized_words = loaded_vector_name.transform(data_vectorized)

    # getting top 10 similar names from the tree
    dista, inde = loaded_tree.query(data_vectorized_words, k=10) 

    #storing everything in a dictionary to later push as a JSON file
    dic = {}
    dic["project_id"] = dat[j]["id"]
    dic["user_id"] = dat[j]["author_id"]
    dic["recom_id"] = []
    dic["recom_author_id"] = []
    
    count = 0
    name_rec = 2 # gives the number of recommendations based on just the name
    combined = 4  # combined gives the name + description recommendation

    # list to re-rank the remaining elements in the end
    li = []
    for i in ind[0].tolist():
        # first 2 recommendations based on the name
        if count < name_rec:
            dic["recom_id"].append(dat[inde[0][count]]["id"])
            dic["recom_author_id"].append(dat[inde[0][count]]["author_id"])
        
        #next 4 recommendations based on name + description
        elif count < name_rec + combined:
            dic["recom_id"].append(dat[i]["id"])
            dic["recom_author_id"].append(dat[i]["author_id"])
        
        #the remaining ones (46 in this case) are stored for re-ranking
        else:
            li.append((5 * dat[i]["star_count"]+dat[i]["view"], i))
        count+=1

    # Re-ranking begins
    count = combined + name_rec
    li.sort(reverse=True)
    num_of_recom = 10  # the total number of recomendations
    for index, tuple in enumerate(li):
        if count >= num_of_recom:
            break
        dic["recom_id"].append(dat[tuple[1]]["id"])
        dic["recom_author_id"].append(dat[tuple[1]]["author_id"])
        
        count += 1

    #this completes the storing of a particular project
    print("Item {} stored".format(j)) 
    finli.append(dic)

#storing the file 
json.dump(finli, f, ensure_ascii=True, indent= 1)
f.close()

#checking the total runtime
end = time.time()
print(end - start)
