require 'rubygems'
require 'nokogiri'

require 'americangothic/review.rb'
require 'americangothic/crawler.rb'

module AmericanGothic
	BASE_PITCHFORK_URL = "http://pitchfork.com"
	REVIEW_URL = "#{BASE_PITCHFORK_URL}/reviews/albums"
	DATA_DIR = "data"
end
