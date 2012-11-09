require 'nokogiri'
require 'open-uri'

class Review

	#private_class_method :new
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

		if has_local_cache? url
			self.new_from_local url
		end

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

		new(title.text,artist.text,artwork,nil,author,publish_date,year,label,text)

	end

	def self.new_from_local url

	end

	def self.has_local_cache? url
		expectedfilename = url.split("/")[-1]
		return File.exists? "#{AmericanGothic::DATADIR}/#{expectedfilename}"
	end

end