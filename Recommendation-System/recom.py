from sklearn.neighbors import KDTree
import joblib
import json
import sys
import time
start = time.time()

DATA_DIR = r'C:\Users\devan\OneDrive\Desktop\Results\datasetcleaned.json'
f1 = open(DATA_DIR,'r', encoding="utf8")
dat = json.load(f1)

loaded_tree = joblib.load(r'C:\Users\devan\OneDrive\Desktop\Results\models\fintree20.pkl')
loaded_model = joblib.load(r'C:\Users\devan\OneDrive\Desktop\Results\models\ldamodel20.pkl')
index = 11 #this is the index of the circuit
dist, ind = loaded_tree.query([loaded_model[index]], k= 50)

print(dist)
print(ind)

wr = open(r'C:\Users\devan\OneDrive\Desktop\Results\kdtest20new.txt','w', encoding="utf8")
original_stdout = sys.stdout

sys.stdout = wr
print("Testing Circuit Index: {}". format(index))
print("https://circuitverse.org/users/{}/projects/{}".format(dat[index]["author_id"], dat[index]["id"]))
print()
count = 0
split = 5 #to change the number of distance and
li = []
for i in ind[0].tolist():
    count +=1
    if count<=split:
        print("Recommendation {}". format(count))
        print("https://circuitverse.org/users/{}/projects/{}".format(dat[i]["author_id"], dat[i]["id"]))
        print()
    else:
        li.append((dat[i]["star_count"]+dat[i]["view"],i))
    
count = split
li.sort(reverse= True)
num_of_recom = 10 # the total number of recomendations
for index, tuple in enumerate(li):
    count +=1
    print("Recommendation {}". format(count))
    print("https://circuitverse.org/users/{}/projects/{}".format(dat[tuple[1]]["author_id"], dat[tuple[1]]["id"]))
    print()
    if count>num_of_recom:
        break
sys.stdout = original_stdout

end = time.time()
print(end - start)
