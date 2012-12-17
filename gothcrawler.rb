require 'nokogiri'
require 'open-uri'
require 'json'
require 'parallel'
require 'raingrams'

include Raingrams

BASE_PITCHFORK_URL = "http://pitchfork.com"
REVIEW_URL = "#{BASE_PITCHFORK_URL}/reviews/albums"
DATA_DIR = "data"
Dir.mkdir(DATA_DIR) unless File.exists? DATA_DIR

page = Nokogiri::HTML(open(REVIEW_URL))
reviews = page.css('.object-grid a')

freqs = Hash.new(0)

class Review

	private_class_method :new
	attr_accessor :title,:text,:slug

	def initialize (album_title,album_artist,artwork,rating,reviewer,date,release_date,label,text,slug)
		@title = album_title
		@artist = album_artist
		@artwork = artwork
		@rating = rating
		@reviewer = reviewer
		@date = date
		@release_date = release_date
		@label = label
		@text = train_with_textxt
		@slug = slug
	end

	def self.new_from_url (url)
		#puts url
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
		slug = url.split("/")[-1]

		new(title.text,artist.text,artwork,nil,author,publish_date,year,label,text,slug)

	end

	def to_json(*a)
		{
			"title" => @title,
			"artist" => @artist,
			"artwork" => @artwork,
			"rating" => @rating,
			"reviewer" => @reviewer,
			"label" => @label,
			"text" => @text
		}.to_json(*a)
	end

end

model = nil 

if File.exists? "#{DATA_DIR}/model"
	model = Model.open("data/model")
else
	model = BigramModel.build :ngram_size=>3
end

should_i_continue = true

while true
	#Parallel.each reviews, :in_threads=>8 do |a|
	reviews.each do |a|
		slug = a['href'].split("/")[-1]
		if File.exists? "#{DATA_DIR}/#{slug}"
			should_i_continue = false
			break
		else
			currReview = Review.new_from_url "#{BASE_PITCHFORK_URL}#{a['href']}" unless File.exists? a['href']
			puts slug

			File.open("#{DATA_DIR}/#{slug}",'w') do |f|
				f.write( currReview.to_json )
			end

			model.train_with_text(currReview.text)
		end
	end

	unless should_i_continue
		break
	end

	nextpage = page.css('.next:has(*)')

	if nextpage.empty?
		break
	else
		page = Nokogiri::HTML(open("#{BASE_PITCHFORK_URL}#{nextpage[0]['href']}"))
		reviews = page.css('.object-grid a')
	end
end

model.save("data/model")



puts model.random_sentence
