require 'nokogiri'

module AmericanGothic
	BASE_PITCHFORK_URL = "http://pitchfork.com"
	REVIEW_URL = "#{BASE_PITCHFORK_URL}/reviews/albums"
	DATA_DIR = "../data"
end

require 'americangothic/review.rb'
require 'americangothic/crawler.rb'