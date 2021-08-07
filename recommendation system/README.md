
# Recommendation System
The recommendation system is the first ML project for [CircuitVerse](https://github.com/CircuitVerse/CircuitVerse). The basic idea is to recommend similar circuits (which are also popular) to the users to increase user engagement and reach of good projects. In this Readme.md file, we have explained every decision or technology in simple words to give a better understanding and to give an idea of why we did, what we did.

## Why use an unsupervised learning-based model?
The data that was available for us (check out the [database schema](https://github.com/CircuitVerse/CircuitVerse/blob/master/db/schema.rb#L275)) to use didn't have a response variable (typically a X and a Y to train and test the model and improve the accuracy). Therefore, we had to rely on the usage of unsupervised learning-based algorithms to find the intrinsic pattern and hidden structures in the data and present it to the user.

## Model Structure
![Recommendation System Structure](https://i.imgur.com/q5o3GGY.jpg)

## Data Cleaning Module

A SQL query was used to extract the id, author_id, name, description, tag_names, views, and star count which were stored as a JSON file (1,80,000 projects approx).  We removed the following:
1. HTML tags, 
2. Non-ASCII characters 
3. Punctuations. 
4. Replaced NULL values and "Untitled" by empty strings.
>**Note:** We did not remove punctuations like &, *, +, etc as they have a meaning in logic circuits.

## Feature Extraction
Feature Extraction is mainly done to extract important parts or features from a huge chunk of items, based on the frequency/count of occurrence and thus reducing the dimensions of the dataset to enhance processing.
Our recommendation system uses [CountVectorizer](https://scikit-learn.org/stable/modules/generated/sklearn.feature_extraction.text.CountVectorizer.html) which converts the collection of documents to a matrix of token counts, thus filtering out the important and relevant keywords.

## Topic Modelling using Latent Dirichlet Allocation (LDA)

[LDA](https://scikit-learn.org/stable/modules/generated/sklearn.discriminant_analysis.LinearDiscriminantAnalysis.html) is used to classify text in a document to a particular topic. It builds a topic per document model and words per topic model, modeled as [Dirichlet distributions](https://www.sciencedirect.com/topics/mathematics/dirichlet-distribution).

-   Each document is modeled as a multinomial distribution of topics and each topic is modeled as a multinomial distribution of words.
-   LDA assumes that every chunk of text we feed into it will contain words that are somehow related. Therefore choosing the right corpus of data is crucial.
-   It also assumes documents are produced from a mixture of topics. Those topics then generate words based on their probability distribution.

Simply put, LDA creates a distribution of words and packs them together as a topic (the number of topics is chosen by the user). When a new sentence is fed into the model, based on the words present in the new sentence, we get a distribution of the sentence over all the topics. The new dimension of each vector becomes the total number of topics hence drastically reducing the dimensions with better filtering. 
In our recommendation system, the log-likelihood was the least for 10 topics for the given dataset.
## K-D Trees

After getting the probability distribution of each project we can compare the items and thus enhancing the 2nd layer of the model. Item distance being the best collaborative filtering approach gives us the most similar items. However, this will be a computationally expensive method with time complexity of  `O(N^2 log(N))`, and training the model will take days. We also won't be able to use this method for new project recommendations in the online mode because of the high runtime.

Therefore, the need to use [K-D Trees](https://www.cs.cmu.edu/~ckingsf/bioinfo-lectures/kdtrees.pdf) arose. A K-D Tree (also called a K-Dimensional Tree) is a binary search tree where data in each node is a K-Dimensional point in space. Points to the left of this space are represented by the left subtree of that node and points to the right of the space are represented by the right subtree. 

The advantages of using K-D Trees were:

 - The time complexity of the nearest neighbor search of K-D Tree is `O(log n)` (hence it can be used online).
 - The cost for building the tree is `O(N log(N))` (faster training).

The top 50 nearest neighbors of each item are then taken and recommendations are computed.

## Computing the Recommendations
We take the top 50 nearest neighbors of the project along with the stars and the views of each project. 
### Old Project
We split the 10 recommendations into 3 parts:

 1. The first 2 recommendations are just name-based ( since some well-documented circuits like [this](https://circuitverse.org/users/3/projects/67) had too many "important" words in the description and hence was giving different results.
 2. The next 4 recommendations are the top 4 nearest neighbors (based on name + description) that we got from the K-D Tree.
 3. We then re-rank the remaining 46 neighbors by giving them a popularity score which is: 
$$
Score = (5 S) + V
$$
> Here S is the number of Stars and V is the number of views of a project.

### New Project
Since we need to calculate the recommendations in real-time, we won't be working and computing the recommendations for names separately. So the first 5 recommendations would be taking the name + description, extracting features, lemmatization, topic modeling, and showing the top 5 K-D Trees recommendations.

The next 5 recommendations would be re-ranking the remaining 45 recommendations based on the above formula and displaying the results to the user.

## Things we discarded

 1. **TF-IDF for feature extraction:** We preferred counts of words rather than a score and LDA models were giving better distributions with CountVectorizer than TF-IDF so we decided to go ahead with this. Not any major reason, might be changed in the future if some problem comes up.
 2. **K- Means clustering:** Initially our plan was just to use K-Means and re-rank the items and recommend. Then to improve the model we integrated LDA with K-Means and the results were pretty good for layer 1. However, for the 2nd layer, we felt the need to incorporate a distance-based collaborative filtering method to recommend items. 
K-Means had the following issues:
-	Uneven distribution of items in clusters.
-	Distance calculation was too computationally expensive.
-	Increased runtime for new projects.
Hence we replaced K-Means with K-D Trees.
3. **Inclusion of Tag names:** Just 1800 out of 1,80,000 projects had tag names and we felt they would add unnecessary noise to our model. We also weren't sure what additional information would they be able to provide us (scope for future contributions). 
4. **Gensim module for LDA:** Though Gensim was faster than Sci-Kit Learn module for LDA modelling but it had one major problem which was multi-processing. Multi-processing / threading created issues which we couldn't resolve (like freezing your local setup) and since  Sci-Kit Learn was a stong option and gave better results, we switched.

## Scope for future contributions 
Since this project was the first recommendation system for the organization, there's tremendous scope for improvement in the project and we would love you to contribute to anything that seems interesting🎉.
 
Some of the things are listed below:

 - Converting the project to a supervised learning problem.
 - Inclusion of labels/components used in circuits and sub-circuits.
 - Other suggestions regarding optimization of the process.
