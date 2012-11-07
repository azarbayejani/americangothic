require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'parallel'

BASE_PITCHFORK_URL = "http://pitchfork.com"
REVIEW_URL = "#{BASE_PITCHFORK_URL}/reviews/albums"
DATA_DIR = "data"
Dir.mkdir(DATA_DIR) unless File.exists? DATA_DIR

page = Nokogiri::HTML(open(REVIEW_URL))
reviews = page.css('.object-grid a')

freqs = Hash.new(0)

class Review

	private_class_method :new
	attr_accessor :title,:text

	def initialize (album_title,album_artist,artwork,rating,reviewer,date,release_date,label,text)
		@title = album_title
		@artist = album_artist
		@artwork = artwork
		@rating = rating
		@reviewer = reviewer
		@date = date
		@release_date = release_date
		@label = label
		@text = text
	end

	def self.new_from_url (url)
		puts url
		begin 
			review = Nokogiri::HTML(open(url))
		rescue Interrupt, Errno::EINTR, Errno::ETIMEDOUT
			retry
		end

		artist = review.css('.info h1')[0]
		title = artist.next_element
		release_info = title.next_element
		reviewer_info = release_info.next_element

		artwork_markup = review.css('.artwork > img')[0]
		if artwork_markup then artwork = artwork_markup['src'] end

		if reviewer_info then author, publish_date = reviewer_info.text.split(';') end
		if release_info then label , year = release_info.text.split(';') end

		text = review.css('.editorial').text.gsub(/\n/,"").delete('-')

		new(title.text,artist.text,artwork,nil,author,publish_date,year,label,text)

	end

end

while true
	Parallel.each reviews, :in_threads=>8 do |a|
		currReview = Review.new_from_url "#{BASE_PITCHFORK_URL}#{a['href']}"
		currReview.text.scan(/[\w'.]+\.?/).each do |word|
			freqs[word]+=1
		end
	end

	nextpage = page.css('.next:has(*)')

	if nextpage.empty?
		break
	else
		page = Nokogiri::HTML(open("#{BASE_PITCHFORK_URL}#{nextpage[0]['href']}"))
		reviews = page.css('.object-grid a')
	end
end

puts freqs.sort_by { |word, freq| freq} .to_json