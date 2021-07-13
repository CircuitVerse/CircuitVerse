from numpy.random.mtrand import randint
import pandas as pd
import json
import sys
from scipy.sparse.construct import rand


f = open(r'C:\Users\devan\OneDrive\Desktop\Results\layer1.json','r', encoding="utf8")
f1 = open(r'C:\Users\devan\OneDrive\Desktop\Results\layer2.json','r', encoding="utf8")
data = json.load(f)
data1 = json.load(f1)


wr = open(r'C:\Users\devan\OneDrive\Desktop\Results\test1.txt','w', encoding="utf8")
original_stdout = sys.stdout

num_of_reccomendations = 5  #change the number to test with different circuits
project_ids = []
temps = [134546, 149040, 161131, 102328, 156503]


# for i in range(num_of_reccomendations):
#     temp = randint(0, len(data)-1)
#     temps.append(temp) 

# print(temps)
sys.stdout = wr
count = 0
for j in range(num_of_reccomendations):
    # temp = randint(0, len(data)-1)
    project_ids.append(data[temps[j]]["id"])
    count = count + 1
    print("Circuit {}".format(count))
    print("https://circuitverse.org/users/{}/projects/{}".format( data[temps[j]]["author_id"], data[temps[j]]["id"]))
    
    item = 0
    clusternum = data[temps[j]]["Cluster Number"]
    for i in range(len(data1)):
        if data1[i]["Cluster Number"] == clusternum:
            item+= 1
            
            print("Item {}".format(item))
            print("\thttps://circuitverse.org/users/{}/projects/{}".format(data1[i]["author_id"], data1[i]["id"]))
            if item >= 10:
                break
    print()
        
sys.stdout = original_stdout


