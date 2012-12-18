require 'nokogiri'
require 'open-uri'

module AmericanGothic
	class Review 

		#private_class_method :new
		attr_accessor :title,:text

		def initialize opts 
			@title = opts[:title] 
			@artist = opts[:artist] 
			@artwork = opts[:artwork] 
			@rating = opts[:rating] 
			@reviewer = opts[:reviewer]
			@date = opts[:date]
			@release_date = opts[:release_date]
			@label = opts[:label]
			@text = opts[:text] 
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
			#if score then score = score.text end

			text = review.css('.editorial').text.gsub(/\n/,"").delete('-')

			opts = { 
				:title => title.text,
				:artist => artist.text,
				:artwork => artwork,
				#:score => score,
				:reviewer => author,
				:date => publish_date,
				:release_date => year,
				:label => label,
				:text => text
			}

			self.new(opts)

		end

		def self.new_from_local url

		end

		def self.has_local_cache? url
			expectedfilename = url.split("/")[-1]
			return File.exists? "#{AmericanGothic::DATADIR}/#{expectedfilename}"
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
end