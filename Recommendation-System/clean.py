# from _typeshed import NoneType
import csv
# import pandas as pd
from io import StringIO
from html.parser import HTMLParser
import json
import string
import re
# from datetime import datetime

# startTime = datetime.now()

printable = set(string.printable)

# Opening JSON file
f = open(r'C:\Users\devan\OneDrive\Desktop\Results\dataset.json', encoding="utf8")

# returns JSON object as
# a dictionary
data = json.load(f)
# df = pd.read_excel(r'C:\Users\devan\OneDrive\Desktop\cv_data.csv')

# define punctuation
punctuations = '''()[]{};:-",<>.?@#$_~'''


def removepunct(s):

    no_punct = ""
    for char in s:
       if char not in punctuations:
           no_punct = no_punct + char

    # display the unpunctuated string
    return no_punct

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


# def chcnull(value):
#     if value == None:
#         return ""

#     else:
#         return value


f = open(r'C:\Users\devan\OneDrive\Desktop\Results\datasetcleaned.json','w', encoding="utf8")

li = []
for j in range(len(data)):
    data[j]["name"] = data[j]["name"].lower().replace("untitled", "")
     
    if data[j]["description"] == "" or data[j]["description"] == None:
        data[j]["combined"] = data[j]["name"]
    else:
        data[j]["description"] = strip_tags(data[j]["description"])
        data[j]["description"] = data[j]["description"].encode("ascii", "ignore")
        data[j]["description"] = data[j]["description"].decode()
        data[j]["description"] = removepunct (data[j]["description"])
        data[j]["combined"] = data[j]["description"] + " " + data[j]["name"]
    li.append(data[j])

json.dump(li, f, ensure_ascii=True, indent=2)

# print(datetime.now() - startTime)
