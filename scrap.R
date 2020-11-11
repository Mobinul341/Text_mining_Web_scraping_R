#Dplyr for data manipulation, rvest for web scraping
library(dplyr)
library(rvest)

#scraping target url
link = "https://www.nature.com/search?q=cancer"
pages = read_html(link)

#scraping data using html css selectors
titles = pages %>% html_nodes("h2 a") %>% html_text()
journal_link = pages %>% html_nodes("h2 a") %>% html_attr("href") %>% paste("https://www.nature.com", ., sep = "")
category = pages %>% html_nodes(".text-gray") %>% html_text()
times = pages %>% html_nodes("time") %>% html_text()

#creating a list of scrap data
library(plyr)
library(quanteda)
library(tm)
journ = list(titles, category, times)
df<- ldply(journ, data.frame)

#writing data into a txt file
capture.output(journ, file = "cancer2.txt")

#Data mining using quanteda


summary(df)
#Converting dataframe into corpus
df_corpus = Corpus((VectorSource(df$titles)))


df_corpus = tm_map(df_corpus, PlainTextDocument) #intermediate preprocessing
df_corpus = tm_map(df_corpus, tolower) #converts all to lower case
df_corpus = tm_map(df_corpus, removePunctuation) #removes puncuation
df_corpus = tm_map(df_corpus, removeWords, stopwords("\n")) #removes common words
df_corpus = tm_map(df_corpus, stemDocument) #removes last few similar letters
dftm = DocumentTermMatrix(df_corpus) #turns corpus into document term matrix
not_sparse = removeSparseTerms(dftm, 0.99) #extract frequently

final_words = as.data.frame(as.matrix(not_sparse)) #most frequent words in dataframe, with one column per word



