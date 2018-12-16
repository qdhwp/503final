import tweepy
import csv
import pandas as pd
import json
####input your credentials here
consumer_key = 
consumer_secret = 
access_token = 
access_token_secret = 

auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)
api = tweepy.API(auth,wait_on_rate_limit=True)
#####United Airlines
# Open/Create a file to append data
csvFile = open('rawtweets.csv', 'w')
#Use csv Writer
csvWriter = csv.writer(csvFile)

hashtag=input("What's the hash tag? (format:#XXX) :")
hashtag=hashtag.replace(" ", "")
if hashtag[0]!="#":
	hashtag="#"+hashtag
	print("You should have inputted # :(")
NO=int(input("How many tweets u want?(<=100) "))
if NO>100:
	NO=100
csvWriter.writerow(["hashtag", hashtag[1:]])
count=0

for tweet in tweepy.Cursor(api.search,q=hashtag,lang="en",tweet_mode='extended').items(NO):
	if (tweet.full_text[:4]=="RT @" ):
		print("retweet:")
		print(tweet.created_at,tweet.retweeted_status.full_text)
		csvWriter.writerow([tweet.created_at, tweet.retweeted_status.full_text])
		count+=1
	else:
		print (tweet.created_at, tweet.full_text)
		csvWriter.writerow([tweet.created_at, tweet.full_text])
		count+=1
		

print()
#csvFile.close()
print("Total tweets got: "+str(count))
import re
import csv
import pandas as pd
import nltk
import enchant
d=enchant.Dict("en_US")
from nltk import word_tokenize
from nltk.corpus import stopwords,words
from gensim import corpora, models, similarities
from wordcloud import WordCloud, STOPWORDS 
#from wordcloud import WordCloud#, ImageColorGenerator
import matplotlib.pyplot as plt

#STOPWORDS=stopwords.words('english')
csvFile = open('rawtweets.csv', 'r')
reader = csv.reader(csvFile, delimiter=",")
tweets=""
a=0
hashtag=next(reader)[1]
print(hashtag)
for tweet in reader:
	#print(tweet[1])
	tweets=tweets+tweet[1]

#print(tweets)	
tweets=str(tweets.encode('utf-8'))[2:]
#print(tweets)	
cltweets=re.sub("(@[A-Za-z0-9\_]+)|(\w+:\/\/\S+)|\\\\x[a-z0-9][a-z0-9]|\\\\n|'RT","",tweets)#|(#[A-Za-z0-9]+)

tokens=word_tokenize(cltweets)
cltokens=[w.lower() for w in tokens if (w.isalpha() and (w.lower() not in STOPWORDS) and (w.lower()!=hashtag.lower()) and (w.lower()!="rt")   )]# and (w.lower() in words.words())   (d.check(w))
#print([type(w) for w in tokens])
#print(cltokens)
df=pd.DataFrame(cltokens)
df.columns=['word']
df=pd.DataFrame(df.groupby('word').word.count())
df.columns=['NO']
df=df.sort_values('NO',ascending=False)
df.to_csv("wordcounts.csv")
df=df.reset_index()
#print(df)
tup=list(zip(df.word,df.NO))
#df2=pd.read_csv("wordcounts.csv")
#print(tup)

text=(" ").join(cltokens)
print(text)
#wordcloud = WordCloud(width=800, height=400, max_words=100, background_color="white").generate(text)#,max_font_size=50

wordcloud  = WordCloud(width=800, height=400, max_words=100, background_color="white").generate_from_frequencies(dict(tup))#, max_font_size=None)

plt.figure(figsize=(10,5))
plt.imshow(wordcloud)#, interpolation="bilinear")
plt.axis("off")
plt.title("Twitter #USEconomy WordCloud")
plt.show()
