#importing Libraries
from io import StringIO
from html.parser import HTMLParser
import json
import joblib

# Opening JSON file
f = open(r'.\Results\dataset.json', encoding="ascii", errors= "ignore")

# returns JSON object as a dictionary
data = json.load(f)


# define punctuation to remove
punctuations = '''()[]{};:-",<>.?@#$_~'''

#function to remove punctuations
def removepunct(s):

    no_punct = ""
    for char in s:
        if char in punctuations:
            s = s.replace(char," ")
    
    return s

#function to remove the HTML tags
class MLStripper(HTMLParser):
    def __init__(self):
        super().__init__()
        self.reset()
        self.strict = False
        self.convert_charrefs = True
        self.text = StringIO()

    def handle_data(self, d):
        self.text.write(d)

    def get_data(self):
        return self.text.getvalue()


def strip_tags(html):
    s = MLStripper()
    s.feed(html)
    return s.get_data()

#opening the  cleaned datset file to write 
f = open(r'.\Results\datasetcleaned.json','w')
li = []
di = {}
#cleaning the dataset
for j in range(len(data)):
    di[data[j]["id"]] = j
    data[j]["name"] = data[j]["name"].lower().replace("untitled", "")
    encoded = data[j]["name"].encode("ascii", "ignore")
    data[j]["name"] = encoded.decode()
    data[j]["name"] = data[j]["name"].replace("\r\n", "")
    data[j]["name"] = removepunct(data[j]["name"])
     
    if data[j]["description"] == "" or data[j]["description"] == None:
        data[j]["combined"] = data[j]["name"] + " " + data[j]["name"]
        encoded = data[j]["combined"].encode("ascii", "ignore")
        data[j]["combined"] = encoded.decode()
        data[j]["combined"] = data[j]["combined"].replace("\r\n", "")
        data[j]["combined"] = removepunct(data[j]["combined"])
    else:
        data[j]["description"] = strip_tags(data[j]["description"])
        data[j]["description"] = data[j]["description"].encode("ascii", "ignore")
        data[j]["description"] = data[j]["description"].decode()
        data[j]["description"] = removepunct(data[j]["description"])
        data[j]["combined"] = data[j]["description"] + " " + data[j]["name"] + " " + data[j]["name"]
        encoded = data[j]["combined"].encode("ascii", "ignore")
        data[j]["combined"] = encoded.decode()
        data[j]["combined"] = data[j]["combined"].replace("\r\n", "")
        data[j]["combined"] = removepunct(data[j]["combined"])
        
    li.append(data[j])

#storing the cleaned dataset
json.dump(li, f, ensure_ascii=True, indent=2)
joblib.dump(di, r'.\Models\mapping.pkl')

