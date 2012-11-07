 require 'set'
 
 #
 # Extract uni, bi, and trigrams.
 #
 # "one two three".ngram(1) # unigrams
 # "one two three".ngram(2) # bigrams
 # "one two three".ngram(3) # trigrams
 # "one two three".ngrams(1..3) # unigrams, bigrams, trigrams
 #
 module Ngram
   REGEX = /[\w'.]+/
   def ngram_tokenize
      self.downcase.scan(REGEX)
   end
 
   def ngram(n=1)
     res = Set.new
     words = ngram_tokenize
     word_count = words.length
     words.each_with_index do |word, ix|
       min = ix
       max = ix + (n-1)
       break if word_count <= max
       res.add words[min..max].join(' ')
     end
     res
   end
 
   def ngrams(range=1..3)
     res = Set.new
     range.each do |n|
       res.merge ngram(n)
     end
     res
   end
 end
 
 class String
   include Ngram
 end
 
 "MSFT is xxx. AAPL is yyy.".ngram # unigram
 "MSFT is xxx. AAPL is yyy.".ngram(2) # bigram
 "MSFT is xxx. AAPL is yyy.".ngram(3) # trigram
 "MSFT is xxx. AAPL is yyy.".ngrams(1..3) # uni, bi, trigram