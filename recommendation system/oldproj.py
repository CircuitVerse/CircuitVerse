import json
import time
import joblib
start = time.time()

# Opening JSON file
f = open(r'.\Results\recommendations.json', encoding="ascii", errors="ignore")

# returns JSON object as a dictionary
data = json.load(f)

project_id = 10
found = False
print("Testing Circuit ID: {}". format(project_id))
mapping = joblib.load(r'.\Models\mapping.pkl')

k = data[mapping[project_id]]
for j in range(10):
    print("https://circuitverse.org/users/{}/projects/{}".format(k["recom_author_id"][j], k["recom_id"][j]))

#Printing the runtime
end = time.time()
print(end - start)
